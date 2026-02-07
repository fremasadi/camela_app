import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/date_converter.dart';
import '../../../core/utils/date_coverter.dart';
import '../../../core/utils/firebase_service.dart';
import '../../../core/utils/price_converter.dart';
import '../../../style/app_color.dart';
import '../../base/views/base_view.dart';
import '../../widgets/input_form_button.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.response});

  final Map<String, dynamic> response;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Map<String, dynamic> bookingData;
  late Map<String, dynamic> paymentData;

  final FirebaseService _firebaseService = FirebaseService();

  Timer? _timer;
  int _remainingSeconds = 0;
  bool isAlreadyPaid = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // =========================================================
  // INIT
  // =========================================================
  void _initializeData() {
    try {
      final data = widget.response['data'];
      final booking = data?['booking'];
      final payment = data?['payment'];

      if (booking == null || payment == null) {
        throw Exception('Data booking atau payment tidak ditemukan');
      }

      bookingData = Map<String, dynamic>.from(booking);
      paymentData = Map<String, dynamic>.from(payment);

      _parseGatewayResponse();
      _setupFirebaseListener();
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memuat halaman pembayaran: $e'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      });
    }
  }

  // =========================================================
  // PARSE PAYMENT GATEWAY RESPONSE
  // =========================================================
  void _parseGatewayResponse() {
    final gatewayResponse = paymentData['payment_gateway_response'];

    // Jika valid, parsing
    if (gatewayResponse != null && gatewayResponse != '') {
      try {
        final parsed = gatewayResponse is String
            ? jsonDecode(gatewayResponse)
            : gatewayResponse;

        paymentData['parsed_gateway_response'] = parsed;

        // Expiry
        final expiry = parsed['expiry_time'];
        if (expiry != null) {
          final expiryDate = DateTime.parse(expiry).toLocal();
          final now = DateTime.now();
          _remainingSeconds = expiryDate.difference(now).inSeconds;

          if (_remainingSeconds > 0) {
            _startCountdown();
          }
        }
      } catch (_) {}
    } else {
      // Default expired: 24 jam
      _remainingSeconds = 24 * 60 * 60;
      _startCountdown();
    }
  }

  // =========================================================
  // COUNTDOWN
  // =========================================================
  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  // =========================================================
  // FIREBASE LISTENER
  // =========================================================
  void _setupFirebaseListener() {
    final orderId =
        bookingData['order_id']?.toString() ??
        paymentData['order_id']?.toString();

    if (orderId == null || orderId.isEmpty) return;

    _firebaseService.listenToBooking(orderId, (updatedBooking) {
      if (updatedBooking == null || !mounted) return;

      setState(() => bookingData = updatedBooking);

      final status = updatedBooking['status'];

      if (status == 'confirmed' && !isAlreadyPaid) {
        isAlreadyPaid = true;
        _showSuccessDialog();
      }
    });
  }

  // =========================================================
  // SUCCESS POPUP
  // =========================================================
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColor.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppColor.primary, size: 48.sp),
            SizedBox(height: 16.h),
            Text(
              'Pembayaran Berhasil!',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.primary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Terima kasih sudah melakukan pembayaran',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => BaseView()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Ok',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'SemiBold',
                  color: AppColor.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // UTILS
  // =========================================================
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil disalin', style: TextStyle(fontSize: 14.sp)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getPaymentStatus() {
    return bookingData['status']?.toString() ?? 'pending';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // =========================================================
  // UI
  // =========================================================
  @override
  Widget build(BuildContext context) {
    final parsedResponse = paymentData['parsed_gateway_response'] ?? {};
    final paymentStatus = _getPaymentStatus();

    // VA Number
    final vaNumber =
        paymentData['va_number']?.toString() ??
        parsedResponse['va_numbers']?[0]?['va_number']?.toString() ??
        '-';

    // Bank
    final bankName =
        (paymentData['bank']?.toString() ??
                parsedResponse['va_numbers']?[0]?['bank']?.toString() ??
                'BCA')
            .toUpperCase();

    // Amount
    final grossAmount =
        paymentData['gross_amount'] ?? bookingData['total_pembayaran'] ?? 0;

    // Expired date
    String expiredDateStr = '-';
    final paymentDate = paymentData['payment_date'];

    if (paymentDate != null) {
      try {
        final date = DateTime.parse(paymentDate.toString());
        final expired = date.add(const Duration(hours: 24));
        expiredDateStr = formatDate(expired.toIso8601String());
      } catch (_) {}
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BaseView()),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.white,
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => BaseView()),
              );
            },
            icon: Icon(Icons.arrow_back, size: 28.sp, color: AppColor.primary),
          ),
          title: Text(
            'Pembayaran',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'SemiBold',
              color: AppColor.black,
            ),
          ),
        ),

        // BODY ---------------------------------------------------
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Section
              Row(
                children: [
                  Icon(
                    paymentStatus == 'pending'
                        ? Icons.timelapse_sharp
                        : Icons.check_circle,
                    size: 28.sp,
                    color: paymentStatus == 'confirmed'
                        ? Colors.green
                        : Colors.orange,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paymentStatus == 'pending'
                              ? 'Bayar Sebelum'
                              : 'Pembayaran Berhasil',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'SemiBold',
                          ),
                        ),
                        Text(
                          expiredDateStr,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontFamily: 'Medium',
                            color: AppColor.greyPrice,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (paymentStatus == 'pending' && _remainingSeconds > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.sp,
                        horizontal: 16.sp,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(80.r),
                      ),
                      child: Text(
                        formatTime(_remainingSeconds),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontFamily: 'SemiBold',
                          color: AppColor.primary,
                        ),
                      ),
                    ),
                ],
              ),

              const Divider(height: 32),

              // VA Section
              Text(
                'Nomor Virtual Account $bankName',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontFamily: 'Medium',
                  color: AppColor.greyPrice,
                ),
              ),
              SizedBox(height: 8.h),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      vaNumber,
                      style: TextStyle(fontSize: 14.sp, fontFamily: 'SemiBold'),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _copyToClipboard(vaNumber),
                    child: Image.asset(
                      'assets/icons/ic_copy.png',
                      width: 25.w,
                      height: 25.h,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              // Amount
              Text(
                'Total Tagihan',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontFamily: 'Medium',
                  color: AppColor.greyPrice,
                ),
              ),
              SizedBox(height: 8.h),

              Text(
                formatCurrency(grossAmount.toString()),
                style: TextStyle(fontSize: 14.sp, fontFamily: 'SemiBold'),
              ),

              const Divider(height: 32),

              // Instructions
              Text(
                'Cara Bayar',
                style: TextStyle(fontSize: 12.sp, fontFamily: 'SemiBold'),
              ),
              SizedBox(height: 16.h),

              _buildInstructionItem('1. Pilih m-Transfer > Virtual Account'),
              _buildInstructionItem(
                '2. Masukkan nomor Virtual Account $bankName',
              ),
              _buildInstructionItem(
                '3. Periksa informasi dan pastikan total tagihan benar',
              ),
              _buildInstructionItem('4. Masukkan PIN Anda'),
              _buildInstructionItem(
                '5. Simpan bukti pembayaran jika diperlukan',
              ),

              SizedBox(height: 24.h),

              InputFormButton(
                onClick: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => BaseView()),
                  );
                },
                titleText: 'Kembali ke Dashboard',
                color: AppColor.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(fontSize: 12.sp, fontFamily: 'Medium'),
      ),
    );
  }
}
