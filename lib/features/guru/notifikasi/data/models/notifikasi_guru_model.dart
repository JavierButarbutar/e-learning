class NotifikasiGuruModel {
  final int idNotifikasi;
  final String tipe;
  final String judul;
  final String isi;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime? createdAt;

  const NotifikasiGuruModel({
    required this.idNotifikasi,
    required this.tipe,
    required this.judul,
    required this.isi,
    this.data,
    required this.isRead,
    this.createdAt,
  });

  factory NotifikasiGuruModel.fromJson(Map<String, dynamic> json) {
    return NotifikasiGuruModel(
      idNotifikasi: json['id_notifikasi'],
      tipe: json['tipe'] ?? '',
      judul: json['judul'] ?? '',
      isi: json['isi'] ?? '',
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : null,
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}
