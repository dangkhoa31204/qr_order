import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
    VoidCallback? onConnected,
  }) async {
    if (_isConnecting) return;
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.Connected) {
      return; // Đã kết nối
    }

    _isConnecting = true;

    // Đánh thức Order service trước khi kết nối SignalR
    // (Render free-tier có thể mất 30-50s để khởi động)
    try {
      debugPrint('🔄 Waking up Order service...');
      await http
          .get(
            Uri.parse('${ApiService.baseUrl}/api/orders'),
            headers: ApiService.accessToken != null
                ? {'Authorization': 'Bearer ${ApiService.accessToken}'}
                : {},
          )
          .timeout(const Duration(seconds: 60));
      debugPrint('✅ Order service is awake, starting SignalR...');
    } catch (_) {
      debugPrint('⚠️ Wake-up ping failed, proceeding with SignalR anyway');
    }

    // Sử dụng trực tiếp ApiService.baseUrl để đi qua API Gateway
    String serverUrl = "${ApiService.baseUrl}$_hubRoute";

    _hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl, options: HttpConnectionOptions(
      accessTokenFactory: () async {
        return ApiService.accessToken ?? "";
      },
      requestTimeout: 30000, // Tăng timeout của client lên 30s (mặc định là 2s, quá ngắn đối với Render free tier)
    ))
        .withAutomaticReconnect()
        .build();

    // Lắng nghe sự kiện OrderCreated
    _hubConnection!.on("OrderCreated", (arguments) {
      debugPrint('🔔 SignalR received: OrderCreated');
      onOrderCreated();
    });

    // Lắng nghe sự kiện OrderUpdated (khi khách gọi thêm món)
    _hubConnection!.on("OrderUpdated", (arguments) {
      debugPrint('🔔 SignalR received: OrderUpdated');
      onOrderCreated(); // Tải lại danh sách đơn
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
      
      // Timeout 90 giây — bao gồm cả cold start Render (30-50s) + handshake
      await _hubConnection!.start()!
          .timeout(const Duration(seconds: 90));
      debugPrint('✅ SignalR connected successfully to $serverUrl');
      _isConnecting = false;
      if (onConnected != null) {
        onConnected();
      }
    } catch (e, st) {
      debugPrint("========== SIGNALR ERROR ==========");
      debugPrint(e.toString());
      debugPrint(st.toString());
      _isConnecting = false;
      _hubConnection = null;
      // Thử lại sau 15 giây để kết nối nhanh hơn khi server đã khởi động xong
      _retryTimer?.cancel();
      _retryTimer = Timer(const Duration(seconds: 15), () {
        init(onOrderCreated, onOrderStatusUpdated: onOrderStatusUpdated, onConnected: onConnected);
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

