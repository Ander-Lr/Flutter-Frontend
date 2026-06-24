class Empresa {
  final String idEmpresa;
  final String nombreEmpresa;
  final String? logoUrl;

  Empresa({
    required this.idEmpresa,
    required this.nombreEmpresa,
    this.logoUrl,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      idEmpresa: json['idEmpresa'] ?? '',
      nombreEmpresa: json['nombreEmpresa'] ?? 'Empresa Desconocida',
      logoUrl: json['logoUrl'],
    );
  }
}

class UserProfile {
  final int id;
  final String email;
  final String username;
  final String? profilePicture;
  final String role;
  final Empresa? empresa;

  UserProfile({
    required this.id,
    required this.email,
    required this.username,
    this.profilePicture,
    required this.role,
    this.empresa,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      profilePicture: json['profilePicture'],
      role: json['role'] ?? 'USER',
      empresa: json['empresa'] != null ? Empresa.fromJson(json['empresa']) : null,
    );
  }
}
