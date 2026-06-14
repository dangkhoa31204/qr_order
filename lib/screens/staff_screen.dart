import 'dart:io';
import 'package:flutter/material.dart';
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
  final Function(TableModel) onUpdateTable;
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
    required this.onUpdateTable,
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
            Text(
              widget.currentUser?.role == AccountRole.admin ? "Admin Dashboard" : "Staff Dashboard",
              style: const TextStyle(
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
                      ? AromaColors.coffeeGold.withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.2),
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
            onAddTable: (_) {},
            onUpdateTable: widget.onUpdateTable,
            onDeleteTable: (_) {},
            onExportQrCode: widget.onExportQrCode,
            isStaff: true,
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
                    color: order.status.color.withValues(alpha: 0.12),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    if (it.note != null && it.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 24.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.subdirectory_arrow_right,
                              size: 14,
                              color: AromaColors.coffeeTextSub,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                it.note!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: AromaColors.coffeeTextSub,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }),

            if (order.note?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AromaColors.coffeeCardLightBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AromaColors.coffeeCardBorder.withValues(alpha: 0.5),
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

            // Controls (Toggle availability)
            Row(
              children: [
                // Availability toggle
                Switch(
                  value: item.isAvailable,
                  onChanged: (valu) => widget.onToggleAvailability(item.menuItemId),
                  activeThumbColor: AromaColors.coffeePrimary,
                  activeTrackColor: AromaColors.coffeeSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
