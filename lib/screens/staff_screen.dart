import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/item_model.dart';
import 'table_management_screen.dart';

class StaffScreen extends StatefulWidget {
  final List<OrderModel> orders;
  final List<MenuItem> menuItems;
  final List<TableModel> tables;
  final Function(String, OrderStatus) onUpdateOrderStatus;
  final Function(String) onToggleAvailability;
  final Function(MenuItem) onCreateMenuItem;
  final Function(MenuItem) onUpdateMenuItem;
  final Function(String) onDeleteMenuItem;
  final Function(TableModel) onAddTable;
  final Function(TableModel) onUpdateTable;
  final Function(String) onDeleteTable;
  final Function(TableModel) onExportQrCode;
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
        widget.orders.where((o) => o.status != OrderStatus.paid).toList();
    final historicOrders =
        widget.orders.where((o) => o.status == OrderStatus.paid).toList();

    return Scaffold(
      backgroundColor: AromaColors.coffeeBackground,
      appBar: AppBar(
        title: const Text(
          "Staff Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        backgroundColor: AromaColors.coffeePrimary,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: widget.onBackToGateway,
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            tooltip: "Đổi vai trò",
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
    double totalBill = 0.0;
    order.items.forEach((it) {
      totalBill += it.menuItem.price * it.quantity;
    });
    totalBill *= 1.10; // apply tax/charge

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
                      "Mã: ${order.id}",
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
                      "${it.menuItem.emoji} ${it.menuItem.name}   x${it.quantity}",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AromaColors.coffeeTextDark,
                      ),
                    ),
                    Text(
                      "\$${(it.menuItem.price * it.quantity).toStringAsFixed(2)}",
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

            if (order.note.isNotEmpty) ...[
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
                  "TỔNG THANH TOÁN (HÓA ĐƠN + 10% THUẾ):",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "\$${totalBill.toStringAsFixed(2)}",
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
                    widget.onUpdateOrderStatus(order.id, nextStatus!),
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
              ),
              alignment: Alignment.center,
              child: Text(item.emoji, style: const TextStyle(fontSize: 28)),
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
                          item.category,
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
                    item.vietnameseName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AromaColors.coffeeTextSub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "\$${item.price.toStringAsFixed(2)}",
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
                  onChanged: (valu) => widget.onToggleAvailability(item.id),
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
                  onPressed: () => widget.onDeleteMenuItem(item.id),
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
  void _showAddMenuItemDialog(BuildContext context) {
    final emojiController = TextEditingController(text: "☕");
    final enNameController = TextEditingController();
    final viNameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    String category = "Coffees";

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
                      emojiController,
                      "Emoji Biểu Tượng (Ví dụ 🥐)",
                    ),
                    const SizedBox(height: 10),
                    // Dropdown for Category selection
                    DropdownButtonFormField<String>(
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
                      items: const [
                        DropdownMenuItem(
                          value: "Coffees",
                          child: Text("Cà phê ☕"),
                        ),
                        DropdownMenuItem(
                          value: "Teas",
                          child: Text("Trà hoa quả 🍵"),
                        ),
                        DropdownMenuItem(
                          value: "Pastries",
                          child: Text("Bánh ngọt 🥐"),
                        ),
                        DropdownMenuItem(
                          value: "Brunch",
                          child: Text("Điểm tâm 🥑"),
                        ),
                      ],
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
                      enNameController,
                      "Tên tiếng Anh (Ví dụ Almond Croissant)",
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      viNameController,
                      "Tên tiếng Việt (Ví dụ Bánh Sừng Bò Hạnh Nhân)",
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      priceController,
                      "Đơn giá USD (Ví dụ 5.50)",
                      isNumber: true,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      descController,
                      "Mô tả chất lượng món",
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
                    final p = double.tryParse(priceController.text) ?? 1.0;
                    final randSuffix =
                        100 + (DateTime.now().microsecondsSinceEpoch % 900);
                    final newItem = MenuItem(
                      id: "m${widget.menuItems.length + 1}-$randSuffix",
                      name: enNameController.text.isNotEmpty
                          ? enNameController.text
                          : "New item",
                      vietnameseName: viNameController.text.isNotEmpty
                          ? viNameController.text
                          : "Món mới",
                      price: p,
                      description: descController.text,
                      emoji: emojiController.text.isNotEmpty
                          ? emojiController.text
                          : "☕",
                      category: category,
                    );
                    widget.onCreateMenuItem(newItem);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AromaColors.coffeePrimary,
                  ),
                  child: const Text(
                    "Khởi tạo món",
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
    final emojiController = TextEditingController(text: item.emoji);
    final enNameController = TextEditingController(text: item.name);
    final viNameController = TextEditingController(text: item.vietnameseName);
    final priceController = TextEditingController(
      text: item.price.toStringAsFixed(2),
    );
    final descController = TextEditingController(text: item.description);
    String category = item.category;

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
                "Sửa Thông Tin Món Ăn",
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
                    _buildTextField(emojiController, "Emoji Biểu Tượng"),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
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
                      items: const [
                        DropdownMenuItem(
                          value: "Coffees",
                          child: Text("Cà phê ☕"),
                        ),
                        DropdownMenuItem(
                          value: "Teas",
                          child: Text("Trà hoa quả 🍵"),
                        ),
                        DropdownMenuItem(
                          value: "Pastries",
                          child: Text("Bánh ngọt 🥐"),
                        ),
                        DropdownMenuItem(
                          value: "Brunch",
                          child: Text("Điểm tâm 🥑"),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            category = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(enNameController, "Tên tiếng Anh"),
                    const SizedBox(height: 10),
                    _buildTextField(viNameController, "Tên tiếng Việt"),
                    const SizedBox(height: 10),
                    _buildTextField(
                      priceController,
                      "Đơn giá USD",
                      isNumber: true,
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      descController,
                      "Mô tả chất lượng món",
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
                    final p =
                        double.tryParse(priceController.text) ?? item.price;
                    final updated = item.copyWith(
                      name: enNameController.text,
                      vietnameseName: viNameController.text,
                      price: p,
                      description: descController.text,
                      emoji: emojiController.text,
                      category: category,
                    );
                    widget.onUpdateMenuItem(updated);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AromaColors.coffeePrimary,
                  ),
                  child: const Text(
                    "Lưu thay đổi",
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

// Inline helper extension for generating integer randomness
extension on int {
  int random() {
    return (this == 0)
        ? 0
        : (0 + (DateTime.now().microsecondsSinceEpoch % (this + 1)));
  }
}

extension on RangeValues {
  // simple math replacement for .random inside bounds
}

class NumRange {
  static int random(int min, int max) {
    final offset = max - min + 1;
    return min + offset.randomValue();
  }
}

extension RangeHelper on int {
  int randomValue() {
    return (this == 0) ? 0 : (DateTime.now().microsecondsSinceEpoch % this);
  }
}

extension RandomRange on int {
  // safe helper to handle custom random within a range
}
