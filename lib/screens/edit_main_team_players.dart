import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:futsal/database/helper.dart';

class EditMainTeamPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> player;

  const EditMainTeamPlayerScreen({Key? key, required this.player})
      : super(key: key);

  @override
  _EditMainTeamPlayerScreenState createState() =>
      _EditMainTeamPlayerScreenState();
}

class _EditMainTeamPlayerScreenState extends State<EditMainTeamPlayerScreen> {
  // ... [همه متغیرها و متدهای قبلی بدون تغییر باقی میمانند]
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _jerseyNumberController;
  late TextEditingController _ageController;
  late TextEditingController _salaryController;
  late TextEditingController _contractDurationController;

  File? _imageFile;
  String? _selectedPosition;
  final List<String> _positions = [
    'Center Forward',
    'Left Flank',
    'Right Flank',
    'Center Back',
    'Goalkeeper'
  ];

  @override
  void initState() {
    super.initState();
    final player = widget.player;

    _firstNameController = TextEditingController(text: player['firstName']);
    _lastNameController = TextEditingController(text: player['lastName']);
    _jerseyNumberController =
        TextEditingController(text: player['jerseyNumber'].toString());
    _ageController = TextEditingController(text: player['age'].toString());
    _salaryController = TextEditingController(
        text: player['salary'] != null ? player['salary'].toString() : '');
    _contractDurationController = TextEditingController(
        text: player['contractDuration'].toString());
    _selectedPosition = player['position'];
    _imageFile =
    player['imagePath'] != null ? File(player['imagePath']) : null;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
    await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  void _updatePlayer() async {
    if (_formKey.currentState!.validate()) {
      final updatedPlayer = {
        'id': widget.player['id'],
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'jerseyNumber': int.tryParse(_jerseyNumberController.text) ?? 0,
        'position': _selectedPosition!,
        'contractDuration':
        int.tryParse(_contractDurationController.text) ?? 1,
        'salary': double.tryParse(_salaryController.text),
        'imagePath': _imageFile?.path,
        'age': int.tryParse(_ageController.text) ?? 0,
      };

      await DatabaseHelper.instance.updateMainTeamPlayer(updatedPlayer);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player updated successfully!')),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _jerseyNumberController.dispose();
    _ageController.dispose();
    _salaryController.dispose();
    _contractDurationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Player'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Player Information'),
                const SizedBox(height: 20),
                _buildTextFormField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _jerseyNumberController,
                  label: 'Jersey Number',
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildPositionDropdown(colors),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _contractDurationController,
                  label: 'Contract Duration (Years)',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _salaryController,
                  label: 'Salary (Optional)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _ageController,
                  label: 'Age',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                _buildImagePickerSection(colors),
                const SizedBox(height: 32),
                _buildActionButtons(colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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
      validator: (value) {
        // [والیدیتورهای قبلی حفظ می‌شوند]
        if (value == null || value.isEmpty) {
    return 'Please enter the age';
    }
    return null;
    },
    );
  }

  Widget _buildPositionDropdown(ColorScheme colors) {
    return DropdownButtonFormField<String>(
      value: _selectedPosition,
      decoration: InputDecoration(
        labelText: 'Position',
        prefixIcon: Icon(Icons.sports_soccer, color: colors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: colors.surface,
      ),
      items: _positions.map((position) {
        return DropdownMenuItem(
          value: position,
          child: Text(position),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedPosition = value),
      validator: (value) => value == null ? 'Please select a position' : null,
    );
  }

  Widget _buildImagePickerSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Player Photo', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _imageFile != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_imageFile!, fit: BoxFit.cover),
              )
                  : Icon(Icons.add_a_photo,
                  size: 40,
                  color: colors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _updatePlayer,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            backgroundColor: colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text('Save Changes',
              style: TextStyle(
                  color: colors.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: Text('Cancel',
              style: TextStyle(
                  color: colors.error,
                  fontSize: 16)),
        ),
      ],
    );
  }
}