import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/navigation/bottom_nav_navigation.dart';

class ConciergeController extends GetxController {
  static const int homeNavigationIndex = BottomNavNavigation.homeIndex;
  static const int mapNavigationIndex = BottomNavNavigation.mapIndex;
  static const int bookingNavigationIndex = BottomNavNavigation.bookingIndex;
  static const int chatNavigationIndex = BottomNavNavigation.chatIndex;
  static const int profileNavigationIndex = BottomNavNavigation.profileIndex;

  final TextEditingController messageController = TextEditingController();

  void sendMessage() {
    if (messageController.text.trim().isEmpty) {
      return;
    }

    messageController.clear();
  }

  void exploreGildedOlive() {}

  void handleBottomNavigation(int index) {
    BottomNavNavigation.handle(
      index,
      currentIndex: chatNavigationIndex,
    );
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
