import 'package:intl/intl.dart';

String formatDateWithDay(String dateStr) {
  DateTime date = DateTime.parse(dateStr);
  final formatter = DateFormat('EEEE, d MMMM y', 'id_ID');
  return formatter.format(date);
}

String formatRecurringDaysSmart(List<dynamic>? days) {
  if (days == null || days.isEmpty) return '-';

  // Urutan hari dalam bahasa Inggris
  const List<String> fullWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  // Peta untuk terjemahan ke Bahasa Indonesia
  const Map<String, String> dayMap = {
    'monday': 'monday',
    'tuesday': 'tuesday',
    'wednesday': 'wednesday',
    'thursday': 'thursday',
    'friday': 'friday',
    'saturday': 'saturday',
    'sunday': 'sunday',
  };

  // Sortir berdasarkan urutan hari
  List<String> inputDays = days.map((e) => e.toString().toLowerCase()).toList();
  inputDays.sort((a, b) => fullWeek.indexOf(a).compareTo(fullWeek.indexOf(b)));

  // Cek untuk membuat rentang
  List<String> result = [];
  List<String> tempRange = [];

  for (var day in fullWeek) {
    if (inputDays.contains(day)) {
      tempRange.add(day);
    } else {
      if (tempRange.length >= 3) {
        // Kalau ada 3 hari atau lebih, jadiin range
        result.add('${dayMap[tempRange.first]}–${dayMap[tempRange.last]}');
      } else {
        // Kurang dari 3, tampilkan satu-satu
        result.addAll(tempRange.map((d) => dayMap[d]!));
      }
      tempRange.clear();
    }
  }

  // Handle sisa di akhir
  if (tempRange.isNotEmpty) {
    if (tempRange.length >= 3) {
      result.add('${dayMap[tempRange.first]}–${dayMap[tempRange.last]}');
    } else {
      result.addAll(tempRange.map((d) => dayMap[d]!));
    }
  }

  return result.join(', ');
}
