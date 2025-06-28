import 'package:flutter/material.dart';
import 'database.dart';
import 'transaksi.dart';
import 'package:provider/provider.dart';
import 'providers/transaksi_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditPage extends StatefulWidget {
  final Transaksi transaksi;
  
  const EditPage({super.key, required this.transaksi});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final TextEditingController totalController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  
  late String selectedJenis;
  late String selectedKategori;
  late String selectedDompet;
  late DateTime selectedDate;
  
  final List<String> jenisOptions = ['Pendapatan', 'Pengeluaran'];
  
  // Kategori untuk Pendapatan
  final List<String> kategoriPendapatan = [
    'Gaji',
    'Bonus',
    'Investasi',
    'Penjualan',
    'Hadiah',
    'Lainnya'
  ];
  
  // Kategori untuk Pengeluaran
  final List<String> kategoriPengeluaran = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Lainnya'
  ];
  
  final List<String> dompetOptions = ['Tunai', 'Bank'];
  
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  XFile? _pickedImage;
  bool _showDeleteIcon = false;

  @override
  void initState() {
    super.initState();
    // Initialize form with existing data
    selectedJenis = widget.transaksi.jenis ?? 'Pendapatan';
    selectedKategori = widget.transaksi.kategori ?? 'Makanan';
    selectedDompet = widget.transaksi.dompet ?? 'Tunai';
    totalController.text = widget.transaksi.total != null
        ? widget.transaksi.total!.toStringAsFixed(
            widget.transaksi.total!.truncateToDouble() == widget.transaksi.total! ? 0 : 3)
        : '';
    deskripsiController.text = widget.transaksi.catatan ?? '';
    selectedDate = widget.transaksi.tanggal != null
        ? DateTime.tryParse(widget.transaksi.tanggal!) ?? DateTime.now()
        : DateTime.now();
    if (widget.transaksi.foto != null && widget.transaksi.foto!.isNotEmpty) {
      _pickedImage = XFile(widget.transaksi.foto!);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> kategoriList = selectedJenis == 'Pendapatan'
        ? kategoriPendapatan
        : kategoriPengeluaran;
    if (!kategoriList.contains(selectedKategori)) {
      selectedKategori = kategoriList.first;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Transaksi"),
        backgroundColor: const Color.fromARGB(255, 11, 68, 238),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              await _deleteTransaksi();
            },
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pilih Tanggal
            const Text(
              "Tanggal Transaksi",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  locale: const Locale('id', 'ID'),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Jenis Transaksi
            const Text(
              "Jenis Transaksi",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedJenis,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: jenisOptions.map((String jenis) {
                return DropdownMenuItem<String>(
                  value: jenis,
                  child: Text(jenis),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedJenis = newValue!;
                  selectedKategori = selectedJenis == 'Pendapatan'
                      ? kategoriPendapatan.first
                      : kategoriPengeluaran.first;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Total
            const Text(
              "Total",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: totalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Masukkan jumlah",
                border: OutlineInputBorder(),
                prefixText: "Rp ",
              ),
            ),
            const SizedBox(height: 16),
            
            // Kategori
            const Text(
              "Kategori",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedKategori,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: kategoriList
                  .map((String kategori) {
                return DropdownMenuItem<String>(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedKategori = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Dompet
            const Text(
              "Dompet",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedDompet,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: dompetOptions.map((String dompet) {
                return DropdownMenuItem<String>(
                  value: dompet,
                  child: Text(dompet),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDompet = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Deskripsi
            const Text(
              "Deskripsi",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: deskripsiController,
              decoration: InputDecoration(
                labelText: "Tulis deskripsi (opsional)",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _pickImage,
                ),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            // Gambar
            if (_pickedImage != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16, top: 8),
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      _showDeleteIcon = true;
                    });
                  },
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_pickedImage!.path),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (_showDeleteIcon)
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _pickedImage = null;
                              _showDeleteIcon = false;
                            });
                          },
                          tooltip: 'Hapus gambar',
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            
            // Tombol Update
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await _updateTransaksi();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 11, 68, 238),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  "Update Transaksi",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _updateTransaksi() async {
    if (totalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total tidak boleh kosong')),
      );
      return;
    }
    
    double? total;
    try {
      total = double.parse(totalController.text);
      if (total <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Total harus lebih dari 0')),
        );
        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total harus berupa angka yang valid')),
      );
      return;
    }
    
    try {
      final updatedTransaksi = Transaksi(
        id: widget.transaksi.id,
        tanggal: selectedDate.toIso8601String(),
        total: total,
        kategori: selectedKategori,
        dompet: selectedDompet,
        catatan: deskripsiController.text,
        jenis: selectedJenis,
        foto: _pickedImage != null ? _pickedImage!.path : '',
      );
      await Provider.of<TransaksiProvider>(context, listen: false).updateTransaksi(updatedTransaksi);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil diupdate')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  Future<void> _deleteTransaksi() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        await Provider.of<TransaksiProvider>(context, listen: false).deleteTransaksi(widget.transaksi.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil dihapus')),
        );
        Navigator.pop(context, true); // trigger refresh
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _pickedImage = image;
        });
      }
    }
  }

  void _showImageDetail(BuildContext context) {
    if (_pickedImage == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.file(
              File(_pickedImage!.path),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    totalController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }
} 