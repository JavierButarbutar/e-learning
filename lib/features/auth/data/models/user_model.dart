abstract class UserModel {
  final String role;
  final String name;
  final String email;
  final String foto;

  const UserModel({
    required this.role,
    required this.name,
    required this.email,
    required this.foto,
  });

  Map<String, dynamic> toMap();

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final role = map['role'] ?? '';
    if (role == 'siswa') return SiswaModel.fromMap(map);
    if (role == 'guru') return GuruModel.fromMap(map);
    throw Exception('Role tidak dikenali: $role');
  }
}

class SiswaModel extends UserModel {
  final String nis;
  final String kelas;

  const SiswaModel({
    required super.name,
    required super.email,
    required super.foto,
    required this.nis,
    required this.kelas,
  }) : super(role: 'siswa');

  factory SiswaModel.fromMap(Map<String, dynamic> map) {
    return SiswaModel(
      name: map['name'] ?? '-',
      email: map['email'] ?? '-',
      foto: map['foto'] ?? '',
      nis: map['nis'] ?? '-',
      kelas: map['kelas'] ?? '-',
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    'role': role,
    'name': name,
    'email': email,
    'foto': foto,
    'nis': nis,
    'kelas': kelas,
  };
}

class GuruModel extends UserModel {
  final String nip;
  final String namaMapel;
  final String noTelp;
  final String alamat;

  const GuruModel({
    required super.name,
    required super.email,
    required super.foto,
    required this.nip,
    required this.namaMapel,
    required this.noTelp,
    required this.alamat,
  }) : super(role: 'guru');

  factory GuruModel.fromMap(Map<String, dynamic> map) {
    return GuruModel(
      name: map['name'] ?? '-',
      email: map['email'] ?? '-',
      foto: map['foto'] ?? '',
      nip: map['nip'] ?? '-',
      namaMapel: map['nama_mapel'] ?? '-',
      noTelp: map['no_telp'] ?? '-',
      alamat: map['alamat'] ?? '-',
    );
  }

  @override
  Map<String, dynamic> toMap() => {
    'role': role,
    'name': name,
    'email': email,
    'foto': foto,
    'nip': nip,
    'nama_mapel': namaMapel,
    'no_telp': noTelp,
    'alamat': alamat,
  };
}
