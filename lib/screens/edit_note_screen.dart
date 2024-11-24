import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:futsal/database/helper.dart';

class EditNoteScreen extends StatefulWidget {
  final Map<String, dynamic> note;

  const EditNoteScreen({Key? key, required this.note}) : super(key: key);

  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _teamNameController;
  late TextEditingController _opponentTeamController;
  late TextEditingController _matchResultController;
  late TextEditingController _topScorerController;
  late TextEditingController _descriptionController;
  late String _matchDate;

  @override
  void initState() {
    super.initState();
    _teamNameController = TextEditingController(text: widget.note['teamName']);
    _opponentTeamController = TextEditingController(text: widget.note['opponentTeam']);
    _matchResultController = TextEditingController(text: widget.note['matchResult']);
    _topScorerController = TextEditingController(text: widget.note['topScorer']);
    _descriptionController = TextEditingController(text: widget.note['description']);
    _matchDate = widget.note['matchDate'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_matchDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _matchDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveNote() async {
    if (_formKey.currentState!.validate()) {
      final updatedNote = {
        'id': widget.note['id'],
        'teamName': _teamNameController.text,
        'opponentTeam': _opponentTeamController.text,
        'matchResult': _matchResultController.text,
        'matchDate': _matchDate,
        'topScorer': _topScorerController.text,
        'description': _descriptionController.text,
      };

      final rowsAffected = await DatabaseHelper.instance.updateGameNote(updatedNote);

      if (rowsAffected > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note updated successfully!')),
        );
        Navigator.pop(context, updatedNote);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update note. Please try again.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _opponentTeamController.dispose();
    _matchResultController.dispose();
    _topScorerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _teamNameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Team Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your team name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _opponentTeamController,
                  decoration: const InputDecoration(
                    labelText: 'Opponent Team Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the opponent team name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _matchResultController,
                  decoration: const InputDecoration(
                    labelText: 'Match Result',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the match result';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Match Date: $_matchDate',
                        style: const TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Select Date', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _topScorerController,
                  decoration: const InputDecoration(
                    labelText: 'Top Scorer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
