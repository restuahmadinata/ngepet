/// Enums for type-safe field values across the application
/// This ensures data consistency in Firestore

// ==================== USER ENUMS ====================

/// Gender options for users and potentially other entities
enum Gender {
  male('Male'),
  female('Female');

  final String value;
  const Gender(this.value);

  static Gender fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.male; // Default value
    }
  }
}

/// Account status for users
enum AccountStatus {
  active('active'),
  suspended('suspended'),
  banned('banned');

  final String value;
  const AccountStatus(this.value);

  static AccountStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'active':
        return AccountStatus.active;
      case 'suspended':
        return AccountStatus.suspended;
      case 'banned':
        return AccountStatus.banned;
      default:
        return AccountStatus.active;
    }
  }
}

// ==================== SHELTER ENUMS ====================

/// Verification status for shelters
enum VerificationStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  final String value;
  const VerificationStatus(this.value);

  static VerificationStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return VerificationStatus.pending;
      case 'approved':
        return VerificationStatus.approved;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
    }
  }
}

// ==================== PET ENUMS ====================

/// Pet categories - extensible list of common pet types
enum PetCategory {
  dog('Dog'),
  cat('Cat'),
  rabbit('Rabbit'),
  bird('Bird'),
  hamster('Hamster'),
  guineaPig('Guinea Pig'),
  fish('Fish'),
  turtle('Turtle'),
  other('Other');

  final String value;
  const PetCategory(this.value);

  static PetCategory fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'dog':
        return PetCategory.dog;
      case 'cat':
        return PetCategory.cat;
      case 'rabbit':
        return PetCategory.rabbit;
      case 'bird':
        return PetCategory.bird;
      case 'hamster':
        return PetCategory.hamster;
      case 'guinea pig':
        return PetCategory.guineaPig;
      case 'fish':
        return PetCategory.fish;
      case 'turtle':
        return PetCategory.turtle;
      case 'other':
        return PetCategory.other;
      default:
        return PetCategory.other;
    }
  }

  /// Get all category values for dropdowns
  static List<String> get allValues => 
      PetCategory.values.map((e) => e.value).toList();
}

/// Adoption status for pets
enum AdoptionStatus {
  available('available'),
  pending('pending'),
  adopted('adopted');

  final String value;
  const AdoptionStatus(this.value);

  static AdoptionStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'available':
        return AdoptionStatus.available;
      case 'pending':
        return AdoptionStatus.pending;
      case 'adopted':
        return AdoptionStatus.adopted;
      default:
        return AdoptionStatus.available;
    }
  }
}

// ==================== ADOPTION APPLICATION ENUMS ====================

/// Residence status for adoption applications
enum ResidenceStatus {
  ownHouse('own_house', 'Own House'),
  rental('rental', 'Rental'),
  boarding('boarding', 'Boarding');

  final String value;
  final String displayName;
  const ResidenceStatus(this.value, this.displayName);

  static ResidenceStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'own_house':
        return ResidenceStatus.ownHouse;
      case 'rental':
        return ResidenceStatus.rental;
      case 'boarding':
        return ResidenceStatus.boarding;
      default:
        return ResidenceStatus.ownHouse;
    }
  }

  static List<String> get allDisplayNames => 
      ResidenceStatus.values.map((e) => e.displayName).toList();
}

/// Application status for adoption requests
enum ApplicationStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  completed('completed');

  final String value;
  const ApplicationStatus(this.value);

  static ApplicationStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return ApplicationStatus.pending;
      case 'approved':
        return ApplicationStatus.approved;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'completed':
        return ApplicationStatus.completed;
      default:
        return ApplicationStatus.pending;
    }
  }
}

/// Request status for the initial application stage
enum RequestStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  final String value;
  const RequestStatus(this.value);

  static RequestStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return RequestStatus.pending;
      case 'approved':
        return RequestStatus.approved;
      case 'rejected':
        return RequestStatus.rejected;
      default:
        return RequestStatus.pending;
    }
  }
}

/// Survey status for the survey stage
enum SurveyStatus {
  notStarted('not_started'),
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  final String value;
  const SurveyStatus(this.value);

  static SurveyStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'not_started':
        return SurveyStatus.notStarted;
      case 'pending':
        return SurveyStatus.pending;
      case 'approved':
        return SurveyStatus.approved;
      case 'rejected':
        return SurveyStatus.rejected;
      default:
        return SurveyStatus.notStarted;
    }
  }
}

/// Handover status for the final handover stage
enum HandoverStatus {
  notStarted('not_started'),
  pending('pending'),
  completed('completed');

  final String value;
  const HandoverStatus(this.value);

  static HandoverStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'not_started':
        return HandoverStatus.notStarted;
      case 'pending':
        return HandoverStatus.pending;
      case 'completed':
        return HandoverStatus.completed;
      default:
        return HandoverStatus.notStarted;
    }
  }
}

// ==================== EVENT ENUMS ====================

/// Event status
enum EventStatus {
  upcoming('upcoming'),
  ongoing('ongoing'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const EventStatus(this.value);

  static EventStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'upcoming':
        return EventStatus.upcoming;
      case 'ongoing':
        return EventStatus.ongoing;
      case 'completed':
        return EventStatus.completed;
      case 'cancelled':
        return EventStatus.cancelled;
      default:
        return EventStatus.upcoming;
    }
  }
}

// ==================== REPORT ENUMS ====================

/// Entity type for reports
enum EntityType {
  user('user'),
  shelter('shelter'),
  pet('pet');

  final String value;
  const EntityType(this.value);

  static EntityType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'user':
        return EntityType.user;
      case 'shelter':
        return EntityType.shelter;
      case 'pet':
        return EntityType.pet;
      default:
        return EntityType.user;
    }
  }
}

/// Violation category for reports
enum ViolationCategory {
  fraud('fraud', 'Fraud'),
  animalAbuse('animal_abuse', 'Animal Abuse'),
  spam('spam', 'Spam'),
  inappropriateContent('inappropriate_content', 'Inappropriate Content');

  final String value;
  final String displayName;
  const ViolationCategory(this.value, this.displayName);

  static ViolationCategory fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'fraud':
        return ViolationCategory.fraud;
      case 'animal_abuse':
        return ViolationCategory.animalAbuse;
      case 'spam':
        return ViolationCategory.spam;
      case 'inappropriate_content':
        return ViolationCategory.inappropriateContent;
      default:
        return ViolationCategory.spam;
    }
  }

  static List<String> get allDisplayNames => 
      ViolationCategory.values.map((e) => e.displayName).toList();
}

/// Report status
enum ReportStatus {
  pending('pending'),
  reviewing('reviewing'),
  resolved('resolved'),
  rejected('rejected');

  final String value;
  const ReportStatus(this.value);

  static ReportStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return ReportStatus.pending;
      case 'reviewing':
        return ReportStatus.reviewing;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.pending;
    }
  }
}

// ==================== SUSPENSION ENUMS ====================

/// Suspension status
enum SuspensionStatus {
  active('active'),
  lifted('lifted'),
  expired('expired');

  final String value;
  const SuspensionStatus(this.value);

  static SuspensionStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'active':
        return SuspensionStatus.active;
      case 'lifted':
        return SuspensionStatus.lifted;
      case 'expired':
        return SuspensionStatus.expired;
      default:
        return SuspensionStatus.active;
    }
  }
}
