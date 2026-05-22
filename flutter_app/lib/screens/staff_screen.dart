import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/item_model.dart';

class StaffScreen extends StatefulWidget {
  final List<OrderModel> orderQueue;
  final List<MenuItem> menuItems;
  final Function() onBackToGateway;
  final Function(String, OrderStatus) onUpdateOrderStatus;
  final Function(MenuItem) onCreateMenuItem;
  final Function(MenuItem) onUpdateMenuItem;
  final Function(String) onDeleteMenuItem;
  final Function(String) onToggleAvailability;

  const StaffScreen({
    super.key,
    required this.orderQueue,
    required this.menuItems,
    required this.onBackToGateway,
    required this.onUpdateOrderStatus,
    required this.onCreateMenuItem,
    required this.onUpdateMenuItem,
    required this.onDeleteMenuItem,
    required this.onToggleAvailability,
  });

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  String activeStaffSubTab = "orders"; // "orders", "menu", "tables"

  // Dialog management controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _vnNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _emojiController = TextEditingController();
  String _selectedCategory = "Coffees";
  bool _itemIsAvailable = true;
  String? _dialogError;

  void _showItemDialog([MenuItem? editingItem]) {
    if (editingItem != null) {
      _nameController.text = editingItem.name;
      _vnNameController.text = editingItem.vietnameseName;
      _priceController.text = editingItem.price.toString();
      _descController.text = editingItem.description;
      _emojiController.text = editingItem.emoji;
      _selectedCategory = editingItem.category;
      _itemIsAvailable = editingItem.isAvailable;
    } else {
      _nameController.clear();
      _vnNameController.clear();
      _priceController.clear();
      _descController.clear();
      _emojiController.text = "☕";
      _selectedCategory = "Coffees";
      _itemIsAvailable = true;
    }
    _dialogError = null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: AromaColors.coffeeBackground,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          editingItem == null ? "Thêm Món Ăn Mới" : "Chỉnh Sửa Món Ăn",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AromaColors.coffeeTextDark,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // English Name
                    _buildFieldLabel("Tên tiếng Anh"),
                    _buildTextField(
                      controller: _nameController,
                      hint: "Ví dụ: Avocado Toast",
                    ),
                    const SizedBox(height: 10),

                    // Vietnamese Name
                    _buildFieldLabel("Tên tiếng Việt"),
                    _buildTextField(
                      controller: _vnNameController,
                      hint: "Ví dụ: Bánh Mì Trái Bơ",
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        // Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel("Giá tiền (\$ USD)"),
                              _buildTextField(
                                controller: _priceController,
                                hint: "e.g. 12.00",
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Emoji
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFieldLabel("Emoji Biểu Tượng"),
                              _buildTextField(
                                controller: _emojiController,
                                hint: "🥑",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Category Chips Setup
                    _buildFieldLabel("Phân loại danh mục"),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        {"id": "Coffees", "icon": "☕", "label": "Cà phê"},
                        {"id": "Teas", "icon": "🍵", "label": "Trà"},
                        {"id": "Pastries", "icon": "🥐", "label": "Bánh"},
                        {"id": "Brunch", "icon": "🥑", "label": "Món ăn"},
                      ].map((cat) {
                        final catId = cat["id"]!;
                        final isSelected = _selectedCategory == catId;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                _selectedCategory = catId;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AromaColors.coffeePrimary : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? AromaColors.coffeePrimary : AromaColors.coffeeCardBorder,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(cat["icon"]!, style: const TextStyle(fontSize: 14)),
                                  Text(
                                    cat["label"]!,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : AromaColors.coffeeTextDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Description text input
                    _buildFieldLabel("Mô tả chi tiết món ăn"),
                    _buildTextField(
                      controller: _descController,
                      hint: "Thành phần bơ sẫm béo ngậy, hạt macca, hạt chia sấy khô giòn tan...",
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),

                    // Available Switch Panel
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AromaColors.coffeeCardBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Sẵn sàng phục vụ",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AromaColors.coffeeTextDark,
                                ),
                              ),
                              Text(
                                _itemIsAvailable ? "Cho phép gọi món ngay" : "Tắt món tạm thời",
                                style: const TextStyle(fontSize: 9, color: Colors.grey),
                              ),
                            ],
                          ),
                          Switch(
                            value: _itemIsAvailable,
                            onChanged: (val) {
                              setDialogState(() {
                                _itemIsAvailable = val;
                              });
                            },
                            activeColor: AromaColors.successGreen,
                          ),
                        ],
                      ),
                    ),

                    if (_dialogError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _dialogError!,
                        style: const TextStyle(
                          color: AromaColors.errorColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    // Form confirmation buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AromaColors.coffeePrimary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text("Hủy", style: TextStyle(color: AromaColors.coffeePrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_nameController.text.trim().isEmpty || _vnNameController.text.trim().isEmpty) {
                                setDialogState(() {
                                  _dialogError = "Vui lòng nhập tên món đầy đủ!";
                                });
                                return;
                              }
                              final price = double.tryParse(_priceController.text.trim());
                              if (price == null || price < 0) {
                                setDialogState(() {
                                  _dialogError = "Vui lòng cung cấp giá thành!";
                                });
                                return;
                              }

                              final finalEmoji = _emojiController.text.trim().isEmpty ? "🍒" : _emojiController.text.trim();

                              if (editingItem == null) {
                                final newItem = MenuItem(
                                  id: "m_${DateTime.now().millisecondsSinceEpoch}",
                                  name: _nameController.text.trim(),
                                  vietnameseName: _vnNameController.text.trim(),
                                  price: price,
                                  description: _descController.text.trim(),
                                  emoji: finalEmoji,
                                  category: _selectedCategory,
                                  isAvailable: _itemIsAvailable,
                                );
                                widget.onCreateMenuItem(newItem);
                              } else {
                                final updatedItem = editingItem.copyWith(
                                  name: _nameController.text.trim(),
                                  vietnameseName: _vnNameController.text.trim(),
                                  price: price,
                                  description: _descController.text.trim(),
                                  emoji: finalEmoji,
                                  category: _selectedCategory,
                                  isAvailable: _itemIsAvailable,
                                );
                                widget.onUpdateMenuItem(updatedItem);
                              }
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AromaColors.coffeePrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text("Hoàn tất", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AromaColors.coffeeTextSub),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13, color: AromaColors.coffeeTextDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AromaColors.coffeeCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AromaColors.coffeeCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AromaColors.coffeePrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AromaColors.coffeeBackground,
      appBar: AppBar(
        title: const Text(
          "Staff Dashboard",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: AromaColors.coffeeDarkAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          ElevatedButton.icon(
            onPressed: widget.onBackToGateway,
            style: ElevatedButton.styleFrom(
              backgroundColor: AromaColors.coffeePrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.logout, size: 14),
            label: const Text("Thoát", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: Column(
        children: [
          // Row of subtab controls
          Container(
            color: AromaColors.coffeeDarkAccent,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Row(
              children: [
                _buildSubTabButton("orders", "🔔 Orders Queue",),
                _buildSubTabButton("menu", "⚙️ Menu Editor"),
                _buildSubTabButton("tables", "🏢 Tables Visual"),
              ],
            ),
          ),

          // Main display of the Workspace
          Expanded(child: _buildWorkspaceArea()),
        ],
      ),
    );
  }

  Widget _buildSubTabButton(String tabId, String label) {
    final isSelected = tabId == activeStaffSubTab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            activeStaffSubTab = tabId;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.Center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? AromaColors.coffeeTextDark : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkspaceArea() {
    switch (activeStaffSubTab) {
      case "orders":
        return _buildOrdersWorkspace();
      case "menu":
        return _buildMenuWorkspace();
      case "tables":
        return _buildTablesWorkspace();
      default:
        return const SizedBox();
    }
  }

  // 1. ORDERS WORKSPACE BOARD
  Widget _buildOrdersWorkspace() {
    final currentOrders = widget.orderQueue.reversed.toList();
    return currentOrders.isEmpty
        ? _buildEmptyState("📋", "Đang chờ khách quét QR và gọi món mộc mạc...")
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: currentOrders.length,
            itemBuilder: (context, idx) {
              final order = currentOrders[idx];
              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AromaColors.coffeeCardBorder),
                ),
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AromaColors.coffeePrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                child: Text(
                                  order.tableLabel,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Mã: ${order.id}",
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AromaColors.coffeeTextDark),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: order.status.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Text(
                              order.status.label,
                              style: TextStyle(color: order.status.color, fontSize: 10, fontWeight: FontWeight.black),
                            ),
                          )
                        ],
                      ),
                      const Divider(height: 24, color: AromaColors.coffeeCardBorder),

                      // Order items list details
                      ...order.items.map((cartItem) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              Text(cartItem.menuItem.emoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${cartItem.menuItem.name} (${cartItem.menuItem.vietnameseName})",
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AromaColors.coffeeTextDark),
                                ),
                              ),
                              Text(
                                "x${cartItem.quantity}",
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AromaColors.coffeePrimary),
                              ),
                            ],
                          ),
                        );
                      }),

                      if (order.note.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AromaColors.coffeeSecondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "💬 Note: ${order.note}",
                            style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: AromaColors.coffeeTextDark),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Order Actions status transitions
                      Row(
                        children: [
                          if (order.status == OrderStatus.pending)
                            _buildActionButton(
                              label: "TIẾP NHẬN BẾP CHẾ BIẾN",
                              color: AromaColors.coffeeGold,
                              icon: Icons.outdoor_grill,
                              onTap: () => widget.onUpdateOrderStatus(order.id, OrderStatus.preparing),
                            ),
                          if (order.status == OrderStatus.preparing)
                            _buildActionButton(
                              label: "BÁO HOÀN THÀNH MÓN",
                              color: AromaColors.successGreen,
                              icon: Icons.check_circle,
                              onTap: () => widget.onUpdateOrderStatus(order.id, OrderStatus.ready),
                            ),
                          if (order.status == OrderStatus.ready)
                            _buildActionButton(
                              label: "THANH TOÁN HÓA ĐƠN",
                              color: AromaColors.coffeePrimary,
                              icon: Icons.monetization_on,
                              onTap: () => widget.onUpdateOrderStatus(order.id, OrderStatus.paid),
                            ),
                          if (order.status == OrderStatus.paid)
                            const Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.done_all, color: AromaColors.coffeeTextSub, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    "Đơn hàng hoàn tất đã thanh toán!",
                                    style: TextStyle(color: AromaColors.coffeeTextSub, fontSize: 11, fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required IconData icon,
    required Function() onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 38,
        child: ElevatedButton.icon(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: Icon(icon, color: Colors.white, size: 16),
          label: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // 2. MENU CRUD WORKSPACE WITH DETAILED POPUPS AND TOGGLE Availability
  Widget _buildMenuWorkspace() {
    return Column(
      children: [
        // Sub-info bar with total items and "+ Add item" trigger
        Container(
          color: AromaColors.coffeeSecondary.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Đồng bộ trực tuyến • ${widget.menuItems.length} Món",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AromaColors.coffeeTextSub),
              ),
              ElevatedButton.icon(
                onPressed: () => _showItemDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AromaColors.coffeePrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                icon: const Icon(Icons.add, size: 14, color: Colors.white),
                label: const Text(
                  "Thêm Món",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        // List display of Menu Creator
        Expanded(
          child: widget.menuItems.isEmpty
              ? _buildEmptyState("🥗", "Không tồn tại món bếp nào. Thêm ngay!")
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: widget.menuItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, idx) {
                    final item = widget.menuItems[idx];
                    return Card(
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AromaColors.coffeeCardBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AromaColors.coffeeSecondary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.Center,
                              child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AromaColors.coffeeTextDark,
                                    ),
                                  ),
                                  Text(
                                    item.vietnameseName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AromaColors.coffeeSecondary.withOpacity(0.4),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.category,
                                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AromaColors.coffeeTextDark),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "\$${item.price.toStringAsFixed(2)}",
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AromaColors.coffeePrimary),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                // Update action
                                IconButton(
                                  onPressed: () => _showItemDialog(item),
                                  icon: const Icon(Icons.edit, color: AromaColors.coffeePrimary, size: 18),
                                ),

                                // Delete action
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Xác nhận xóa?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                        content: Text("Bạn có chắc chắn muốn xóa '${item.name}' không?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("Hủy"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              widget.onDeleteMenuItem(item.id);
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text("Đã xóa món ${item.name}"),
                                                  backgroundColor: AromaColors.errorColor,
                                                ),
                                              );
                                            },
                                            child: const Text("XÓA", style: TextStyle(color: AromaColors.errorColor)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.delete, color: AromaColors.errorColor, size: 18),
                                ),

                                const SizedBox(width: 4),

                                // Enable/Disable availability toggle Switch
                                Column(
                                  children: [
                                    Transform.scale(
                                      scale: 0.8,
                                      child: Switch(
                                        value: item.isAvailable,
                                        onChanged: (_) => widget.onToggleAvailability(item.id),
                                        activeColor: AromaColors.successGreen,
                                      ),
                                    ),
                                    Text(
                                      item.isAvailable ? "BÁN" : "HẾT",
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.black,
                                        color: item.isAvailable ? AromaColors.successGreen : AromaColors.errorColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // 3. TABLES VISUAL GRAPH
  Widget _buildTablesWorkspace() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sơ Đồ Phòng Bàn Thời Gian Thực",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AromaColors.coffeeTextDark),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: systemTables.map((tbl) {
                // Find if table has an active order
                final hasActiveOrder = widget.orderQueue.any((ord) => ord.tableId == tbl.id && ord.status != OrderStatus.paid);
                final statusColor = hasActiveOrder ? AromaColors.coffeeGold : AromaColors.successGreen;

                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: statusColor.withOpacity(0.5), width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tbl.label,
                              style: const TextStyle(fontWeight: FontWeight.black, fontSize: 13, color: AromaColors.coffeeTextDark),
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                            ),
                          ],
                        ),
                        Text(
                          tbl.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.Center,
                          child: Text(
                            hasActiveOrder ? "ĐANG HOẠT ĐỘNG" : "TRỐNG SẴN SÀNG",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.black,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String emoji, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AromaColors.coffeeTextSub, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
