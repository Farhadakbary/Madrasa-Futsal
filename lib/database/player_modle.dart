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
  });

  // تبدیل یک بازیکن به Map برای ذخیره در دیتابیس
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
    };
  }

  // ساخت یک بازیکن از Map که از دیتابیس دریافت شده
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
    );
  }
}
