
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ngepet/app/widgets/button1.dart';
import 'package:ngepet/app/controllers/auth_controller.dart';

class ProfileController extends GetxController {}

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Profile Page'),
              const SizedBox(height: 20),
              Button1(
                onPressed: () async {
                  await Get.find<AuthController>().signOut();
                },
                text: 'Logout',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
