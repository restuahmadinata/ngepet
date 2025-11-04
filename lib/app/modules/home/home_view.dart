import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../adopt/adopt_view.dart';
import '../event/event_view.dart';
import '../chat/chat_view.dart';
import '../profile/profile_view.dart';
import 'home_controller.dart';
import 'dart:math';


class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = const [
      AdoptView(),
      EventView(),
      HomePage(),
      ChatView(),
      ProfileView(),
    ];

    return Obx(() {
      final currentIndex = controller.currentIndex.value;
      return Scaffold(
        appBar: currentIndex == 2
            ? AppBar(
                title: const Text('Halo, User'),
                elevation: 0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
              )
            : null,
        body: _pages[currentIndex],
        bottomNavigationBar: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final isSelected = currentIndex == index;
              final iconPaths = [
                'assets/images/nav_adopt.svg',
                'assets/images/nav_event.svg',
                'assets/images/nav_home.svg',
                'assets/images/nav_chat.svg',
                'assets/images/nav_profile.svg'
              ];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GestureDetector(
                  onTap: () => controller.changePage(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: SvgPicture.asset(
                        iconPaths[index],
                        colorFilter: ColorFilter.mode(
                          isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).unselectedWidgetColor,
                          BlendMode.srcIn,
                        ),
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      );
    });
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> dummyList = [
      'Selamat datang di Beranda!',
      'Ini adalah konten dummy random.',
      'Semoga harimu menyenangkan!',
      'Jangan lupa tersenyum hari ini.',
      'Ayo eksplor fitur aplikasi!'
    ];
    final random = Random();
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            dummyList[random.nextInt(dummyList.length)],
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
