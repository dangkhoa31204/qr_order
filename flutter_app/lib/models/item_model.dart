import 'package:flutter/material.dart';
import '../constants.dart';

enum UserRole { undecided, customer, staff }

enum OrderStatus {
  pending,
  preparing,
  ready,
  paid;

  String get label => {
        OrderStatus.pending: "Chờ xác nhận",
        OrderStatus.preparing: "Đang chế biến",
        OrderStatus.ready: "Hoàn thành món",
        OrderStatus.paid: "Đã thanh toán",
      }[this]!;

  Color get color => {
        OrderStatus.pending: AromaColors.coffeeGold,
        OrderStatus.preparing: const Color(0xFF1E88E5),
        OrderStatus.ready: AromaColors.successGreen,
        OrderStatus.paid: AromaColors.coffeeTextSub,
      }[this]!;
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
    required this.emoji,
    required this.category,
    this.isAvailable = true,
  });

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
  final String status; // "Empty", "Active", "Paid"

  TableModel({
    required this.id,
    required this.label,
    required this.description,
    required this.status,
  });

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
    required this.quantity,
    this.note = "",
  });

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
    this.timeMinutes = 0,
    required this.timestamp,
    this.note = "",
    required this.tableLabel,
  });

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
  MenuItem(id: "m9", name: "Cold Brew Tonic", vietnameseName: "Cà Phê Lạnh Sủi Bọt", price: 6.50, description: "Cà phê ủ lạnh 18 tiếng rót cùng nước tonic cao cấp sảng khoái và lát chanh vàng tươi.", emoji: "🍹", category: "Coffees"),
];

final List<TableModel> systemTables = [
  TableModel(id: "03", label: "Bàn #03", description: "Khu vực ấm cúng trong nhà", status: "Empty"),
  TableModel(id: "08", label: "Bàn #08", description: "Cạnh cửa sổ ngắm phố xá", status: "Active"),
  TableModel(id: "12", label: "Bàn #12", description: "Ban công gió mát lộng lẫy", status: "Empty"),
  TableModel(id: "15", label: "Bàn #15", description: "Phòng VIP riêng tư sang trọng", status: "Empty"),
];
