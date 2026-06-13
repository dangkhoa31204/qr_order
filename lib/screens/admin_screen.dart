import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../models/item_model.dart';
import '../models/account_model.dart';
import 'table_management_screen.dart';

class AdminScreen extends StatefulWidget {
  final List<OrderModel> orders;
  final List<MenuItem> menuItems;
  final List<TableModel> tables;
  final List<AccountModel> staffs;
  final Function(int, OrderStatus) onUpdateOrderStatus;
  final Function(int) onToggleAvailability;
  final Function(MenuItem) onCreateMenuItem;
  final Function(MenuItem) onUpdateMenuItem;
  final Function(int) onDeleteMenuItem;
  final Function(TableModel) onAddTable;
  final Function(TableModel) onUpdateTable;
  final Function(int) onDeleteTable;
  final Function(TableModel) onExportQrCode;
  final Function(AccountModel, String) onCreateStaff;
  final Function(AccountModel) onUpdateStaff;
  final Function(int) onDeleteStaff;
  final AccountModel? currentUser;
  final VoidCallback onBackToGateway;

  const AdminScreen({
    super.key,
    required this.orders,
    required this.menuItems,
    required this.tables,
    required this.staffs,
    required this.onUpdateOrderStatus,
    required this.onToggleAvailability,
    required this.onCreateMenuItem,
    required this.onUpdateMenuItem,
    required this.onDeleteMenuItem,
    required this.onAddTable,
    required this.onUpdateTable,
    required this.onDeleteTable,
    required this.onExportQrCode,
    required this.onCreateStaff,
    required this.onUpdateStaff,
    required this.onDeleteStaff,
    this.currentUser,
    required this.onBackToGateway,
  });

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Separate active order vs historic/paid orders
    final activeOrders =
        widget.orders.where((o) => o.status != OrderStatus.paid && o.status != OrderStatus.cancelled).toList();
    final historicOrders =
        widget.orders.where((o) => o.status == OrderStatus.paid || o.status == OrderStatus.cancelled).toList();

    return Scaffold(
      backgroundColor: AromaColors.coffeeBackground,
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              "Admin Dashboard",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            if (widget.currentUser != null) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.currentUser!.role == AccountRole.admin
                      ? AromaColors.coffeeGold.withOpacity(0.9)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.currentUser!.role.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: widget.currentUser!.role == AccountRole.admin
                        ? AromaColors.coffeeTextDark
                        : Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: false,
        backgroundColor: AromaColors.coffeePrimary,
        elevation: 0,
        actions: [
          if (widget.currentUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Text(
                  widget.currentUser!.username,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          IconButton(
            onPressed: widget.onBackToGateway,
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            tooltip: "Đăng xuất",
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AromaColors.coffeeGold,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: "THỐNG KÊ"),
            Tab(icon: Icon(Icons.people), text: "QUẢN LÝ NHÂN VIÊN"),
            Tab(icon: Icon(Icons.restaurant_menu), text: "QUẢN LÝ MENU"),
            Tab(icon: Icon(Icons.table_restaurant), text: "QUẢN LÝ BÀN"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAdminDashboardTab(historicOrders),
          _buildStaffTab(),
          _buildMenuTab(),
          TableManagementScreen(
            tables: widget.tables,
            onAddTable: widget.onAddTable,
            onUpdateTable: widget.onUpdateTable,
            onDeleteTable: widget.onDeleteTable,
            onExportQrCode: widget.onExportQrCode,
          ),
        ],
      ),
    );
  }

  // --- TAB 1: Admin Dashboard ---
  Widget _buildAdminDashboardTab(List<OrderModel> history) {
    final paidOrders = history.where((o) => o.status == OrderStatus.paid).toList();
    
    final now = DateTime.now();
    
    int thisWeekCount = 0;
    int thisMonthCount = 0;
    int thisYearCount = 0;
    
    for (var o in paidOrders) {
      final date = o.createdAt;
      if (date.year == now.year) {
        thisYearCount++;
        if (date.month == now.month) {
          thisMonthCount++;
          if (now.difference(date).inDays <= 7) {
            thisWeekCount++;
          }
        }
      }
    }
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "TỔNG QUAN ĐƠN HÀNG HOÀN THÀNH",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AromaColors.coffeePrimary,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildStatCard("Tuần này\n(7 ngày qua)", thisWeekCount, Icons.calendar_view_week)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Tháng này", thisMonthCount, Icons.calendar_month)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard("Năm nay", thisYearCount, Icons.calendar_today)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AromaColors.coffeePrimary),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AromaColors.coffeeTextDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AromaColors.coffeeTextSub,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: Staff Management ---
  Widget _buildStaffTab() {
    final staffList = widget.staffs.where((s) => s.role == AccountRole.staff).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TỔNG CỘNG: ${staffList.length} NHÂN VIÊN",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AromaColors.coffeeTextSub,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddStaffDialog(context),
                icon: const Icon(Icons.person_add, size: 14, color: Colors.white),
                label: const Text(
                  "THÊM NHÂN VIÊN",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AromaColors.coffeePrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            itemCount: staffList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              return _buildStaffCard(staffList[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStaffCard(AccountModel staff) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AromaColors.coffeeCardBorder),
      ),
      color: staff.isActive ? Colors.white : Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AromaColors.coffeePrimary.withOpacity(0.1),
              child: const Icon(Icons.person, size: 32, color: AromaColors.coffeePrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          staff.fullName.isNotEmpty ? staff.fullName : staff.username,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AromaColors.coffeeTextDark,
                          ),
                        ),
                      ),
                      if (!staff.isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text("Vô hiệu hóa", style: TextStyle(fontSize: 10, color: Colors.red)),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Tài khoản: ${staff.username}",
                    style: const TextStyle(fontSize: 12, color: AromaColors.coffeeTextSub),
                  ),
                  if (staff.email.isNotEmpty)
                    Text(
                      "Email: ${staff.email}",
                      style: const TextStyle(fontSize: 12, color: AromaColors.coffeeTextSub),
                    ),
                  if (staff.phoneNumber?.isNotEmpty == true)
                    Text(
                      "SĐT: ${staff.phoneNumber}",
                      style: const TextStyle(fontSize: 12, color: AromaColors.coffeeTextSub),
                    ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => _showEditStaffDialog(context, staff),
                  icon: const Icon(Icons.edit, size: 20, color: AromaColors.coffeePrimary),
                  tooltip: "Sửa",
                ),
                if (staff.isActive)
                  IconButton(
                    onPressed: () => widget.onDeleteStaff(staff.accountId),
                    icon: const Icon(Icons.block, size: 20, color: Colors.redAccent),
                    tooltip: "Khóa tài khoản",
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: Menu catalog management ---
  Widget _buildMenuTab() {
    return Column(
      children: [
        // Table Header or Create Menu Button
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TỔNG CỘNG: ${widget.menuItems.length} MÓN ĂN",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AromaColors.coffeeTextSub,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddMenuItemDialog(context),
                icon: const Icon(Icons.add, size: 14, color: Colors.white),
                label: const Text(
                  "THÊM MÓN MỚI",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AromaColors.coffeePrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            itemCount: widget.menuItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = widget.menuItems[index];
              return _buildManagementItemCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildManagementItemCard(MenuItem item) {
    ImageProvider? imageProvider;
    if (item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      final path = item.imageUrl!;
      final isLocalFile = !path.startsWith('http') &&
          (path.startsWith('/') || path.contains(':\\\\') || path.contains(':/'));
      if (isLocalFile) {
        imageProvider = FileImage(File(path));
      } else {
        imageProvider = NetworkImage(path);
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AromaColors.coffeeCardBorder),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14).copyWith(right: 8),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AromaColors.coffeeCardLightBg,
                borderRadius: BorderRadius.circular(14),
                image: imageProvider != null
                    ? DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: imageProvider == null
                  ? Text(item.categoryIcon, style: const TextStyle(fontSize: 28))
                  : null,
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AromaColors.coffeeTextDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AromaColors.coffeeSecondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.categoryLabel,
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AromaColors.coffeePrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formatVND(item.price),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AromaColors.coffeePrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Controls (Toggle availability, edit item, delete item)
            Row(
              children: [
                // Availability toggle
                Switch(
                  value: item.isAvailable,
                  onChanged: (valu) => widget.onToggleAvailability(item.menuItemId),
                  activeColor: AromaColors.coffeePrimary,
                  activeTrackColor: AromaColors.coffeeSecondary,
                ),
                // Edit Dialog
                IconButton(
                  onPressed: () => _showEditMenuItemDialog(context, item),
                  icon: const Icon(
                    Icons.edit,
                    size: 18,
                    color: AromaColors.coffeePrimary,
                  ),
                  tooltip: "Sửa món",
                ),
                // Delete
                IconButton(
                  onPressed: () => widget.onDeleteMenuItem(item.menuItemId),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  tooltip: "Xóa món",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- POPUP DIALOGS: ADD MENU ITEM ---
  Future<void> _pickImage(StateSetter setDialogState, Function(String) onPicked) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (image != null) {
      setDialogState(() {
        onPicked(image.path);
      });
    }
  }

  Widget _buildImagePicker({
    required String? imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AromaColors.coffeeCardLightBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AromaColors.coffeeCardBorder,
            width: 1.5,
          ),
        ),
        child: imagePath != null && imagePath.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: AromaColors.coffeePrimary.withOpacity(0.6),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Chạm để chọn ảnh từ thiết bị",
                    style: TextStyle(
                      fontSize: 12,
                      color: AromaColors.coffeeTextSub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    "(Tùy chọn)",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showAddMenuItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    String? pickedImagePath;
    CategoryType category = CategoryType.coffee;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Thêm Món Thực Đơn Mới",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AromaColors.coffeeTextDark,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      nameController,
                      "Tên món (Ví dụ: Cà phê sữa)",
                    ),
                    const SizedBox(height: 10),
                    // Dropdown for Category selection
                    DropdownButtonFormField<CategoryType>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: "Phân mục ẩm thực",
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: AromaColors.coffeePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      items: CategoryType.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text("${cat.label} ${cat.icon}"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            category = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      priceController,
                      "Đơn giá VND (Ví dụ: 30000)",
                      isNumber: true,
                    ),
                    const SizedBox(height: 10),
                    // Image Picker thay thế cho Image URL
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Ảnh món ăn",
                        style: TextStyle(
                          fontSize: 12,
                          color: AromaColors.coffeePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildImagePicker(
                      imagePath: pickedImagePath,
                      onTap: () => _pickImage(setDialogState, (path) {
                        pickedImagePath = path;
                      }),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      descController,
                      "Mô tả chi tiết",
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Hủy bỏ",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final p = double.tryParse(priceController.text) ?? 0.0;
                    final newItem = MenuItem(
                      menuItemId: widget.menuItems.length + 100, // mock ID, DB sẽ tự gen ID
                      name: nameController.text.isNotEmpty ? nameController.text : "Món mới",
                      price: p,
                      description: descController.text,
                      category: category,
                      imageUrl: pickedImagePath,
                    );
                    widget.onCreateMenuItem(newItem);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AromaColors.coffeePrimary,
                  ),
                  child: const Text(
                    "Thêm món",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- POPUP DIALOGS: EDIT MENU ITEM ---
  void _showEditMenuItemDialog(BuildContext context, MenuItem item) {
    final nameController = TextEditingController(text: item.name);
    final priceController = TextEditingController(
      text: item.price.toStringAsFixed(0),
    );
    final descController = TextEditingController(text: item.description ?? "");
    String? pickedImagePath = item.imageUrl;
    CategoryType category = item.category;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Sửa Thông Tin Món",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AromaColors.coffeeTextDark,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(nameController, "Tên món"),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<CategoryType>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: "Phân mục ẩm thực",
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: AromaColors.coffeePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(),
                      ),
                      items: CategoryType.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text("${cat.label} ${cat.icon}"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            category = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      priceController,
                      "Đơn giá VND",
                      isNumber: true,
                    ),
                    const SizedBox(height: 10),
                    // Image Picker thay thế cho Image URL
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Ảnh món ăn",
                        style: TextStyle(
                          fontSize: 12,
                          color: AromaColors.coffeePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildImagePicker(
                      imagePath: pickedImagePath,
                      onTap: () => _pickImage(setDialogState, (path) {
                        pickedImagePath = path;
                      }),
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      descController,
                      "Mô tả",
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Hủy bỏ",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final p = double.tryParse(priceController.text) ?? item.price;
                    final updated = item.copyWith(
                      name: nameController.text,
                      price: p,
                      description: descController.text,
                      imageUrl: pickedImagePath,
                      category: category,
                      updatedAt: DateTime.now(),
                    );
                    widget.onUpdateMenuItem(updated);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AromaColors.coffeePrimary,
                  ),
                  child: const Text(
                    "Lưu",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13, color: AromaColors.coffeeTextDark),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(
          fontSize: 12,
          color: AromaColors.coffeeTextSub,
        ),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }

  // --- POPUP DIALOGS: ADD STAFF ---
  void _showAddStaffDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Thêm Nhân Viên Mới", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(usernameController, "Tên đăng nhập"),
                const SizedBox(height: 10),
                _buildTextField(emailController, "Email"),
                const SizedBox(height: 10),
                _buildTextField(passwordController, "Mật khẩu"),
                const SizedBox(height: 10),
                _buildTextField(fullNameController, "Họ tên"),
                const SizedBox(height: 10),
                _buildTextField(phoneController, "Số điện thoại"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy bỏ", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final newStaff = AccountModel(
                  accountId: 0,
                  username: usernameController.text,
                  email: emailController.text,
                  passwordHash: "",
                  fullName: fullNameController.text,
                  phoneNumber: phoneController.text,
                  role: AccountRole.staff,
                );
                widget.onCreateStaff(newStaff, passwordController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AromaColors.coffeePrimary),
              child: const Text("Tạo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // --- POPUP DIALOGS: EDIT STAFF ---
  void _showEditStaffDialog(BuildContext context, AccountModel staff) {
    final usernameController = TextEditingController(text: staff.username);
    final emailController = TextEditingController(text: staff.email);
    final fullNameController = TextEditingController(text: staff.fullName);
    final phoneController = TextEditingController(text: staff.phoneNumber ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Sửa Thông Tin Nhân Viên", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(usernameController, "Tên đăng nhập"),
                const SizedBox(height: 10),
                _buildTextField(emailController, "Email"),
                const SizedBox(height: 10),
                _buildTextField(fullNameController, "Họ tên"),
                const SizedBox(height: 10),
                _buildTextField(phoneController, "Số điện thoại"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy bỏ", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final updated = staff.copyWith(
                  username: usernameController.text,
                  email: emailController.text,
                  fullName: fullNameController.text,
                  phoneNumber: phoneController.text,
                );
                widget.onUpdateStaff(updated);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AromaColors.coffeePrimary),
              child: const Text("Lưu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
