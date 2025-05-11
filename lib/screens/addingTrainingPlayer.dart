import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:futsal/database/player_modle.dart';
import 'package:futsal/screens/trianing_player_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:futsal/database/helper.dart';
import 'package:intl/intl.dart';

class AddFutsalPlayerScreen extends StatefulWidget {
  const AddFutsalPlayerScreen({
    Key? key,
  }) : super(key: key);

  @override
  _AddFutsalPlayerScreenState createState() => _AddFutsalPlayerScreenState();
}

class _AddFutsalPlayerScreenState extends State<AddFutsalPlayerScreen> {
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

  void _savePlayer() async {
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text;
      final lastName = _lastNameController.text;
      final phone = _phoneController.text;
      final age = int.tryParse(_ageController.text) ?? 0;
      final position = _selectedPosition;
      final time = _selectedTime;
      final fee = double.tryParse(_feeController.text) ?? 0.0;
      final registrationDate = _registrationDateController.text;
      final imagePath = _imageFile?.path;

      final newPlayer = FutsalPlayer(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        age: age,
        position: position!,
        fee: fee,
        registrationTime: time!,
        registrationDate: registrationDate,
        imagePath: imagePath,
      );

      try {
        await DatabaseHelper.instance.insertPlayer(newPlayer.toMap());
        print('Player saved successfully!');
      } catch (e) {
        print('Error saving player: $e');
      }
      Navigator.pop(context,
          MaterialPageRoute(builder: (context) => const PlayersListScreen()));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Futsal Player'),
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
                  _buildSectionHeader('Player Information'),
                  const SizedBox(height: 20),
                  _buildImagePickerSection(colors),
                  const SizedBox(height: 24),
                  _buildTextFormField(
                    controller: _firstNameController,
                    label: 'First Name',
                    icon: Icons.person_outline,
                    colors: colors,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    icon: Icons.person_outlined,
                    colors: colors,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _phoneController,
                    label: 'Phone',
                    icon: Icons.phone,
                    colors: colors,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _ageController,
                    label: 'Age',
                    icon: Icons.cake_outlined,
                    colors: colors,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _feeController,
                    label: 'Fee',
                    icon: Icons.attach_money,
                    colors: colors,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownFormField(
                    colors: colors,
                    value: _selectedPosition,
                    items: _positions,
                    label: 'Position',
                    icon: Icons.sports_soccer,
                    onChanged: (value) => setState(() => _selectedPosition = value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownFormField(
                    colors: colors,
                    value: _selectedTime,
                    items: _times,
                    label: 'Time',
                    icon: Icons.access_time,
                    onChanged: (value) => setState(() => _selectedTime = value),
                  ),
                  const SizedBox(height: 16),
                  _buildDatePickerField(context, colors),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colors,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: _getValidatorForField(label),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colors.primary),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownFormField({
    required ColorScheme colors,
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colors.primary),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((String value) {
        return DropdownMenuItem(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
      dropdownColor: colors.surface,
    );
  }

  Widget _buildDatePickerField(BuildContext context, ColorScheme colors) {
    return TextFormField(
      controller: _registrationDateController,
      decoration: InputDecoration(
        labelText: 'Registration Date',
        prefixIcon: Icon(Icons.date_range, color: colors.primary),
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onTap: () => _selectDate(context),
      validator: (value) => value!.isEmpty ? 'Please select date' : null,
    );
  }

  Widget _buildImagePickerSection(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Player Photo',
            style: Theme.of(context).textTheme.titleMedium),
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
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
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
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: _savePlayer,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            backgroundColor: colors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text('Save',
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



  Widget _buildInputRow({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: _getValidatorForField(label),
        decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.purple.shade400),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Colors.grey.shade100,
    focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(
    color: Colors.purple,
    width: 1.5),
    ),

    ));
  }

  Widget _buildDropdownRow({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon,  color: Colors.purple.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
      dropdownColor: Colors.white,
      icon:  Icon(Icons.arrow_drop_down, color: Colors.purple.shade400),
    );
  }

  Widget _buildDatePickerRow() {
    return TextFormField(
      controller: _registrationDateController,
      decoration: InputDecoration(
        labelText: 'Registration Date',
        prefixIcon: Icon(Icons.calendar_today, color: Colors.purple.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        suffixIcon: IconButton(
          icon: Icon(Icons.date_range, color: Colors.purple.shade400),
          onPressed: () => _selectDate(context),
        ),
      ),
      onTap: () => _selectDate(context),
      validator: (value) => value!.isEmpty ? 'Please select date' : null,
    );
  }

  String? Function(String?)? _getValidatorForField(String label) {
    switch (label) {
      case 'First Name':
      case 'Last Name':
        return (value) => value!.isEmpty ? 'Required field' : null;
      case 'Phone':
        return (value) => !RegExp(r'^07[0-9]{8}$').hasMatch(value!)
            ? 'Invalid phone number'
            : null;
      case 'Age':
        return (value) => int.parse(value!) < 7 || int.parse(value) > 60
            ? 'Invalid age (7-60)'
            : null;
      case 'Fee':
        return (value) => double.parse(value!) > 2000
            ? 'Max fee 2000'
            : null;
      default:
        return (value) => null;
    }
  }
}