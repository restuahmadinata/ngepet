import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AdoptController extends GetxController {}

class AdoptView extends StatelessWidget {
  const AdoptView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adopt'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const SafeArea(child: Center(child: Text('Adopt Page'))),
    );
  }
}
