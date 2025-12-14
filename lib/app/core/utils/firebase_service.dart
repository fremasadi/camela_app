import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// Ambil data booking berdasarkan order_id (hanya cek sekali)
  Future<Map<String, dynamic>?> fetchBookingByOrderId(String orderId) async {
    final snapshot = await _dbRef
        .child('notifications/bookings')
        .orderByChild('order_id')
        .equalTo(orderId)
        .get();

    if (!snapshot.exists) return null;

    final data = snapshot.value as Map<dynamic, dynamic>;
    final key = data.keys.first;

    return {
      'id': key,
      ...Map<String, dynamic>.from(data[key]),
    };
  }

  /// Listen realtime perubahan booking berdasarkan order_id
  void listenToBooking(String orderId, Function(Map<String, dynamic>?) onData) {
    _dbRef
        .child('notifications/bookings')
        .orderByChild('order_id')
        .equalTo(orderId)
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final key = data.keys.first;

        onData({
          'id': key,
          ...Map<String, dynamic>.from(data[key]),
        });
      } else {
        onData(null);
      }
    });
  }
}
