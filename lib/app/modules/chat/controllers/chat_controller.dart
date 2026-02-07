import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatController extends GetxController {
  final textController = TextEditingController();
  final scrollController = ScrollController();

  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // ✅ GEMINI CONFIGURATION
  late GenerativeModel _geminiModel;
  late ChatSession _chatSession;

  // ⚠️ GANTI DENGAN API KEY ANDA
  final String _apiKey = 'AIzaSyDcq6hGjPzEg1hUfvkaNad7BEkGdTGDP10';

  // Quick replies
  final List<String> quickReplies = [
    'Jam buka salon?',
    'Harga layanan?',
    'Cara booking?',
    'Lokasi salon?',
  ];

  // System prompt untuk Gemini (konteks salon)
  final String _systemPrompt = '''
Kamu adalah asisten virtual untuk Salon Camela di Surabaya. 
Berikut informasi penting yang harus kamu ketahui:

INFORMASI SALON:
- Nama: Salon Camela
- Lokasi: Jl. Raya Darmo No. 123, Surabaya, Jawa Timur 60264
- Telepon: (031) 1234-5678
- WhatsApp: 0812-3456-7890

JAM OPERASIONAL:
- Senin - Jumat: 09.00 - 20.00 WIB
- Sabtu - Minggu: 08.00 - 21.00 WIB
- Tanggal Merah: 10.00 - 18.00 WIB

LAYANAN & HARGA:
Hair Care:
- Potong Rambut: Rp 50.000
- Creambath: Rp 75.000
- Hair Coloring: Rp 200.000
- Smoothing: Rp 450.000
- Rebonding: Rp 500.000

Nail Care:
- Manicure: Rp 75.000
- Pedicure: Rp 85.000
- Gel Polish: Rp 150.000
- Nail Art: Rp 100.000

Paket Bundle:
- Hair & Nail Care: Rp 350.000 (Hemat 30%)

CARA BOOKING:
1. Buka menu "Layanan" di aplikasi
2. Pilih layanan yang diinginkan
3. Pilih tanggal dan jam booking
4. Lakukan pembayaran
5. Selesai! Akan dapat konfirmasi

METODE PEMBAYARAN:
- Transfer Bank (BCA, BNI, BRI, Mandiri)
- E-Wallet (GoPay, OVO, Dana, ShopeePay)
- Cash (khusus walk-in)

PROMO BULAN INI:
- Diskon 20% untuk member baru
- Gratis creambath setiap pembelian paket bundling
- Cashback 50rb untuk transaksi di atas 500rb

INSTRUKSI PENTING:
- Jawab dengan ramah, profesional, dan informatif
- Gunakan emoji secukupnya (jangan berlebihan)
- Jawab dalam Bahasa Indonesia
- Jika ditanya di luar konteks salon, arahkan kembali ke topik salon
- Jika tidak tahu jawaban pasti, sarankan untuk menghubungi CS: 0812-3456-7890
- Berikan jawaban singkat dan jelas (maksimal 3 paragraf)
''';

  // FAQ lokal sebagai fallback (jika Gemini error)
  final Map<String, String> _localFallback = {
    'jam':
        'Salon Camela buka setiap hari:\n\n'
        '• Senin - Jumat: 09.00 - 20.00 WIB\n'
        '• Sabtu - Minggu: 08.00 - 21.00 WIB\n'
        '• Tanggal Merah: 10.00 - 18.00 WIB',

    'harga':
        'Berikut daftar layanan dan harga:\n\n'
        '💇 Hair Care: Rp 50.000 - Rp 500.000\n'
        '💅 Nail Care: Rp 75.000 - Rp 150.000\n'
        '🎁 Paket Bundle: Rp 350.000\n\n'
        'Untuk detail lengkap, tanyakan ke saya!',

    'booking':
        'Cara booking:\n'
        '1. Menu "Layanan" → Pilih layanan\n'
        '2. Pilih tanggal & jam\n'
        '3. Bayar → Selesai!\n\n'
        'Booking 1-2 hari sebelumnya lebih baik!',

    'lokasi':
        '📍 Jl. Raya Darmo No. 123, Surabaya\n'
        '📞 (031) 1234-5678\n'
        '📱 WA: 0812-3456-7890',
  };

  @override
  void onInit() {
    super.onInit();
    _initializeGemini();
    _addBotMessage(
      'Halo! 👋 Selamat datang di Camela Salon!\n\n'
      'Saya assistant virtual bertenaga AI yang siap membantu Anda. '
      'Ada yang bisa saya bantu hari ini?',
    );
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// ✅ Initialize Gemini AI
  void _initializeGemini() {
    try {
      _geminiModel = GenerativeModel(
        model: 'gemini-2.5-flash', // ✅ Model terbaru yang stabil
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 500,
        ),
      );

      // Start chat session dengan system prompt
      _chatSession = _geminiModel.startChat(
        history: [
          Content.text(_systemPrompt),
          Content.model([
            TextPart('Baik, saya siap membantu sebagai asisten Salon Camela!'),
          ]),
        ],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ Send message with Gemini integration
  void sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    // Add user message
    _addMessage(trimmedText, isUser: true);

    // Clear input
    textController.clear();

    // Show typing indicator
    isLoading.value = true;

    try {
      // ✅ Try Gemini AI first
      final response = await _getGeminiResponse(trimmedText);

      // Simulate typing delay untuk natural feel
      await Future.delayed(const Duration(milliseconds: 500));

      _addBotMessage(response);
    } catch (e) {
      // ✅ Fallback to local FAQ if Gemini fails
      final fallbackResponse = _getFallbackResponse(trimmedText);
      await Future.delayed(const Duration(milliseconds: 300));
      _addBotMessage(fallbackResponse);
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Get response from Gemini AI
  Future<String> _getGeminiResponse(String userMessage) async {
    try {
      final response = await _chatSession.sendMessage(
        Content.text(userMessage),
      );

      final text = response.text?.trim();

      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      return text;
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ Fallback response (local FAQ)
  String _getFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    // Check keywords
    for (var entry in _localFallback.entries) {
      if (message.contains(entry.key)) {
        return entry.value;
      }
    }

    // Default fallback
    return 'Maaf, saya mengalami kendala teknis 😅\n\n'
        'Silakan hubungi CS kami untuk bantuan lebih lanjut:\n'
        '📱 WhatsApp: 0812-3456-7890\n'
        '📞 Telepon: (031) 1234-5678';
  }

  /// Add message to list
  void _addMessage(String text, {required bool isUser}) {
    messages.add({
      'text': text,
      'isUser': isUser,
      'timestamp': _getCurrentTime(),
    });

    // Auto scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Add bot message
  void _addBotMessage(String text) {
    _addMessage(text, isUser: false);
  }

  /// Get current time formatted
  String _getCurrentTime() {
    return DateFormat('HH:mm').format(DateTime.now());
  }

  /// ✅ Reset chat (optional feature)
  void resetChat() {
    messages.clear();
    _initializeGemini(); // Restart session
    _addBotMessage('Chat direset! 🔄\n\nAda yang bisa saya bantu?');
  }
}
