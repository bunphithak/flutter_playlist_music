import 'package:get/get.dart';

import '../modules/spotify_page/bindings/spotify_page_binding.dart';
import '../modules/spotify_page/views/spotify_page_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPOTIFY_PAGE;

  static final routes = [
    GetPage(
      name: _Paths.SPOTIFY_PAGE,
      page: () =>  SpotifyPageView(),
      binding: SpotifyPageBinding(),
    ),
  ];
}
