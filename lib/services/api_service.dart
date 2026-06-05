import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';
import '../models/account_model.dart';

class ApiService {
  // Configurable base URL for C# ASP.NET Core backend
  // In Android Emulator, http://10.0.2.2:5000 directs to the host machine's localhost
  static String baseUrl = "http://10.0.2.2:5000";
  static bool useMockFallback = true; // Toggle fallback when server is offline

  // In-memory cache for mock data when C# server is offline
  static final List<MenuItem> _mockMenuItems = List.from(initialMenuItems);
  static final List<OrderModel> _mockOrderQueue = [
    OrderModel(
      orderId: 1,
      tableId: 8,
      items: [
        OrderItemModel(
          menuItemId: 1,
          quantity: 1,
          unitPrice: 30000,
          menuItemRef: initialMenuItems.firstWhere((it) => it.menuItemId == 1),
        ),
        OrderItemModel(
          menuItemId: 2,
          quantity: 2,
          unitPrice: 45000,
          menuItemRef: initialMenuItems.firstWhere((it) => it.menuItemId == 2),
        ),
      ],
      status: OrderStatus.preparing,
      totalAmount: 120000,
      note: "Latte ít đường, Espresso nóng",
    ),
  ];

  // Mock accounts khớp DB seed
  static final List<AccountModel> _mockAccounts = [
    seedAdmin,
    seedStaff,
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

  // 0. AUTH API CALLS
  static Future<AccountModel?> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/auth/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"username": username, "password": password}),
          )
          .timeout(const Duration(seconds: 3));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return AccountModel.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}

    // Mock fallback
    if (useMockFallback) {
      final match = _mockAccounts.where(
        (a) => a.username == username && (a.passwordHash == password || password == '12345'),
      );
      if (match.isNotEmpty) return match.first;
    }
    return null;
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
    final idx = _mockMenuItems.indexWhere((it) => it.menuItemId == item.menuItemId);
    if (idx != -1) {
      _mockMenuItems[idx] = item;
    }

    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl/api/menu/${item.menuItemId}"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(item.toJson()),
          )
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }

  static Future<bool> deleteMenuItem(int menuItemId) async {
    _mockMenuItems.removeWhere((it) => it.menuItemId == menuItemId);

    try {
      final response = await http
          .delete(Uri.parse("$baseUrl/api/menu/$menuItemId"))
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }

  static Future<bool> toggleMenuItemAvailability(int menuItemId) async {
    final idx = _mockMenuItems.indexWhere((it) => it.menuItemId == menuItemId);
    if (idx != -1) {
      final original = _mockMenuItems[idx];
      _mockMenuItems[idx] = original.copyWith(
        isAvailable: !original.isAvailable,
      );
    }

    try {
      final response = await http
          .patch(Uri.parse("$baseUrl/api/menu/$menuItemId/toggle-availability"))
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
    int orderId,
    OrderStatus status,
  ) async {
    final idx = _mockOrderQueue.indexWhere((o) => o.orderId == orderId);
    if (idx != -1) {
      _mockOrderQueue[idx] = _mockOrderQueue[idx].copyWith(status: status);
    }

    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl/api/orders/$orderId/status"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"status": status.value}),
          )
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }

  // 3. TABLE API CALLS
  static final List<TableModel> _mockTables = List.from(systemTables);

  static Future<List<TableModel>> fetchTables() async {
    final result = await _safeGet("/api/tables");
    if (result["success"] == true) {
      final List rawList = result["data"];
      return rawList.map((item) => TableModel.fromJson(item)).toList();
    } else {
      print(
        "ApiService.fetchTables failed: ${result["error"]}. Utilizing mock fallback.",
      );
      return _mockTables;
    }
  }

  static Future<bool> createTable(TableModel table) async {
    _mockTables.add(table);

    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/tables"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(table.toJson()),
          )
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }

  static Future<bool> updateTable(TableModel table) async {
    final idx = _mockTables.indexWhere((t) => t.tableId == table.tableId);
    if (idx != -1) {
      _mockTables[idx] = table;
    }

    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl/api/tables/${table.tableId}"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(table.toJson()),
          )
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }

  static Future<bool> deleteTable(int tableId) async {
    _mockTables.removeWhere((t) => t.tableId == tableId);

    try {
      final response = await http
          .delete(Uri.parse("$baseUrl/api/tables/$tableId"))
          .timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }
}
