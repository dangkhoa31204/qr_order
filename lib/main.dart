import 'dart:async';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'models/item_model.dart';
import 'models/account_model.dart';
import 'services/api_service.dart';
import 'services/signalr_service.dart';
import 'screens/login_screen.dart';
import 'screens/staff_screen.dart';
import 'screens/admin_screen.dart';

void main() {
  runApp(const AromaBistroApp());
}

class AromaBistroApp extends StatelessWidget {
  const AromaBistroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aroma Bistro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AromaColors.coffeePrimary,
        scaffoldBackgroundColor: AromaColors.coffeeBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AromaColors.coffeePrimary,
          primary: AromaColors.coffeePrimary,
          background: AromaColors.coffeeBackground,
        ),
        fontFamily: 'Serif',
      ),
      home: const MainGateScreen(),
    );
  }
}

class MainGateScreen extends StatefulWidget {
  const MainGateScreen({super.key});

  @override
  State<MainGateScreen> createState() => _MainGateScreenState();
}

class _MainGateScreenState extends State<MainGateScreen> {
  bool _isLoggedIn = false;
  AccountModel? _currentUser;

  List<MenuItem> _menuItems = [];
  List<OrderModel> _orderQueue = [];
  List<TableModel> _tables = [];
  List<AccountModel> _staffs = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBackendData();
  }

  // Complete data reload (Menu, orders, tables)
  Future<void> _loadBackendData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final menu = await ApiService.fetchMenuItems();
      final orders = await ApiService.fetchOrderQueue();
      final tables = await ApiService.fetchTables();
      final staffs = await ApiService.fetchStaffs();

      setState(() {
        _menuItems = menu;
        _orderQueue = orders;
        _tables = tables;
        _staffs = staffs;
      });
    } catch (e) {
      print("Error loading backend data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- ACTIONS ---

  // Kitchen Status advanced progression
  Future<void> _updateOrderStatus(int orderId, OrderStatus status) async {
    final success = await ApiService.updateOrderStatus(orderId, status);
    if (success) {
      _loadBackendData();
    }
  }

  // Modify item availability
  Future<void> _toggleAvailability(int itemId) async {
    final success = await ApiService.toggleMenuItemAvailability(itemId);
    if (success) {
      _loadBackendData();
    }
  }

  // Add item
  Future<void> _createMenuItem(MenuItem item) async {
    final success = await ApiService.createMenuItem(item);
    if (success) {
      _loadBackendData();
    }
  }

  // Edit item
  Future<void> _updateMenuItem(MenuItem item) async {
    final success = await ApiService.updateMenuItem(item);
    if (success) {
      _loadBackendData();
    }
  }

  // Delete item
  Future<void> _deleteMenuItem(int id) async {
    final success = await ApiService.deleteMenuItem(id);
    if (success) {
      _loadBackendData();
    }
  }

  // Table Management Functions
  Future<void> _addTable(TableModel table) async {
    final success = await ApiService.createTable(table);
    if (success) {
      _loadBackendData();
    }
  }

  Future<void> _updateTable(TableModel table) async {
    final success = await ApiService.updateTable(table);
    if (success) {
      _loadBackendData();
    }
  }

  Future<void> _deleteTable(int tableId) async {
    final success = await ApiService.deleteTable(tableId);
    if (success) {
      _loadBackendData();
    }
  }

  void _exportQrCode(TableModel table) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Mã QR của ${table.label} đã được lưu!"),
        backgroundColor: AromaColors.successGreen,
      ),
    );
  }

  // Staff Management Functions (Admin Only)
  Future<void> _createStaff(AccountModel staff, String password) async {
    final success = await ApiService.createStaff(staff, password);
    if (success) {
      _loadBackendData();
    }
  }

  Future<void> _updateStaff(AccountModel staff) async {
    final success = await ApiService.updateStaff(staff);
    if (success) {
      _loadBackendData();
    }
  }

  Future<void> _deleteStaff(int accountId) async {
    final success = await ApiService.deleteStaff(accountId);
    if (success) {
      _loadBackendData();
    }
  }

  void _handleLogin(AccountModel account) {
    setState(() {
      _isLoggedIn = true;
      _currentUser = account;
    });
    _loadBackendData();
    // Khởi tạo SignalR ngay sau khi login thành công
    SignalRService.init(() {
      _loadBackendData();
    });
  }

  UserRole get _currentRole {
    if (_currentUser == null) return UserRole.staff;
    return _currentUser!.role == AccountRole.admin
        ? UserRole.admin
        : UserRole.staff;
  }

  // --- POPUPS & API OPTION DIALOG ---
  void _showConfigureApiDialog() {
    final controller = TextEditingController(text: ApiService.baseUrl);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Cấu hình C# API Server",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Nhập địa chỉ máy chủ ASP.NET Core API cục bộ của bạn để đồng bộ dữ liệu thật:",
                style:
                    TextStyle(fontSize: 12, color: AromaColors.coffeeTextSub),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: "API URL",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                style: const TextStyle(
                    fontSize: 13, color: AromaColors.coffeeTextDark),
              ),
              const SizedBox(height: 12),
              const Text(
                "Gợi ý kết nối:\n• localhost PC: http://10.0.2.2:5000\n• Lan IP: http://192.168.1.XX:5000\n• Web live service: URL công khai của bạn",
                style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: Colors.blueGrey),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy bỏ", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  ApiService.baseUrl = controller.text.trim();
                });
                Navigator.pop(context);
                _loadBackendData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Kính chào! Đã chuyển hướng máy chủ sang: ${ApiService.baseUrl}"),
                    backgroundColor: AromaColors.coffeePrimary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AromaColors.coffeePrimary),
              child: const Text("Lưu Kết Nối",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  // --- SCREEN RENDERING CONTROLLER ---
  @override
  Widget build(BuildContext context) {
    // Show login if not logged in
    if (!_isLoggedIn) {
      return LoginScreen(
        onLoginSuccess: _handleLogin,
      );
    }

    if (_currentRole == UserRole.admin) {
      return AdminScreen(
        orders: _orderQueue,
        menuItems: _menuItems,
        tables: _tables,
        staffs: _staffs,
        onUpdateOrderStatus: _updateOrderStatus,
        onToggleAvailability: _toggleAvailability,
        onCreateMenuItem: _createMenuItem,
        onUpdateMenuItem: _updateMenuItem,
        onDeleteMenuItem: _deleteMenuItem,
        onAddTable: _addTable,
        onUpdateTable: _updateTable,
        onDeleteTable: _deleteTable,
        onCreateStaff: _createStaff,
        onUpdateStaff: _updateStaff,
        onDeleteStaff: _deleteStaff,
        onExportQrCode: _exportQrCode,
        currentUser: _currentUser,
        onBackToGateway: () {
          SignalRService.disconnect();
          ApiService.clearToken();
          setState(() {
            _isLoggedIn = false;
            _currentUser = null;
          });
        },
      );
    }

    // Show StaffScreen if logged in
    return StaffScreen(
      orders: _orderQueue,
      menuItems: _menuItems,
      tables: _tables,
      onUpdateOrderStatus: _updateOrderStatus,
      onToggleAvailability: _toggleAvailability,
      onUpdateTable: _updateTable,
      onExportQrCode: _exportQrCode,
      currentUser: _currentUser,
      onBackToGateway: () {
        SignalRService.disconnect();
        ApiService.clearToken();
        setState(() {
          _isLoggedIn = false;
          _currentUser = null;
        });
      },
    );
  }
}
