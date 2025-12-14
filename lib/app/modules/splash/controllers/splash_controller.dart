import 'package:get/get.dart';
import 'package:camela_app/app/core/repository/auth/login_repository.dart';
import 'package:camela_app/app/routes/app_pages.dart';

class SplashController extends GetxController {
  // State untuk menentukan tampilan
  final isChecking = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2)); // efek splash

    final token = await LoginRepository.getToken();

    if (token != null) {
      print(token);
      Get.offAllNamed(Routes.BASE);
    } else {
      // ubah state → tampilkan UI welcome
      isChecking.value = false;
    }
  }
}
