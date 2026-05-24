import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/url.dart';

class ChatController extends GetxController {
  final textController = TextEditingController();
  final scrollController = ScrollController();

  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Quick replies
  final List<String> quickReplies = [
    'Jam buka salon?',
    'Harga layanan?',
    'Cara booking?',
    'Lokasi salon?',
  ];

  @override
  void onInit() {
    super.onInit();
    _addBotMessage(
      'Halo! 👋 Selamat datang di Camela Salon!\n\n'
      'Saya assistant virtual yang siap membantu Anda. '
      'Ada yang bisa saya bantu hari ini?',
    );
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Send message to Chatbot API
  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    // Add user message
    _addMessage(trimmedText, isUser: true);

    // Clear input
    textController.clear();

    // Show typing indicator
    isLoading.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan. Silakan login terlebih dahulu.');
      }

      // Prepare history for API
      // Limit history to last 20 messages as per documentation
      final historyList = messages.length > 20
          ? messages.sublist(messages.length - 20)
          : messages.toList();

      final history = historyList.map((msg) {
        return {
          'role': msg['isUser'] ? 'user' : 'assistant',
          'content': msg['text'],
        };
      }).toList();

      // Remove the last message (the one we just added) from history 
      // because it's sent in the "message" field
      if (history.isNotEmpty) history.removeLast();

      final response = await http.post(
        Uri.parse(AppUrl.chatbot),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'message': trimmedText,
          'history': history,
        }),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        final reply = data['data']['reply'];
        _addBotMessage(reply);
      } else {
        throw Exception(data['message'] ?? 'Gagal memproses pesan');
      }
    } catch (e) {
      debugPrint('Chatbot Error: $e');
      _addBotMessage(
        'Maaf, saya mengalami kendala teknis saat ini. 😅\n\n'
        'Silakan hubungi kami via WhatsApp untuk bantuan langsung:\n'
        '📱 WhatsApp: 0812-3456-7890',
      );
    } finally {
      isLoading.value = false;
    }
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

  /// Reset chat
  void resetChat() {
    messages.clear();
    _addBotMessage('Chat direset! 🔄\n\nAda yang bisa saya bantu?');
  }
}
