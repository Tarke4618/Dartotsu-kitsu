import 'package:dartotsu/Services/Screens/BaseAnimeScreen.dart';
import 'package:dartotsu/Services/Screens/BaseHomeScreen.dart';
import 'package:dartotsu/Services/Screens/BaseMangaScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../Services/BaseServiceData.dart';
import '../../Services/MediaService.dart';
import '../../Services/Screens/BaseLoginScreen.dart';
import '../../Theme/LanguageSwitcher.dart';
import 'KitsuData.dart';

class KitsuService extends MediaService {
  KitsuService() {
    Kitsu.getSavedToken();
  }

  @override
  String get getName => getString.kitsu;

  @override
  String get iconPath => "assets/svg/kitsu.svg";

  @override
  BaseServiceData get data => Kitsu;

  @override
  BaseHomeScreen? get homeScreen => null;

  @override
  BaseAnimeScreen? get animeScreen => null;

  @override
  BaseMangaScreen? get mangaScreen => null;

  @override
  BaseLoginScreen get loginScreen =>
      Get.put(KitsuLoginScreen(Kitsu), tag: "KitsuLoginScreen");
}

class KitsuLoginScreen extends BaseLoginScreen {
  final KitsuController kitsu;

  KitsuLoginScreen(this.kitsu);

  @override
  void login(BuildContext context) => kitsu.login(context);
}
