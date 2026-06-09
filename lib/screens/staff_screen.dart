import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../models/item_model.dart';
import '../models/account_model.dart';
import 'table_management_screen.dart';

class StaffScreen extends StatefulWidget {
  final List<OrderModel> orders;
  final List<MenuItem> menuItems;
  final List<TableModel> tables;
  final Function(int, OrderStatus) onUpdateOrderStatus;
  final Function(int) onToggleAvailability;
  final Function(MenuItem) onCreateMenuItem;
  final Function(MenuItem) onUpdateMenuItem;
  final Function(int) onDeleteMenuItem;
  final Function(TableModel) onAddTable;
  final Function(TableModel) onUpdateTable;
  final Function(int) onDeleteTable;
  final Function(TableModel) onExportQrCode;
  final AccountModel? currentUser;
  final VoidCallback onBackToGateway;

  const StaffScreen({
    super.key,
    required this.orders,
    required this.menuItems,
    required this.tables,
    required this.onUpdateOrderStatus,
    required this.onToggleAvailability,
    required this.onCreateMenuItem,
    required this.onUpdateMenuItem,
    required this.onDeleteMenuItem,
    required this.onAddTable,
    required this.onUpdateTable,
    required this.onDeleteTable,
    required this.onExportQrCode,
    this.currentUser,
    required this.onBackToGateway,
  });

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
              "Staff Dashboard",
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
            Tab(icon: Icon(Icons.receipt_long), text: "ĐƠN ORDER ĐỂ NẤU"),
            Tab(icon: Icon(Icons.restaurant_menu), text: "QUẢN LÝ MENU"),
            Tab(icon: Icon(Icons.table_restaurant), text: "QUẢN LÝ BÀN"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersTab(activeOrders, historicOrders),
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

  // --- TAB 1: Real-time Order management ---
  Widget _buildOrdersTab(List<OrderModel> active, List<OrderModel> history) {
    if (active.isEmpty && history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AromaColors.coffeeSecondary,
                shape: BoxShape.circle,
              ),
              child: const Text("📝", style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 16),
            const Text(
              "Chưa có đơn hàng nào gửi lên!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AromaColors.coffeeTextDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Sơ đồ bàn đang trống trải ấm cúng",
              style: TextStyle(fontSize: 12, color: AromaColors.coffeeTextSub),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (active.isNotEmpty) ...[
          const Row(
            children: [
              Icon(
                Icons.hourglass_empty,
                color: AromaColors.pendingOrange,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                "ĐANG CHẾ BIẾN & CHỜ DUYỆT",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AromaColors.coffeePrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: active.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final o = active[index];
              return _buildOrderCard(o);
            },
          ),
          const SizedBox(height: 32),
        ],
        if (history.isNotEmpty) ...[
          const Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AromaColors.successGreen,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                "LỊCH SỬ ĐÃ THANH TOÁN HOÀN TẤT",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AromaColors.coffeeTextSub,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final o = history[index];
              return _buildOrderCard(o);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    String mainActionText = "";
    OrderStatus? nextStatus;
    if (order.status == OrderStatus.pending) {
      mainActionText = "🔥 CHẤP NHẬN & NẤU MÓN";
      nextStatus = OrderStatus.preparing;
    } else if (order.status == OrderStatus.preparing) {
      mainActionText = "✅ HOÀN THÀNH CHẾ BIẾN";
      nextStatus = OrderStatus.ready;
    } else if (order.status == OrderStatus.ready) {
      mainActionText = "💵 XÁC NHẬN THANH TOÁN";
      nextStatus = OrderStatus.paid;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AromaColors.coffeeCardBorder),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order meta
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AromaColors.coffeePrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        order.tableLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Mã: ${order.orderId}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AromaColors.coffeeTextDark,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: order.status.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    order.status.labelVi,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: order.status.color,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Item descriptions list
            ...order.items.map((it) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${it.menuItemRef?.categoryIcon ?? '🍽️'} ${it.menuItemRef?.name ?? 'Món ăn (ID: ${it.menuItemId})'}   x${it.quantity}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AromaColors.coffeeTextDark,
                      ),
                    ),
                    Text(
                      formatVND(it.unitPrice * it.quantity),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AromaColors.coffeePrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            if (order.note?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AromaColors.coffeeCardLightBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AromaColors.coffeeCardBorder.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notes,
                      size: 14,
                      color: AromaColors.coffeeTextSub,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Ghi chú: ${order.note}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AromaColors.coffeeTextSub,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 24),

            // Cash breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TỔNG THANH TOÁN:",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  formatVND(order.totalAmount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AromaColors.coffeePrimary,
                  ),
                ),
              ],
            ),

            // Action push button
            if (nextStatus != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    widget.onUpdateOrderStatus(order.orderId, nextStatus!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: order.status.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 44),
                  elevation: 0,
                ),
                child: Text(
                  mainActionText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
            if (order.status == OrderStatus.pending) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => widget.onUpdateOrderStatus(order.orderId, OrderStatus.cancelled),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                ),
                child: const Text("Hủy Đơn"),
              )
            ]
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
}
