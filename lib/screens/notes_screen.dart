import 'package:flutter/material.dart';
import 'package:futsal/database/helper.dart';
import 'package:futsal/screens/adding_notes.dart';
import 'package:futsal/screens/edit_note_screen.dart';

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
    setState(() => _notes = notes);
  }

  Future<void> _deleteNote(int id) async {
    await _dbHelper.deleteGameNote(id);
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Reports'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.primary, colors.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.background, colors.surfaceVariant],
          ),
        ),
        child: _notes.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note_alt_outlined,
                  size: 80, color: colors.onSurface.withOpacity(0.3)),
              const SizedBox(height: 20),
              Text(
                'No Reports Found',
                style: TextStyle(
                  fontSize: 20,
                  color: colors.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _notes.length,
          itemBuilder: (context, index) =>
              _buildNoteCard(_notes[index], colors),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
          if (newNote != null) _loadNotes();
        },
        backgroundColor: colors.primary,
        child: Icon(Icons.add, color: colors.onPrimary),
      ),
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note, ColorScheme colors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.sports_soccer,
              color: colors.primary),
        ),
        title: Text(
          note['opponentTeam'] ?? 'Unknown Team',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Date: ${note['matchDate'] ?? 'N/A'}',
              style: TextStyle(
                  fontSize: 14,
                  color: colors.onSurface.withOpacity(0.7)),
            ),
            if (note['matchResult'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Result: ${note['matchResult']}',
                  style: TextStyle(
                      fontSize: 14,
                      color: colors.primary),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: colors.primary),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditNoteScreen(note: note)),
                );
                if (result != null) _loadNotes();
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: colors.error),
              onPressed: () => _showDeleteDialog(note['id'], colors),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(int id, ColorScheme colors) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Report', style: TextStyle(color: colors.error)),
        content: const Text('Are you sure you want to delete this report?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: colors.onSurface)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteNote(id);
            },
            child: Text('Delete', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
  }
}