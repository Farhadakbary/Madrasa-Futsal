import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:futsal/database/helper.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

  @override
  _AddNoteScreenState createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _opponentTeamController = TextEditingController();
  final TextEditingController _matchResultController = TextEditingController();
  final TextEditingController _topScorerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _matchDate;

  @override
  void initState() {
    super.initState();
    _matchDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      final note = {
        'teamName': _teamNameController.text,
        'opponentTeam': _opponentTeamController.text,
        'matchResult': _matchResultController.text,
        'matchDate': _matchDate,
        'topScorer': _topScorerController.text,
        'description': _descriptionController.text,
      };

      final id = await DatabaseHelper.instance
          .insertGameNote(note);

      if (id > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved successfully!')),
        );
        Navigator.pop(context, note);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to save note. Please try again.')),
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
        title: const Text('Add Match Note',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Match Note Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _teamNameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Team Name',
                    labelStyle: TextStyle(color: Colors.green),
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
                    labelStyle: TextStyle(color: Colors.green),
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
                    labelStyle: TextStyle(color: Colors.green),
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
                        style:
                            const TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Select Date',style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _topScorerController,
                  decoration: const InputDecoration(
                    labelText: 'Top Scorer',
                    labelStyle: TextStyle(color: Colors.green),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the top scorer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Match Description',
                    labelStyle: TextStyle(color: Colors.green),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please provide a description of the match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _saveNote,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Save',style: TextStyle(color: Colors.green)),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',style: TextStyle(color: Colors.black),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
