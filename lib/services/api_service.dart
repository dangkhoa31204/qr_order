import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';

class ApiService {
  // Configurable base URL for C# ASP.NET Core backend
  // In Android Emulator, http://10.0.2.2:5000 directs to the host machine's localhost
  static String baseUrl = "http://10.0.2.2:5000";
  static bool useMockFallback = true; // Toggle fallback when server is offline

  // In-memory cache for mock data when C# server is offline
  static final List<MenuItem> _mockMenuItems = List.from(initialMenuItems);
  static final List<OrderModel> _mockOrderQueue = [
    OrderModel(
      id: "B08-31620",
      tableId: "08",
      timeMinutes: 0,
      items: [
        CartItem(
          menuItem: initialMenuItems.firstWhere((it) => it.id == "m5"),
          quantity: 1,
        ),
        CartItem(
          menuItem: initialMenuItems.firstWhere((it) => it.id == "m1"),
          quantity: 2,
        ),
      ],
      status: OrderStatus.preparing,
      timestamp: "5 phút trước",
      note: "Trà đào ít đá ngọt vừa, bánh nướng sừng bò nóng hổi giòn rụm",
      tableLabel: "Bàn #08",
    ),
  ];

  // Helper to fetch response with timeout and error fallback
  static Future<Map<String, dynamic>> _safeGet(String path) async {
    try {
      final response = await http
          .get(Uri.parse("$baseUrl$path"))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {"success": true, "data": jsonDecode(response.body)};
      }
      return {
        "success": false,
        "error": "Server returned status code ${response.statusCode}",
      };
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  // 1. MENU API CALLS
  static Future<List<MenuItem>> fetchMenuItems() async {
    final result = await _safeGet("/api/menu");
    if (result["success"] == true) {
      final List rawList = result["data"];
      return rawList.map((item) => MenuItem.fromJson(item)).toList();
    } else {
      print(
        "ApiService.fetchMenuItems failed: ${result["error"]}. Utilizing mock fallback.",
      );
      return _mockMenuItems;
    }
  }

  static Future<bool> createMenuItem(MenuItem item) async {
    // Add to local mock list as fallback
    _mockMenuItems.add(item);

    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/menu"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(item.toJson()),
          )
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback; // fallback success
    }
  }

  static Future<bool> updateMenuItem(MenuItem item) async {
    // Modify local mock list as fallback
    final idx = _mockMenuItems.indexWhere((it) => it.id == item.id);
    if (idx != -1) {
      _mockMenuItems[idx] = item;
    }

    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl/api/menu/${item.id}"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(item.toJson()),
          )
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }

  static Future<bool> deleteMenuItem(String id) async {
    _mockMenuItems.removeWhere((it) => it.id == id);

    try {
      final response = await http
          .delete(Uri.parse("$baseUrl/api/menu/$id"))
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }

  static Future<bool> toggleMenuItemAvailability(String id) async {
    final idx = _mockMenuItems.indexWhere((it) => it.id == id);
    if (idx != -1) {
      final original = _mockMenuItems[idx];
      _mockMenuItems[idx] = original.copyWith(
        isAvailable: !original.isAvailable,
      );
    }

    try {
      final response = await http
          .patch(Uri.parse("$baseUrl/api/menu/$id/toggle-availability"))
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }

  // 2. ORDER QUEUE API CALLS
  static Future<List<OrderModel>> fetchOrderQueue() async {
    final result = await _safeGet("/api/orders");
    if (result["success"] == true) {
      final List rawList = result["data"];
      return rawList.map((item) => OrderModel.fromJson(item)).toList();
    } else {
      print(
        "ApiService.fetchOrderQueue failed: ${result["error"]}. Utilizing mock fallback.",
      );
      return _mockOrderQueue;
    }
  }

  static Future<bool> submitOrder(OrderModel order) async {
    _mockOrderQueue.add(order);

    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/orders"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(order.toJson()),
          )
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }

  static Future<bool> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    final idx = _mockOrderQueue.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _mockOrderQueue[idx] = _mockOrderQueue[idx].copyWith(status: status);
    }

    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl/api/orders/$orderId/status"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"status": status.valueString}),
          )
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }

  // 3. TABLE API CALLS
  static Future<List<TableModel>> fetchTables() async {
    final result = await _safeGet("/api/tables");
    if (result["success"] == true) {
      final List rawList = result["data"];
      return rawList.map((item) => TableModel.fromJson(item)).toList();
    } else {
      print(
        "ApiService.fetchTables failed: ${result["error"]}. Utilizing mock fallback.",
      );
      return systemTables;
    }
  }
}
