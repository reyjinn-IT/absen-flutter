class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? nim;
  final String? nidn;
  final String? phone;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.nim,
    this.nidn,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      nim: json['nim'],
      nidn: json['nidn'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'nim': nim,
      'nidn': nidn,
      'phone': phone,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isDosen => role == 'dosen';
  bool get isMahasiswa => role == 'mahasiswa';
}