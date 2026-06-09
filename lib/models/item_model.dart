import 'package:flutter/material.dart';
import '../constants.dart';

/*==================================================
  CATEGORY ENUM — khớp MenuItems.Category (INT)
  1 = Coffee, 2 = Tea, 3 = Cake, 4 = Juice, 99 = Other
==================================================*/
enum CategoryType {
  coffee(1, 'Cà phê', '☕'),
  tea(2, 'Trà', '🍵'),
  cake(3, 'Bánh ngọt', '🍰'),
  juice(4, 'Nước ép', '🧃'),
  other(99, 'Khác', '🍽️');

  final int value;
  final String label;
  final String icon;
  const CategoryType(this.value, this.label, this.icon);

  static CategoryType fromInt(int v) {
    switch (v) {
      case 1:
        return CategoryType.coffee;
      case 2:
        return CategoryType.tea;
      case 3:
        return CategoryType.cake;
      case 4:
        return CategoryType.juice;
      case 99:
      default:
        return CategoryType.other;
    }
  }
}

/*==================================================
  TABLE STATUS ENUM — khớp Tables.Status (INT)
  1 = Available, 2 = Occupied, 3 = Maintenance
==================================================*/
enum TableStatus {
  available(1, 'Trống', Colors.green),
  occupied(2, 'Đang sử dụng', Colors.orange),
  maintenance(3, 'Bảo trì', Colors.grey);

  final int value;
  final String label;
  final Color color;
  const TableStatus(this.value, this.label, this.color);

  static TableStatus fromInt(int v) {
    switch (v) {
      case 1:
        return TableStatus.available;
      case 2:
        return TableStatus.occupied;
      case 3:
        return TableStatus.maintenance;
      default:
        return TableStatus.available;
    }
  }
}

/*==================================================
  ORDER STATUS ENUM — khớp Orders.Status (INT)
  1 = Pending, 2 = Preparing, 3 = Ready, 4 = Paid, 5 = Cancelled
==================================================*/
enum OrderStatus {
  pending(1),
  preparing(2),
  ready(3),
  paid(4),
  cancelled(5);

  final int value;
  const OrderStatus(this.value);

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return AromaColors.pendingOrange;
      case OrderStatus.preparing:
        return AromaColors.preparingBlue;
      case OrderStatus.ready:
        return AromaColors.successGreen;
      case OrderStatus.paid:
        return AromaColors.coffeeTextSub;
      case OrderStatus.cancelled:
        return Colors.redAccent;
    }
  }

  String get labelVi {
    switch (this) {
      case OrderStatus.pending:
        return "Chờ xác nhận";
      case OrderStatus.preparing:
        return "Đang chế biến";
      case OrderStatus.ready:
        return "Hoàn thành món";
      case OrderStatus.paid:
        return "Đã thanh toán";
      case OrderStatus.cancelled:
        return "Đã hủy";
    }
  }

  static OrderStatus fromInt(int v) {
    switch (v) {
      case 1:
        return OrderStatus.pending;
      case 2:
        return OrderStatus.preparing;
      case 3:
        return OrderStatus.ready;
      case 4:
        return OrderStatus.paid;
      case 5:
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static OrderStatus fromString(String text) {
    switch (text.toLowerCase()) {
      case 'preparing':
      case '2':
        return OrderStatus.preparing;
      case 'ready':
      case '3':
        return OrderStatus.ready;
      case 'paid':
      case '4':
        return OrderStatus.paid;
      case 'cancelled':
      case '5':
        return OrderStatus.cancelled;
      case 'pending':
      case '1':
      default:
        return OrderStatus.pending;
    }
  }

  String get valueString => toString().split('.').last;
}

/*==================================================
  MENU ITEM MODEL — khớp bảng [MenuItems]
==================================================*/
class MenuItem {
  final int menuItemId;
  final String name;
  final String? description;
  final double price;
  final CategoryType category;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MenuItem({
    required this.menuItemId,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.isAvailable = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      menuItemId: json['menuItemId'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: CategoryType.fromInt(json['category'] as int? ?? 99),
      imageUrl: json['imageUrl']?.toString(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'description': description,
      'price': price,
      'category': category.value,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  MenuItem copyWith({
    int? menuItemId,
    String? name,
    String? description,
    double? price,
    CategoryType? category,
    String? imageUrl,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper: icon emoji dựa theo category
  String get categoryIcon => category.icon;

  /// Helper: label category tiếng Việt
  String get categoryLabel => category.label;
}

/*==================================================
  TABLE MODEL — khớp bảng [Tables]
==================================================*/
class TableModel {
  final int tableId;
  final int capacity;
  final TableStatus status;
  final DateTime createdAt;

  TableModel({
    required this.tableId,
    this.capacity = 4,
    this.status = TableStatus.available,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Tự sinh label từ tableId (DB không có field label)
  String get label => "Bàn #$tableId";

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      tableId: json['tableId'] as int? ?? 0,
      capacity: json['capacity'] as int? ?? 4,
      status: TableStatus.fromInt(json['status'] as int? ?? 1),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'capacity': capacity,
      'status': status.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  TableModel copyWith({
    int? tableId,
    int? capacity,
    TableStatus? status,
    DateTime? createdAt,
  }) {
    return TableModel(
      tableId: tableId ?? this.tableId,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/*==================================================
  ORDER ITEM MODEL — khớp bảng [OrderItems]
==================================================*/
class OrderItemModel {
  final int? orderItemId;
  final int orderId;
  final int menuItemId;
  final int quantity;
  final double unitPrice;
  final String? note;

  // Không có trong DB, dùng để hiển thị UI
  final MenuItem? menuItemRef;

  OrderItemModel({
    this.orderItemId,
    this.orderId = 0,
    required this.menuItemId,
    required this.quantity,
    required this.unitPrice,
    this.note,
    this.menuItemRef,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json, {MenuItem? menuItemRef}) {
    return OrderItemModel(
      orderItemId: json['orderItemId'] as int?,
      orderId: json['orderId'] as int? ?? 0,
      menuItemId: json['menuItemId'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      note: json['note']?.toString(),
      menuItemRef: menuItemRef,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderItemId': orderItemId,
      'orderId': orderId,
      'menuItemId': menuItemId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'note': note,
    };
  }

  OrderItemModel copyWith({
    int? orderItemId,
    int? orderId,
    int? menuItemId,
    int? quantity,
    double? unitPrice,
    String? note,
    MenuItem? menuItemRef,
  }) {
    return OrderItemModel(
      orderItemId: orderItemId ?? this.orderItemId,
      orderId: orderId ?? this.orderId,
      menuItemId: menuItemId ?? this.menuItemId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      note: note ?? this.note,
      menuItemRef: menuItemRef ?? this.menuItemRef,
    );
  }
}

/*==================================================
  ORDER MODEL — khớp bảng [Orders]
==================================================*/
class OrderModel {
  final int orderId;
  final int tableId;
  final int? handledBy;
  final OrderStatus status;
  final double totalAmount;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.orderId,
    required this.tableId,
    this.handledBy,
    this.status = OrderStatus.pending,
    this.totalAmount = 0,
    this.note,
    DateTime? createdAt,
    this.updatedAt,
    this.items = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  /// Tự sinh tableLabel từ tableId
  String get tableLabel => "Bàn #$tableId";

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List? ?? [];
    List<OrderItemModel> itemList = rawItems
        .map((it) => OrderItemModel.fromJson(it as Map<String, dynamic>))
        .toList();

    return OrderModel(
      orderId: json['orderId'] as int? ?? 0,
      tableId: json['tableId'] as int? ?? 0,
      handledBy: json['handledBy'] as int?,
      status: json['status'] is int
          ? OrderStatus.fromInt(json['status'] as int)
          : OrderStatus.fromString(json['status']?.toString() ?? 'pending'),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      note: json['note']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      items: itemList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'tableId': tableId,
      'handledBy': handledBy,
      'status': status.value,
      'totalAmount': totalAmount,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'items': items.map((it) => it.toJson()).toList(),
    };
  }

  OrderModel copyWith({
    int? orderId,
    int? tableId,
    int? handledBy,
    OrderStatus? status,
    double? totalAmount,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      tableId: tableId ?? this.tableId,
      handledBy: handledBy ?? this.handledBy,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }
}

/*==================================================
  SEED DATA — khớp DB SEED
==================================================*/

/// Seed Menu Items — giá VND khớp DB
final List<MenuItem> initialMenuItems = [
  MenuItem(
    menuItemId: 1,
    name: "Espresso",
    description: "Italian espresso",
    price: 30000,
    category: CategoryType.coffee,
    isAvailable: false,
  ),
  MenuItem(
    menuItemId: 2,
    name: "Latte",
    description: "Milk coffee",
    price: 45000,
    category: CategoryType.coffee,
    isAvailable: false,
  ),
  MenuItem(
    menuItemId: 3,
    name: "Matcha Tea",
    description: "Japanese matcha",
    price: 50000,
    category: CategoryType.tea,
    isAvailable: true,
  ),
  MenuItem(
    menuItemId: 4,
    name: "Cheesecake",
    description: "New York cheesecake",
    price: 55000,
    category: CategoryType.cake,
    isAvailable: false,
  ),
  MenuItem(
    menuItemId: 5,
    name: "Orange Juice",
    description: "Fresh orange juice",
    price: 40000,
    category: CategoryType.juice,
    isAvailable: true,
  ),
  MenuItem(
    menuItemId: 6,
    name: "CaPheTrung",
    description: "ca phe rat ng...",
    price: 20000,
    category: CategoryType.coffee,
    isAvailable: false,
  ),
  MenuItem(
    menuItemId: 7,
    name: "aas",
    description: "asdasd",
    price: 30000,
    category: CategoryType.coffee,
    isAvailable: false,
  ),
  MenuItem(
    menuItemId: 8,
    name: "v Brainy",
    description: "co",
    price: 30000,
    category: CategoryType.tea,
    isAvailable: true,
  ),
];

/// Seed Tables — 8 bàn khớp DB (Capacity: 4,4,4,4,6,6,8,8)
final List<TableModel> systemTables = [
  TableModel(tableId: 1, capacity: 4, status: TableStatus.available),
  TableModel(tableId: 2, capacity: 4, status: TableStatus.available),
  TableModel(tableId: 3, capacity: 4, status: TableStatus.available),
  TableModel(tableId: 4, capacity: 4, status: TableStatus.available),
  TableModel(tableId: 5, capacity: 6, status: TableStatus.available),
  TableModel(tableId: 6, capacity: 6, status: TableStatus.available),
  TableModel(tableId: 7, capacity: 8, status: TableStatus.available),
  TableModel(tableId: 8, capacity: 8, status: TableStatus.occupied),
];

/*==================================================
  HELPER: Format tiền VND
==================================================*/
String formatVND(double amount) {
  final intAmount = amount.round();
  final str = intAmount.toString();
  final result = str.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
  return '${result}đ';
}
