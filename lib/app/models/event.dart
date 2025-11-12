import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk Event
/// Collection: events/{eventId}
class Event {
  final String eventId;
  final String shelterId;
  final String judulEvent;
  final String deskripsiEvent;
  final String lokasi;
  final DateTime tanggalEvent;
  final String? waktuMulai; // Format: HH:mm
  final String? waktuSelesai; // Format: HH:mm
  final String? fotoBanner;
  final String statusEvent; // 'upcoming', 'ongoing', 'completed', 'cancelled'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Event({
    required this.eventId,
    required this.shelterId,
    required this.judulEvent,
    required this.deskripsiEvent,
    required this.lokasi,
    required this.tanggalEvent,
    this.waktuMulai,
    this.waktuSelesai,
    this.fotoBanner,
    this.statusEvent = 'upcoming',
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor untuk membuat Event dari Firestore document
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Event(
      eventId: doc.id,
      shelterId: data['shelterId'] ?? '',
      judulEvent: data['judulEvent'] ?? data['title'] ?? '',
      deskripsiEvent: data['deskripsiEvent'] ?? data['description'] ?? '',
      lokasi: data['lokasi'] ?? data['location'] ?? '',
      tanggalEvent: _parseTanggalEvent(data['tanggalEvent'] ?? data['dateTime']),
      waktuMulai: data['waktuMulai'] ?? data['startTime'],
      waktuSelesai: data['waktuSelesai'] ?? data['endTime'],
      fotoBanner: data['fotoBanner'] ?? data['banner'] ?? data['imageUrl'],
      statusEvent: data['statusEvent'] ?? data['status'] ?? 'upcoming',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor untuk membuat Event dari Map
  factory Event.fromMap(Map<String, dynamic> data, String id) {
    return Event(
      eventId: id,
      shelterId: data['shelterId'] ?? '',
      judulEvent: data['judulEvent'] ?? data['title'] ?? '',
      deskripsiEvent: data['deskripsiEvent'] ?? data['description'] ?? '',
      lokasi: data['lokasi'] ?? data['location'] ?? '',
      tanggalEvent: _parseTanggalEvent(data['tanggalEvent'] ?? data['dateTime']),
      waktuMulai: data['waktuMulai'] ?? data['startTime'],
      waktuSelesai: data['waktuSelesai'] ?? data['endTime'],
      fotoBanner: data['fotoBanner'] ?? data['banner'] ?? data['imageUrl'],
      statusEvent: data['statusEvent'] ?? data['status'] ?? 'upcoming',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Helper untuk parsing tanggal event dari berbagai format
  static DateTime _parseTanggalEvent(dynamic date) {
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

  /// Konversi Event ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'shelterId': shelterId,
      'judulEvent': judulEvent,
      'deskripsiEvent': deskripsiEvent,
      'lokasi': lokasi,
      'tanggalEvent': Timestamp.fromDate(tanggalEvent),
      'waktuMulai': waktuMulai,
      'waktuSelesai': waktuSelesai,
      'fotoBanner': fotoBanner,
      'statusEvent': statusEvent,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Copy dengan perubahan tertentu
  Event copyWith({
    String? eventId,
    String? shelterId,
    String? judulEvent,
    String? deskripsiEvent,
    String? lokasi,
    DateTime? tanggalEvent,
    String? waktuMulai,
    String? waktuSelesai,
    String? fotoBanner,
    String? statusEvent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      eventId: eventId ?? this.eventId,
      shelterId: shelterId ?? this.shelterId,
      judulEvent: judulEvent ?? this.judulEvent,
      deskripsiEvent: deskripsiEvent ?? this.deskripsiEvent,
      lokasi: lokasi ?? this.lokasi,
      tanggalEvent: tanggalEvent ?? this.tanggalEvent,
      waktuMulai: waktuMulai ?? this.waktuMulai,
      waktuSelesai: waktuSelesai ?? this.waktuSelesai,
      fotoBanner: fotoBanner ?? this.fotoBanner,
      statusEvent: statusEvent ?? this.statusEvent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Event(eventId: $eventId, judulEvent: $judulEvent, tanggalEvent: $tanggalEvent)';
  }
}
