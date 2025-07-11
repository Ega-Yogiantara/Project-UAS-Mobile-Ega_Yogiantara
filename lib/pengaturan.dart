import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'database.dart';
import 'gaya.dart';
import 'package:provider/provider.dart';
import 'providers/transaksi_provider.dart';

class PengaturanPage extends StatelessWidget {
  const PengaturanPage({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('Logout: is_logged_in = \x1B[32m\x1B[0m');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _openGayaPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GayaPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: const Color.fromARGB(255, 11, 68, 238),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.refresh, color: Colors.orange),
                  title: const Text('Reset Data'),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset Data'),
                        content: const Text('Apakah Anda yakin ingin mereset semua data? Tindakan ini tidak dapat dibatalkan.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Reset', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      try {
                        // Pastikan user masih login sebelum reset
                        final prefs = await SharedPreferences.getInstance();
                        final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
                        
                        if (!isLoggedIn) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sesi login tidak valid'),
                              ),
                            );
                          }
                          return;
                        }
                        
                        // Reset semua data transaksi menggunakan provider
                        await Provider.of<TransaksiProvider>(context, listen: false).resetAllData();
                        
                        // Pastikan status login tetap terjaga
                        await prefs.setBool('is_logged_in', true);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data berhasil direset!'),
                            ),
                          );
                          
                          // Kembali ke halaman utama tanpa logout
                          if (context.mounted) {
                            Navigator.popUntil(context, (route) => route.isFirst);
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error saat reset data: $e'),
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.format_paint, color: Colors.blue),
                  title: const Text('Gaya'),
                  onTap: () {
                    _openGayaPage(context);
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                onTap: () {
                  _logout(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
} 