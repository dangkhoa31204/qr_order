import 'dart:async';
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
  final Function(int, int, OrderItemStatus) onUpdateOrderItemStatus;
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
    required this.onUpdateOrderItemStatus,
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
  VoidCallback? _closeQrDialog;

  @override
  void didUpdateWidget(StaffScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_activeQrOrderId != null) {
      final order = widget.orders.firstWhere(
        (o) => o.orderId == _activeQrOrderId,
        orElse: () => OrderModel(orderId: -1, tableId: -1),
      );
      if (order.orderId == -1 || order.status == OrderStatus.paid) {
        // Đóng dialog bằng callback đã lưu (context chính xác)
        _closeQrDialog?.call();
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
              style: AromaTypography.h3.copyWith(color: AromaColors.coffeeSurface),
            ),
            if (widget.currentUser != null) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.currentUser!.role == AccountRole.admin
                      ? AromaColors.coffeeGold
                      : AromaColors.coffeeSurface.withOpacity(0.2),
                  borderRadius: AromaStyles.radiusSmall,
                ),
                child: Text(
                  widget.currentUser!.role.label.toUpperCase(),
                  style: AromaTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: widget.currentUser!.role == AccountRole.admin
                        ? AromaColors.coffeeTextDark
                        : AromaColors.coffeeSurface,
                    fontSize: 10,
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
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  widget.currentUser!.username,
                  style: AromaTypography.bodyMedium.copyWith(color: AromaColors.coffeeSurface.withOpacity(0.8)),
                ),
              ),
            ),
          IconButton(
            onPressed: widget.onBackToGateway,
            icon: const Icon(Icons.logout, color: AromaColors.coffeeSurface, size: 22),
            tooltip: "Đăng xuất",
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AromaColors.coffeeGold,
          unselectedLabelColor: AromaColors.coffeeSurface.withOpacity(0.6),
          indicatorColor: AromaColors.coffeeGold,
          indicatorWeight: 4,
          labelStyle: AromaTypography.buttonText.copyWith(fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long_rounded), text: "ĐƠN ORDER"),
            Tab(icon: Icon(Icons.restaurant_menu_rounded), text: "MENU"),
            Tab(icon: Icon(Icons.table_restaurant_rounded), text: "BÀN"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersTab(activeOrders),
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
  Widget _buildOrdersTab(List<OrderModel> active) {
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
                    "DANH SÁCH ĐƠN HÀNG (${active.length})",
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
          child: active.isEmpty
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
                        "Không có đơn hàng hoạt động!",
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

    final bool allItemsServed = order.items.isNotEmpty && order.items.every((it) => it.status == OrderItemStatus.served);

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
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
                      Text(
                        "Mã: ${order.orderId}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AromaColors.coffeeTextDark,
                        ),
                      ),
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
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
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
                    if (order.status != OrderStatus.paid &&
                        order.status != OrderStatus.cancelled &&
                        order.items.any((i) => i.status == OrderItemStatus.pending)) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AromaColors.errorRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.new_releases, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              "CÓ MÓN MỚI",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
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
                                    ? const Icon(Icons.fastfood, size: 16, color: AromaColors.coffeeTextSub)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "$itemName   x${it.quantity}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AromaColors.coffeeTextDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (order.status != OrderStatus.paid && order.status != OrderStatus.cancelled)
                                          Container(
                                            height: 24,
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                            decoration: BoxDecoration(
                                              color: it.status.color.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: it.status.color.withOpacity(0.3)),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<OrderItemStatus>(
                                                value: it.status,
                                                icon: Icon(Icons.arrow_drop_down, size: 14, color: it.status.color),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: it.status.color,
                                                ),
                                                isDense: true,
                                                dropdownColor: Colors.white,
                                                onChanged: (OrderItemStatus? newValue) {
                                                  if (newValue != null && newValue != it.status) {
                                                    widget.onUpdateOrderItemStatus(order.orderId, it.orderItemId ?? 0, newValue);
                                                  }
                                                },
                                                items: OrderItemStatus.values.map((st) {
                                                  return DropdownMenuItem(
                                                    value: st,
                                                    child: Text(st.labelVi),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: it.status.color.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              it.status.labelVi,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: it.status.color,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('HH:mm').format(it.createdAt.toLocal()),
                                          style: const TextStyle(fontSize: 10, color: AromaColors.coffeeTextSub),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
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
                  onPressed: allItemsServed ? () => _showSepayQrDialog(order) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: allItemsServed ? AromaColors.preparingBlue : Colors.grey.shade300,
                    foregroundColor: allItemsServed ? Colors.white : Colors.grey.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 44),
                    elevation: 0,
                  ),
                  child: const Text(
                    "💵 THANH TOÁN QR",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                if (!allItemsServed) ...[
                  const SizedBox(height: 6),
                  const Text(
                    "⚠️ Chưa thể tạo mã QR. Còn món chưa phục vụ xong.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AromaColors.errorRed,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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

  void _showPaymentSuccessScreen(OrderModel order) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'payment_success',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox(),
      transitionBuilder: (ctx, anim1, anim2, _) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.elasticOut);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: anim1,
            child: _PaymentSuccessDialog(order: order),
          ),
        );
      },
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

    // Dùng dialogContext để pop đúng context của dialog
    BuildContext? dialogContext;

    // Flag chống double-trigger: cả SignalR lẫn polling đều gọi closeDialogAndNotify
    // biến này đảm bảo success screen chỉ hiển thị đúng 1 lần
    bool _successShown = false;

    void closeDialogAndNotify() {
      if (_successShown) return; // Ngăn double-trigger
      _successShown = true;

      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }
      if (mounted) {
        setState(() => _activeQrOrderId = null);
        _closeQrDialog = null;
        // Hiện màn hình thanh toán thành công
        _showPaymentSuccessScreen(order);
      }
    }

    Timer? pollingTimer;
    Timer? countdownTimer;
    int secondsLeft = 15 * 60; // 15 phút

    // Bắt đầu tự động kiểm tra trạng thái đơn hàng mỗi 3 giây phòng trường hợp SignalR lỗi/chậm
    pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_activeQrOrderId == null) {
        timer.cancel();
        return;
      }
      try {
        final currentOrder = await ApiService.fetchOrderById(order.orderId);
        debugPrint('📡 Polling order ${order.orderId}: status=${currentOrder?.status} (${currentOrder?.status.value})');
        if (currentOrder != null && currentOrder.status == OrderStatus.paid) {
          timer.cancel();
          // Đóng dialog trực tiếp từ polling timer với context chính xác
          widget.onUpdateOrderStatus(order.orderId, OrderStatus.paid);
          closeDialogAndNotify();
        }
      } catch (e) {
        debugPrint("❌ Error polling order status: $e");
      }
    });

    // Lưu callback đóng dialog để didUpdateWidget cũng có thể gọi (SignalR path)
    _closeQrDialog = closeDialogAndNotify;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        dialogContext = ctx;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Khởi chạy bộ đếm ngược
            if (countdownTimer == null) {
              countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                if (secondsLeft > 0) {
                  setDialogState(() {
                    secondsLeft--;
                  });
                } else {
                  timer.cancel();
                  if (Navigator.canPop(ctx)) {
                    Navigator.pop(ctx);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mã thanh toán đã hết hạn sau 15 phút"),
                      backgroundColor: AromaColors.errorRed,
                    ),
                  );
                }
              });
            }

            final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
            final seconds = (secondsLeft % 60).toString().padLeft(2, '0');

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
                          "Thanh toán chuyển khoản QR",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AromaColors.coffeeTextDark,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(ctx),
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
                    
                    const SizedBox(height: 8),
                    Text(
                      "Hiệu lực còn lại: $minutes:$seconds",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AromaColors.errorRed,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
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
                    // Cập nhật local ngay lập tức để UI đóng và bàn trống tức thì
                    widget.onUpdateOrderStatus(order.orderId, OrderStatus.paid);
                    closeDialogAndNotify();

                    // Đồng thời gửi webhook lên backend ở chế độ background để cập nhật cơ sở dữ liệu trên server
                    unawaited(Future(() async {
                      try {
                        final url = "${ApiService.baseUrl}/api/payments/sepay-webhook";
                        await http.post(
                          Uri.parse(url),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode({
                            "transferAmount": order.totalAmount,
                            "transferType": "in",
                            "transactionContent": "AROMA${order.orderId}",
                            "referenceNumber": "TEST_${DateTime.now().millisecondsSinceEpoch}"
                          }),
                        ).timeout(const Duration(seconds: 4));
                      } catch (e) {
                        debugPrint("Background webhook simulation error: $e");
                      }
                    }));
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
      _closeQrDialog = null;
      dialogContext = null;
      pollingTimer?.cancel();
      countdownTimer?.cancel();
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

/// Dialog thanh toán thành công — hiển thị sau khi SeePay xác nhận
class _PaymentSuccessDialog extends StatefulWidget {
  final OrderModel order;
  const _PaymentSuccessDialog({required this.order});

  @override
  State<_PaymentSuccessDialog> createState() => _PaymentSuccessDialogState();
}

class _PaymentSuccessDialogState extends State<_PaymentSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _pulseController;
  late Animation<double> _checkAnim;
  late Animation<double> _pulseAnim;
  Timer? _autoCloseTimer;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _checkAnim = CurvedAnimation(parent: _checkController, curve: Curves.easeOutBack);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkController.forward();

    // Đếm ngược và tự đóng
    _autoCloseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _pulseController.dispose();
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  String get _formattedAmount {
    final amount = widget.order.totalAmount;
    final formatted = amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '$formatted đ';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade900.withValues(alpha: 0.5),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Checkmark animation
              ScaleTransition(
                scale: _pulseAnim,
                child: ScaleTransition(
                  scale: _checkAnim,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Thanh toán thành công!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Đơn hàng #${widget.order.orderId} · ${widget.order.tableLabel}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Amount box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: Column(
                  children: [
                    Text(
                      'SỐ TIỀN ĐÃ THU',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.65),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formattedAmount,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SeePay badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, size: 14, color: Colors.white.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  Text(
                    'Xác nhận qua SeePay · TPBank',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Close button + countdown
              GestureDetector(
                onTap: () { if (Navigator.canPop(context)) Navigator.pop(context); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    'Đóng ($_countdown)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
