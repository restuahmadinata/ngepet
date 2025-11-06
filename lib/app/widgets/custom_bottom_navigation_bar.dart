import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(iconPaths.length, (index) {
          final isSelected = currentIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: GestureDetector(
              onTap: () => onTap(index),
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
    );
  }
}
