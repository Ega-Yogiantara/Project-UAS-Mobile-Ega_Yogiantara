import 'package:flutter/material.dart';
import 'package:setup_uas/create.dart';
import 'package:setup_uas/edit.dart';
import 'package:setup_uas/laporan.dart';
import 'package:setup_uas/database.dart';
import 'package:setup_uas/transaksi.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'providers/transaksi_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  double totalPendapatan = 0.0;
  double totalPengeluaran = 0.0;

  // Filter bulan & tahun
  final DateTime _now = DateTime.now();
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  late final List<int> yearOptions = List.generate(10, (i) => _now.year - 5 + i);

  // Search
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  bool showSearchBar = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<TransaksiProvider>(context, listen: false).loadTransaksi()
    );
  }

  List<Transaksi> get filteredTransaksi {
    final transaksiList = Provider.of<TransaksiProvider>(context).transaksiList;
    return transaksiList.where((trx) {
      if (trx.tanggal == null) return false;
      try {
        final date = DateTime.parse(trx.tanggal!);
        final matchBulan = date.month == selectedMonth && date.year == selectedYear;
        final matchSearch = searchQuery.isEmpty || (trx.catatan?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
        return matchBulan && matchSearch;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  double get filteredTotalPendapatan =>
      filteredTransaksi.where((trx) => trx.jenis == 'Pendapatan').fold(0.0, (sum, trx) => sum + (trx.total ?? 0.0));
  double get filteredTotalPengeluaran =>
      filteredTransaksi.where((trx) => trx.jenis == 'Pengeluaran').fold(0.0, (sum, trx) => sum + (trx.total ?? 0.0));
  double get filteredSaldo => filteredTotalPendapatan - filteredTotalPengeluaran;

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatCurrencyNoRp(double? amount) {
    if (amount == null) return '0';
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '', // tanpa Rp
      decimalDigits: 0,
    );
    return formatter.format(amount).trim();
  }

  String _formatMonthYear(int month, int year) {
    final date = DateTime(year, month);
    return DateFormat('MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catatan Keuangan"),
        backgroundColor: const Color.fromARGB(255, 11, 68, 238),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(showSearchBar ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                showSearchBar = !showSearchBar;
                if (!showSearchBar) {
                  searchQuery = '';
                  searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const CreatePage())
          );
          // Refresh data setelah kembali dari CreatePage
          Provider.of<TransaksiProvider>(context, listen: false).loadTransaksi();
        },
        backgroundColor: const Color.fromARGB(255, 11, 68, 238),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (showSearchBar)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Cari catatan...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              searchQuery = '';
                              searchController.clear();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (val) {
                  setState(() {
                    searchQuery = val;
                  });
                },
              ),
            ),
          // Month Picker Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
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
          ),
          // Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Pendapatan',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatCurrencyNoRp(filteredTotalPendapatan),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Pengeluaran',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatCurrencyNoRp(filteredTotalPengeluaran),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Saldo',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatCurrencyNoRp(filteredSaldo),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: filteredSaldo >= 0
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Transactions List
          Expanded(
            child: filteredTransaksi.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Belum ada transaksi",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "Tekan + untuk menambah transaksi",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await Provider.of<TransaksiProvider>(context, listen: false).loadTransaksi();
                    },
                    child: ListView.builder(
                      itemCount: filteredTransaksi.length,
                      itemBuilder: (context, index) {
                        final trx = filteredTransaksi[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                        _formatCurrencyNoRp(trx.total),
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
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}