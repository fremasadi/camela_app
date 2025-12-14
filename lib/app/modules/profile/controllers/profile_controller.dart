import 'package:get/get.dart';
import 'package:camela_app/app/core/repository/auth/login_repository.dart';
import 'package:camela_app/app/routes/app_pages.dart';

class ProfileController extends GetxController {
  var userData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final user = await LoginRepository.getUser();
    userData.value = user;
  }

  Future<void> logout() async {
    await LoginRepository.logout();
    Get.offAllNamed(Routes.LOGIN);
  }
}
