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

      final id = await DatabaseHelper.instance.insertGameNote(note);

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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Match Report'),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormHeader('Match Details'),
                  const SizedBox(height: 20),
                  _buildTeamInputField(colors),
                  const SizedBox(height: 16),
                  _buildOpponentInputField(colors),
                  const SizedBox(height: 16),
                  _buildResultInputField(colors),
                  const SizedBox(height: 16),
                  _buildDateSelector(colors),
                  const SizedBox(height: 16),
                  _buildScorerInputField(colors),
                  const SizedBox(height: 16),
                  _buildDescriptionField(colors),
                  const SizedBox(height: 32),
                  _buildActionButtons(colors),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onBackground,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTeamInputField(ColorScheme colors) {
    return _buildFormField(
      controller: _teamNameController,
      label: 'Team Name',
      icon: Icons.groups_rounded,
      colors: colors,
    );
  }

  Widget _buildOpponentInputField(ColorScheme colors) {
    return _buildFormField(
      controller: _opponentTeamController,
      label: 'Opponent Team',
      icon: Icons.sports_soccer_rounded,
      colors: colors,
    );
  }

  Widget _buildResultInputField(ColorScheme colors) {
    return _buildFormField(
      controller: _matchResultController,
      label: 'Match Result',
      icon: Icons.scoreboard_rounded,
      colors: colors,
    );
  }

  Widget _buildScorerInputField(ColorScheme colors) {
    return _buildFormField(
      controller: _topScorerController,
      label: 'Top Scorer',
      icon: Icons.emoji_events_rounded,
      colors: colors,
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colors,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: colors.surface,
      ),
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildDateSelector(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.event_rounded, color: colors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              DateFormat('MMMM dd, yyyy').format(DateTime.parse(_matchDate!)),
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurface,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_calendar_rounded, color: colors.primary),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionField(ColorScheme colors) {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Match Analysis',
        alignLabelWithHint: true,
        prefixIcon: Icon(Icons.description_rounded, color: colors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: colors.surface,
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _saveNote,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            backgroundColor: colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'SAVE CHANGES',
            style: TextStyle(
              color: colors.onPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          ),
          child: Text(
            'CANCEL',
            style: TextStyle(
              color: colors.error,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
