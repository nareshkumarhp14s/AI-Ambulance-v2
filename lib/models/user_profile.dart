class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final int age;
  final String gender;
  final String bloodGroup;
  final String address;
  final String emergencyContact;
  final String medicalConditions;
  final String profileImage;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.address,
    required this.emergencyContact,
    required this.medicalConditions,
    required this.profileImage,
  });

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      name: map["name"] ?? "",
      email: map["email"] ?? "",
      phone: map["phone"] ?? "",
      age: map["age"] ?? 0,
      gender: map["gender"] ?? "",
      bloodGroup: map["bloodGroup"] ?? "",
      address: map["address"] ?? "",
      emergencyContact: map["emergencyContact"] ?? "",
      medicalConditions: map["medicalConditions"] ?? "",
      profileImage: map["profileImage"] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "phone": phone,
      "age": age,
      "gender": gender,
      "bloodGroup": bloodGroup,
      "address": address,
      "emergencyContact": emergencyContact,
      "medicalConditions": medicalConditions,
      "profileImage": profileImage,
    };
  }
}
