import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/item_model.dart';
import '../widgets/mock_qr_dialog.dart';

class CustomerScreen extends StatefulWidget {
  final List<MenuItem> menuItems;
  final Function() onBackToGateway;
  final OrderModel? activeCustomerOrder;
  final Function(OrderModel) onOrderSubmitted;
  final Function() onOpenTracker;

  const CustomerScreen({
    super.key,
    required this.menuItems,
    required this.onBackToGateway,
    required this.activeCustomerOrder,
    required this.onOrderSubmitted,
    required this.onOpenTracker,
  });

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  String selectedTableId = "08";
  String selectedTableLabel = "Bàn #08";
  String searchQuery = "";
  String activeCategory = "All";

  // Local cart state
  final Map<String, CartItem> cartState = {};
  String orderNoteInput = "";

  double get subtotal {
    double total = 0.0;
    cartState.forEach((_, item) {
      total += item.menuItem.price * item.quantity;
    });
    return total;
  }

  double get serviceTax => subtotal * 0.10;
  double get totalAmount => subtotal + serviceTax;
  int get cartCount {
    int count = 0;
    cartState.forEach((_, item) {
      count += item.quantity;
    });
    return count;
  }

  void _addCart(MenuItem item) {
    setState(() {
      if (cartState.containsKey(item.id)) {
        cartState[item.id] = cartState[item.id]!.copyWith(
          quantity: cartState[item.id]!.quantity + 1,
        );
      } else {
        cartState[item.id] = CartItem(menuItem: item, quantity: 1);
      }
    });
  }

  void _removeCart(MenuItem item) {
    setState(() {
      if (cartState.containsKey(item.id)) {
        final current = cartState[item.id]!;
        if (current.quantity > 1) {
          cartState[item.id] = current.copyWith(
            quantity: current.quantity - 1,
          );
        } else {
          cartState.remove(item.id);
        }
      }
    });
  }

  void _openQrSimulation() {
    showDialog(
      context: context,
      builder: (context) => MockQrScannerDialog(
        onScanned: (tableId, tableLabel) {
          setState(() {
            selectedTableId = tableId;
            selectedTableLabel = tableLabel;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Đã chuyển sang $tableLabel thành công!"),
              backgroundColor: AromaColors.coffeePrimary,
            ),
          );
        },
      ),
    );
  }

  void _openCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AromaColors.coffeeBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final list = cartState.values.toList();
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
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
                            "Giỏ hàng của bạn",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AromaColors.coffeeTextDark,
                            ),
                          ),
                          Text(
                            selectedTableLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AromaColors.coffeeGold,
                              fontWeight: FontWeight.bold,
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
                  if (list.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          "Giỏ hàng trống! Hãy chọn những tách cà phê thơm lành.",
                          style: TextStyle(color: AromaColors.coffeeTextSub),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else ...[
                    // Scrollable list
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: AromaColors.coffeeCardBorder,
                          height: 12,
                        ),
                        itemBuilder: (context, idx) {
                          final item = list[idx];
                          return Row(
                            children: [
                              Text(item.menuItem.emoji, style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.menuItem.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      "\$${item.menuItem.price.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        color: AromaColors.coffeePrimary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      _removeCart(item.menuItem);
                                      setModalState(() {});
                                    },
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  ),
                                  Text(
                                    "${item.quantity}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _addCart(item.menuItem);
                                      setModalState(() {});
                                    },
                                    icon: const Icon(Icons.add_circle_outline, size: 20),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Special request notes text-field
                    const Text(
                      "Ghi chú cho Bếp / Kỷ thuật viên pha chế:",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AromaColors.coffeeTextSub,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      onChanged: (val) => orderNoteInput = val,
                      controller: TextEditingController(text: orderNoteInput)
                        ..selection = TextSelection.collapsed(offset: orderNoteInput.length),
                      decoration: InputDecoration(
                        hintText: "Tìm món ngon đậm đà, mô tả ít đường, sữa hạt hay nhiều đá...",
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 11),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AromaColors.coffeeCardBorder),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Receipt Info Block
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AromaColors.coffeeCardBorder),
                      ),
                      child: Column(
                        children: [
                          _buildPriceSummaryRow("Tạm tính món ăn", subtotal),
                          const SizedBox(height: 4),
                          _buildPriceSummaryRow("Thuế VAT & Phí dịch vụ (10%)", serviceTax),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "TỔNG THANH TOÁN",
                                style: TextStyle(
                                  fontWeight: FontWeight.black,
                                  fontSize: 14,
                                  color: AromaColors.coffeePrimary,
                                ),
                              ),
                              Text(
                                "\$${totalAmount.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.black,
                                  fontSize: 16,
                                  color: AromaColors.coffeePrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Checkout button action
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          if (cartState.isNotEmpty) {
                            final generatedId = "B$selectedTableId-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}";
                            final newOrder = OrderModel(
                              id: generatedId,
                              tableId: selectedTableId,
                              items: cartState.values.toList(),
                              status: OrderStatus.pending,
                              timestamp: "Vừa xong",
                              note: orderNoteInput,
                              tableLabel: selectedTableLabel,
                            );
                            widget.onOrderSubmitted(newOrder);
                            setState(() {
                              cartState.clear();
                              orderNoteInput = "";
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Gửi đơn hàng $generatedId thành công!"),
                                backgroundColor: AromaColors.successGreen,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AromaColors.coffeePrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text(
                          "XÁC NHẬN GỬI BẾP GỌI MÓN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPriceSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AromaColors.coffeeTextSub),
        ),
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AromaColors.coffeeTextDark),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ["All", "Coffees", "Teas", "Pastries", "Brunch"];

    final filteredItems = widget.menuItems.where((item) {
      final matchesCategory = activeCategory == "All" || item.category == activeCategory;
      final matchesSearch = item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.vietnameseName.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AromaColors.coffeeBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1.5,
        titleSpacing: 14,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AromaColors.coffeePrimary,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.Center,
              child: const Text("☕", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Aroma Bistro",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AromaColors.coffeeTextDark),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: AromaColors.successGreen, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Bàn đang ngồi: $selectedTableId",
                        style: const TextStyle(fontSize: 10, color: AromaColors.coffeeTextSub, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _openQrSimulation,
            icon: const Icon(Icons.qr_code_scanner, color: AromaColors.coffeePrimary, size: 22),
          ),
          const SizedBox(width: 4),
          ElevatedButton.icon(
            onPressed: widget.onBackToGateway,
            style: ElevatedButton.styleFrom(
              backgroundColor: AromaColors.coffeePrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.swap_horiz, size: 14),
            label: const Text("Đổi Vai", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
        ],
      ),
      body: Column(
        children: [
          // Row of Category chips
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, idx) {
                final cat = categories[idx];
                final isSelected = cat == activeCategory;
                String displayName = cat;
                if (cat == "All") displayName = "Tất cả món";
                if (cat == "Coffees") displayName = "Cà phê ☕";
                if (cat == "Teas") displayName = "Trà hoa quả 🍵";
                if (cat == "Pastries") displayName = "Bánh ngọt 🥐";
                if (cat == "Brunch") displayName = "Điểm tâm 🥑";

                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    label: Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : AromaColors.coffeeTextSub,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => activeCategory = cat);
                    },
                    selectedColor: AromaColors.coffeePrimary,
                    checkmarkColor: Colors.white,
                    backgroundColor: AromaColors.coffeeSecondary.withOpacity(0.25),
                  ),
                );
              },
            ),
          ),

          // Search Field Text-input box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: "Tìm món ngon, cà phê đậm gu...",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AromaColors.coffeePrimary, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: AromaColors.coffeeCardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: AromaColors.coffeeCardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: const BorderSide(color: AromaColors.coffeePrimary, width: 1.5),
                ),
              ),
            ),
          ),

          // Grid style ListView matching high quality requirements
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("☕", style: TextStyle(fontSize: 44)),
                        SizedBox(height: 8),
                        Text(
                          "Món bạn chọn chưa sẵn có!",
                          style: TextStyle(color: AromaColors.coffeeTextSub, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, idx) {
                      final item = filteredItems[idx];
                      final count = cartState[item.id]?.quantity ?? 0;

                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: AromaColors.coffeeCardBorder),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Photo container matching Emoji design
                              Stack(
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: AromaColors.coffeeSecondary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    alignment: Alignment.Center,
                                    child: Text(item.emoji, style: const TextStyle(fontSize: 32)),
                                  ),
                                  if (!item.isAvailable)
                                    Container(
                                      width: 72,
                                      height: 72,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.55),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      alignment: Alignment.Center,
                                      child: const Text(
                                        "HẾT HÀNG",
                                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                ],
                              ),
                              const SizedBox(width: 12),

                              // Item descriptions
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AromaColors.coffeeTextDark,
                                      ),
                                    ),
                                    Text(
                                      item.vietnameseName,
                                      style: const TextStyle(fontSize: 11, color: AromaColors.coffeeTextSub),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      item.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 10, color: Colors.grey, height: 1.2),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          "\$${item.price.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            color: AromaColors.coffeePrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "(~${(item.price * 25000).toStringAsFixed(0)}đ)",
                                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              // Add item action
                              if (!item.isAvailable)
                                const Text(
                                  "Hết món",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AromaColors.errorColor,
                                  ),
                                )
                              else if (count == 0)
                                TextButton(
                                  onPressed: () => _addCart(item),
                                  style: TextButton.styleFrom(
                                    backgroundColor: AromaColors.coffeeSecondary.withOpacity(0.3),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text(
                                    "+ THÊM",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AromaColors.coffeePrimary,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  decoration: BoxDecoration(
                                    color: AromaColors.coffeePrimary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () => _removeCart(item),
                                        icon: const Icon(Icons.remove, color: Colors.white, size: 14),
                                      ),
                                      Text(
                                        "$count",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () => _addCart(item),
                                        icon: const Icon(Icons.add, color: Colors.white, size: 14),
                                      ),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Total float view footer panel
          if (cartCount > 0)
            Padding(
              padding: const EdgeInsets.all(14),
              child: GestureDetector(
                onTap: _openCartSheet,
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AromaColors.coffeePrimary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: const BoxDecoration(
                              color: AromaColors.coffeeGold,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "$cartCount",
                              style: const TextStyle(
                                color: AromaColors.coffeeDarkAccent,
                                fontWeight: FontWeight.black,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Xem giỏ hàng",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      Text(
                        "\$${subtotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: AromaColors.coffeeGold,
                          fontWeight: FontWeight.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Track order float panel
          if (widget.activeCustomerOrder != null && widget.activeCustomerOrder!.status != OrderStatus.paid)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Card(
                color: AromaColors.coffeeDarkAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: widget.onOpenTracker,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(color: AromaColors.coffeeGold, shape: BoxShape.circle),
                              child: const Icon(Icons.autorenew, color: AromaColors.coffeePrimary, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Đơn ${widget.activeCustomerOrder!.id} • Lên món: ${widget.activeCustomerOrder!.status.label}",
                                  style: const TextStyle(color: AromaColors.coffeeGold, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                const Text(
                                  "Nhấn để xem lộ trình bếp sủi bọt...",
                                  style: TextStyle(color: Colors.white70, fontSize: 10),
                                ),
                              ],
                            )
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AromaColors.coffeePrimary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.activeCustomerOrder!.tableLabel,
                            style: const TextStyle(color: AromaColors.coffeeGold, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
