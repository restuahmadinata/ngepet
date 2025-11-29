import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../adopt/adopt_view.dart';
import '../../../shared/modules/event/event_view.dart';
import '../home/home_view.dart';
import '../../../shared/modules/chat/chat_list_view.dart';
import '../profile/profile_view.dart';
import 'user_navigation_controller.dart';

class UserNavigationView extends GetView<UserNavigationController> {
  const UserNavigationView({super.key});

  final List<Widget> _pages = const [
    AdoptView(),
    EventView(),
    HomePage(),
    ChatListView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = controller.currentIndex.value;
      return Scaffold(
        extendBody: true,
        appBar: currentIndex == 2 // Home index
            ? AppBar(
                automaticallyImplyLeading: false,
                titleSpacing: 16,
                toolbarHeight: 80,
                title: HomeAppBarTitle(),
                elevation: 0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
              )
            : null,
        body: _pages[currentIndex],
        bottomNavigationBar: _buildBottomNavigationBar(context, currentIndex),
      );
    });
  }

  Widget _buildBottomNavigationBar(BuildContext context, int currentIndex) {
    final iconPaths = [
      'assets/images/nav_adopt.svg',
      'assets/images/nav_event.svg',
      'assets/images/nav_home.svg',
      'assets/images/nav_chat.svg',
      'assets/images/nav_profile.svg',
    ];

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(iconPaths.length, (index) {
          final isSelected = currentIndex == index;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.changePage(index),
                splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
                highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 8,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: SvgPicture.asset(
                      iconPaths[index],
                      colorFilter: ColorFilter.mode(
                        isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).unselectedWidgetColor,
                        BlendMode.srcIn,
                      ),
                      width: 28,
                      height: 28,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
