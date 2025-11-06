import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/rectangle_search_bar.dart';
import '../../widgets/pet_list.dart';

class AdoptController extends GetxController {
  var selectedTab = 0.obs; // 0 for Exploring, 1 for Following

  void changeTab(int index) {
    selectedTab.value = index;
  }
}

class AdoptView extends StatelessWidget {
  const AdoptView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AdoptController controller = Get.put(AdoptController());

    final exploringPets = [
      {
        'imageUrl': 'https://images.unsplash.com/photo-1544568100-847a948585b9',
        'name': 'Areeliotus',
        'breed': 'Black Dawg',
        'age': '69 tahun',
        'shelter': 'Thug Hunter Victim Shelter',
        'location': 'Ngawi',
        'gender': 'Non-binary',
      },
      {
        'imageUrl': 'https://images.unsplash.com/photo-1574158622682-e40e69881006',
        'name': 'Buddy',
        'breed': 'Golden Retriever',
        'age': '1 tahun',
        'shelter': 'Shelter B',
        'location': 'Bandung',
        'gender': 'Jantan',
      },
      {
        'imageUrl': 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee',
        'name': 'Luna',
        'breed': 'Siamese',
        'age': '3 tahun',
        'shelter': 'Shelter C',
        'location': 'Surabaya',
        'gender': 'Betina',
      },
    ];

    final followingPets = [
      {
        'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64',
        'name': 'Max',
        'breed': 'Bulldog',
        'age': '4 tahun',
        'shelter': 'Shelter D',
        'location': 'Yogyakarta',
        'gender': 'Jantan',
      },
      {
        'imageUrl': 'https://images.unsplash.com/photo-1516280030429-27679b3dc9cf',
        'name': 'Bella',
        'breed': 'Maine Coon',
        'age': '1.5 tahun',
        'shelter': 'Shelter E',
        'location': 'Semarang',
        'gender': 'Betina',
      },
    ];

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, bottom: 8),
          child: Text(
            'Adopt',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SingleChildScrollView(
            child: Column(
              children: [
                RectangleSearchBar(
                  hintText: 'cari hewan',
                  onChanged: (value) {
                    // Handle search
                  },
                  controller: TextEditingController(),
                ),
                const SizedBox(height: 24),
                Obx(() => Row(
                  children: [
                    GestureDetector(
                      onTap: () => controller.changeTab(0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Exploring',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: controller.selectedTab.value == 0 ? FontWeight.bold : FontWeight.normal,
                              color: controller.selectedTab.value == 0 ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () => controller.changeTab(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Following',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: controller.selectedTab.value == 1 ? FontWeight.bold : FontWeight.normal,
                              color: controller.selectedTab.value == 1 ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 24),
                Obx(() => PetListWidget(
                  pets: controller.selectedTab.value == 0 ? exploringPets : followingPets,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
