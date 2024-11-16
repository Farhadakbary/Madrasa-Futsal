import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:futsal/database/helper.dart';

class AddMainTeamPlayerScreen extends StatefulWidget {
  const AddMainTeamPlayerScreen({Key? key}) : super(key: key);

  @override
  _AddMainTeamPlayerScreenState createState() =>
      _AddMainTeamPlayerScreenState();
}

class _AddMainTeamPlayerScreenState extends State<AddMainTeamPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _jerseyNumberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _contractDurationController =
  TextEditingController();

  File? _imageFile;
  String? _selectedPosition;
  String? _registrationDate;
  final List<String> _positions = [
    'Forward',
    'Midfielder',
    'Defender',
    'Goalkeeper'
  ];

  @override
  void initState() {
    super.initState();
    _registrationDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
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

  void _savePlayer() async {
    if (_formKey.currentState!.validate()) {
      final firstName = _firstNameController.text;
      final lastName = _lastNameController.text;
      final jerseyNumber = int.tryParse(_jerseyNumberController.text) ?? 0;
      final age = int.tryParse(_ageController.text) ?? 0;
      final salary = double.tryParse(_salaryController.text);
      final contractDuration =
          int.tryParse(_contractDurationController.text) ?? 1;
      final position = _selectedPosition;
      final imagePath = _imageFile?.path;

      final newPlayer = {
        'firstName': firstName,
        'lastName': lastName,
        'jerseyNumber': jerseyNumber,
        'position': position!,
        'contractDuration': contractDuration,
        'salary': salary,
        'imagePath': imagePath,
        'registrationDate': _registrationDate,
        'age': age,
      };

      await DatabaseHelper.instance.insertMainTeamPlayer(newPlayer);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Main team player saved successfully!')),
      );

      Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Main Team Player'),
        backgroundColor: Colors.red,
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
                  'Main Team Player Information',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _jerseyNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jersey Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the jersey number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedPosition,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    border: OutlineInputBorder(),
                  ),
                  items: _positions.map((position) {
                    return DropdownMenuItem(
                      value: position,
                      child: Text(position),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPosition = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a position';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contractDurationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Contract Duration (1-5 years)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final duration = int.tryParse(value ?? '') ?? 0;
                    if (duration < 1 || duration > 5) {
                      return 'Enter a valid duration (1-5)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _salaryController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Salary (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _imageFile != null
                        ? Image.file(_imageFile!, width: 80, height: 80)
                        : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 50),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _pickImage,
                      style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Pick Image'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Registration Date: $_registrationDate',
                  style: const TextStyle(fontSize: 16, color: Colors.blue),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _savePlayer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Save'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
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
