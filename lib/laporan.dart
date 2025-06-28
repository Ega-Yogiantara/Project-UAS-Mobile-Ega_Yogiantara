import 'package:flutter/material.dart';
import 'database.dart';
import 'transaksi.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'edit.dart';
import 'package:provider/provider.dart';
import 'providers/transaksi_provider.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => LaporanPageState();
}

class LaporanPageState extends State<LaporanPage> {
  List<Transaksi> filteredTransaksi = [];
  double totalPendapatan = 0.0;
  double totalPengeluaran = 0.0;
  String selectedFilter = 'Semua';
  
  // Filter bulan & tahun
  final DateTime _now = DateTime.now();
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  
  final List<String> filterOptions = ['Semua', 'Pendapatan', 'Pengeluaran'];

  // Tambahkan mapping warna kategori
  final Map<String, Color> kategoriColors = {
    'Gaji': Colors.blue,
    'Transportasi': Colors.red,
    'Belanja': Colors.orange,
    'Tagihan': Colors.purple,
    'Hiburan': Colors.green,
    'Kesehatan': Colors.teal,
    'Pendidikan': Colors.brown,
    'Hadiah': Colors.pink,
    'Investasi': Colors.indigo,
    'Penjualan': Colors.cyan,
    'Bonus': Colors.amber,
    'Lainnya': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<TransaksiProvider>(context, listen: false).loadTransaksi()
    );
  }

  void loadData() {
    final allTransaksi = Provider.of<TransaksiProvider>(context, listen: false).transaksiList;
    setState(() {
      totalPendapatan = allTransaksi.where((trx) => trx.jenis == 'Pendapatan').fold(0.0, (sum, trx) => sum + (trx.total ?? 0.0));
      totalPengeluaran = allTransaksi.where((trx) => trx.jenis == 'Pengeluaran').fold(0.0, (sum, trx) => sum + (trx.total ?? 0.0));
    });
    _applyFilters();
  }

  void _applyFilters() {
    final allTransaksi = Provider.of<TransaksiProvider>(context, listen: false).transaksiList;
    List<Transaksi> filtered = allTransaksi;
    
    // Filter by jenis
    if (selectedFilter != 'Semua') {
      filtered = filtered.where((trx) => trx.jenis == selectedFilter).toList();
    }
    
    // Filter by bulan & tahun
    filtered = filtered.where((trx) {
      if (trx.tanggal == null) return false;
      try {
        final date = DateTime.parse(trx.tanggal!);
        return date.month == selectedMonth && date.year == selectedYear;
      } catch (e) {
        return false;
      }
    }).toList();
    
    setState(() {
      filteredTransaksi = filtered;
    });
  }

  String _formatCurrency(double? amount) {
    if (amount == null) return 'Rp 0';
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatMonthYear(int month, int year) {
    final date = DateTime(year, month);
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  Map<String, double> _getKategoriSummary() {
    Map<String, double> summary = {};
    for (var trx in filteredTransaksi) {
      final kategori = trx.kategori ?? 'Lainnya';
      final total = trx.total ?? 0.0;
      summary[kategori] = (summary[kategori] ?? 0.0) + total;
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    final allTransaksi = Provider.of<TransaksiProvider>(context).transaksiList;
    filteredTransaksi = allTransaksi;
    _applyFilters();
    final kategoriSummary = _getKategoriSummary();
    final totalFiltered = filteredTransaksi.fold<double>(
      0.0, (sum, trx) => sum + (trx.total ?? 0.0)
    );
    // Buat colorList sesuai urutan kategori pada dataMap
    final colorList = kategoriSummary.keys.map((kategori) => kategoriColors[kategori] ?? Colors.grey).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Keuangan"),
        backgroundColor: const Color.fromARGB(255, 11, 68, 238),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Filter Section
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedFilter,
                          isExpanded: true,
                          isDense: true,
                          icon: Icon(Icons.arrow_drop_down, size: 24, color: Theme.of(context).iconTheme.color),
                          style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                          items: filterOptions.map((String filter) {
                            return DropdownMenuItem<String>(
                              value: filter,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  filter,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedFilter = newValue!;
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final picked = await showMonthPicker(
                          context: context,
                          initialDate: DateTime(selectedYear, selectedMonth),
                          firstDate: DateTime(DateTime.now().year - 5, 1),
                          lastDate: DateTime(DateTime.now().year + 5, 12),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedMonth = picked.month;
                            selectedYear = picked.year;
                          });
                          _applyFilters();
                        }
                      },
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatMonthYear(selectedMonth, selectedYear),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Pie Chart Ringkasan Kategori
              if (kategoriSummary.isNotEmpty)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan per Kategori',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        PieChart(
                          dataMap: kategoriSummary,
                          colorList: colorList,
                          chartType: ChartType.disc,
                          chartRadius: 110,
                          legendOptions: const LegendOptions(
                            showLegends: true,
                            legendPosition: LegendPosition.right,
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValuesInPercentage: true,
                            showChartValues: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              // Summary Card
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Total Transaksi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              filteredTransaksi.length.toString(),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Total Nilai', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(totalFiltered),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // List Transaksi
              ...filteredTransaksi.map((trx) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                elevation: 2,
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPage(transaksi: trx),
                      ),
                    );
                    if (result == true) {
                      Provider.of<TransaksiProvider>(context, listen: false).loadTransaksi();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Baris 1: Kategori & Total
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                trx.kategori ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _formatCurrency(trx.total),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: trx.jenis == 'Pendapatan' ? Colors.blue : Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        // Baris 2: Catatan
                        if (trx.catatan?.isNotEmpty == true)
                          Padding(
                            padding: const EdgeInsets.only(top: 2, bottom: 2),
                            child: Text(
                              trx.catatan!,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        // Baris 3: Dompet & Tanggal
                        Row(
                          children: [
                            Text(
                              trx.dompet ?? '',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(trx.tanggal),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )),
              if (filteredTransaksi.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.analytics,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Tidak ada transaksi",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 