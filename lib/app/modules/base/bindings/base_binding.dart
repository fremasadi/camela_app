import 'package:camela_app/app/modules/history/controllers/history_controller.dart';
import 'package:camela_app/app/modules/home/controllers/home_controller.dart';
import 'package:camela_app/app/modules/profile/controllers/profile_controller.dart';
import 'package:get/get.dart';

import '../controllers/base_controller.dart';

class BaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BaseController());
    Get.put(ProfileController());
    Get.put(HomeController());
    Get.put(HistoryController());

  }
}
