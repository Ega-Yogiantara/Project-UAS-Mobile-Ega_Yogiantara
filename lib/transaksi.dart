class Transaksi {
  int? id;
  String? tanggal;
  double? total;
  String? kategori;
  String? dompet;
  String? catatan;
  String? jenis; // Pendapatan atau Pengeluaran
  final String? foto;

  Transaksi({
    this.id, 
    this.tanggal, 
    this.total, 
    this.kategori, 
    this.dompet, 
    this.catatan,
    this.jenis,
    this.foto,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'],
      tanggal: json['tanggal'],
      total: json['total'] is int
          ? (json['total'] as int).toDouble()
          : (json['total'] is double
              ? json['total']
              : (json['total'] != null
                  ? double.tryParse(json['total'].toString())
                  : null)),
      kategori: json['kategori'],
      dompet: json['dompet'],
      catatan: json['catatan'],
      jenis: json['jenis'],
      foto: json['foto'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': tanggal,
      'total': total,
      'kategori': kategori,
      'dompet': dompet,
      'catatan': catatan,
      'jenis': jenis,
      'foto': foto,
    };
  }
  
  @override
  String toString() {
    return 'Transaksi(id: $id, tanggal: $tanggal, total: $total, kategori: $kategori, dompet: $dompet, catatan: $catatan, jenis: $jenis, foto: $foto)';
  }
} 