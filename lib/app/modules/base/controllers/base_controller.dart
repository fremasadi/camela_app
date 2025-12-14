import 'package:get/get.dart';
import 'package:camela_app/app/modules/home/views/home_view.dart';
import 'package:camela_app/app/modules/history/views/history_view.dart';
import 'package:camela_app/app/modules/profile/views/profile_view.dart';
import 'package:flutter/material.dart';

class BaseController extends GetxController {
  final currentIndex = 0.obs;

  // Daftar halaman
  final pages = <Widget>[
    const HomeView(),
    const HistoryView(),
    const ProfileView(),
  ];

  void changePage(int index) {
    currentIndex.value = index;
  }
}
