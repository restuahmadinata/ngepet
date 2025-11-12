import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk Laporan
/// Collection: laporan/{laporanId}
class Report {
  final String laporanId;
  final String pelaporId;
  final String terlaporId;
  final String jenisEntitas; // 'user', 'shelter', 'pet'
  final String kategoriPelanggaran; // 'penipuan', 'kekerasan_hewan', 'spam', 'konten_tidak_pantas'
  final String deskripsiLaporan;
  final String? lokasiKejadian;
  final String? buktiLampiran;
  final String statusLaporan; // 'pending', 'reviewing', 'resolved', 'rejected'
  final String? adminId;
  final String? catatanAdmin;
  final DateTime? tanggalLaporan;
  final DateTime? tanggalDitinjau;

  Report({
    required this.laporanId,
    required this.pelaporId,
    required this.terlaporId,
    required this.jenisEntitas,
    required this.kategoriPelanggaran,
    required this.deskripsiLaporan,
    this.lokasiKejadian,
    this.buktiLampiran,
    this.statusLaporan = 'pending',
    this.adminId,
    this.catatanAdmin,
    this.tanggalLaporan,
    this.tanggalDitinjau,
  });

  /// Factory constructor untuk membuat Report dari Firestore document
  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Report(
      laporanId: doc.id,
      pelaporId: data['pelaporId'] ?? data['reporterId'] ?? '',
      terlaporId: data['terlaporId'] ?? data['reportedId'] ?? '',
      jenisEntitas: data['jenisEntitas'] ?? data['entityType'] ?? '',
      kategoriPelanggaran: data['kategoriPelanggaran'] ?? data['violationCategory'] ?? '',
      deskripsiLaporan: data['deskripsiLaporan'] ?? data['description'] ?? '',
      lokasiKejadian: data['lokasiKejadian'] ?? data['location'],
      buktiLampiran: data['buktiLampiran'] ?? data['evidence'],
      statusLaporan: data['statusLaporan'] ?? data['status'] ?? 'pending',
      adminId: data['adminId'],
      catatanAdmin: data['catatanAdmin'] ?? data['adminNotes'],
      tanggalLaporan: (data['tanggalLaporan'] as Timestamp?)?.toDate(),
      tanggalDitinjau: (data['tanggalDitinjau'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor untuk membuat Report dari Map
  factory Report.fromMap(Map<String, dynamic> data, String id) {
    return Report(
      laporanId: id,
      pelaporId: data['pelaporId'] ?? data['reporterId'] ?? '',
      terlaporId: data['terlaporId'] ?? data['reportedId'] ?? '',
      jenisEntitas: data['jenisEntitas'] ?? data['entityType'] ?? '',
      kategoriPelanggaran: data['kategoriPelanggaran'] ?? data['violationCategory'] ?? '',
      deskripsiLaporan: data['deskripsiLaporan'] ?? data['description'] ?? '',
      lokasiKejadian: data['lokasiKejadian'] ?? data['location'],
      buktiLampiran: data['buktiLampiran'] ?? data['evidence'],
      statusLaporan: data['statusLaporan'] ?? data['status'] ?? 'pending',
      adminId: data['adminId'],
      catatanAdmin: data['catatanAdmin'] ?? data['adminNotes'],
      tanggalLaporan: (data['tanggalLaporan'] as Timestamp?)?.toDate(),
      tanggalDitinjau: (data['tanggalDitinjau'] as Timestamp?)?.toDate(),
    );
  }

  /// Konversi Report ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'laporanId': laporanId,
      'pelaporId': pelaporId,
      'terlaporId': terlaporId,
      'jenisEntitas': jenisEntitas,
      'kategoriPelanggaran': kategoriPelanggaran,
      'deskripsiLaporan': deskripsiLaporan,
      'lokasiKejadian': lokasiKejadian,
      'buktiLampiran': buktiLampiran,
      'statusLaporan': statusLaporan,
      'adminId': adminId,
      'catatanAdmin': catatanAdmin,
      'tanggalLaporan': tanggalLaporan != null 
          ? Timestamp.fromDate(tanggalLaporan!) 
          : FieldValue.serverTimestamp(),
      'tanggalDitinjau': tanggalDitinjau != null 
          ? Timestamp.fromDate(tanggalDitinjau!) 
          : null,
    };
  }

  /// Copy dengan perubahan tertentu
  Report copyWith({
    String? laporanId,
    String? pelaporId,
    String? terlaporId,
    String? jenisEntitas,
    String? kategoriPelanggaran,
    String? deskripsiLaporan,
    String? lokasiKejadian,
    String? buktiLampiran,
    String? statusLaporan,
    String? adminId,
    String? catatanAdmin,
    DateTime? tanggalLaporan,
    DateTime? tanggalDitinjau,
  }) {
    return Report(
      laporanId: laporanId ?? this.laporanId,
      pelaporId: pelaporId ?? this.pelaporId,
      terlaporId: terlaporId ?? this.terlaporId,
      jenisEntitas: jenisEntitas ?? this.jenisEntitas,
      kategoriPelanggaran: kategoriPelanggaran ?? this.kategoriPelanggaran,
      deskripsiLaporan: deskripsiLaporan ?? this.deskripsiLaporan,
      lokasiKejadian: lokasiKejadian ?? this.lokasiKejadian,
      buktiLampiran: buktiLampiran ?? this.buktiLampiran,
      statusLaporan: statusLaporan ?? this.statusLaporan,
      adminId: adminId ?? this.adminId,
      catatanAdmin: catatanAdmin ?? this.catatanAdmin,
      tanggalLaporan: tanggalLaporan ?? this.tanggalLaporan,
      tanggalDitinjau: tanggalDitinjau ?? this.tanggalDitinjau,
    );
  }

  @override
  String toString() {
    return 'Report(laporanId: $laporanId, kategoriPelanggaran: $kategoriPelanggaran, statusLaporan: $statusLaporan)';
  }
}
