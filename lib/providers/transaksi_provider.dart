import 'package:flutter/material.dart';
import '../database.dart';
import '../transaksi.dart';

class TransaksiProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Transaksi> _transaksiList = [];

  List<Transaksi> get transaksiList => _transaksiList;

  Future<void> loadTransaksi() async {
    _transaksiList = await _databaseHelper.getTransaksi();
    notifyListeners();
  }

  Future<void> addTransaksi(Transaksi trx) async {
    await _databaseHelper.insertTransaksiWithDate(
      trx.total ?? 0.0,
      trx.kategori ?? '',
      trx.dompet ?? '',
      trx.catatan ?? '',
      trx.jenis ?? '',
      DateTime.parse(trx.tanggal ?? DateTime.now().toIso8601String()),
      trx.foto,
    );
    await loadTransaksi();
  }

  Future<void> updateTransaksi(Transaksi trx) async {
    await _databaseHelper.updateTransaksi(trx);
    await loadTransaksi();
  }

  Future<void> deleteTransaksi(int id) async {
    await _databaseHelper.deleteTransaksi(id);
    await loadTransaksi();
  }
} 