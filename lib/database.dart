import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'transaksi.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class DatabaseHelper {
    final String _databaseName = 'uas.db';
    final int _databaseVersion = 3;
    

    //Table Transaksi
    final String _tableName = 'transaksi';
    final String _columnId = 'id';
    final String _columnTanggal = 'tanggal';
    final String _columnTotal = 'total';
    final String _columnKategori = 'kategori';
    final String _columnDompet = 'dompet';
    final String _columnCatatan = 'catatan';
    final String _columnJenis = 'jenis';
    final String _columnFoto = 'foto';


    

    Database? _database;
    Future<Database> database() async {
        if (_database != null) return _database!;
        _database = await _initDatabase();
        return _database!;
    }

    Future _initDatabase() async {
        Directory documentDirectory = await getApplicationDocumentsDirectory();
        String path = join(documentDirectory.path, _databaseName);
        return openDatabase(
            path, 
            version: _databaseVersion, 
            onCreate: _onCreate,
            onUpgrade: _onUpgrade,
        );
    }

    Future _onCreate(Database db, int version) async {
        await db.execute('''
            CREATE TABLE $_tableName (
                $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
                $_columnTanggal TEXT,
                $_columnTotal REAL,
                $_columnKategori TEXT,
                $_columnDompet TEXT,
                $_columnCatatan TEXT,
                $_columnJenis TEXT,
                $_columnFoto TEXT
            )
        ''');
    }
    
    Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 3) {
            await db.execute('ALTER TABLE $_tableName ADD COLUMN $_columnFoto TEXT');
        }
    }

    Future<List<Transaksi>> getTransaksi() async {
        final db = await database();
        final data = await db.query(_tableName, orderBy: '$_columnTanggal DESC');
        print('Raw data from database: $data'); // Debug print
        List<Transaksi> result =
            data.map((e) => Transaksi.fromJson(e)).toList();    
        print('Transaksi list: $result'); // Debug print
        return result;
    }
    
    Future<int> insert(Map<String, dynamic> row) async {
        final db = await database();
        final query = await db.insert(_tableName, row);
        return query;
    }
    
    // Method khusus untuk insert transaksi
    Future<int> insertTransaksi(double total, String kategori, String dompet, String catatan, String jenis) async {
        final db = await database();
        final data = {
            _columnTanggal: DateTime.now().toIso8601String(),
            _columnTotal: total,
            _columnKategori: kategori,
            _columnDompet: dompet,
            _columnCatatan: catatan,
            _columnJenis: jenis,
        };
        print('Inserting data: $data'); // Debug print
        final result = await db.insert(_tableName, data);
        print('Insert result: $result'); // Debug print
        return result;
    }
    
    // Method khusus untuk insert transaksi dengan tanggal custom
    Future<int> insertTransaksiWithDate(double total, String kategori, String dompet, String catatan, String jenis, DateTime tanggal, [String? foto]) async {
        final db = await database();
        return await db.insert(_tableName, {
            _columnTanggal: tanggal.toIso8601String(),
            _columnTotal: total,
            _columnKategori: kategori,
            _columnDompet: dompet,
            _columnCatatan: catatan,
            _columnJenis: jenis,
            _columnFoto: foto,
        });
    }
    
    // Method untuk update transaksi
    Future<int> updateTransaksi(Transaksi transaksi) async {
        final db = await database();
        final data = {
            _columnTanggal: transaksi.tanggal,
            _columnTotal: transaksi.total,
            _columnKategori: transaksi.kategori,
            _columnDompet: transaksi.dompet,
            _columnCatatan: transaksi.catatan,
            _columnJenis: transaksi.jenis,
            _columnFoto: transaksi.foto,
        };
        return await db.update(
            _tableName,
            data,
            where: '$_columnId = ?',
            whereArgs: [transaksi.id],
        );
    }
    
    // Method untuk mendapatkan transaksi berdasarkan jenis
    Future<List<Transaksi>> getTransaksiByJenis(String jenis) async {
        final db = await database();
        final data = await db.query(
            _tableName,
            where: '$_columnJenis = ?',
            whereArgs: [jenis],
            orderBy: '$_columnTanggal DESC',
        );
        List<Transaksi> result =
            data.map((e) => Transaksi.fromJson(e)).toList();    
        return result;
    }
    
    // Method untuk mendapatkan transaksi berdasarkan kategori
    Future<List<Transaksi>> getTransaksiByKategori(String kategori) async {
        final db = await database();
        final data = await db.query(
            _tableName,
            where: '$_columnKategori = ?',
            whereArgs: [kategori],
            orderBy: '$_columnTanggal DESC',
        );
        List<Transaksi> result =
            data.map((e) => Transaksi.fromJson(e)).toList();    
        return result;
    }
    
    // Method untuk mendapatkan total pendapatan
    Future<double> getTotalPendapatan() async {
        final db = await database();
        final result = await db.rawQuery('''
            SELECT SUM($_columnTotal) as total 
            FROM $_tableName 
            WHERE $_columnJenis = 'Pendapatan'
        ''');
        return result.first['total'] as double? ?? 0.0;
    }
    
    // Method untuk mendapatkan total pengeluaran
    Future<double> getTotalPengeluaran() async {
        final db = await database();
        final result = await db.rawQuery('''
            SELECT SUM($_columnTotal) as total 
            FROM $_tableName 
            WHERE $_columnJenis = 'Pengeluaran'
        ''');
        return result.first['total'] as double? ?? 0.0;
    }
    
    // Method untuk menghapus transaksi
    Future<int> deleteTransaksi(int id) async {
        final db = await database();
        return await db.delete(
            _tableName,
            where: '$_columnId = ?',
            whereArgs: [id],
        );
    }
    
    // Method untuk menghapus semua data transaksi
    Future<int> deleteAllTransaksi() async {
        final db = await database();
        return await db.delete(_tableName);
    }
    
    // Method untuk debugging - melihat semua data di database
    Future<void> debugDatabase() async {
        final db = await database();
        final tables = await db.query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
        print('Tables in database: $tables');
        
        final data = await db.query(_tableName);
        print('All data in $_tableName: $data');
    }
}