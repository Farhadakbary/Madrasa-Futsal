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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Main Team Player',style: TextStyle(color: Colors.white),),
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
                  'Edit Player Information',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(color: Colors.green),
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
                    labelStyle: TextStyle(color: Colors.green),
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
                    labelStyle: TextStyle(color: Colors.green),
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
                    labelStyle: TextStyle(color: Colors.green),
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
                    labelStyle: TextStyle(color: Colors.green),
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
                    labelStyle: TextStyle(color: Colors.green),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    labelStyle: TextStyle(color: Colors.green),
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
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('Pick Image',style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _updatePlayer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Save Changes',style: TextStyle(color: Colors.black)),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',style: TextStyle(color: Colors.black)),
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
