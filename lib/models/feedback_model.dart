class FeedbackModel {
  final int feedbackId;
  final int orderId;
  final int tableId;
  final int rating;
  final String? comment;
  final bool isHidden;
  final DateTime createdAt;

  FeedbackModel({
    required this.feedbackId,
    required this.orderId,
    required this.tableId,
    required this.rating,
    this.comment,
    required this.isHidden,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      feedbackId: json['feedbackId'] as int? ?? 0,
      orderId: json['orderId'] as int? ?? 0,
      tableId: json['tableId'] as int? ?? 0,
      rating: json['rating'] as int? ?? 5,
      comment: json['comment']?.toString(),
      isHidden: json['isHidden'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feedbackId': feedbackId,
      'orderId': orderId,
      'tableId': tableId,
      'rating': rating,
      'comment': comment,
      'isHidden': isHidden,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
