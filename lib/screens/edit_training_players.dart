import 'dart:io';
import 'package:flutter/material.dart';
import 'package:futsal/database/player_modle.dart';
import 'package:image_picker/image_picker.dart';
import '../database/helper.dart';
import 'package:intl/intl.dart';

class EditFutsalPlayerScreen extends StatefulWidget {
  final FutsalPlayer player;
  const EditFutsalPlayerScreen({Key? key, required this.player}) : super(key: key);

  @override
  _EditFutsalPlayerScreenState createState() => _EditFutsalPlayerScreenState();
}

class _EditFutsalPlayerScreenState extends State<EditFutsalPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _registrationDateController =
  TextEditingController();

  File? _imageFile;
  String? _selectedPosition;
  String? _selectedTime;

  final List<String> _positions = [
    'Center Forward',
    'Left Flank',
    'Right Flank',
    'Center Back',
    'Goalkeeper'
  ];
  final List<String> _times = [
    '10:00',
    '12:00',
    '14:00',
    '16:00',
    '18:00',
    '20:00'
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final player = widget.player;
    _firstNameController.text = player.firstName;
    _lastNameController.text = player.lastName;
    _phoneController.text = player.phone;
    _ageController.text = player.age.toString();
    _feeController.text = player.fee.toString();
    _selectedPosition = player.position;
    _selectedTime = player.registrationTime;
    _registrationDateController.text = player.registrationDate ?? '';
    if (player.imagePath != null) {
      _imageFile = File(player.imagePath!);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
    await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _registrationDateController.text =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }


  Future<void> _updatePlayer() async {
    if (_formKey.currentState!.validate()) {
      final updatedPlayer = widget.player.copyWith(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text,
        age: int.tryParse(_ageController.text) ?? 0,
        fee: double.tryParse(_feeController.text) ?? 0.0,
        position: _selectedPosition!,
        registrationTime: _selectedTime!,
        registrationDate: _registrationDateController.text,
        imagePath: _imageFile?.path,
      );

      final rowsUpdated =
      await DatabaseHelper.instance.updatePlayer(updatedPlayer);

      if (rowsUpdated > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player updated successfully!')),
        );
        Navigator.pop(context, updatedPlayer);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update player.')),
        );
      }
    }
  }


  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _feeController.dispose();
    _registrationDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                Text('Edit Player Details', style: textTheme.headlineSmall),
                const SizedBox(height: 24),
                _buildFormField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outlined,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _ageController,
                  label: 'Age',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _feeController,
                  label: 'Fee',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildDropdownFormField(
                  value: _selectedPosition,
                  label: 'Position',
                  icon: Icons.sports_soccer,
                  items: _positions,
                  onChanged: (value) => setState(() => _selectedPosition = value),
                ),
                const SizedBox(height: 16),
                _buildDropdownFormField(
                  value: _selectedTime,
                  label: 'Training Time',
                  icon: Icons.access_time,
                  items: _times,
                  onChanged: (value) => setState(() => _selectedTime = value),
                ),
                const SizedBox(height: 16),
                _buildDatePickerField(context, colors),
                const SizedBox(height: 24),
                _buildImageSection(colors),
                const SizedBox(height: 32),
                _buildActionButtons(colors),
              ],
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
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
    );
  }

  Widget _buildDropdownFormField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
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
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePickerField(BuildContext context, ColorScheme colors) {
    return TextFormField(
      controller: _registrationDateController,
      decoration: InputDecoration(
        labelText: 'Registration Date',
        prefixIcon: Icon(Icons.calendar_today, color: colors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: colors.surface,
      ),
      onTap: () => _selectDate(context),
      validator: (value) => value!.isEmpty ? 'Select a date' : null,
    );
  }

  Widget _buildImageSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Player Photo', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: colors.primaryContainer,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : widget.player.imagePath != null
                    ? FileImage(File(widget.player.imagePath!))
                    : null,
                child: _imageFile == null && widget.player.imagePath == null
                    ? Icon(Icons.person, size: 40, color: colors.primary)
                    : null,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Change Photo',
                    style: TextStyle(color: colors.onPrimary)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
          child: Text(
            'SAVE CHANGES',
            style: TextStyle(
              color: colors.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: Text(
            'CANCEL',
            style: TextStyle(
              color: colors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}