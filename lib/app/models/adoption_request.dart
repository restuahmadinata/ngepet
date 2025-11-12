import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk Pengajuan Adopsi
/// Collection: pengajuan_adopsi/{pengajuanId}
class AdoptionRequest {
  final String pengajuanId;
  final String hewanId;
  final String userId;
  final String shelterId;
  final String alasanAdopsi;
  final String pengalamanHewan;
  final String statusTempatTinggal; // 'rumah_sendiri', 'kontrak', 'kos'
  final bool memilikiHalaman;
  final int jumlahAnggotaKeluarga;
  final String deskripsiLingkungan;
  final String statusPengajuan; // 'pending', 'approved', 'rejected', 'completed'
  final String? catatanShelter;
  final DateTime? tanggalPengajuan;
  final DateTime? tanggalDiproses;
  final DateTime? updatedAt;

  AdoptionRequest({
    required this.pengajuanId,
    required this.hewanId,
    required this.userId,
    required this.shelterId,
    required this.alasanAdopsi,
    required this.pengalamanHewan,
    required this.statusTempatTinggal,
    required this.memilikiHalaman,
    required this.jumlahAnggotaKeluarga,
    required this.deskripsiLingkungan,
    this.statusPengajuan = 'pending',
    this.catatanShelter,
    this.tanggalPengajuan,
    this.tanggalDiproses,
    this.updatedAt,
  });

  /// Factory constructor untuk membuat AdoptionRequest dari Firestore document
  factory AdoptionRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AdoptionRequest(
      pengajuanId: doc.id,
      hewanId: data['hewanId'] ?? data['petId'] ?? '',
      userId: data['userId'] ?? '',
      shelterId: data['shelterId'] ?? '',
      alasanAdopsi: data['alasanAdopsi'] ?? data['reason'] ?? '',
      pengalamanHewan: data['pengalamanHewan'] ?? data['experience'] ?? '',
      statusTempatTinggal: data['statusTempatTinggal'] ?? data['housingStatus'] ?? '',
      memilikiHalaman: data['memilikiHalaman'] ?? data['hasYard'] ?? false,
      jumlahAnggotaKeluarga: data['jumlahAnggotaKeluarga'] ?? data['familyMembers'] ?? 0,
      deskripsiLingkungan: data['deskripsiLingkungan'] ?? data['environmentDescription'] ?? '',
      statusPengajuan: data['statusPengajuan'] ?? data['status'] ?? 'pending',
      catatanShelter: data['catatanShelter'] ?? data['shelterNotes'],
      tanggalPengajuan: (data['tanggalPengajuan'] as Timestamp?)?.toDate(),
      tanggalDiproses: (data['tanggalDiproses'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Factory constructor untuk membuat AdoptionRequest dari Map
  factory AdoptionRequest.fromMap(Map<String, dynamic> data, String id) {
    return AdoptionRequest(
      pengajuanId: id,
      hewanId: data['hewanId'] ?? data['petId'] ?? '',
      userId: data['userId'] ?? '',
      shelterId: data['shelterId'] ?? '',
      alasanAdopsi: data['alasanAdopsi'] ?? data['reason'] ?? '',
      pengalamanHewan: data['pengalamanHewan'] ?? data['experience'] ?? '',
      statusTempatTinggal: data['statusTempatTinggal'] ?? data['housingStatus'] ?? '',
      memilikiHalaman: data['memilikiHalaman'] ?? data['hasYard'] ?? false,
      jumlahAnggotaKeluarga: data['jumlahAnggotaKeluarga'] ?? data['familyMembers'] ?? 0,
      deskripsiLingkungan: data['deskripsiLingkungan'] ?? data['environmentDescription'] ?? '',
      statusPengajuan: data['statusPengajuan'] ?? data['status'] ?? 'pending',
      catatanShelter: data['catatanShelter'] ?? data['shelterNotes'],
      tanggalPengajuan: (data['tanggalPengajuan'] as Timestamp?)?.toDate(),
      tanggalDiproses: (data['tanggalDiproses'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Konversi AdoptionRequest ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'pengajuanId': pengajuanId,
      'hewanId': hewanId,
      'userId': userId,
      'shelterId': shelterId,
      'alasanAdopsi': alasanAdopsi,
      'pengalamanHewan': pengalamanHewan,
      'statusTempatTinggal': statusTempatTinggal,
      'memilikiHalaman': memilikiHalaman,
      'jumlahAnggotaKeluarga': jumlahAnggotaKeluarga,
      'deskripsiLingkungan': deskripsiLingkungan,
      'statusPengajuan': statusPengajuan,
      'catatanShelter': catatanShelter,
      'tanggalPengajuan': tanggalPengajuan != null 
          ? Timestamp.fromDate(tanggalPengajuan!) 
          : FieldValue.serverTimestamp(),
      'tanggalDiproses': tanggalDiproses != null 
          ? Timestamp.fromDate(tanggalDiproses!) 
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Copy dengan perubahan tertentu
  AdoptionRequest copyWith({
    String? pengajuanId,
    String? hewanId,
    String? userId,
    String? shelterId,
    String? alasanAdopsi,
    String? pengalamanHewan,
    String? statusTempatTinggal,
    bool? memilikiHalaman,
    int? jumlahAnggotaKeluarga,
    String? deskripsiLingkungan,
    String? statusPengajuan,
    String? catatanShelter,
    DateTime? tanggalPengajuan,
    DateTime? tanggalDiproses,
    DateTime? updatedAt,
  }) {
    return AdoptionRequest(
      pengajuanId: pengajuanId ?? this.pengajuanId,
      hewanId: hewanId ?? this.hewanId,
      userId: userId ?? this.userId,
      shelterId: shelterId ?? this.shelterId,
      alasanAdopsi: alasanAdopsi ?? this.alasanAdopsi,
      pengalamanHewan: pengalamanHewan ?? this.pengalamanHewan,
      statusTempatTinggal: statusTempatTinggal ?? this.statusTempatTinggal,
      memilikiHalaman: memilikiHalaman ?? this.memilikiHalaman,
      jumlahAnggotaKeluarga: jumlahAnggotaKeluarga ?? this.jumlahAnggotaKeluarga,
      deskripsiLingkungan: deskripsiLingkungan ?? this.deskripsiLingkungan,
      statusPengajuan: statusPengajuan ?? this.statusPengajuan,
      catatanShelter: catatanShelter ?? this.catatanShelter,
      tanggalPengajuan: tanggalPengajuan ?? this.tanggalPengajuan,
      tanggalDiproses: tanggalDiproses ?? this.tanggalDiproses,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AdoptionRequest(pengajuanId: $pengajuanId, hewanId: $hewanId, statusPengajuan: $statusPengajuan)';
  }
}
