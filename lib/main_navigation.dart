import 'package:flutter/material.dart';
import 'home.dart';
import 'laporan.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'database.dart';
import 'gaya.dart';
import 'pengaturan.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final Future<void> _localeFuture = initializeDateFormatting('id_ID', null);

  final GlobalKey<LaporanPageState> laporanKey = GlobalKey<LaporanPageState>();

  List<Widget> get _pages => [
    const HomePage(),
    LaporanPage(key: laporanKey),
    const PengaturanPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        laporanKey.currentState?.loadData();
      }
    });
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return LaporanPage(key: laporanKey);
      case 2:
        return const PengaturanPage();
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _localeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          body: _getPage(_selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Laporan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Pengaturan',
              ),
            ],
          ),
        );
      },
    );
  }
} 