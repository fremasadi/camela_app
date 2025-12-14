class BookingModel {
  final bool status;
  final String message;
  final BookingData? data;

  BookingModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? BookingData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class BookingData {
  final int? bookingId;
  final String? orderId;
  final double? totalHarga;
  final double? totalPembayaran;
  final String? jenisPembayaran;
  final Booking? booking;
  final Payment? payment;

  BookingData({
    this.bookingId,
    this.orderId,
    this.totalHarga,
    this.totalPembayaran,
    this.jenisPembayaran,
    this.booking,
    this.payment,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      bookingId: json['booking_id'],
      orderId: json['order_id'],
      totalHarga: _parseDouble(json['total_harga']),
      totalPembayaran: _parseDouble(json['total_pembayaran']),
      jenisPembayaran: json['jenis_pembayaran'],
      booking: json['booking'] != null ? Booking.fromJson(json['booking']) : null,
      payment: json['payment'] != null ? Payment.fromJson(json['payment']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'order_id': orderId,
      'total_harga': totalHarga,
      'total_pembayaran': totalPembayaran,
      'jenis_pembayaran': jenisPembayaran,
      'booking': booking?.toJson(),
      'payment': payment?.toJson(),
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class Booking {
  final int? id;
  final String? orderId;
  final int? userId;
  final String? tanggalBooking;
  final String? jamBooking;
  final String? status;
  final double? totalHarga;
  final String? jenisPembayaran;
  final double? totalPembayaran;
  final String? paymentType;
  final String? createdAt;
  final String? updatedAt;

  Booking({
    this.id,
    this.orderId,
    this.userId,
    this.tanggalBooking,
    this.jamBooking,
    this.status,
    this.totalHarga,
    this.jenisPembayaran,
    this.totalPembayaran,
    this.paymentType,
    this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      orderId: json['order_id'],
      userId: json['user_id'],
      tanggalBooking: json['tanggal_booking'],
      jamBooking: json['jam_booking'],
      status: json['status'],
      totalHarga: BookingData._parseDouble(json['total_harga']),
      jenisPembayaran: json['jenis_pembayaran'],
      totalPembayaran: BookingData._parseDouble(json['total_pembayaran']),
      paymentType: json['payment_type'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'tanggal_booking': tanggalBooking,
      'jam_booking': jamBooking,
      'status': status,
      'total_harga': totalHarga,
      'jenis_pembayaran': jenisPembayaran,
      'total_pembayaran': totalPembayaran,
      'payment_type': paymentType,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Payment {
  final int? id;
  final int? bookingId;
  final String? orderId;
  final String? transactionId;
  final double? grossAmount;
  final String? transactionStatus;
  final String? fraudStatus;
  final String? paymentType;
  final String? paymentGateway;
  final String? paymentGatewayReferenceId;
  final String? bank;
  final String? vaNumber;
  final String? qrUrl;
  final String? deeplinkUrl;
  final String? paymentUrl;
  final Map<String, dynamic>? paymentGatewayResponse;
  final String? paymentProof;
  final String? paymentDate;
  final String? transactionTime;
  final String? settlementTime;
  final String? expiredAt;
  final String? createdAt;
  final String? updatedAt;

  Payment({
    this.id,
    this.bookingId,
    this.orderId,
    this.transactionId,
    this.grossAmount,
    this.transactionStatus,
    this.fraudStatus,
    this.paymentType,
    this.paymentGateway,
    this.paymentGatewayReferenceId,
    this.bank,
    this.vaNumber,
    this.qrUrl,
    this.deeplinkUrl,
    this.paymentUrl,
    this.paymentGatewayResponse,
    this.paymentProof,
    this.paymentDate,
    this.transactionTime,
    this.settlementTime,
    this.expiredAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      bookingId: json['booking_id'],
      orderId: json['order_id'],
      transactionId: json['transaction_id'],
      grossAmount: BookingData._parseDouble(json['gross_amount']),
      transactionStatus: json['transaction_status'],
      fraudStatus: json['fraud_status'],
      paymentType: json['payment_type'],
      paymentGateway: json['payment_gateway'],
      paymentGatewayReferenceId: json['payment_gateway_reference_id'],
      bank: json['bank'],
      vaNumber: json['va_number'],
      qrUrl: json['qr_url'],
      deeplinkUrl: json['deeplink_url'],
      paymentUrl: json['payment_url'],
      paymentGatewayResponse: json['payment_gateway_response'] is Map
          ? Map<String, dynamic>.from(json['payment_gateway_response'])
          : null,
      paymentProof: json['payment_proof'],
      paymentDate: json['payment_date'],
      transactionTime: json['transaction_time'],
      settlementTime: json['settlement_time'],
      expiredAt: json['expired_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'order_id': orderId,
      'transaction_id': transactionId,
      'gross_amount': grossAmount,
      'transaction_status': transactionStatus,
      'fraud_status': fraudStatus,
      'payment_type': paymentType,
      'payment_gateway': paymentGateway,
      'payment_gateway_reference_id': paymentGatewayReferenceId,
      'bank': bank,
      'va_number': vaNumber,
      'qr_url': qrUrl,
      'deeplink_url': deeplinkUrl,
      'payment_url': paymentUrl,
      'payment_gateway_response': paymentGatewayResponse,
      'payment_proof': paymentProof,
      'payment_date': paymentDate,
      'transaction_time': transactionTime,
      'settlement_time': settlementTime,
      'expired_at': expiredAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}