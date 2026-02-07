import 'dart:async';
import 'dart:convert';

import 'package:camela_app/app/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/date_converter.dart';
import '../../../core/utils/date_coverter.dart';
import '../../../core/utils/firebase_service.dart';
import '../../../core/utils/price_converter.dart';
import '../../base/views/base_view.dart';

class GopayPaymentPage extends StatefulWidget {
  const GopayPaymentPage({super.key, required this.response});

  final Map<String, dynamic> response;

  @override
  State<GopayPaymentPage> createState() => _GopayPaymentPageState();
}

class _GopayPaymentPageState extends State<GopayPaymentPage> {
  late Map<String, dynamic> payment;
  late Map<String, dynamic> paymentData;

  // ✅ FIX: Inisialisasi dengan nilai default, bukan late
  int _remainingSeconds = 0;
  Timer? _timer; // ✅ FIX: Gunakan nullable Timer

  final FirebaseService _firebaseService = FirebaseService();
  bool isAlreadyPaid = false;
  bool isLaunchingApp = false;

  void startCountdown() {
    if (_remainingSeconds <= 0) return;

    // ✅ FIX: Cancel existing timer jika ada
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
          }
        });
      }
    });
  }

  Future<void> _launchGoPay() async {
    if (payment['payment_deeplink'] == null) {
      _showErrorDialog('Link pembayaran tidak tersedia');
      return;
    }

    final url = Uri.parse(payment['payment_deeplink']);

    setState(() {
      isLaunchingApp = true;
    });

    try {
      // Coba mode: externalApplication dulu
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      // Kalau gagal, fallback ke inAppWebView
      if (!launched) {
        launched = await launchUrl(
          url,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      }

      if (!launched) {
        _showErrorDialog('Tidak dapat membuka halaman pembayaran');
      }
    } catch (e) {
      _showErrorDialog('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          isLaunchingApp = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          'Error',
          style: TextStyle(
            fontSize: 16.sp,
            fontFamily: 'SemiBold',
            color: Colors.red,
          ),
        ),
        content: Text(message, style: TextStyle(fontSize: 12.sp)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 12.sp,
                fontFamily: 'SemiBold',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    try {
      // Sesuaikan dengan struktur PaymentPage
      final data = widget.response['data'];
      final booking = data?['booking'];
      final paymentResponse = data?['payment'];

      if (booking == null || paymentResponse == null) {
        throw Exception('Data booking atau payment tidak ditemukan');
      }

      // Inisialisasi payment dengan data dari response
      payment = Map<String, dynamic>.from(paymentResponse);

      // Gunakan data booking (bukan infaq)
      paymentData = Map<String, dynamic>.from(booking);

      final paymentGatewayResponse = payment['payment_gateway_response'];

      // Aman dari error JSON, opsional saja sekarang
      dynamic parsedResponse = {};
      try {
        if (paymentGatewayResponse != null &&
            paymentGatewayResponse is String &&
            paymentGatewayResponse.isNotEmpty) {
          parsedResponse = jsonDecode(paymentGatewayResponse);

          if (parsedResponse is String) {
            parsedResponse = jsonDecode(parsedResponse);
          }
        }
      } catch (_) {
        parsedResponse = {};
      }

      // SET VALUE FIXED DARI DATABASE
      payment['payment_deeplink'] = payment['deeplink_url'];
      payment['payment_qr_url'] = payment['qr_url'];

      // ✅ Prioritas: gunakan kolom langsung dari database
      payment['payment_deeplink'] =
          payment['deeplink_url'] ?? payment['payment_url'];
      payment['payment_qr_url'] = payment['qr_url'];

      // ✅ Fallback: parse dari actions jika tidak ada
      if ((payment['payment_deeplink'] == null ||
              payment['payment_qr_url'] == null) &&
          parsedResponse['actions'] != null) {
        if (payment['payment_deeplink'] == null) {
          final deeplink = parsedResponse['actions'].firstWhere(
            (action) => action['name'] == 'deeplink-redirect',
            orElse: () => null,
          )?['url'];

          if (deeplink != null) {
            payment['payment_deeplink'] = deeplink;
          }
        }

        if (payment['payment_qr_url'] == null) {
          final qrAction = parsedResponse['actions'].firstWhere(
            (action) => action['name'] == 'generate-qr-code',
            orElse: () => null,
          );
          if (qrAction != null && qrAction['url'] != null) {
            payment['payment_qr_url'] = qrAction['url'];
          }
        }
      }

      // ✅ Ambil expiry time (prioritas: dari parsed response, fallback ke expired_at)
      String? expiryTimeString = parsedResponse['expiry_time'];

      if (expiryTimeString == null && payment['expired_at'] != null) {
        expiryTimeString = payment['expired_at'];
      }

      if (expiryTimeString == null) {
        // Default: 1 jam dari sekarang jika tidak ada expiry
        _remainingSeconds = 3600;
      } else {
        try {
          final expiryTime = DateTime.parse(expiryTimeString).toLocal();
          final now = DateTime.now();
          _remainingSeconds = expiryTime.difference(now).inSeconds;
          _remainingSeconds = _remainingSeconds > 0 ? _remainingSeconds : 0;
        } catch (e) {
          _remainingSeconds = 3600; // Default 1 jam
        }
      }

      startCountdown();

      // Set up Firebase listener dengan order_id dari booking
      final orderId =
          paymentData['order_id']?.toString() ??
          payment['order_id']?.toString();

      if (orderId != null && orderId.isNotEmpty) {
        _firebaseService.listenToBooking(orderId, (updatedBooking) {
          if (updatedBooking != null && mounted) {
            setState(() {
              paymentData = updatedBooking;
            });

            // Ubah status check menjadi 'confirmed' agar konsisten dengan PaymentPage
            if (updatedBooking['status'] == 'confirmed' && !isAlreadyPaid) {
              isAlreadyPaid = true;
              _showSuccessDialog();
            }
          }
        });
      }
    } catch (e, stackTrace) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memuat halaman pembayaran: $e $stackTrace'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      });
    }
  }

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

  @override
  void dispose() {
    _timer?.cancel(); // ✅ FIX: Safe cancel dengan null check
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BaseView()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.white,
          leading: IconButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BaseView()),
            ),
            icon: Icon(Icons.arrow_back, size: 28.sp, color: AppColor.primary),
          ),
          centerTitle: false,
          title: Text(
            'Pembayaran GoPay',
            style: TextStyle(
              fontSize: 16.sp,
              fontFamily: 'SemiBold',
              color: AppColor.black,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status dan Timer
                Row(
                  children: [
                    if (paymentData['status'] == 'pending')
                      Icon(Icons.timelapse_sharp, size: 28.sp),
                    if (paymentData['status'] == 'confirmed')
                      Icon(
                        Icons.check_circle,
                        size: 28.sp,
                        color: Colors.green,
                      ),

                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (paymentData['status'] == 'pending')
                            Text(
                              'Bayar Sebelum',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: 'SemiBold',
                              ),
                            ),
                          if (paymentData['status'] == 'confirmed')
                            Text(
                              'Pembayaran Berhasil',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontFamily: 'SemiBold',
                              ),
                            ),
                          Text(
                            formatDate(payment['expired_at']),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontFamily: 'Medium',
                              color: AppColor.greyPrice,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (paymentData['status'] == 'pending' &&
                        _remainingSeconds > 0)
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Divider(),
                ),

                // QR Code dan Button
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Scan QR atau buka aplikasi GoPay:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'Medium',
                          color: AppColor.black,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // QR Code
                      if (payment['payment_qr_url'] != null)
                        Container(
                          padding: EdgeInsets.all(16.sp),
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Image.network(
                            payment['payment_qr_url'],
                            width: 200.w,
                            height: 200.w,
                            errorBuilder: (_, _, _) => Container(
                              width: 200.w,
                              height: 200.w,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Text('Gagal memuat QR'),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 20.h),

                      // Button Buka GoPay
                      if (paymentData['status'] == 'pending')
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton.icon(
                            onPressed: isLaunchingApp ? null : _launchGoPay,
                            icon: isLaunchingApp
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    Icons.open_in_new,
                                    color: AppColor.white,
                                    size: 20.sp,
                                  ),
                            label: Text(
                              isLaunchingApp
                                  ? 'Membuka...'
                                  : 'Buka Halaman Pembayaran',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontFamily: 'SemiBold',
                                color: AppColor.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 12.h),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Divider(),
                ),

                // Total Tagihan
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
                  formatCurrency(payment['gross_amount'].toString()),
                  style: TextStyle(fontFamily: 'SemiBold', fontSize: 14.sp),
                ),
                SizedBox(height: 24.h),

                // Instruksi
                Text(
                  'Instruksi Pembayaran GoPay:',
                  style: TextStyle(fontFamily: 'SemiBold', fontSize: 12.sp),
                ),
                SizedBox(height: 12.h),
                Text(
                  '1. Klik tombol "Buka Halaman Pembayaran" di atas.',
                  style: TextStyle(fontSize: 12.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  '2. Atau scan QR code menggunakan aplikasi GoPay.',
                  style: TextStyle(fontSize: 12.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  '3. Pastikan total tagihan sudah benar.',
                  style: TextStyle(fontSize: 12.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  '4. Selesaikan pembayaran di aplikasi GoPay.',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
