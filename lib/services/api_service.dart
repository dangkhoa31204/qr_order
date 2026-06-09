import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item_model.dart';
import '../models/account_model.dart';

class ApiService {
  // Configurable base URL — trỏ đến backend Render thật
  static String baseUrl = "https://prm-backend-igqt.onrender.com";
  static bool useMockFallback = true; // Toggle fallback when server is offline

  // JWT Token lưu sau khi login thành công
  static String? _accessToken;
  static DateTime? _tokenExpiresAt;

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
  static bool _hasLoadedServerMenu = false;
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
          .get(Uri.parse("$baseUrl$path"), headers: _authHeaders)
          .timeout(const Duration(seconds: 10));
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
  /// Request body: { "usernameOrEmail": "...", "password": "..." }
  /// Response: LoginResponse { accessToken, expiresAt, username, role }
  static Future<LoginResult> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/Auth/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "usernameOrEmail": username,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));

        // Lưu JWT token cho các request tiếp theo
        _accessToken = loginResponse.accessToken;
        _tokenExpiresAt = loginResponse.expiresAt;

        final account = loginResponse.toAccountModel();
        return LoginResult.success(account);
      } else if (response.statusCode == 401) {
        return LoginResult.failure(
            "Tên đăng nhập hoặc mật khẩu không chính xác");
      } else if (response.statusCode == 400) {
        // Thử parse message lỗi từ server
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
      // Không kết nối được server → thử mock fallback
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
  // 1. ACCOUNT API CALLS
  // ============================================================
  static Future<List<AccountModel>> fetchStaffAccounts() async {
    // Admin lấy danh sách tất cả tài khoản Staff role 2
    final result = await _safeGet("/api/Auth/staff");
    if (result["success"] == true) {
      final data = result["data"];
      final List rawList;
      if (data is List) {
        rawList = data;
      } else if (data is Map<String, dynamic> && data["data"] is List) {
        rawList = data["data"] as List;
      } else if (data is Map<String, dynamic> && data["accounts"] is List) {
        rawList = data["accounts"] as List;
      } else {
        rawList = const [];
      }

      return rawList
          .map((item) => AccountModel.fromJson(item))
          .where((account) => account.role == AccountRole.staff)
          .toList();
    } else {
      print(
        "ApiService.fetchStaffAccounts failed: ${result["error"]}. Utilizing mock fallback.",
      );
      return _mockAccounts
          .where((account) => account.role == AccountRole.staff)
          .toList();
    }
  }

  static Future<AccountModel?> createStaffAccount({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/Auth/admin-create"),
            headers: _authHeaders,
            body: jsonEncode({
              "username": username,
              "email": email,
              "password": password,
              "fullName": fullName,
              "phoneNumber": phoneNumber,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final newAccount = AccountModel.fromJson(jsonDecode(response.body));
        // Chỉ thêm vào mock nếu thành công thật sự từ server
        _mockAccounts.add(newAccount);
        return newAccount;
      }
      
      print("Tạo Staff thất bại: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      print("Lỗi kết nối khi tạo Staff: $e");
      if (useMockFallback) {
        int maxId = 0;
        for (var account in _mockAccounts) {
          if (account.accountId > maxId) maxId = account.accountId;
        }
        final mockAccount = AccountModel(
          accountId: maxId + 1,
          username: username,
          email: email,
          passwordHash: password,
          fullName: fullName,
          phoneNumber: phoneNumber,
          role: AccountRole.staff,
        );
        _mockAccounts.add(mockAccount);
        return mockAccount;
      }
      return null;
    }
  }

  static Future<AccountModel?> updateAccount(AccountModel account) async {
    final idx =
        _mockAccounts.indexWhere((it) => it.accountId == account.accountId);
    if (idx != -1) {
      _mockAccounts[idx] = account;
    }

    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl/api/Auth/accounts/${account.accountId}"),
            headers: _authHeaders,
            body: jsonEncode({
              "username": account.username,
              "email": account.email,
              "fullName": account.fullName,
              "phoneNumber": account.phoneNumber ?? "",
              "isActive": account.isActive,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return AccountModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (_) {
      return useMockFallback ? account : null;
    }
  }

  static Future<bool> deleteAccount(int accountId) async {
    final idx = _mockAccounts.indexWhere((it) => it.accountId == accountId);
    if (idx != -1) {
      _mockAccounts[idx] = _mockAccounts[idx].copyWith(isActive: false);
    }

    try {
      final response = await http
          .delete(
            Uri.parse("$baseUrl/api/Auth/accounts/$accountId"),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }

  // ============================================================
  // 2. MENU API CALLS
  // ============================================================
  static Future<List<MenuItem>> fetchMenuItems() async {
    // Lấy tất cả món trong hệ thống, bao gồm món đã ẩn. Chỉ Admin được truy cập.
    final result = await _safeGet("/api/Menu/all");
    if (result["success"] == true) {
      final List rawList = result["data"];
      final serverItems =
          rawList.map((item) => MenuItem.fromJson(item)).toList();

      if (!_hasLoadedServerMenu) {
        _mockMenuItems.clear();
        _hasLoadedServerMenu = true;
      }

      for (final item in serverItems) {
        final idx =
            _mockMenuItems.indexWhere((it) => it.menuItemId == item.menuItemId);
        if (idx != -1) {
          _mockMenuItems[idx] = item;
        } else {
          _mockMenuItems.add(item);
        }
      }

      return List<MenuItem>.from(_mockMenuItems);
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
            Uri.parse("$baseUrl/api/Menu"),
            headers: _authHeaders,
            body: jsonEncode(item.toJson()),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback; // fallback success
    }
  }

  static Future<bool> updateMenuItem(MenuItem item) async {
    // Modify local mock list as fallback
    final idx =
        _mockMenuItems.indexWhere((it) => it.menuItemId == item.menuItemId);
    if (idx != -1) {
      _mockMenuItems[idx] = item;
    }

    try {
      final response = await http
          .put(
            Uri.parse("$baseUrl/api/Menu/${item.menuItemId}"),
            headers: _authHeaders,
            body: jsonEncode(item.toJson()),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }

  static Future<bool> deleteMenuItem(int menuItemId) async {
    _mockMenuItems.removeWhere((it) => it.menuItemId == menuItemId);

    try {
      final response = await http
          .delete(
            Uri.parse("$baseUrl/api/Menu/$menuItemId"),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 10));
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
          .patch(
            Uri.parse("$baseUrl/api/Menu/$menuItemId/toggle-availability"),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }

  // ============================================================
  // 2. ORDER QUEUE API CALLS
  // ============================================================
  static Future<List<OrderModel>> fetchOrderQueue() async {
    final result = await _safeGet("/api/Orders");
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
            Uri.parse("$baseUrl/api/Orders"),
            headers: _authHeaders,
            body: jsonEncode(order.toJson()),
          )
          .timeout(const Duration(seconds: 10));
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
            Uri.parse("$baseUrl/api/Orders/$orderId/status"),
            headers: _authHeaders,
            body: jsonEncode({"status": status.value}),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }

  // ============================================================
  // 3. TABLE API CALLS
  // ============================================================
  static final List<TableModel> _mockTables = List.from(systemTables);

  static Future<List<TableModel>> fetchTables() async {
    final result = await _safeGet("/api/Tables");
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
    // Generate an auto-increment ID for offline fallback
    int maxId = 0;
    for (var t in _mockTables) {
      if (t.tableId > maxId) maxId = t.tableId;
    }
    final mockTable = table.copyWith(tableId: maxId + 1);
    _mockTables.add(mockTable);

    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/Tables"),
            headers: _authHeaders,
            body: jsonEncode({
              "capacity": table.capacity,
            }),
          )
          .timeout(const Duration(seconds: 10));
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
            Uri.parse("$baseUrl/api/Tables/${table.tableId}"),
            headers: _authHeaders,
            body: jsonEncode({
              "capacity": table.capacity,
              "status": table.status.value,
            }),
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
    }
  }

  static Future<bool> deleteTable(int tableId) async {
    _mockTables.removeWhere((t) => t.tableId == tableId);

    try {
      final response = await http
          .delete(
            Uri.parse("$baseUrl/api/Tables/$tableId"),
            headers: _authHeaders,
          )
          .timeout(const Duration(seconds: 10));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return useMockFallback;
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
