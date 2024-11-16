import 'package:flutter/material.dart';
import 'package:futsal/database/helper.dart';
import 'package:futsal/screens/adding_results.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _dbHelper.getAllGameNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _deleteNote(int id) async {
    await _dbHelper.deleteGameNote(id);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _notes.isEmpty
            ? const Center(
          child: Text(
            'No notes added yet.',
            style: TextStyle(fontSize: 18, color: Colors.blueGrey),
          ),
        )
            : ListView.builder(
          itemCount: _notes.length,
          itemBuilder: (context, index) {
            final note = _notes[index];
            return _buildNoteTile(note, size);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNoteScreen(),
            ),
          );
          if (newNote != null) {
            setState(() {
              _notes.add(newNote); // اضافه کردن نوت جدید به لیست
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteTile(Map<String, dynamic> note, Size size) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue.shade100,
          child: Icon(
            Icons.sticky_note_2_rounded,
            color: Colors.blue.shade700,
            size: 30,
          ),
        ),
        title: Text(
          note['opponentTeam'] ?? 'No Opponent',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        subtitle: Text(
          'Date: ${note['matchDate'] ?? 'N/A'}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        tileColor: Colors.white,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteConfirmationDialog(note['id']); // تأیید حذف
              },
            ),
            const Icon(Icons.more_vert, color: Colors.blue),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteNote(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
