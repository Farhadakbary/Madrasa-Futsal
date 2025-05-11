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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Match Note'),
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
                  _buildFormField(
                    controller: _teamNameController,
                    label: 'Team Name',
                    icon: Icons.group,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _opponentTeamController,
                    label: 'Opponent Team',
                    icon: Icons.sports,
                  ),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _matchResultController,
                    label: 'Match Result',
                    icon: Icons.score,
                  ),
                  const SizedBox(height: 16),
                  _buildDateSelector(colors),
                  const SizedBox(height: 16),
                  _buildFormField(
                    controller: _topScorerController,
                    label: 'Top Scorer',
                    icon: Icons.emoji_events,
                  ),
                  const SizedBox(height: 16),
                  _buildDescriptionField(colors),
                  const SizedBox(height: 24),
                  _buildActionButtons(colors),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildDateSelector(ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.date_range, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              DateFormat('MMM dd, yyyy').format(DateTime.parse(_matchDate)),
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurface,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: colors.primary),
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
        labelText: 'Match Description',
        alignLabelWithHint: true,
        prefixIcon: Icon(Icons.description, color: colors.primary),
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
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            backgroundColor: colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Save Changes',
            style: TextStyle(color: colors.onPrimary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(color: colors.error),
          ),
        ),
      ],
    );
  }
}