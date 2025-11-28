/// Enums for type-safe field values across the application
/// This ensures data consistency in Firestore
library;

enum BirdBreed {
  parakeet('Parakeet'),
  cockatiel('Cockatiel'),
  lovebird('Lovebird'),
  canary('Canary'),
  finch('Finch'),
  africanGrey('African Grey'),
  macaw('Macaw'),
  budgerigar('Budgerigar'),
  conure('Conure'),
  other('Other');

  final String value;
  const BirdBreed(this.value);

  static BirdBreed fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'parakeet':
        return BirdBreed.parakeet;
      case 'cockatiel':
        return BirdBreed.cockatiel;
      case 'lovebird':
        return BirdBreed.lovebird;
      case 'canary':
        return BirdBreed.canary;
      case 'finch':
        return BirdBreed.finch;
      case 'african grey':
        return BirdBreed.africanGrey;
      case 'macaw':
        return BirdBreed.macaw;
      case 'budgerigar':
        return BirdBreed.budgerigar;
      case 'conure':
        return BirdBreed.conure;
      case 'other':
        return BirdBreed.other;
      default:
        return BirdBreed.other;
    }
  }

  static List<String> get allValues => BirdBreed.values.map((e) => e.value).toList();
}

enum HamsterBreed {
  syrian('Syrian'),
  dwarfCampbell('Dwarf Campbell'),
  dwarfWinterWhite('Dwarf Winter White'),
  roborovski('Roborovski'),
  chinese('Chinese'),
  russian('Russian'),
  other('Other');

  final String value;
  const HamsterBreed(this.value);

  static HamsterBreed fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'syrian':
        return HamsterBreed.syrian;
      case 'dwarf campbell':
        return HamsterBreed.dwarfCampbell;
      case 'dwarf winter white':
        return HamsterBreed.dwarfWinterWhite;
      case 'roborovski':
        return HamsterBreed.roborovski;
      case 'chinese':
        return HamsterBreed.chinese;
      case 'russian':
        return HamsterBreed.russian;
      case 'other':
        return HamsterBreed.other;
      default:
        return HamsterBreed.other;
    }
  }

  static List<String> get allValues => HamsterBreed.values.map((e) => e.value).toList();
}

enum GuineaPigBreed {
  american('American'),
  abyssinian('Abyssinian'),
  peruvian('Peruvian'),
  silkie('Silkie'),
  teddy('Teddy'),
  texel('Texel'),
  whiteCrested('White Crested'),
  other('Other');

  final String value;
  const GuineaPigBreed(this.value);

  static GuineaPigBreed fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'american':
        return GuineaPigBreed.american;
      case 'abyssinian':
        return GuineaPigBreed.abyssinian;
      case 'peruvian':
        return GuineaPigBreed.peruvian;
      case 'silkie':
        return GuineaPigBreed.silkie;
      case 'teddy':
        return GuineaPigBreed.teddy;
      case 'texel':
        return GuineaPigBreed.texel;
      case 'white crested':
        return GuineaPigBreed.whiteCrested;
      case 'other':
        return GuineaPigBreed.other;
      default:
        return GuineaPigBreed.other;
    }
  }

  static List<String> get allValues => GuineaPigBreed.values.map((e) => e.value).toList();
}

enum FishBreed {
  goldfish('Goldfish'),
  betta('Betta'),
  guppy('Guppy'),
  molly('Molly'),
  tetra('Tetra'),
  angelfish('Angelfish'),
  cichlid('Cichlid'),
  platy('Platy'),
  swordtail('Swordtail'),
  other('Other');

  final String value;
  const FishBreed(this.value);

  static FishBreed fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'goldfish':
        return FishBreed.goldfish;
      case 'betta':
        return FishBreed.betta;
      case 'guppy':
        return FishBreed.guppy;
      case 'molly':
        return FishBreed.molly;
      case 'tetra':
        return FishBreed.tetra;
      case 'angelfish':
        return FishBreed.angelfish;
      case 'cichlid':
        return FishBreed.cichlid;
      case 'platy':
        return FishBreed.platy;
      case 'swordtail':
        return FishBreed.swordtail;
      case 'other':
        return FishBreed.other;
      default:
        return FishBreed.other;
    }
  }

  static List<String> get allValues => FishBreed.values.map((e) => e.value).toList();
}

enum TurtleBreed {
  redEaredSlider('Red-Eared Slider'),
  paintedTurtle('Painted Turtle'),
  boxTurtle('Box Turtle'),
  mapTurtle('Map Turtle'),
  muskTurtle('Musk Turtle'),
  snappingTurtle('Snapping Turtle'),
  softshellTurtle('Softshell Turtle'),
  other('Other');

  final String value;
  const TurtleBreed(this.value);

  static TurtleBreed fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'red-eared slider':
        return TurtleBreed.redEaredSlider;
      case 'painted turtle':
        return TurtleBreed.paintedTurtle;
      case 'box turtle':
        return TurtleBreed.boxTurtle;
      case 'map turtle':
        return TurtleBreed.mapTurtle;
      case 'musk turtle':
        return TurtleBreed.muskTurtle;
      case 'snapping turtle':
        return TurtleBreed.snappingTurtle;
      case 'softshell turtle':
        return TurtleBreed.softshellTurtle;
      case 'other':
        return TurtleBreed.other;
      default:
        return TurtleBreed.other;
    }
  }

  static List<String> get allValues => TurtleBreed.values.map((e) => e.value).toList();
}

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

// ==================== BREED ENUMS ====================

enum DogBreed {
  goldenRetriever('Golden Retriever'),
  labrador('Labrador Retriever'),
  germanShepherd('German Shepherd'),
  poodle('Poodle'),
  bulldog('Bulldog'),
  beagle('Beagle'),
  shihTzu('Shih Tzu'),
  pomeranian('Pomeranian'),
  husky('Siberian Husky'),
  dachshund('Dachshund'),
  other('Other');

  final String value;
  const DogBreed(this.value);

  static DogBreed fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'golden retriever':
        return DogBreed.goldenRetriever;
      case 'labrador retriever':
      case 'labrador':
        return DogBreed.labrador;
      case 'german shepherd':
        return DogBreed.germanShepherd;
      case 'poodle':
        return DogBreed.poodle;
      case 'bulldog':
        return DogBreed.bulldog;
      case 'beagle':
        return DogBreed.beagle;
      case 'shih tzu':
        return DogBreed.shihTzu;
      case 'pomeranian':
        return DogBreed.pomeranian;
      case 'siberian husky':
      case 'husky':
        return DogBreed.husky;
      case 'dachshund':
        return DogBreed.dachshund;
      case 'other':
        return DogBreed.other;
      default:
        return DogBreed.other;
    }
  }

  static List<String> get allValues => DogBreed.values.map((e) => e.value).toList();
}

enum CatBreed {
  persian('Persian'),
  siamese('Siamese'),
  maineCoon('Maine Coon'),
  bengal('Bengal'),
  sphynx('Sphynx'),
  ragdoll('Ragdoll'),
  britishShorthair('British Shorthair'),
  scottishFold('Scottish Fold'),
  munchkin('Munchkin'),
  other('Other');

  final String value;
  const CatBreed(this.value);

  static CatBreed fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'persian':
        return CatBreed.persian;
      case 'siamese':
        return CatBreed.siamese;
      case 'maine coon':
        return CatBreed.maineCoon;
      case 'bengal':
        return CatBreed.bengal;
      case 'sphynx':
        return CatBreed.sphynx;
      case 'ragdoll':
        return CatBreed.ragdoll;
      case 'british shorthair':
        return CatBreed.britishShorthair;
      case 'scottish fold':
        return CatBreed.scottishFold;
      case 'munchkin':
        return CatBreed.munchkin;
      case 'other':
        return CatBreed.other;
      default:
        return CatBreed.other;
    }
  }

  static List<String> get allValues => CatBreed.values.map((e) => e.value).toList();
}

enum RabbitBreed {
  hollandLop('Holland Lop'),
  netherlandDwarf('Netherland Dwarf'),
  rex('Rex'),
  lionhead('Lionhead'),
  miniRex('Mini Rex'),
  flemishGiant('Flemish Giant'),
  angora('Angora'),
  other('Other');

  final String value;
  const RabbitBreed(this.value);

  static RabbitBreed fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'holland lop':
        return RabbitBreed.hollandLop;
      case 'netherland dwarf':
        return RabbitBreed.netherlandDwarf;
      case 'rex':
        return RabbitBreed.rex;
      case 'lionhead':
        return RabbitBreed.lionhead;
      case 'mini rex':
        return RabbitBreed.miniRex;
      case 'flemish giant':
        return RabbitBreed.flemishGiant;
      case 'angora':
        return RabbitBreed.angora;
      case 'other':
        return RabbitBreed.other;
      default:
        return RabbitBreed.other;
    }
  }

  static List<String> get allValues => RabbitBreed.values.map((e) => e.value).toList();
}

// Add more breed enums for other pet types as needed (BirdBreed, HamsterBreed, etc.)

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

// ==================== CHAT & MESSAGING ENUMS ====================

/// Sender type for messages
enum SenderType {
  user('user'),
  shelter('shelter');

  final String value;
  const SenderType(this.value);

  static SenderType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'user':
        return SenderType.user;
      case 'shelter':
        return SenderType.shelter;
      default:
        return SenderType.user;
    }
  }
}

/// Message type for chat messages
enum MessageType {
  text('text'),
  image('image'),
  deleted('deleted');

  final String value;
  const MessageType(this.value);

  static MessageType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'deleted':
        return MessageType.deleted;
      default:
        return MessageType.text;
    }
  }
}
