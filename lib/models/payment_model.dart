enum PaymentStatus { pending, completed, failed, refunded }

enum PaymentMethod { creditCard, bankTransfer, mobilePayment, cash }

enum PaymentType { housingFee, securityDeposit, maintenanceFee, penalty }

class PaymentModel {
  final String? id;
  final String studentId;
  final String? studentProfileId;
  final double amount;
  final DateTime paymentDate;
  final PaymentStatus status;
  final PaymentMethod paymentMethod;
  final PaymentType paymentType;
  final String? referenceNumber;
  final String? receiptNumber;
  final Map<String, dynamic>? transactionDetails;
  final String? notes;

  PaymentModel({
    this.id,
    required this.studentId,
    this.studentProfileId,
    required this.amount,
    required this.paymentDate,
    required this.status,
    required this.paymentMethod,
    required this.paymentType,
    this.referenceNumber,
    this.receiptNumber,
    this.transactionDetails,
    this.notes,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      studentId: json['student_id'],
      studentProfileId: json['student_profile_id'],
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['payment_date']),
      status: _parseStatus(json['status']),
      paymentMethod: _parseMethod(json['payment_method']),
      paymentType: _parseType(json['payment_type']),
      referenceNumber: json['reference_number'],
      receiptNumber: json['receipt_number'],
      transactionDetails: json['transaction_details'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'student_profile_id': studentProfileId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'payment_method': paymentMethod.toString().split('.').last,
      'payment_type': paymentType.toString().split('.').last,
      'reference_number': referenceNumber,
      'receipt_number': receiptNumber,
      'transaction_details': transactionDetails,
      'notes': notes,
    };
  }

  PaymentModel copyWith({
    String? id,
    String? studentId,
    String? studentProfileId,
    double? amount,
    DateTime? paymentDate,
    PaymentStatus? status,
    PaymentMethod? paymentMethod,
    PaymentType? paymentType,
    String? referenceNumber,
    String? receiptNumber,
    Map<String, dynamic>? transactionDetails,
    String? notes,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentProfileId: studentProfileId ?? this.studentProfileId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentType: paymentType ?? this.paymentType,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      transactionDetails: transactionDetails ?? this.transactionDetails,
      notes: notes ?? this.notes,
    );
  }

  static PaymentStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }

  static PaymentMethod _parseMethod(String method) {
    switch (method.toLowerCase()) {
      case 'creditcard':
        return PaymentMethod.creditCard;
      case 'banktransfer':
        return PaymentMethod.bankTransfer;
      case 'mobilepayment':
        return PaymentMethod.mobilePayment;
      case 'cash':
      default:
        return PaymentMethod.cash;
    }
  }

  static PaymentType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'housingfee':
        return PaymentType.housingFee;
      case 'securitydeposit':
        return PaymentType.securityDeposit;
      case 'maintenancefee':
        return PaymentType.maintenanceFee;
      case 'penalty':
      default:
        return PaymentType.penalty;
    }
  }
}
