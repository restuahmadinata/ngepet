import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for Event
/// Collection: events/{eventId}
class Event {
  final String eventId;
  final String shelterId;
  final String eventTitle;
  final String eventDescription;
  final String location;
  final DateTime eventDate;
  final String? eventTime; // Format: HH:mm
  final List<String> imageUrls; // Array of event image URLs
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Event({
    required this.eventId,
    required this.shelterId,
    required this.eventTitle,
    required this.eventDescription,
    required this.location,
    required this.eventDate,
    this.eventTime,
    this.imageUrls = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to create Event from Firestore document
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Event(
      eventId: doc.id,
      shelterId: data['shelterId'] ?? '',
      eventTitle: data['eventTitle'] ?? '',
      eventDescription: data['eventDescription'] ?? '',
      location: data['location'] ?? '',
      eventDate: _parseEventDate(data['eventDate']),
      eventTime: data['eventTime'] ?? data['startTime'], // Fallback to startTime for backward compatibility
      imageUrls: data['imageUrls'] != null 
          ? List<String>.from(data['imageUrls'])
          : [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor to create Event from Map
  factory Event.fromMap(Map<String, dynamic> data, String id) {
    return Event(
      eventId: id,
      shelterId: data['shelterId'] ?? '',
      eventTitle: data['eventTitle'] ?? '',
      eventDescription: data['eventDescription'] ?? '',
      location: data['location'] ?? '',
      eventDate: _parseEventDate(data['eventDate']),
      eventTime: data['eventTime'] ?? data['startTime'], // Fallback to startTime for backward compatibility
      imageUrls: data['imageUrls'] != null 
          ? List<String>.from(data['imageUrls'])
          : [],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Helper to parse event date from various formats
  static DateTime _parseEventDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is DateTime) return date;
    if (date is String) {
      // Coba parse format DD/MM/YYYY
      try {
        final parts = date.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      } catch (e) {
        print('Error parsing date string: $e');
      }
    }
    return DateTime.now();
  }

  /// Convert Event to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'shelterId': shelterId,
      'eventTitle': eventTitle,
      'eventDescription': eventDescription,
      'location': location,
      'eventDate': Timestamp.fromDate(eventDate),
      'eventTime': eventTime,
      'imageUrls': imageUrls,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Copy with specific changes
  Event copyWith({
    String? eventId,
    String? shelterId,
    String? eventTitle,
    String? eventDescription,
    String? location,
    DateTime? eventDate,
    String? eventTime,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      eventId: eventId ?? this.eventId,
      shelterId: shelterId ?? this.shelterId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventDescription: eventDescription ?? this.eventDescription,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Event(eventId: $eventId, eventTitle: $eventTitle, eventDate: $eventDate)';
  }
}
