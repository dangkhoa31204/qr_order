import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../constants.dart';
import '../models/item_model.dart';
import '../utils/qr_generator.dart';

class TableManagementScreen extends StatefulWidget {
  final List<TableModel> tables;
  final Function(TableModel) onAddTable;
  final Function(TableModel) onUpdateTable;
  final Function(int) onDeleteTable;
  final Function(TableModel) onExportQrCode;
  final bool isStaff;
  final VoidCallback? onRefreshData;

  const TableManagementScreen({
    super.key,
    required this.tables,
    required this.onAddTable,
    required this.onUpdateTable,
    required this.onDeleteTable,
    required this.onExportQrCode,
    this.isStaff = false,
    this.onRefreshData,
  });

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  late List<TableModel> _tables;

  @override
  void initState() {
    super.initState();
    _tables = List.from(widget.tables);
  }

  @override
  void didUpdateWidget(covariant TableManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tables != oldWidget.tables) {
      setState(() {
        _tables = List.from(widget.tables);
      });
    }
  }


  // Admin only: add new table
  void _showAddTableDialog() {
    final capacityController = TextEditingController(text: '4');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Text("🍽️", style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text(
                "Thêm Bàn Mới",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AromaColors.coffeeTextDark,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Sức chứa (số lượng khách)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy", style: TextStyle(color: AromaColors.coffeeTextSub)),
            ),
            ElevatedButton(
              onPressed: () {
                final capacity = int.tryParse(capacityController.text.trim());
                if (capacity == null || capacity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Sức chứa phải là số nguyên lớn hơn 0"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                int maxId = 0;
                for (var t in _tables) {
                  if (t.tableId > maxId) maxId = t.tableId;
                }
                final newTable = TableModel(
                  tableId: maxId + 1,
                  capacity: capacity,
                  status: TableStatus.available,
                );

                widget.onAddTable(newTable);
                setState(() => _tables.add(newTable));

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("✅ Đã thêm bàn thành công (Sức chứa: $capacity)"),
                    backgroundColor: AromaColors.successGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AromaColors.coffeePrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Thêm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showEditTableDialog(TableModel table) {
    final capacityController = TextEditingController(text: table.capacity.toString());
    TableStatus status = table.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Text(
                    "✏️",
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Sửa ${table.label}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AromaColors.coffeeTextDark,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ID bàn chỉ hiển thị, không cho sửa
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AromaColors.coffeeSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AromaColors.coffeeCardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.tag, size: 18, color: AromaColors.coffeeTextSub),
                          const SizedBox(width: 8),
                          Text(
                            "ID Bàn: ${table.tableId}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AromaColors.coffeeTextDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Sức chứa (số lượng khách)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TableStatus>(
                      initialValue: status,
                      decoration: InputDecoration(
                        labelText: "Trạng thái",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      items: TableStatus.values.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: s.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(s.label),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            status = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Hủy",
                    style: TextStyle(color: AromaColors.coffeeTextSub),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final capacity = int.tryParse(capacityController.text.trim()) ?? table.capacity;

                    final updatedTable = table.copyWith(
                      capacity: capacity,
                      status: status,
                    );

                    widget.onUpdateTable(updatedTable);
                    setState(() {
                      final idx = _tables.indexWhere((t) => t.tableId == table.tableId);
                      if (idx != -1) {
                        _tables[idx] = updatedTable;
                      }
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "✅ Đã cập nhật ${updatedTable.label} thành công",
                        ),
                        backgroundColor: AromaColors.successGreen,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AromaColors.coffeePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Lưu",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showQrPreview(TableModel table) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AromaColors.coffeeBackground,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${table.label} - Mã QR",
                      style: const TextStyle(
                        fontSize: 18,
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
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AromaColors.coffeeCardBorder,
                      width: 2,
                    ),
                  ),
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: FutureBuilder<Uint8List?>(
                      future:
                          QrCodeGenerator.generateTableQrCode(table.tableId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AromaColors.coffeePrimary,
                            ),
                          );
                        }
                        if (snapshot.hasData && snapshot.data != null) {
                          return Image.memory(snapshot.data!);
                        }
                        return const Center(
                          child: Text("Lỗi tạo mã QR"),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "ID: ${table.tableId}",
                  style: const TextStyle(
                    color: AromaColors.coffeeTextSub,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AromaColors.coffeeSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    QrCodeGenerator.getOrderUrl(table.tableId),
                    style: const TextStyle(
                      color: AromaColors.coffeePrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _exportQrCode(table);
                        },
                        icon: const Icon(Icons.download),
                        label: const Text("Tải Xuống"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AromaColors.coffeePrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

  void _exportQrCode(TableModel table) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⏳ Đang lưu mã QR..."),
        backgroundColor: AromaColors.pendingOrange,
      ),
    );

    final success = await QrCodeGenerator.saveQrCode(table.tableId.toString(), table.label);

    if (!mounted) return;
    if (success) {
      widget.onExportQrCode(table);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Đã lưu mã QR cho ${table.label} vào thư mục Downloads"),
          backgroundColor: AromaColors.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Không thể lưu mã QR. Vui lòng kiểm tra quyền truy cập."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Admin only: delete table
  void _deleteTable(TableModel table) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Xác Nhận Xóa"),
          content: Text("Bạn có chắc chắn muốn xóa ${table.label}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onDeleteTable(table.tableId);
                setState(() => _tables.removeWhere((t) => t.tableId == table.tableId));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("🗑️ Đã xóa ${table.label}"),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Xóa", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    "Danh Sách Bàn",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AromaColors.coffeeTextDark,
                    ),
                  ),
                  if (widget.onRefreshData != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: widget.onRefreshData,
                      icon: const Icon(Icons.refresh, size: 18, color: AromaColors.coffeePrimary),
                      tooltip: "Tải lại",
                    ),
                  ],
                ],
              ),
              if (!widget.isStaff)
                ElevatedButton.icon(
                  onPressed: _showAddTableDialog,
                  icon: const Icon(Icons.add),
                  label: const Text("Thêm Bàn"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AromaColors.coffeePrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: _tables.isEmpty
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
                        child:
                            const Text("🍽️", style: TextStyle(fontSize: 48)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Chưa có bàn nào",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AromaColors.coffeeTextDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Nhấn 'Thêm Bàn' để bắt đầu",
                        style: TextStyle(
                          fontSize: 12,
                          color: AromaColors.coffeeTextSub,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tables.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final table = _tables[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(
                          color: AromaColors.coffeeCardBorder,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AromaColors.coffeeSecondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "🍽️",
                                style: TextStyle(fontSize: 32),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    table.label,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AromaColors.coffeeTextDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Sức chứa: ${table.capacity} người",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AromaColors.coffeeTextSub,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: table.status.color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      table.status.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: table.status.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.qr_code_2,
                                    color: AromaColors.coffeePrimary,
                                  ),
                                  onPressed: () => _showQrPreview(table),
                                  tooltip: "Xem & Tải QR",
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: AromaColors.preparingBlue,
                                  ),
                                  onPressed: () => _showEditTableDialog(table),
                                  tooltip: "Sửa bàn",
                                ),
                                if (!widget.isStaff)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteTable(table),
                                    tooltip: "Xóa bàn",
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
}
