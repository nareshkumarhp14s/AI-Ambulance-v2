class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? photoUrl;
  final String? bloodGroup;
  final String? emergencyContact;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.photoUrl,
    this.bloodGroup,
    this.emergencyContact,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      uid: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'patient',
      photoUrl: map['photoUrl'],
      bloodGroup: map['bloodGroup'],
      emergencyContact: map['emergencyContact'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'photoUrl': photoUrl,
      'bloodGroup': bloodGroup,
      'emergencyContact': emergencyContact,
    };
  }
}
