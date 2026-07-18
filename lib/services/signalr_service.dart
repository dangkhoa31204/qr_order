import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'api_service.dart';

class SignalRService {
  static const String _hubRoute = "/hubs/staff";
  static HubConnection? _hubConnection;
  static Timer? _retryTimer;
  static bool _isConnecting = false;

  /// Khởi tạo kết nối SignalR
  /// [onOrderCreated]        — gọi khi có đơn mới được tạo
  /// [onOrderStatusUpdated]  — gọi khi trạng thái đơn thay đổi
  static Future<void> init(
    Function onOrderCreated, {
    Function(int orderId, String newStatus)? onOrderStatusUpdated,
  }) async {
    if (_isConnecting) return;
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.Connected) {
      return; // Đã kết nối
    }

    _isConnecting = true;

    // Sử dụng trực tiếp ApiService.baseUrl để đi qua API Gateway
    String serverUrl = "${ApiService.baseUrl}$_hubRoute";

    _hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl, options: HttpConnectionOptions(
      accessTokenFactory: () async {
        return ApiService.accessToken ?? "";
      },
    ))
        .withAutomaticReconnect()
        .build();

    // Tăng timeout bắt tay lên 60 giây — Render cold start thường mất 30-50 giây
    _hubConnection!.handshakeResponseTimeout = 60000;

    // Lắng nghe sự kiện OrderCreated
    _hubConnection!.on("OrderCreated", (arguments) {
      debugPrint('🔔 SignalR received: OrderCreated');
      onOrderCreated();
    });

    // Lắng nghe sự kiện OrderStatusUpdated
    if (onOrderStatusUpdated != null) {
      _hubConnection!.on("OrderStatusUpdated", (arguments) {
        try {
          debugPrint('🔔 SignalR received raw arguments: $arguments');
          if (arguments == null || arguments.isEmpty) return;

          int orderId = -1;
          String newStatus = '';

          final firstArg = arguments[0];
          if (firstArg is Map) {
            orderId = firstArg['orderId'] as int? ?? firstArg['OrderId'] as int? ?? -1;
            final statusVal = firstArg['status'] ?? firstArg['Status'];
            newStatus = statusVal?.toString() ?? '';
          } else if (firstArg is num) {
            orderId = firstArg.toInt();
            newStatus = (arguments.length > 1) ? arguments[1]?.toString() ?? '' : '';
          }

          debugPrint('🔔 SignalR parsed: OrderStatusUpdated orderId=$orderId status=$newStatus');
          if (orderId != -1) {
            onOrderStatusUpdated(orderId, newStatus);
          }
        } catch (e) {
          debugPrint('❌ SignalR OrderStatusUpdated parse error: $e');
        }
      });
    }

    try {
      debugPrint("========== SIGNALR TOKEN ==========");
      debugPrint("Token: ${ApiService.accessToken}");
      debugPrint("========== SIGNALR TOKEN ==========");
      
      // Timeout 30 giây — đủ thời gian cho Render cold start
      await _hubConnection!.start()!
          .timeout(const Duration(seconds: 30));
      debugPrint('✅ SignalR connected successfully to $serverUrl');
      _isConnecting = false;
    } catch (e, st) {
      debugPrint("========== SIGNALR ERROR ==========");
      debugPrint(e.toString());
      debugPrint(st.toString());
      _isConnecting = false;
      _hubConnection = null;
      // Thử lại sau 15 giây để kết nối nhanh hơn khi server đã khởi động xong
      _retryTimer?.cancel();
      _retryTimer = Timer(const Duration(seconds: 15), () {
        init(onOrderCreated, onOrderStatusUpdated: onOrderStatusUpdated);
      });
    }
  }

  /// Ngắt kết nối SignalR (khi logout)
  static Future<void> disconnect() async {
    _retryTimer?.cancel();
    _retryTimer = null;
    _isConnecting = false;
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      _hubConnection = null;
      debugPrint('🛑 SignalR disconnected.');
    }
  }
}

