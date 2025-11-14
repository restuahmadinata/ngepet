import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/pet_photo_helper.dart';

/// Widget untuk mendapatkan primary photo URL dari pet document
class PetPhotoBuilder extends StatelessWidget {
  final String petId;
  final Widget Function(String? photoUrl) builder;
  final String? fallbackUrl;

  const PetPhotoBuilder({
    super.key,
    required this.petId,
    required this.builder,
    this.fallbackUrl,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: PetPhotoHelper().getPrimaryPhotoUrl(petId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return builder(fallbackUrl ?? 'https://via.placeholder.com/300x300?text=Loading');
        }

        final photoUrl = snapshot.data ?? 
                        fallbackUrl ?? 
                        'https://via.placeholder.com/300x300?text=Pet';
        
        return builder(photoUrl);
      },
    );
  }
}

/// Widget untuk mendapatkan semua photos dari pet document
class PetPhotosBuilder extends StatelessWidget {
  final String petId;
  final Widget Function(List<String> photoUrls) builder;

  const PetPhotosBuilder({
    super.key,
    required this.petId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: PetPhotoHelper().getPetPhotoUrls(petId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return builder(['https://via.placeholder.com/300x300?text=Loading']);
        }

        final photoUrls = snapshot.data ?? 
                         ['https://via.placeholder.com/300x300?text=Pet'];
        
        return builder(photoUrls.isEmpty 
            ? ['https://via.placeholder.com/300x300?text=No+Image']
            : photoUrls);
      },
    );
  }
}

/// Stream builder untuk realtime updates
class PetPhotosStream extends StatelessWidget {
  final String petId;
  final Widget Function(List<String> photoUrls) builder;

  const PetPhotosStream({
    super.key,
    required this.petId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: PetPhotoHelper().streamPetPhotos(petId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return builder(['https://via.placeholder.com/300x300?text=Loading']);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return builder(['https://via.placeholder.com/300x300?text=Error']);
        }

        final photos = snapshot.data!;
        
        return builder(photos.isEmpty 
            ? ['https://via.placeholder.com/300x300?text=No+Image']
            : photos);
      },
    );
  }
}

/// Helper untuk mengambil pet data dengan photos
class PetWithPhotos {
  final String petId;
  final Map<String, dynamic> petData;
  final List<String> photoUrls;
  final String primaryPhotoUrl;

  PetWithPhotos({
    required this.petId,
    required this.petData,
    required this.photoUrls,
    required this.primaryPhotoUrl,
  });

  static Future<PetWithPhotos> fromDocument(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final helper = PetPhotoHelper();
    
    // Try to get photos from subcollection first
    final photoUrls = await helper.getPetPhotoUrls(doc.id);
    
    // Fallback to old imageUrls field if subcollection is empty
    final urls = photoUrls.isNotEmpty 
        ? photoUrls 
        : (data['imageUrls'] as List?)?.map((e) => e.toString()).toList() ?? [];
    
    final primaryUrl = urls.isNotEmpty 
        ? urls[0] 
        : 'https://via.placeholder.com/300x300?text=Pet';

    return PetWithPhotos(
      petId: doc.id,
      petData: data,
      photoUrls: urls,
      primaryPhotoUrl: primaryUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'imageUrl': primaryPhotoUrl,
      'imageUrls': photoUrls,
      'name': petData['name'] ?? 'Pet Name',
      'breed': petData['breed'] ?? 'Breed',
      'age': petData['age'] ?? 'Age',
      'shelter': petData['shelterName'] ?? 'Shelter',
      'shelterName': petData['shelterName'] ?? 'Shelter',
      'location': petData['location'] ?? 'Location',
      'gender': petData['gender'] ?? 'Male',
      'description': petData['description'] ?? '',
      'type': petData['type'] ?? '',
      'status': petData['status'] ?? 'available',
      'shelterId': petData['shelterId'] ?? '',
    };
  }
}
