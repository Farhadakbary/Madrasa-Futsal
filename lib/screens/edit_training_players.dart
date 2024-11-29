import 'dart:io';
import 'package:flutter/material.dart';
import 'package:futsal/database/player_modle.dart';
import 'package:futsal/screens/trianing_player_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../database/helper.dart';
import 'package:intl/intl.dart';

class EditFutsalPlayerScreen extends StatefulWidget {
  final FutsalPlayer player;
  const EditFutsalPlayerScreen({Key? key, required this.player,})
      : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Futsal Player',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
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
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter first name'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter last name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter phone number'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    labelStyle: TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter age' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _feeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fee',
                    labelStyle: TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter fee' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _positions.contains(_selectedPosition)
                      ? _selectedPosition
                      : _positions.first,
                  decoration: const InputDecoration(
                    labelText: 'Position',
                    labelStyle: TextStyle(color: Colors.blue),
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
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _times.contains(_selectedTime)
                      ? _selectedTime
                      : _times.first,
                  decoration: const InputDecoration(
                    labelText: 'Registration Time',
                    labelStyle: TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(),
                  ),
                  items: _times.map((time) {
                    return DropdownMenuItem(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTime = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _registrationDateController,
                  decoration: const InputDecoration(
                    labelText: 'Registration Date',
                    labelStyle: TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () {
                    FocusScope.of(context)
                        .requestFocus(FocusNode()); // Hide the keyboard
                    _selectDate(context);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a registration date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _imageFile != null
                        ? Image.file(_imageFile!, width: 80, height: 80)
                        : const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person, size: 40),
                          ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _pickImage,
                     style:  ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: const Text('Pick Image',style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _updatePlayer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 12,color: Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PlayersListScreen()));
                      },
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
