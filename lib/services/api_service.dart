import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';
import '../models/account_model.dart';
import '../models/feedback_model.dart';

class ApiService {
  // Configurable base URL — trỏ đến backend ASP.NET Core của bạn
  static String baseUrl = "https://prm-gateway.onrender.com";
  static bool useMockFallback = false;

  // JWT Token lưu sau khi login thành công
  static String? _accessToken;
  static DateTime? _tokenExpiresAt;

  static String? get accessToken => _accessToken;

  /// Kiểm tra token còn hạn hay không
  static bool get isTokenValid {
    if (_accessToken == null || _tokenExpiresAt == null) return false;
    return DateTime.now().isBefore(_tokenExpiresAt!);
  }

  /// Lấy header Authorization với Bearer token
  static Map<String, String> get _authHeaders {
    final headers = <String, String>{
      "Content-Type": "application/json",
    };
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      headers["Authorization"] = "Bearer $_accessToken";
    }
    return headers;
  }

  /// Xóa token khi logout
  static void clearToken() {
    _accessToken = null;
    _tokenExpiresAt = null;
  }

  // In-memory cache for mock data when C# server is offline
  static final List<MenuItem> _mockMenuItems = List.from(initialMenuItems);
  static final List<OrderModel> _mockOrderQueue = [];

  // Mock accounts khớp DB seed
  static final List<AccountModel> _mockAccounts = [
    seedAdmin,
    seedStaff,
  ];

  // Helper to fetch response with timeout and error fallback
  static Future<Map<String, dynamic>> _safeGet(String path) async {
    if (_accessToken == null && useMockFallback) {
      return {"success": false, "error": "Offline mode"};
    }
    try {
      final response = await http
          .get(Uri.parse("$baseUrl$path"), headers: _authHeaders)
          .timeout(const Duration(seconds: 30));
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

  // ============================================================
  // 0. AUTH API CALLS — JWT Authentication
  // ============================================================

  /// Login bằng API thật: POST /api/Auth/login
  static Future<LoginResult> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/auth/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "usernameOrEmail": username,
              "password": password,
            }),
          )
          .timeout(const Duration(
              seconds: 60)); // Render.com cold start có thể mất 30-60s

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        _accessToken = loginResponse.accessToken;
        _tokenExpiresAt = loginResponse.expiresAt;
        final account = loginResponse.toAccountModel();
        return LoginResult.success(account);
      } else if (response.statusCode == 401) {
        return LoginResult.failure(
            "Tên đăng nhập hoặc mật khẩu không chính xác");
      } else if (response.statusCode == 400) {
        try {
          final body = jsonDecode(response.body);
          final message = body['message']?.toString() ??
              body['title']?.toString() ??
              "Thông tin đăng nhập không hợp lệ";
          return LoginResult.failure(message);
        } catch (_) {
          return LoginResult.failure("Thông tin đăng nhập không hợp lệ");
        }
      } else {
        return LoginResult.failure(
            "Lỗi máy chủ (${response.statusCode}). Vui lòng thử lại sau.");
      }
    } catch (e) {
      if (useMockFallback) {
        final match = _mockAccounts.where(
          (a) =>
              a.username == username &&
              (a.passwordHash == password || password == '12345'),
        );
        if (match.isNotEmpty) {
          return LoginResult.success(match.first);
        }
        return LoginResult.failure(
            "Tên đăng nhập hoặc mật khẩu không chính xác (chế độ offline)");
      }
      return LoginResult.failure(
          "Không thể kết nối tới máy chủ.\nVui lòng kiểm tra kết nối mạng.");
    }
  }

  // ============================================================
  // 1. MENU API CALLS
  // ============================================================
  static Future<List<MenuItem>> fetchMenuItems() async {
    final path = _accessToken != null ? "/api/menu/all" : "/api/menu";
    final result = await _safeGet(path);
    if (result["success"] == true) {
      final List rawList = result["data"];
      return rawList.map((item) => MenuItem.fromJson(item)).toList();
    } else {
      debugPrint(
          'ApiService.fetchMenuItems failed: ${result["error"]}. Utilizing mock fallback.');
      return _mockMenuItems;
    }
  }

  static Future<String?> uploadImage(String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/api/menu/upload-image"),
      );
      if (_accessToken != null && _accessToken!.isNotEmpty) {
        request.headers["Authorization"] = "Bearer $_accessToken";
      }
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 20));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        return decoded["imageUrl"] as String?;
      } else {
        debugPrint(
            "Upload image failed with status: ${response.statusCode}, body: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
    }
    return null;
  }

  static Future<bool> createMenuItem(MenuItem item) async {
    var finalItem = item;
    if (item.imageUrl != null &&
        item.imageUrl!.isNotEmpty &&
        !item.imageUrl!.startsWith('http')) {
      final file = File(item.imageUrl!);
      if (await file.exists()) {
        final uploadedUrl = await uploadImage(item.imageUrl!);
        if (uploadedUrl != null) {
          finalItem = item.copyWith(imageUrl: uploadedUrl);
        } else {
          finalItem = item.copyWith(clearImageUrl: true);
        }
      } else {
        finalItem = item.copyWith(clearImageUrl: true);
      }
    }
    _mockMenuItems.add(finalItem);
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/menu"),
            headers: _authHeaders,
            body: jsonEncode(finalItem.toJson()),
          )
          .timeout(const Duration(seconds: 10));
      return (response.statusCode >= 200 && response.statusCode < 300) ||
          useMockFallback;
    } catch (_) {
      return useMockFallback;
    }
  }

  static Future<bool> updateMenuItem(MenuItem item) async {
    var finalItem = item;
    if (item.imageUrl != null &&
        item.imageUrl!.isNotEmpty &&
        !item.imageUrl!.startsWith('http')) {
      final file = File(item.imageUrl!);
      if (await file.exists()) {
        final uploadedUrl = await uploadImage(item.imageUrl!);
        if (uploadedUrl != null) {
          finalItem = item.copyWith(imageUrl: uploadedUrl);
        } else {
          finalItem = item.copyWith(clearImageUrl: true);
        }
      } else {
        finalItem = item.copyWith(clearImageUrl: true);
      }
    }
    final idx = _mockMenuItems
        .indexWhere((it) => it.menuItemId == finalItem.menuItemId);
    if (idx != -1) {
      _mockMenuItems[idx] = finalItem;
    }
    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl/api/menu/${finalItem.menuItemId}"),
            headers: _authHeaders,
            body: jsonEncode(finalItem.toJson()),
          )
          .timeout(const Duration(seconds: 10));
      return (response.statusCode >= 200 && response.statusCode < 300) ||
          useMockFallback;
    } catch (_) {
      return useMockFallback;
    }
  }

  static Future<bool> deleteMenuItem(int menuItemId) async {
    _mockMenuItems.removeWhere((it) => it.menuItemId == menuItemId);
    try {
      final response = await http
          .delete(
            Uri.parse("$baseUrl/api/menu/$menuItemId"),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 10));
      return (response.statusCode >= 200 && response.statusCode < 300) ||
          useMockFallback;
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
          .patch(
            Uri.parse("$baseUrl/api/menu/$menuItemId/toggle-availability"),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 10));
      return (response.statusCode >= 200 && response.statusCode < 300) ||
          useMockFallback;
    } catch (_) {
      return useMockFallback;
    }
  }

  // ============================================================
  // 2. ORDER QUEUE API CALLS
  // ============================================================
  static Future<List<OrderModel>> fetchOrderQueue() async {
    final result = await _safeGet("/api/orders");
    if (result["success"] == true) {
      final List rawList = result["data"];
      return rawList.map((item) => OrderModel.fromJson(item)).toList();
    } else {
      debugPrint(
          'ApiService.fetchOrderQueue failed: ${result["error"]}. Utilizing mock fallback.');
      return _mockOrderQueue;
    }
  }

  /// Lấy thông tin chi tiết của một đơn hàng trực tiếp từ Server (không dùng mock fallback)
  static Future<OrderModel?> fetchOrderById(int orderId) async {
    final result = await _safeGet("/api/orders/$orderId");
    if (result["success"] == true) {
      return OrderModel.fromJson(result["data"]);
    }
    return null;
  }

  static Future<bool> submitOrder(OrderModel order) async {
    _mockOrderQueue.add(order);
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/orders"),
            headers: _authHeaders,
            body: jsonEncode(order.toJson()),
          )
          .timeout(const Duration(seconds: 10));
      return (response.statusCode >= 200 && response.statusCode < 300) ||
          useMockFallback;
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

    if (_accessToken == null && useMockFallback) return true;

    final uri = Uri.parse("$baseUrl/api/orders/$orderId/status");
    final payloads = [
      {"status": status.value},
      {"status": status.valueString},
    ];

    try {
      http.Response? lastResponse;

      for (final payload in payloads) {
        final patchResponse = await http
            .patch(
              uri,
              headers: _authHeaders,
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 10));

        if (patchResponse.statusCode >= 200 && patchResponse.statusCode < 300) {
          return true;
        }

        lastResponse = patchResponse;
        if (patchResponse.statusCode != 405 &&
            patchResponse.statusCode != 400) {
          break;
        }

        final putResponse = await http
            .put(
              uri,
              headers: _authHeaders,
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 10));

        if (putResponse.statusCode >= 200 && putResponse.statusCode < 300) {
          return true;
        }

        lastResponse = putResponse;
        if (putResponse.statusCode != 405 && putResponse.statusCode != 400) {
          break;
        }
      }

      debugPrint(
          '❌ Lỗi Cập Nhật Đơn $orderId: Server trả về ${lastResponse?.statusCode} - ${lastResponse?.body}');
      return useMockFallback;
    } catch (e) {
      debugPrint('❌ Lỗi Mạng Cập Nhật Đơn: $e');
      return useMockFallback;
    }
  }

  static Future<bool> updateOrderItemStatus(
    int orderId,
    int orderItemId,
    OrderItemStatus status,
  ) async {
    // Update local state for mock
    final oIdx = _mockOrderQueue.indexWhere((o) => o.orderId == orderId);
    if (oIdx != -1) {
      final order = _mockOrderQueue[oIdx];
      final iIdx = order.items.indexWhere((i) => i.orderItemId == orderItemId);
      if (iIdx != -1) {
        final newItems = List<OrderItemModel>.from(order.items);
        newItems[iIdx] = newItems[iIdx].copyWith(status: status);
        _mockOrderQueue[oIdx] = order.copyWith(items: newItems);
      }
    }

    if (_accessToken == null && useMockFallback) return true;

    try {
      final response = await http
          .patch(
            Uri.parse("$baseUrl/api/orders/$orderId/items/$orderItemId/status"),
            headers: _authHeaders,
            body: jsonEncode({"status": status.value}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      debugPrint(
          '❌ Lỗi Cập Nhật Món $orderItemId: Server trả về ${response.statusCode} - ${response.body}');
      return useMockFallback;
    } catch (e) {
      debugPrint('❌ Lỗi Mạng Cập Nhật Món: $e');
      return useMockFallback;
    }
  }

  // ============================================================
  // 3. TABLE API CALLS
  // ============================================================
  static final List<TableModel> _mockTables = List.from(systemTables);

  static Future<List<TableModel>> fetchTables() async {
    final result = await _safeGet("/api/tables");
    if (result["success"] == true) {
      final List rawList = result["data"];
      return rawList.map((item) => TableModel.fromJson(item)).toList();
    } else {
      debugPrint(
          'ApiService.fetchTables failed: ${result["error"]}. Utilizing mock fallback.');
      return _mockTables;
    }
  }

  static Future<bool> createTable(TableModel table) async {
    int maxId = 0;
    for (var t in _mockTables) {
      if (t.tableId > maxId) maxId = t.tableId;
    }
    final mockTable = table.copyWith(tableId: maxId + 1);
    _mockTables.add(mockTable);

    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/tables"),
            headers: _authHeaders,
            body: jsonEncode({
              "capacity": table.capacity,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return (response.statusCode >= 200 && response.statusCode < 300) ||
          useMockFallback;
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
            headers: _authHeaders,
            body: jsonEncode({
              "capacity": table.capacity,
              "status": table.status.value,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      debugPrint(
          "❌ Lỗi Cập Nhật Bàn ${table.tableId}: Server trả về ${response.statusCode} - ${response.body}");
      return useMockFallback;
    } catch (e) {
      debugPrint("❌ Lỗi Mạng Cập Nhật Bàn: $e");
      return useMockFallback;
    }
  }

  static Future<bool> deleteTable(int tableId) async {
    _mockTables.removeWhere((t) => t.tableId == tableId);

    try {
      final response = await http
          .delete(
            Uri.parse("$baseUrl/api/tables/$tableId"),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      debugPrint(
          "❌ Lỗi Xóa Bàn $tableId: Server trả về ${response.statusCode} - ${response.body}");
      return useMockFallback;
    } catch (e) {
      debugPrint("❌ Lỗi Mạng Xóa Bàn: $e");
      return useMockFallback;
    }
  }

  // ============================================================
  // 4. STAFF ACCOUNT API CALLS (Admin Only)
  // ============================================================
  static Future<List<AccountModel>> fetchStaffs() async {
    final result = await _safeGet("/api/auth/staff");
    if (result["success"] == true) {
      final List rawList = result["data"];
      return rawList.map((item) => AccountModel.fromJson(item)).toList();
    } else {
      debugPrint(
          'ApiService.fetchStaffs failed: ${result["error"]}. Utilizing mock fallback.');
      return _mockAccounts.where((a) => a.role == AccountRole.staff).toList();
    }
  }

  static Future<bool> createStaff(AccountModel staff, String password) async {
    int maxId = 0;
    for (var a in _mockAccounts) {
      if (a.accountId > maxId) maxId = a.accountId;
    }
    final mockStaff =
        staff.copyWith(accountId: maxId + 1, passwordHash: password);
    _mockAccounts.add(mockStaff);

    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/auth/admin-create"),
            headers: _authHeaders,
            body: jsonEncode({
              "username": staff.username,
              "email": staff.email,
              "password": password,
              "fullName": staff.fullName,
              "phoneNumber": staff.phoneNumber,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return (response.statusCode >= 200 && response.statusCode < 300) ||
          useMockFallback;
    } catch (_) {
      return useMockFallback;
    }
  }

  static Future<bool> updateStaff(AccountModel staff) async {
    final idx = _mockAccounts.indexWhere((a) => a.accountId == staff.accountId);
    if (idx != -1) {
      _mockAccounts[idx] = staff;
    }

    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl/api/auth/accounts/${staff.accountId}"),
            headers: _authHeaders,
            body: jsonEncode({
              "username": staff.username,
              "email": staff.email,
              "fullName": staff.fullName,
              "phoneNumber": staff.phoneNumber,
              "isActive": staff.isActive,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return (response.statusCode >= 200 && response.statusCode < 300) ||
          useMockFallback;
    } catch (_) {
      return useMockFallback;
    }
  }

  static Future<bool> deleteStaff(int accountId) async {
    final idx = _mockAccounts.indexWhere((a) => a.accountId == accountId);
    if (idx != -1) {
      _mockAccounts[idx] = _mockAccounts[idx].copyWith(isActive: false);
    }

    try {
      final response = await http
          .delete(
            Uri.parse("$baseUrl/api/auth/accounts/$accountId"),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 10));
      return (response.statusCode >= 200 && response.statusCode < 300) ||
          useMockFallback;
    } catch (_) {
      return useMockFallback;
    }
  }

  // ============================================================
  // 5. FEEDBACK API CALLS (Admin Only)
  // ============================================================
  static final List<FeedbackModel> _mockFeedbacks = [
    FeedbackModel(
      feedbackId: 1,
      orderId: 1,
      tableId: 8,
      rating: 5,
      comment: "Đồ uống rất ngon, phục vụ nhanh!",
      isHidden: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FeedbackModel(
      feedbackId: 2,
      orderId: 2,
      tableId: 2,
      rating: 3,
      comment: "Cà phê hơi ngọt so với khẩu vị của mình.",
      isHidden: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  static Future<List<FeedbackModel>> fetchFeedbacks() async {
    final result = await _safeGet("/api/feedbacks");
    if (result["success"] == true) {
      final List rawList = result["data"];
      return rawList.map((item) => FeedbackModel.fromJson(item)).toList();
    } else {
      debugPrint(
          'ApiService.fetchFeedbacks failed: ${result["error"]}. Utilizing mock fallback.');
      return _mockFeedbacks;
    }
  }

  static Future<bool> toggleFeedbackVisibility(int feedbackId) async {
    final idx = _mockFeedbacks.indexWhere((f) => f.feedbackId == feedbackId);
    if (idx != -1) {
      final original = _mockFeedbacks[idx];
      _mockFeedbacks[idx] = FeedbackModel(
        feedbackId: original.feedbackId,
        orderId: original.orderId,
        tableId: original.tableId,
        rating: original.rating,
        comment: original.comment,
        isHidden: !original.isHidden,
        createdAt: original.createdAt,
      );
    }

    try {
      final response = await http
          .patch(
            Uri.parse("$baseUrl/api/feedbacks/$feedbackId/visibility"),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 10));
      return (response.statusCode >= 200 && response.statusCode < 300) ||
          useMockFallback;
    } catch (_) {
      return useMockFallback;
    }
  }

  /// Gửi tin nhắn chat tới AI Assistant (Qwen) cho Staff/Admin
  static Future<String> sendStaffAiChat(List<Map<String, String>> messages) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/ai/staff-chat"),
            headers: _authHeaders,
            body: jsonEncode({"messages": messages}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reply"] ?? "Không nhận được phản hồi từ AI.";
      }
      return "Lỗi từ server AI (${response.statusCode}).";
    } catch (e) {
      return "Không thể kết nối tới dịch vụ AI. Vui lòng kiểm tra lại kết nối mạng.";
    }
  }

  /// Phân tích giọng nói order món ăn thành dữ liệu JSON
  static Future<Map<String, dynamic>> parseVoiceOrder(String voiceText, {int? tableId}) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/ai/parse-voice"),
            headers: _authHeaders,
            body: jsonEncode({"voiceText": voiceText, "tableId": tableId}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {"success": false, "message": "Server trả về lỗi: ${response.statusCode}"};
    } catch (e) {
      return {"success": false, "message": "Không thể kết nối AI voice parser."};
    }
  }

  /// Lấy Đề xuất Tối ưu Vận hành & Doanh số AI cho Admin Dashboard
  static Future<Map<String, dynamic>> getDashboardRecommendations() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/api/ai/dashboard-recommendations"),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {
        "summary": "Không thể lấy đề xuất từ AI (${response.statusCode})",
        "recommendations": <String>[]
      };
    } catch (e) {
      return {
        "summary": "Không thể kết nối đến AI Microservice.",
        "recommendations": <String>[]
      };
    }
  }
}

/// Kết quả login: thành công hoặc thất bại kèm message chi tiết
class LoginResult {
  final bool isSuccess;
  final AccountModel? account;
  final String? errorMessage;

  LoginResult._({
    required this.isSuccess,
    this.account,
    this.errorMessage,
  });

  factory LoginResult.success(AccountModel account) {
    return LoginResult._(isSuccess: true, account: account);
  }

  factory LoginResult.failure(String message) {
    return LoginResult._(isSuccess: false, errorMessage: message);
  }
}
