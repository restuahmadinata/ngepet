import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/shared/modules/pet_detail/pet_detail_view.dart';

class PetListItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String breed;
  final String age;
  final String shelter;
  final String location;
  final String gender;
  final VoidCallback? onAdoptPressed;
  final Map<String, dynamic>? fullData;

  const PetListItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.breed,
    required this.age,
    required this.shelter,
    required this.location,
    required this.gender,
    this.onAdoptPressed,
    this.fullData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (fullData != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetDetailView(petData: fullData!),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    httpHeaders: const {
                      'Connection': 'keep-alive',
                      'User-Agent': 'Flutter App',
                    },
                    maxHeightDiskCache: 600,
                    maxWidthDiskCache: 600,
                    memCacheHeight: 600,
                    memCacheWidth: 600,
                    fadeInDuration: const Duration(milliseconds: 500),
                    fadeOutDuration: const Duration(milliseconds: 200),
                    placeholder: (context, url) => Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) {
                      print('Error loading image: $url');
                      print('Error details: $error');
                      return Container(
                        width: 150,
                        height: 150,
                        color: Colors.grey.shade300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 48,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Failed to load photo',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                      const SizedBox(height: 0),
                      Text(
                        '$breed - $age months',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                        softWrap: true,
                      ),
                      Row(
                        children: [
                          Icon(
                            gender == 'Male' ? Icons.male : Icons.female,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              gender,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.home, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              shelter,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: onAdoptPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.withOpacity(0.1),
                          foregroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Ajukan Adopsi'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PetListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> pets;

  const PetListWidget({super.key, required this.pets});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        return PetListItem(
          imageUrl: pet['imageUrl']?.toString() ?? '',
          name: pet['name']?.toString() ?? '',
          breed: pet['breed']?.toString() ?? '',
          age: pet['age']?.toString() ?? '',
          shelter: pet['shelter']?.toString() ?? '',
          location: pet['location']?.toString() ?? '',
          gender: pet['gender']?.toString() ?? '',
          fullData: pet,
          onAdoptPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mengajukan adopsi untuk ${pet['name']}')),
            );
          },
        );
      },
    );
  }
}
