import 'dart:io';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/item_model.dart';

class CustomerScreen extends StatefulWidget {
  final Map<int, int> cart;
  final Function(MenuItem) onAddCart;
  final Function(MenuItem) onRemoveCart;
  final VoidCallback onBackToGateway;
  final int selectedTableId;
  final String selectedTableLabel;
  final List<MenuItem> menuItems;
  final OrderModel? activeOrder;
  final Function(int, List<OrderItemModel>, String) onSubmitOrder;
  final VoidCallback onCancelActiveOrder;

  const CustomerScreen({
    super.key,
    required this.cart,
    required this.onAddCart,
    required this.onRemoveCart,
    required this.onBackToGateway,
    required this.selectedTableId,
    required this.selectedTableLabel,
    required this.menuItems,
    required this.activeOrder,
    required this.onSubmitOrder,
    required this.onCancelActiveOrder,
  });

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  CategoryType? _activeCategory; // null means 'All'
  String _searchQuery = "";
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Totals calculation
    double subtotal = 0.0;
    int totalItemsCount = 0;
    List<OrderItemModel> cartItems = [];

    widget.cart.forEach((itemId, qty) {
      if (qty > 0) {
        final item = widget.menuItems.firstWhere(
          (it) => it.menuItemId == itemId,
          orElse: () => initialMenuItems.first,
        );
        subtotal += item.price * qty;
        totalItemsCount += qty;
        cartItems.add(OrderItemModel(
          menuItemId: item.menuItemId,
          quantity: qty,
          unitPrice: item.price,
          menuItemRef: item,
        ));
      }
    });

    double taxAndService = subtotal * 0.10; // 10% tax/service
    double totalAmount = subtotal + taxAndService;

    // Menu filtering
    final filteredItems = widget.menuItems.where((item) {
      final matchesCategory =
          _activeCategory == null || item.category == _activeCategory;
      final matchesSearch =
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AromaColors.coffeeBackground,
      bottomNavigationBar: _buildBottomStatusBars(
        totalItemsCount,
        subtotal,
        cartItems,
        taxAndService,
        totalAmount,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Premium Elegant Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AromaColors.coffeePrimary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "☕",
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Aroma Bistro",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AromaColors.coffeeTextDark,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AromaColors.successGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.selectedTableLabel,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AromaColors.coffeeTextSub,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: widget.onBackToGateway,
                        icon: const Icon(
                          Icons.refresh,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Đổi Bàn",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AromaColors.coffeePrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          minimumSize: const Size(0, 42),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Horizontal Custom Categories Row
            SizedBox(
              height: 48,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: CategoryType.values.length + 1,
                itemBuilder: (context, index) {
                  CategoryType? cat = index == 0 ? null : CategoryType.values[index - 1];
                  final isSelected = cat == _activeCategory;

                  String displayLabel = cat == null ? "Tất cả" : "${cat.label} ${cat.icon}";

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        displayLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isSelected
                              ? Colors.white
                              : AromaColors.coffeeTextSub,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _activeCategory = cat;
                          });
                        }
                      },
                      selectedColor: AromaColors.coffeePrimary,
                      backgroundColor: AromaColors.coffeeSecondary,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                style: const TextStyle(
                  fontSize: 13,
                  color: AromaColors.coffeeTextDark,
                ),
                decoration: InputDecoration(
                  hintText: "Tìm món ăn, đồ uống thơm phức...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AromaColors.coffeePrimary,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(
                      color: AromaColors.coffeeCardBorder,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(
                      color: AromaColors.coffeePrimary,
                    ),
                  ),
                ),
              ),
            ),

            // Grid / List items list loading
            Expanded(
              child: filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("☕", style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty
                                ? "Không tìm thấy món ăn phù hợp"
                                : "Menu rỗng!",
                            style: const TextStyle(
                              color: AromaColors.coffeeTextSub,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final count = widget.cart[item.menuItemId] ?? 0;
                        return _buildMenuItemCard(item, count);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage(String path) {
    // Kiểm tra nếu là file local (đường dẫn bắt đầu bằng / hoặc chứa :\)
    final isLocalFile = !path.startsWith('http') && (path.startsWith('/') || path.contains(':\\'));
    if (isLocalFile && File(path).existsSync()) {
      return Image.file(
        File(path),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    } else if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 32, color: Colors.grey),
      );
    }
    return const Icon(Icons.image_not_supported, size: 32, color: Colors.grey);
  }

  Widget _buildMenuItemCard(MenuItem item, int count) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AromaColors.coffeeCardBorder),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            // Left Emoji/Image container
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AromaColors.coffeeCardLightBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: _buildItemImage(item.imageUrl!),
                        )
                      : Text(item.categoryIcon, style: const TextStyle(fontSize: 38)),
                ),
                if (!item.isAvailable)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "HẾT HÀNG",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Description column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AromaColors.coffeeTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.description != null && item.description!.isNotEmpty)
                    Text(
                      item.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        height: 1.3,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        formatVND(item.price),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AromaColors.coffeePrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Actions (Add to cart)
            if (!item.isAvailable)
              ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AromaColors.coffeeSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 36),
                ),
                child: const Text(
                  "Hết",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              )
            else if (count == 0)
              ElevatedButton(
                onPressed: () => widget.onAddCart(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AromaColors.coffeeCardLightBg,
                  foregroundColor: AromaColors.coffeePrimary,
                  elevation: 0,
                  side: const BorderSide(color: AromaColors.coffeeCardBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 36),
                ),
                child: const Text(
                  "+ THÊM",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AromaColors.coffeePrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => widget.onRemoveCart(item),
                      icon: const Icon(
                        Icons.remove,
                        size: 14,
                        color: Colors.white,
                      ),
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    Text(
                      "$count",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    IconButton(
                      onPressed: () => widget.onAddCart(item),
                      icon: const Icon(
                        Icons.add,
                        size: 14,
                        color: Colors.white,
                      ),
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomStatusBars(
    int totalItems,
    double subtotal,
    List<OrderItemModel> cartItems,
    double tax,
    double total,
  ) {
    final showCart = totalItems > 0;
    final showTracker = widget.activeOrder != null &&
        widget.activeOrder!.status != OrderStatus.paid && widget.activeOrder!.status != OrderStatus.cancelled;

    if (!showCart && !showTracker) return null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Real-time active tracking sticky button
        if (showTracker)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Card(
              elevation: 4,
              color: AromaColors.coffeeTextDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ListTile(
                onTap: () => _showOrderTrackerDialog(context),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AromaColors.coffeeGold,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text("🍳", style: TextStyle(fontSize: 22)),
                ),
                title: Row(
                  children: [
                    Text(
                      "${widget.activeOrder!.tableLabel} • ${widget.activeOrder!.status.labelVi}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                subtitle: const Text(
                  "Chạm để xem chi tiết tình trạng đơn",
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),

        // 2. Shopping cart bottom floating bar
        if (showCart)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: ElevatedButton(
              onPressed: () => _showCartBottomSheet(
                context,
                cartItems,
                subtotal,
                tax,
                total,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AromaColors.coffeePrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AromaColors.coffeeGold,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "$totalItems",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AromaColors.coffeePrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Xem giỏ hàng",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formatVND(subtotal),
                    style: const TextStyle(
                      color: AromaColors.coffeeGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showCartBottomSheet(
    BuildContext context,
    List<OrderItemModel> items,
    double subtotal,
    double tax,
    double total,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            double curSubtotal = 0.0;
            items.forEach((it) {
              curSubtotal += it.unitPrice * it.quantity;
            });
            double curTax = curSubtotal * 0.10;
            double curTotal = curSubtotal + curTax;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 24,
                right: 24,
              ),
              child: MainCartSheetContent(
                items: items,
                subtotal: curSubtotal,
                tax: curTax,
                total: curTotal,
                tableLabel: widget.selectedTableLabel,
                noteController: _noteController,
                onIncrease: (item) {
                  if (item.menuItemRef != null) {
                    widget.onAddCart(item.menuItemRef!);
                    // Refresh modal local state
                    final idx = items.indexWhere(
                      (it) => it.menuItemId == item.menuItemId,
                    );
                    if (idx != -1) {
                      setSheetState(() {
                        items[idx] = items[idx].copyWith(
                          quantity: items[idx].quantity + 1,
                        );
                      });
                    }
                    setState(() {}); // refresh outer screen
                  }
                },
                onDecrease: (item) {
                  if (item.menuItemRef != null) {
                    widget.onRemoveCart(item.menuItemRef!);
                    final idx = items.indexWhere(
                      (it) => it.menuItemId == item.menuItemId,
                    );
                    if (idx != -1) {
                      setSheetState(() {
                        if (items[idx].quantity > 1) {
                          items[idx] = items[idx].copyWith(
                            quantity: items[idx].quantity - 1,
                          );
                        } else {
                          items.removeAt(idx);
                        }
                      });
                    }
                    setState(() {});
                  }
                },
                onCheckout: () {
                  if (items.isNotEmpty) {
                    widget.onSubmitOrder(
                      widget.selectedTableId,
                      items,
                      _noteController.text,
                    );
                    _noteController.clear();
                    Navigator.pop(context);
                    // Automatically open order progress path
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _showOrderTrackerDialog(context);
                    });
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showOrderTrackerDialog(BuildContext context) {
    if (widget.activeOrder == null) return;
    showDialog(
      context: context,
      builder: (context) {
        return OrderTrackerDialog(
          order: widget.activeOrder!,
          onCancel: () {
            widget.onCancelActiveOrder();
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

// Shopping cart visual items card
class MainCartSheetContent extends StatelessWidget {
  final List<OrderItemModel> items;
  final double subtotal;
  final double tax;
  final double total;
  final String tableLabel;
  final TextEditingController noteController;
  final Function(OrderItemModel) onIncrease;
  final Function(OrderItemModel) onDecrease;
  final VoidCallback onCheckout;

  const MainCartSheetContent({
    super.key,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.tableLabel,
    required this.noteController,
    required this.onIncrease,
    required this.onDecrease,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Giỏ Hàng Gọi Món",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AromaColors.coffeeTextDark,
                  ),
                ),
                Text(
                  tableLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AromaColors.coffeeTextSub,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const SizedBox(
            height: 120,
            child: Center(
              child: Text(
                "Giỏ hàng của bạn đang rỗng",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(
                  color: AromaColors.coffeeCardBorder,
                  height: 16,
                ),
                itemBuilder: (context, index) {
                  final it = items[index];
                  return Row(
                    children: [
                      Text(
                        it.menuItemRef?.categoryIcon ?? '🍽️',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              it.menuItemRef?.name ?? 'Món ăn',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AromaColors.coffeeTextDark,
                              ),
                            ),
                            Text(
                              formatVND(it.unitPrice * it.quantity),
                              style: const TextStyle(
                                color: AromaColors.coffeePrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AromaColors.coffeeSecondary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => onDecrease(it),
                              icon: const Icon(
                                Icons.remove,
                                size: 12,
                                color: AromaColors.coffeePrimary,
                              ),
                              constraints: const BoxConstraints.tightFor(
                                width: 24,
                                height: 24,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            Text(
                              "${it.quantity}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AromaColors.coffeePrimary,
                              ),
                            ),
                            IconButton(
                              onPressed: () => onIncrease(it),
                              icon: const Icon(
                                Icons.add,
                                size: 12,
                                color: AromaColors.coffeePrimary,
                              ),
                              constraints: const BoxConstraints.tightFor(
                                width: 24,
                                height: 24,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        const SizedBox(height: 12),
        const Text(
          "Ghi chú cho bếp (không hành, ít đường, đá riêng...):",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AromaColors.coffeePrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: noteController,
          maxLines: 2,
          style: const TextStyle(
            fontSize: 12,
            color: AromaColors.coffeeTextDark,
          ),
          decoration: InputDecoration(
            hintText: "Mời bạn nhập lưu ý...",
            filled: true,
            fillColor: AromaColors.coffeeCardLightBg,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AromaColors.coffeeCardBorder),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AromaColors.coffeeCardLightBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildBillRow("Tạm tính:", formatVND(subtotal)),
              const SizedBox(height: 6),
              _buildBillRow(
                "Thuế VAT & Phí DV (10%):",
                formatVND(tax),
              ),
              const Divider(height: 16),
              _buildBillRow(
                "TỔNG CỘNG:",
                formatVND(total),
                isTotal: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: items.isEmpty ? null : onCheckout,
          style: ElevatedButton.styleFrom(
            backgroundColor: AromaColors.coffeePrimary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text(
            "GỬI YÊU CẦU GỌI MÓN MỚI",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBillRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 13 : 11,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AromaColors.coffeeTextDark : Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 15 : 12,
            fontWeight: FontWeight.bold,
            color: isTotal
                ? AromaColors.coffeePrimary
                : AromaColors.coffeeTextDark,
          ),
        ),
      ],
    );
  }
}

// Dialog displaying step-by-step cooking progress path
class OrderTrackerDialog extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onCancel;

  const OrderTrackerDialog({
    super.key,
    required this.order,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    // Stepper index derivation
    int currentStep = 0;
    if (order.status == OrderStatus.preparing) currentStep = 1;
    if (order.status == OrderStatus.ready) currentStep = 2;
    if (order.status == OrderStatus.paid) currentStep = 3;
    if (order.status == OrderStatus.cancelled) currentStep = -1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AromaColors.coffeeBackground,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tiến Độ Đơn Hàng",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AromaColors.coffeeTextDark,
                        ),
                      ),
                      Text(
                        "Mã đơn: ${order.orderId}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: AromaColors.coffeeTextSub,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Animated Status Badge
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: order.status.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(order.status == OrderStatus.cancelled ? "❌" : "🔥", style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      order.status.labelVi.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: order.status.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (currentStep >= 0) ...[
                // Interactive Step Stepper Graphics
                _buildProgressRow(
                  0,
                  "GỬI ĐƠN HÀNG CHỜ DUYỆT",
                  "Chờ bếp xác nhận nấu",
                  currentStep >= 0,
                ),
                _buildConnectorLine(currentStep >= 1),
                _buildProgressRow(
                  1,
                  "BẾP ĐANG CHẾ BIẾN MÓN",
                  "Món ăn đang được nấu nướng",
                  currentStep >= 1,
                ),
                _buildConnectorLine(currentStep >= 2),
                _buildProgressRow(
                  2,
                  "BÀN ĂN HOÀN THÀNH MÓN",
                  "Mời bạn thưởng thức tại bàn",
                  currentStep >= 2,
                ),
                _buildConnectorLine(currentStep >= 3),
                _buildProgressRow(
                  3,
                  "ĐÃ THANH TOÁN XONG",
                  "Chúc quý khách ngày tốt lành",
                  currentStep >= 3,
                ),
              ] else ...[
                const Center(
                  child: Text(
                    "Đơn hàng này đã bị hủy.",
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                )
              ],

              const SizedBox(height: 24),
              const Text(
                "CHI TIẾT MÓN ORDER:",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AromaColors.coffeePrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Ordered items breakdown
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AromaColors.coffeeCardBorder.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    ...order.items.map((it) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${it.menuItemRef?.categoryIcon ?? '🍽️'} ${it.menuItemRef?.name ?? 'Món ăn'} x${it.quantity}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: AromaColors.coffeeTextDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              formatVND(it.unitPrice * it.quantity),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AromaColors.coffeePrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    if (order.note?.isNotEmpty == true) ...[
                      const Divider(),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AromaColors.coffeeCardLightBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Lưu ý: ${order.note}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AromaColors.coffeeTextSub,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Cancel button only if Pending
              if (order.status == OrderStatus.pending)
                TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: Colors.redAccent,
                    size: 14,
                  ),
                  label: const Text(
                    "HỦY GỌI MÓN (KHI CHỜ DUYỆT)",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRow(
    int step,
    String title,
    String subtitle,
    bool isDone,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone
                ? AromaColors.successGreen
                : Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  "${step + 1}",
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDone ? AromaColors.coffeeTextDark : Colors.grey,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: AromaColors.coffeeTextSub,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectorLine(bool isDone) {
    return Container(
      width: 2,
      height: 12,
      margin: const EdgeInsets.only(left: 11),
      color: isDone ? AromaColors.successGreen : Colors.grey.withOpacity(0.3),
    );
  }
}
