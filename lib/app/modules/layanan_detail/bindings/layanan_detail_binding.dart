import 'package:get/get.dart';

import '../controllers/layanan_detail_controller.dart';

class LayananDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LayananDetailController>(
      () => LayananDetailController(),
    );
  }
}
