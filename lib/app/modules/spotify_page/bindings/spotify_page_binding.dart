import 'package:get/get.dart';

import '../controllers/spotify_page_controller.dart';

class SpotifyPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpotifyController>(
      () => SpotifyController(),
    );
  }
}
