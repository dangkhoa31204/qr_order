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

    final serverUrl = "${ApiService.baseUrl}$_hubRoute";

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
          // Backend gửi: [orderId (int), newStatus (string)]
          final orderId = (arguments != null && arguments.isNotEmpty)
              ? (arguments[0] as num?)?.toInt() ?? -1
              : -1;
          final newStatus = (arguments != null && arguments.length > 1)
              ? arguments[1]?.toString() ?? ''
              : '';
          debugPrint('🔔 SignalR received: OrderStatusUpdated orderId=$orderId status=$newStatus');
          onOrderStatusUpdated(orderId, newStatus);
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

