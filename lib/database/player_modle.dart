class FutsalPlayer {
  int? id;
  String firstName;
  String lastName;
  String phone;
  int age;
  String position;
  double fee;
  String registrationTime;
  String? imagePath;
  String? registrationDate;  // New field added

  FutsalPlayer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.age,
    required this.position,
    required this.fee,
    required this.registrationTime,
    this.imagePath,
    this.registrationDate,  // Include registrationDate in constructor
  });

  FutsalPlayer copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    int? age,
    String? position,
    double? fee,
    String? registrationTime,
    String? imagePath,
    String? registrationDate,  // Add registrationDate to copyWith
  }) {
    return FutsalPlayer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      position: position ?? this.position,
      fee: fee ?? this.fee,
      registrationTime: registrationTime ?? this.registrationTime,
      imagePath: imagePath ?? this.imagePath,
      registrationDate: registrationDate ?? this.registrationDate,  // Include registrationDate in copyWith
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'age': age,
      'position': position,
      'fee': fee,
      'registrationTime': registrationTime,
      'imagePath': imagePath,
      'registrationDate': registrationDate,  // Include registrationDate in toMap
    };
  }

  factory FutsalPlayer.fromMap(Map<String, dynamic> map) {
    return FutsalPlayer(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phone: map['phone'],
      age: map['age'],
      position: map['position'],
      fee: map['fee'],
      registrationTime: map['registrationTime'],
      imagePath: map['imagePath'],
      registrationDate: map['registrationDate'],  // Include registrationDate in fromMap
    );
  }
}
