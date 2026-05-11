import 'dart:io';
import 'package:flutter/material.dart';
import 'status_badge.dart';

/// Menampilkan section "File Jawaban" dengan 3 kondisi:
/// 1. Ada file di server (sudah diupload)
/// 2. File baru dipilih (belum diupload)
/// 3. Belum ada file sama sekali
class FileJawabanSection extends StatelessWidget {
  // State file
  final String?  fileTeruploadNama;
  final String?  fileTeruploadUrl;
  final File?    fileBaru;
  final String?  namaFileBaru;
  final String?  ukuranFileBaru;

  // Status
  final bool   sudahDinilai;
  final String? statusPengumpulan;

  // Callbacks
  final VoidCallback onPilihFile;
  final VoidCallback onHapusFileBaru;
  final VoidCallback onHapusFileTerupload;

  const FileJawabanSection({
    super.key,
    required this.fileTeruploadNama,
    required this.fileTeruploadUrl,
    required this.fileBaru,
    required this.namaFileBaru,
    required this.ukuranFileBaru,
    required this.sudahDinilai,
    required this.statusPengumpulan,
    required this.onPilihFile,
    required this.onHapusFileBaru,
    required this.onHapusFileTerupload,
  });

  @override
  Widget build(BuildContext context) {
    final sudahAdaFileServer = fileTeruploadNama != null;
    final sudahPilihFileBaru = fileBaru != null;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Header ────────────────────────────────────────────
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('File Jawaban',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A), fontFamily: 'Poppins')),
        if (statusPengumpulan != null)
          StatusBadge(status: statusPengumpulan!),
      ]),
      const SizedBox(height: 10),

      // ── Kondisi 1: File sudah di server ──────────────────
      if (sudahAdaFileServer)
        _FileTeruploadCard(
          namaFile: fileTeruploadNama!,
          fileUrl: fileTeruploadUrl,
          sudahDinilai: sudahDinilai,
          onHapus: onHapusFileTerupload,
        )

      // ── Kondisi 2: File baru dipilih ─────────────────────
      else if (sudahPilihFileBaru)
        _FileBaruCard(
          namaFile: namaFileBaru!,
          ukuranFile: ukuranFileBaru!,
          onHapus: onHapusFileBaru,
        )

      // ── Kondisi 3: Belum ada file ─────────────────────────
      else
        GestureDetector(
          onTap: sudahDinilai ? null : onPilihFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sudahDinilai
                    ? const Color(0xFFEEEEEE)
                    : const Color(0xFF2E7D32),
                width: 1.5,
              ),
            ),
            child: Column(children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: sudahDinilai
                    ? const Color(0xFFF5F5F5)
                    : const Color(0xFFE8F5E9),
                child: Icon(Icons.upload_file_outlined,
                    color: sudahDinilai
                        ? const Color(0xFFBBBBBB)
                        : const Color(0xFF2E7D32),
                    size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                sudahDinilai ? 'Tidak dapat upload file' : 'Klik untuk pilih file',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: sudahDinilai
                      ? const Color(0xFFBBBBBB)
                      : const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 4),
              const Text('PDF, DOC, DOCX, JPG, PNG, PPT (Maks. 10 MB)',
                  style: TextStyle(fontSize: 11, color: Color(0xFF888888),
                      fontFamily: 'Poppins')),
            ]),
          ),
        ),

      // ── Info 1 file ───────────────────────────────────────
      if (!sudahAdaFileServer && !sudahDinilai)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(children: const [
            Icon(Icons.info_outline_rounded, size: 13, color: Color(0xFF888888)),
            SizedBox(width: 5),
            Text('Hanya 1 file yang dapat diupload per tugas',
                style: TextStyle(fontSize: 11, color: Color(0xFF888888),
                    fontFamily: 'Poppins')),
          ]),
        ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Sub-widget: file yang sudah ada di server
// ─────────────────────────────────────────────────────────────
class _FileTeruploadCard extends StatelessWidget {
  final String  namaFile;
  final String? fileUrl;
  final bool    sudahDinilai;
  final VoidCallback onHapus;

  const _FileTeruploadCard({
    required this.namaFile,
    required this.fileUrl,
    required this.sudahDinilai,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E7D32), width: 1.5),
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.insert_drive_file_outlined,
                color: Color(0xFF2E7D32), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(namaFile,
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A), fontFamily: 'Poppins'),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(children: const [
                  Icon(Icons.check_circle_rounded,
                      size: 12, color: Color(0xFF2E7D32)),
                  SizedBox(width: 4),
                  Text('Sudah diupload',
                      style: TextStyle(fontSize: 11,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins')),
                ]),
              ],
            ),
          ),
          if (!sudahDinilai)
            GestureDetector(
              onTap: onHapus,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFEBEE),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 16, color: Color(0xFFE53935)),
              ),
            ),
        ]),
        if (!sudahDinilai) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8)),
            child: Row(children: const [
              Icon(Icons.info_outline_rounded,
                  size: 13, color: Color(0xFFF5A623)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Untuk upload ulang, tekan ikon hapus lalu pilih file baru.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF856404),
                      fontFamily: 'Poppins', height: 1.4),
                ),
              ),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sub-widget: file baru dipilih (belum diupload)
// ─────────────────────────────────────────────────────────────
class _FileBaruCard extends StatelessWidget {
  final String   namaFile;
  final String   ukuranFile;
  final VoidCallback onHapus;

  const _FileBaruCard({
    required this.namaFile,
    required this.ukuranFile,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.insert_drive_file_outlined,
              color: Color(0xFFE53935), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(namaFile,
                  style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A), fontFamily: 'Poppins'),
                  overflow: TextOverflow.ellipsis),
              Text(ukuranFile,
                  style: const TextStyle(fontSize: 11,
                      color: Color(0xFF888888), fontFamily: 'Poppins')),
            ],
          ),
        ),
        GestureDetector(
          onTap: onHapus,
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF5F5F5),
                border: Border.all(color: const Color(0xFFEEEEEE))),
            child: const Icon(Icons.close_rounded,
                size: 14, color: Color(0xFF888888)),
          ),
        ),
      ]),
    );
  }
}