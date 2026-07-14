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

    // Nếu cấu hình dùng API Gateway, chuyển trực tiếp qua Service URL cho SignalR
    String serverUrl = "${ApiService.baseUrl}$_hubRoute";
    if (ApiService.baseUrl.contains("prm-gateway.onrender.com")) {
      serverUrl = "https://qr-order-api.onrender.com$_hubRoute";
    }

    _hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl, options: HttpConnectionOptions(
      accessTokenFactory: () async {
        return ApiService.accessToken ?? "";
      },
    ))
        .withAutomaticReconnect()
        .build();

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
      // Timeout 10 giây — đủ thời gian cho Render cold start nhưng không spam log
      await _hubConnection!.start()!
          .timeout(const Duration(seconds: 10));
      debugPrint('✅ SignalR connected successfully to $serverUrl');
      _isConnecting = false;
    } catch (e) {
      debugPrint('⚠️ SignalR unavailable (polling fallback active): ${e.runtimeType}');
      _isConnecting = false;
      _hubConnection = null;
      // Thử lại sau 60 giây — im lặng để không spam log
      _retryTimer?.cancel();
      _retryTimer = Timer(const Duration(seconds: 60), () {
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

