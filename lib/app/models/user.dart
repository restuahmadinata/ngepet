import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

/// Model for User
/// Collection: users/{userId}
class User {
  final String userId;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final DateTime? dateOfBirth;
  final Gender? gender; // Male, Female
  final String? profilePhoto;
  final AccountStatus accountStatus; // active, suspended, banned
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.userId,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.address,
    this.city,
    this.dateOfBirth,
    this.gender,
    this.profilePhoto,
    this.accountStatus = AccountStatus.active,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to create User from Firestore document
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return User(
      userId: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      city: data['city'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      gender: data['gender'] != null ? Gender.fromString(data['gender']) : null,
      profilePhoto: data['profilePhoto'],
      accountStatus: AccountStatus.fromString(data['accountStatus']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor to create User from Map
  factory User.fromMap(Map<String, dynamic> data, String id) {
    return User(
      userId: id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      city: data['city'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      gender: data['gender'] != null ? Gender.fromString(data['gender']) : null,
      profilePhoto: data['profilePhoto'],
      accountStatus: AccountStatus.fromString(data['accountStatus']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert User to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender?.value,
      'profilePhoto': profilePhoto,
      'accountStatus': accountStatus.value,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Copy with specific changes
  User copyWith({
    String? userId,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? city,
    DateTime? dateOfBirth,
    Gender? gender,
    String? profilePhoto,
    AccountStatus? accountStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      accountStatus: accountStatus ?? this.accountStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(userId: $userId, fullName: $fullName, email: $email, accountStatus: $accountStatus)';
  }
}
