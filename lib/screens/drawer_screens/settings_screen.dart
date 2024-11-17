import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  String _selectedLanguage = 'en';
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'en';
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setString('language', _selectedLanguage);
    await prefs.setDouble('fontSize', _fontSize);
  }

  Future<void> _resetSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      _isDarkMode = false;
      _selectedLanguage = 'en';
      _fontSize = 16.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: _isDarkMode ? Colors.black : Colors.blue,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [

          SwitchListTile(
            title: Text(
              'Dark Mode',
              style: TextStyle(fontSize: _fontSize),
            ),
            value: _isDarkMode,
            onChanged: (bool value) {
              setState(() {
                _isDarkMode = value;
              });
              _saveSettings();
            },
          ),
          const Divider(),

          ListTile(
            title: Text(
              'Language',
              style: TextStyle(fontSize: _fontSize),
            ),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                  _saveSettings();
                }
              },
              items: const [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'fa',
                  child: Text('فارسی'),
                ),
              ],
            ),
          ),
          const Divider(),

          ListTile(
            title: Text(
              'Font Size',
              style: TextStyle(fontSize: _fontSize),
            ),
            subtitle: Slider(
              min: 12.0,
              max: 24.0,
              value: _fontSize,
              onChanged: (double value) {
                setState(() {
                  _fontSize = value;
                });
                _saveSettings();
              },
            ),
          ),
          const Divider(),

          ListTile(
            title: Center(
              child: ElevatedButton(
                onPressed: () {
                  _resetSettings();
                },
                child: const Text('Reset Settings'),
              ),
            ),
          ),
        ],
      ),
    backgroundColor: _isDarkMode ? Colors.grey.shade900 : Colors.white,
    );
  }

}
