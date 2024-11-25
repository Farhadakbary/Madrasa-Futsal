import 'package:flutter/material.dart';
import 'package:futsal/database/helper.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({Key? key}) : super(key: key);

  Future<void> _backupData(BuildContext context) async {
    try {
      await _showLoadingDialog(context, 'Creating backup...');
      await DatabaseHelper.instance.backupDatabase();
      Navigator.pop(context);
      _showSnackBar(context, 'Backup created successfully!');
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar(context, 'Error during backup: $e');
    }
  }

  Future<void> _restoreData(BuildContext context) async {
    try {
      await _showLoadingDialog(context, 'Restoring data...');
      await DatabaseHelper.instance.restoreDatabase();
      Navigator.pop(context);
      _showSnackBar(context, 'Data restored successfully!');
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar(context, 'Error during restore: $e');
    }
  }

  Future<void> _showLoadingDialog(BuildContext context, String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            children: [
              Icon(Icons.backup, size: 80, color: Colors.blue.shade700),
              const SizedBox(height: 10),
              const Text(
                'Manage Your Data',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                message,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.backup,
                    size: 60,
                    color: Colors.green,
                  ),
                  Text(
                    'Backup, restore, or clear your application data easily using the options below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            _buildActionTile(
              context,
              title: 'Backup Data',
              icon: Icons.cloud_upload,
              color: Colors.green.shade700,
              onTap: () => _backupData(context),
            ),
            _buildActionTile(
              context,
              title: 'Restore Data',
              icon: Icons.cloud_download,
              color: Colors.blue.shade700,
              onTap: () => _restoreData(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
