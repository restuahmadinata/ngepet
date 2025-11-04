import 'package:get/get.dart';
import 'package:flutter/material.dart';

class EventController extends GetxController {}

class EventView extends StatelessWidget {
  const EventView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const SafeArea(child: Center(child: Text('Event Page'))),
    );
  }
}
