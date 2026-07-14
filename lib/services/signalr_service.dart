import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'api_service.dart';

class SignalRService {
  static const String _hubRoute = "/hubs/staff"; // Thay đổi nếu backend dùng route khác
  static HubConnection? _hubConnection;

  /// Khởi tạo kết nối SignalR
  /// [onOrderCreated]        — gọi khi có đơn mới được tạo
  /// [onOrderStatusUpdated]  — gọi khi trạng thái đơn thay đổi (kèm orderId & newStatus dạng String)
  static Future<void> init(
    Function onOrderCreated, {
    Function(int orderId, String newStatus)? onOrderStatusUpdated,
  }) async {
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.Connected) {
      return; // Đã kết nối
    }

    // Nếu cấu hình dùng API Gateway, chuyển trực tiếp qua Service URL cho SignalR (vì Gateway không cấu hình route cho Websockets/SignalR)
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

    // Lắng nghe sự kiện OrderStatusUpdated — backend broadcast khi staff đổi trạng thái đơn
    if (onOrderStatusUpdated != null) {
      _hubConnection!.on("OrderStatusUpdated", (arguments) {
        try {
          debugPrint('🔔 SignalR received raw arguments: $arguments');
          if (arguments == null || arguments.isEmpty) return;

          int orderId = -1;
          String newStatus = '';

          final firstArg = arguments[0];
          if (firstArg is Map) {
            // Trường hợp backend gửi nguyên Object OrderResponse
            orderId = firstArg['orderId'] as int? ?? firstArg['OrderId'] as int? ?? -1;
            final statusVal = firstArg['status'] ?? firstArg['Status'];
            newStatus = statusVal?.toString() ?? '';
          } else if (firstArg is num) {
            // Trường hợp backend gửi 2 tham số: [orderId, newStatus]
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
      await _hubConnection!.start();
      debugPrint('✅ SignalR connected successfully to $serverUrl');
    } catch (e) {
      debugPrint('❌ SignalR connection failed: $e');
    }
  }

  /// Ngắt kết nối SignalR (khi logout)
  static Future<void> disconnect() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      _hubConnection = null;
      debugPrint('🛑 SignalR disconnected.');
    }
  }
}

