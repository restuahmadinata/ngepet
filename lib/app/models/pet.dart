import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

/// Model for Pet/Animal
/// Collection: pets/{petId}
/// All pet data including category and photos stored in one collection
class Pet {
  final String petId;
  final String shelterId;
  final PetCategory category; // Pet type: Dog, Cat, Rabbit, Bird, etc
  final String petName;
  final Gender gender; // Male, Female
  final int ageMonths; // Age must be in months only
  final String breed;
  final String description;
  final String healthCondition;
  final AdoptionStatus adoptionStatus; // available, pending, adopted
  final String location;
  final String shelterName;
  final List<String> imageUrls; // Array of image URLs, index 0 = primary photo/thumbnail
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Pet({
    required this.petId,
    required this.shelterId,
    required this.category,
    required this.petName,
    required this.gender,
    required this.ageMonths,
    required this.breed,
    required this.description,
    required this.healthCondition,
    this.adoptionStatus = AdoptionStatus.available,
    required this.location,
    required this.shelterName,
    this.imageUrls = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to create Pet from Firestore document
  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Pet(
      petId: doc.id,
      shelterId: data['shelterId'] ?? '',
      category: PetCategory.fromString(data['category']),
      petName: data['petName'] ?? '',
      gender: Gender.fromString(data['gender']),
      ageMonths: _parseAgeMonths(data['ageMonths']),
      breed: data['breed'] ?? '',
      description: data['description'] ?? '',
      healthCondition: data['healthCondition'] ?? 'Healthy',
      adoptionStatus: AdoptionStatus.fromString(data['adoptionStatus']),
      location: data['location'] ?? '',
      shelterName: data['shelterName'] ?? '',
      imageUrls: data['imageUrls'] != null 
          ? List<String>.from(data['imageUrls'])
          : [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor to create Pet from Map
  factory Pet.fromMap(Map<String, dynamic> data, String id) {
    return Pet(
      petId: id,
      shelterId: data['shelterId'] ?? '',
      category: PetCategory.fromString(data['category']),
      petName: data['petName'] ?? '',
      gender: Gender.fromString(data['gender']),
      ageMonths: _parseAgeMonths(data['ageMonths']),
      breed: data['breed'] ?? '',
      description: data['description'] ?? '',
      healthCondition: data['healthCondition'] ?? 'Healthy',
      adoptionStatus: AdoptionStatus.fromString(data['adoptionStatus']),
      location: data['location'] ?? '',
      shelterName: data['shelterName'] ?? '',
      imageUrls: data['imageUrls'] != null 
          ? List<String>.from(data['imageUrls'])
          : [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Helper for parsing age in months from various formats
  static int _parseAgeMonths(dynamic age) {
    if (age == null) return 0;
    if (age is int) return age;
    if (age is double) return age.toInt();
    if (age is String) {
      // Try to parse if string format like "3 months"
      final match = RegExp(r'(\d+)').firstMatch(age);
      if (match != null) {
        return int.tryParse(match.group(1) ?? '0') ?? 0;
      }
    }
    return 0;
  }

  /// Convert Pet to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'petId': petId,
      'shelterId': shelterId,
      'category': category.value,
      'petName': petName,
      'gender': gender.value,
      'ageMonths': ageMonths,
      'breed': breed,
      'description': description,
      'healthCondition': healthCondition,
      'adoptionStatus': adoptionStatus.value,
      'location': location,
      'shelterName': shelterName,
      'imageUrls': imageUrls,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Copy with specific changes
  Pet copyWith({
    String? petId,
    String? shelterId,
    PetCategory? category,
    String? petName,
    Gender? gender,
    int? ageMonths,
    String? breed,
    String? description,
    String? healthCondition,
    AdoptionStatus? adoptionStatus,
    String? location,
    String? shelterName,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pet(
      petId: petId ?? this.petId,
      shelterId: shelterId ?? this.shelterId,
      category: category ?? this.category,
      petName: petName ?? this.petName,
      gender: gender ?? this.gender,
      ageMonths: ageMonths ?? this.ageMonths,
      breed: breed ?? this.breed,
      description: description ?? this.description,
      healthCondition: healthCondition ?? this.healthCondition,
      adoptionStatus: adoptionStatus ?? this.adoptionStatus,
      location: location ?? this.location,
      shelterName: shelterName ?? this.shelterName,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Pet(petId: $petId, petName: $petName, category: $category, adoptionStatus: $adoptionStatus)';
  }
}
