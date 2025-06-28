import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class GayaPage extends StatelessWidget {
  const GayaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gaya'),
        backgroundColor: const Color.fromARGB(255, 11, 68, 238),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mode Gelap'),
            value: isDarkMode,
            onChanged: (val) {
              themeProvider.setTheme(val ? ThemeMode.dark : ThemeMode.light);
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          SwitchListTile(
            title: const Text('Mode Terang'),
            value: !isDarkMode,
            onChanged: (val) {
              themeProvider.setTheme(val ? ThemeMode.light : ThemeMode.dark);
            },
            secondary: const Icon(Icons.light_mode),
          ),
        ],
      ),
    );
  }
} 