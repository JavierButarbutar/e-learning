class ProgressMateri {
  final String mapel;
  final String materi;
  final dynamic item;
  bool isCompleted;

  ProgressMateri({
    required this.mapel,
    required this.materi,
    required this.item,
    this.isCompleted = false,
  });
}

class ProgressStore {
  static final List<ProgressMateri> aktivitas = [];
}