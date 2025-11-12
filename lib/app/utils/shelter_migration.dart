import 'package:cloud_firestore/cloud_firestore.dart';

/// Script migrasi data shelter dari koleksi 'users' ke 'shelters'
/// 
/// PERINGATAN: Script ini harus dijalankan dengan hati-hati!
/// Sebaiknya backup data terlebih dahulu sebelum menjalankan migrasi.
/// 
/// Cara penggunaan:
/// 1. Import file ini ke main.dart atau buat file terpisah
/// 2. Panggil fungsi migrateSheltersToNewCollection() saat app pertama kali jalan
/// 3. Setelah migrasi selesai, hapus kode pemanggilan fungsi ini

class ShelterMigration {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fungsi utama untuk migrasi data shelter
  Future<void> migrateSheltersToNewCollection() async {
    print('🚀 Memulai migrasi data shelter...');
    
    try {
      // 1. Ambil semua user dengan role 'shelter'
      final shelterUsers = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'shelter')
          .get();

      print('📊 Ditemukan ${shelterUsers.docs.length} shelter untuk dimigrasi');

      int successCount = 0;
      int failCount = 0;

      // 2. Loop setiap shelter dan pindahkan ke koleksi baru
      for (var doc in shelterUsers.docs) {
        try {
          final data = doc.data();
          final uid = doc.id;

          // 3. Buat dokumen baru di koleksi 'shelters'
          await _firestore.collection('shelters').doc(uid).set({
            'uid': uid,
            'email': data['email'] ?? '',
            'shelterName': data['shelterName'] ?? data['name'] ?? '',
            'address': data['shelterAddress'] ?? data['address'] ?? '',
            'phone': data['shelterPhone'] ?? data['phone'] ?? '',
            'legalNumber': data['shelterLegalNumber'] ?? '',
            'description': data['shelterDescription'] ?? '',
            'verificationStatus': data['verificationStatus'] ?? 'pending',
            'isVerified': data['isVerified'] ?? false,
            'submittedAt': data['submittedAt'],
            'approvedAt': data['approvedAt'],
            'rejectedAt': data['rejectedAt'],
            'rejectionReason': data['rejectionReason'],
            'createdAt': data['created_at'] ?? FieldValue.serverTimestamp(),
          });

          // 4. Hapus data shelter dari koleksi 'users'
          // OPSIONAL: Komentari jika ingin tetap menyimpan di users
          await _firestore.collection('users').doc(uid).delete();

          successCount++;
          print('✅ Berhasil migrasi shelter: ${data['shelterName'] ?? uid}');
        } catch (e) {
          failCount++;
          print('❌ Gagal migrasi shelter ${doc.id}: $e');
        }
      }

      print('');
      print('=' * 50);
      print('📊 HASIL MIGRASI:');
      print('✅ Berhasil: $successCount shelter');
      print('❌ Gagal: $failCount shelter');
      print('=' * 50);

      if (failCount == 0) {
        print('🎉 Migrasi selesai dengan sempurna!');
      } else {
        print('⚠️ Migrasi selesai dengan beberapa error. Periksa log di atas.');
      }
    } catch (e) {
      print('❌ Error saat migrasi: $e');
    }
  }

  /// Fungsi untuk memverifikasi hasil migrasi
  Future<void> verifyMigration() async {
    print('🔍 Memverifikasi hasil migrasi...');
    
    try {
      // Hitung jumlah shelter di koleksi baru
      final newShelters = await _firestore.collection('shelters').get();
      print('📊 Total shelter di koleksi baru: ${newShelters.docs.length}');

      // Hitung jumlah user dengan role shelter yang tersisa
      final remainingShelterUsers = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'shelter')
          .get();
      print('📊 Shelter yang tersisa di users: ${remainingShelterUsers.docs.length}');

      if (remainingShelterUsers.docs.isEmpty) {
        print('✅ Verifikasi berhasil! Semua shelter sudah dipindahkan.');
      } else {
        print('⚠️ Masih ada ${remainingShelterUsers.docs.length} shelter di koleksi users.');
      }

      // Tampilkan sample data
      if (newShelters.docs.isNotEmpty) {
        print('\n📋 Sample data shelter yang berhasil dimigrasi:');
        for (var doc in newShelters.docs.take(3)) {
          final data = doc.data();
          print('  - ${data['shelterName']} (${data['email']})');
          print('    Status: ${data['verificationStatus']}');
        }
      }
    } catch (e) {
      print('❌ Error saat verifikasi: $e');
    }
  }

  /// Fungsi untuk rollback (jika diperlukan)
  /// PERINGATAN: Hanya gunakan jika migrasi gagal dan ingin mengembalikan data
  Future<void> rollbackMigration() async {
    print('⏮️ Memulai rollback migrasi...');
    print('⚠️ PERINGATAN: Pastikan Anda yakin ingin rollback!');
    
    // Tunggu 5 detik untuk membatalkan
    await Future.delayed(Duration(seconds: 5));
    
    try {
      // Ambil semua shelter dari koleksi baru
      final shelters = await _firestore.collection('shelters').get();
      
      int successCount = 0;
      int failCount = 0;

      for (var doc in shelters.docs) {
        try {
          final data = doc.data();
          final uid = doc.id;

          // Kembalikan ke koleksi users
          await _firestore.collection('users').doc(uid).set({
            'uid': uid,
            'email': data['email'],
            'name': data['shelterName'],
            'role': 'shelter',
            'shelterName': data['shelterName'],
            'shelterAddress': data['address'],
            'shelterPhone': data['phone'],
            'shelterLegalNumber': data['legalNumber'],
            'shelterDescription': data['description'],
            'verificationStatus': data['verificationStatus'],
            'isVerified': data['isVerified'],
            'submittedAt': data['submittedAt'],
            'approvedAt': data['approvedAt'],
            'rejectedAt': data['rejectedAt'],
            'rejectionReason': data['rejectionReason'],
            'created_at': data['createdAt'],
          });

          // Hapus dari koleksi shelters
          await _firestore.collection('shelters').doc(uid).delete();

          successCount++;
          print('✅ Berhasil rollback: ${data['shelterName']}');
        } catch (e) {
          failCount++;
          print('❌ Gagal rollback ${doc.id}: $e');
        }
      }

      print('');
      print('📊 HASIL ROLLBACK:');
      print('✅ Berhasil: $successCount');
      print('❌ Gagal: $failCount');
    } catch (e) {
      print('❌ Error saat rollback: $e');
    }
  }
}

/// Contoh penggunaan:
/// 
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await Firebase.initializeApp();
///   
///   // Jalankan migrasi (hanya sekali)
///   final migration = ShelterMigration();
///   await migration.migrateSheltersToNewCollection();
///   
///   // Verifikasi hasil
///   await migration.verifyMigration();
///   
///   // Jika ada masalah, rollback
///   // await migration.rollbackMigration();
///   
///   runApp(MyApp());
/// }
