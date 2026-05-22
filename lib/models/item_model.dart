import 'package:flutter/material.dart';
import '../constants.dart';

enum OrderStatus {
  pending,
  preparing,
  ready,
  paid;

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
    }
  }

  static OrderStatus fromString(String text) {
    switch (text.toLowerCase()) {
      case 'preparing':
      case '1':
        return OrderStatus.preparing;
      case 'ready':
      case '2':
        return OrderStatus.ready;
      case 'paid':
      case '3':
        return OrderStatus.paid;
      case 'pending':
      case '0':
      default:
        return OrderStatus.pending;
    }
  }

  String get valueString => toString().split('.').last;
}

class MenuItem {
  final String id;
  final String name;
  final String vietnameseName;
  final double price;
  final String description;
  final String emoji;
  final String category;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.name,
    required this.vietnameseName,
    required this.price,
    required this.description,
    this.emoji = "☕",
    this.category = "Coffees",
    this.isAvailable = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      vietnameseName: json['vietnameseName']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '☕',
      category: json['category']?.toString() ?? 'Coffees',
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vietnameseName': vietnameseName,
      'price': price,
      'description': description,
      'emoji': emoji,
      'category': category,
      'isAvailable': isAvailable,
    };
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? vietnameseName,
    double? price,
    String? description,
    String? emoji,
    String? category,
    bool? isAvailable,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      vietnameseName: vietnameseName ?? this.vietnameseName,
      price: price ?? this.price,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class TableModel {
  final String id;
  final String label;
  final String description;
  final String status;

  TableModel({
    required this.id,
    required this.label,
    required this.description,
    required this.status,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Empty',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'description': description,
      'status': status,
    };
  }

  TableModel copyWith({
    String? id,
    String? label,
    String? description,
    String? status,
  }) {
    return TableModel(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }
}

class CartItem {
  final MenuItem menuItem;
  final int quantity;
  final String note;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.note = "",
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      menuItem: MenuItem.fromJson(json['menuItem'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
      note: json['note']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItem': menuItem.toJson(),
      'quantity': quantity,
      'note': note,
    };
  }

  CartItem copyWith({
    MenuItem? menuItem,
    int? quantity,
    String? note,
  }) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }
}

class OrderModel {
  final String id;
  final String tableId;
  final List<CartItem> items;
  final OrderStatus status;
  final int timeMinutes;
  final String timestamp;
  final String note;
  final String tableLabel;

  OrderModel({
    required this.id,
    required this.tableId,
    required this.items,
    required this.status,
    required this.timeMinutes,
    required this.timestamp,
    required this.note,
    required this.tableLabel,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List? ?? [];
    List<CartItem> itemList = rawItems
        .map((it) => CartItem.fromJson(it as Map<String, dynamic>))
        .toList();

    return OrderModel(
      id: json['id']?.toString() ?? '',
      tableId: json['tableId']?.toString() ?? '',
      items: itemList,
      status: OrderStatus.fromString(json['status']?.toString() ?? 'pending'),
      timeMinutes: json['timeMinutes'] as int? ?? 0,
      timestamp: json['timestamp']?.toString() ?? 'Vừa xong',
      note: json['note']?.toString() ?? '',
      tableLabel: json['tableLabel']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableId': tableId,
      'items': items.map((it) => it.toJson()).toList(),
      'status': status.valueString,
      'timeMinutes': timeMinutes,
      'timestamp': timestamp,
      'note': note,
      'tableLabel': tableLabel,
    };
  }

  OrderModel copyWith({
    String? id,
    String? tableId,
    List<CartItem>? items,
    OrderStatus? status,
    int? timeMinutes,
    String? timestamp,
    String? note,
    String? tableLabel,
  }) {
    return OrderModel(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      items: items ?? this.items,
      status: status ?? this.status,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      tableLabel: tableLabel ?? this.tableLabel,
    );
  }
}

final List<MenuItem> initialMenuItems = [
  MenuItem(id: "m1", name: "Butter Croissant", vietnameseName: "Bánh Sừng Bò Pháp", price: 4.50, description: "Bánh sừng bò ngập hương bơ Pháp, giòn rụm thơm ngon nướng vàng ươm mỗi sáng.", emoji: "🥐", category: "Pastries"),
  MenuItem(id: "m2", name: "Avocado Toast", vietnameseName: "Bánh Mì Trái Bơ", price: 12.00, description: "Bánh mì lát nướng giòn rải bơ tươi nhuyễn, cà chua bi và hạt chia hữu cơ.", emoji: "🥑", category: "Brunch"),
  MenuItem(id: "m3", name: "Matcha Latte", vietnameseName: "Trà Xanh Nhật Matcha", price: 5.75, description: "Trà xanh matcha Nhật Bản thượng hạng đánh mịn cùng sữa hạt organic thơm béo.", emoji: "🍵", category: "Teas"),
  MenuItem(id: "m4", name: "Quinoa Salmon Bowl", vietnameseName: "Cơm Salmond Quinoa", price: 14.50, description: "Cá hồi áp chảo thơm lừng cùng quinoa đỏ, khoai lang nướng và cải xoăn hữu cơ.", emoji: "🥗", category: "Brunch"),
  MenuItem(id: "m5", name: "Espresso Doppio", vietnameseName: "Cà Phê Espresso Đôi", price: 3.50, description: "Cà phê pha máy Espresso Doppio đậm đà nguyên bản từ hạt Arabica Cầu Đất tinh tế.", emoji: "☕", category: "Coffees"),
  MenuItem(id: "m6", name: "Fluffy Blueberry Pancake", vietnameseName: "Bánh Kẹp Việt Quất", price: 9.75, description: "Bánh pancake xếp lớp xốp mềm tràn ngập quả việt quất tươi và si rô phong nguyên chất.", emoji: "🥞", category: "Pastries"),
  MenuItem(id: "m7", name: "Egg Benedict", vietnameseName: "Trứng Benedict Kiểu Anh", price: 13.00, description: "Trứng chần sánh dẻo, giăm bông hun khói và sốt bơ béo Hollandaise trên English muffin.", emoji: "🍳", category: "Brunch"),
  MenuItem(id: "m8", name: "Peach Hibiscus Tea", vietnameseName: "Trà Hibiscus Đào Hồng", price: 6.00, description: "Vị chua thanh mát lành từ hoa hồng đài hòa quyện trà đào ngào mật ong ngọt nhẹ.", emoji: "🍑", category: "Teas"),
  MenuItem(id: "m9", name: "Cold Brew Tonic", vietnameseName: "Cà Phê Lạnh Sủi Bọt", price: 6.50, description: "Cà phê sấy khô ủ lạnh 18 tiếng rót cùng nước tonic cao cấp sảng khoái và lát chanh vàng tươi.", emoji: "🍹", category: "Coffees"),
];

final List<TableModel> systemTables = [
  TableModel(id: "03", label: "Bàn #03", description: "Khu vực ấm cúng trong nhà", status: "Empty"),
  TableModel(id: "08", label: "Bàn #08", description: "Cạnh cửa sổ ngắm phố xá", status: "Active"),
  TableModel(id: "12", label: "Bàn #12", description: "Ban công gió mát lộng lẫy", status: "Empty"),
  TableModel(id: "15", label: "Bàn #15", description: "Phòng VIP riêng tư sang trọng", status: "Empty"),
];
