import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(iconPaths.length, (index) {
          final isSelected = currentIndex == index;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onTap(index),
                splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
                highlightColor: Theme.of(
                  context,
                ).primaryColor.withOpacity(0.05),
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
