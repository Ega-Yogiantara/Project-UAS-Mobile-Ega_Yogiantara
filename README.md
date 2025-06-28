<<<<<<< HEAD
# Setup UAS - Aplikasi Pencatatan Keuangan

Aplikasi pencatatan keuangan sederhana yang dibangun dengan Flutter dan Firebase.

## Fitur

- Login dan Register dengan Firebase Authentication
- Pencatatan transaksi pendapatan dan pengeluaran
- Kategori transaksi yang dapat dikustomisasi
- Laporan keuangan dengan grafik
- Reset data transaksi
- Tema gelap/terang
- Penyimpanan foto untuk transaksi

## Perbaikan Terbaru

### Fix: Reset Data Tidak Menyebabkan Logout

**Masalah:** Saat melakukan reset data, aplikasi melakukan logout secara tidak sengaja.

**Penyebab:** 
- Fungsi reset data tidak mempertahankan status login dengan benar
- Tidak ada pengecekan status login sebelum dan sesudah reset
- Provider tidak diperbarui dengan benar setelah reset

**Solusi:**
1. Menambahkan method `resetAllData()` di `TransaksiProvider`
2. Menambahkan pengecekan status login sebelum reset data
3. Memastikan status login tetap terjaga setelah reset
4. Menggunakan provider untuk mengelola state dengan lebih baik

**File yang diperbaiki:**
- `lib/pengaturan.dart` - Perbaikan fungsi reset data
- `lib/providers/transaksi_provider.dart` - Penambahan method resetAllData

## Cara Menjalankan

1. Pastikan Flutter sudah terinstall
2. Install dependencies: `flutter pub get`
3. Jalankan aplikasi: `flutter run`

## Dependencies

- firebase_core
- firebase_auth
- shared_preferences
- sqflite
- provider
- intl
- flutter_localizations
- image_picker
- pie_chart
- month_picker_dialog

## Struktur Database

Tabel `transaksi`:
- id (INTEGER PRIMARY KEY)
- tanggal (TEXT)
- total (REAL)
- kategori (TEXT)
- dompet (TEXT)
- catatan (TEXT)
- jenis (TEXT)
- foto (TEXT)
=======
Link apk : 

>>>>>>> 6eda18fdefb3f5572519cced5fa5a8b3ee975f47
