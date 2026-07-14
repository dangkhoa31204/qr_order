import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/item_model.dart';
import '../models/account_model.dart';
import '../services/api_service.dart';
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
  final VoidCallback onRefreshData;

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
    required this.onRefreshData,
  });

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _activeQrOrderId;

  @override
  void didUpdateWidget(StaffScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_activeQrOrderId != null) {
      final order = widget.orders.firstWhere(
        (o) => o.orderId == _activeQrOrderId,
        orElse: () => OrderModel(orderId: -1, tableId: -1),
      );
      if (order.orderId == -1 || order.status == OrderStatus.paid) {
        _activeQrOrderId = null;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Đơn hàng đã được thanh toán thành công qua Sepay!"),
            backgroundColor: AromaColors.successGreen,
          ),
        );
      }
    }
  }

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
            onRefreshData: widget.onRefreshData,
          ),
        ],
      ),
    );
  }

  // --- TAB 1: Real-time Order management ---
  Widget _buildOrdersTab(List<OrderModel> active, List<OrderModel> history) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "DANH SÁCH ĐƠN HÀNG (${active.length + history.length})",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AromaColors.coffeeTextSub,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: widget.onRefreshData,
                    icon: const Icon(Icons.refresh, size: 18, color: AromaColors.coffeePrimary),
                    tooltip: "Tải lại",
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: active.isEmpty && history.isEmpty
              ? Center(
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
                )
              : ListView(
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
                ),
        ),
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
                    const SizedBox(width: 8),
                    Text(
                      "|  ${DateFormat('HH:mm  dd/MM/yyyy').format(order.createdAt.toLocal())}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: AromaColors.coffeeTextSub,
                        fontWeight: FontWeight.w500,
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
              // Find matching menuItem from widget.menuItems to display categoryIcon and name
              final matchedMenuItem = widget.menuItems.firstWhere(
                (m) => m.menuItemId == it.menuItemId,
                orElse: () => MenuItem(
                  menuItemId: it.menuItemId,
                  name: it.menuItemName ?? '',
                  price: it.unitPrice,
                  category: CategoryType.other,
                ),
              );

              final String itemName = (matchedMenuItem.name.isNotEmpty)
                  ? matchedMenuItem.name
                  : (it.menuItemName ?? 'Món ăn (ID: ${it.menuItemId})');

              // Setup image provider for order item photo
              ImageProvider? itemImageProvider;
              if (matchedMenuItem.imageUrl != null && matchedMenuItem.imageUrl!.isNotEmpty) {
                final path = matchedMenuItem.imageUrl!;
                final isLocalFile = !path.startsWith('http') &&
                    (path.startsWith('/') || path.contains(':\\\\') || path.contains(':/'));
                if (isLocalFile) {
                  itemImageProvider = FileImage(File(path));
                } else {
                  itemImageProvider = NetworkImage(path);
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AromaColors.coffeeCardLightBg,
                                borderRadius: BorderRadius.circular(6),
                                image: itemImageProvider != null
                                    ? DecorationImage(
                                        image: itemImageProvider,
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: itemImageProvider == null
                                  ? const Icon(Icons.fastfood, size: 14, color: AromaColors.coffeeTextSub)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "$itemName   x${it.quantity}",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AromaColors.coffeeTextDark,
                              ),
                            ),
                          ],
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
                                "Ghi chú riêng: ${it.note!}",
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
                        "Ghi chú chung: ${order.note}",
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
              if (order.status == OrderStatus.ready) ...[
                ElevatedButton(
                  onPressed: () => _showSepayQrDialog(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AromaColors.preparingBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 44),
                    elevation: 0,
                  ),
                  child: const Text(
                    "💵 THANH TOÁN QR (SEPAY)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () =>
                      widget.onUpdateOrderStatus(order.orderId, nextStatus!),
                  icon: const Icon(Icons.money, size: 16),
                  label: const Text(
                    "Xác nhận thanh toán tiền mặt (Thủ công)",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AromaColors.coffeeTextSub,
                  ),
                ),
              ] else ...[
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
              Row(
                children: [
                  Text(
                    "TỔNG CỘNG: ${widget.menuItems.length} MÓN ĂN",
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AromaColors.coffeeTextSub,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: widget.onRefreshData,
                    icon: const Icon(Icons.refresh, size: 18, color: AromaColors.coffeePrimary),
                    tooltip: "Tải lại",
                  ),
                ],
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
                  ? const Icon(Icons.fastfood, size: 28, color: AromaColors.coffeeTextSub)
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

  void _showSepayQrDialog(OrderModel order) {
    setState(() {
      _activeQrOrderId = order.orderId;
    });

    final qrUrl = "https://img.vietqr.io/image/"
        "${SepayConfig.bankId}-${SepayConfig.accountNumber}-compact2.jpg"
        "?amount=${order.totalAmount.toInt()}"
        "&addInfo=AROMA${order.orderId}"
        "&accountName=${Uri.encodeComponent(SepayConfig.accountName)}";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Thanh toán QR qua Sepay",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AromaColors.coffeeTextDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),
                
                // QR code image container
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AromaColors.coffeeCardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      qrUrl,
                      width: 240,
                      height: 240,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          width: 240,
                          height: 240,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AromaColors.coffeePrimary,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          width: 240,
                          height: 240,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, color: Colors.red, size: 40),
                                SizedBox(height: 8),
                                Text(
                                  "Không tải được mã QR",
                                  style: TextStyle(fontSize: 12, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Payment details
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AromaColors.coffeeCardLightBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AromaColors.coffeeCardBorder.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      _buildQrDetailRow("Số tiền:", formatVND(order.totalAmount), isBoldValue: true),
                      const SizedBox(height: 6),
                      _buildQrDetailRow("Nội dung:", "AROMA${order.orderId}", isBoldValue: true, isSelectable: true),
                      const SizedBox(height: 6),
                      _buildQrDetailRow("Tài khoản:", SepayConfig.accountNumber),
                      const SizedBox(height: 6),
                      _buildQrDetailRow("Ngân hàng:", SepayConfig.bankId),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Waiting message
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AromaColors.successGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Đang chờ khách thanh toán...",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Nút giả lập thanh toán phục vụ kiểm thử
                TextButton.icon(
                  onPressed: () async {
                    bool simulateLocally = false;
                    try {
                      final url = "${ApiService.baseUrl}/api/payments/sepay-webhook";
                      final response = await http.post(
                        Uri.parse(url),
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode({
                          "transferAmount": order.totalAmount,
                          "transferType": "in",
                          "transactionContent": "AROMA${order.orderId}",
                          "referenceNumber": "TEST_${DateTime.now().millisecondsSinceEpoch}"
                        }),
                      ).timeout(const Duration(seconds: 4));
                      if (response.statusCode >= 200 && response.statusCode < 300) {
                        debugPrint("✅ Giả lập webhook thành công!");
                      } else {
                        debugPrint("❌ Giả lập thất bại: ${response.statusCode} - ${response.body}");
                        simulateLocally = true;
                      }
                    } catch (e) {
                      debugPrint("❌ Lỗi mạng khi giả lập webhook: $e. Giả lập local.");
                      simulateLocally = true;
                    }

                    if (simulateLocally) {
                      widget.onUpdateOrderStatus(order.orderId, OrderStatus.paid);
                    }
                  },
                  icon: const Icon(Icons.bug_report, size: 16, color: Colors.orange),
                  label: const Text(
                    "Giả lập thanh toán thành công (Test)",
                    style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      _activeQrOrderId = null;
    });
  }

  Widget _buildQrDetailRow(String label, String value, {bool isBoldValue = false, bool isSelectable = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AromaColors.coffeeTextSub),
        ),
        isSelectable
            ? SelectableText(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
                  color: AromaColors.coffeeTextDark,
                ),
              )
            : Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
                  color: AromaColors.coffeeTextDark,
                ),
              ),
      ],
    );
  }
}
