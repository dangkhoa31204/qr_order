import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'api_service.dart';

class SignalRService {
  static const String _hubRoute = "/hubs/staff"; // Thay đổi nếu backend dùng route khác
  static HubConnection? _hubConnection;

  /// Khởi tạo kết nối SignalR
  static Future<void> init(Function onOrderCreated) async {
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
