import 'package:flutter/material.dart';
import '../../../../core/storage/shared_pref.dart';

class InformasiPribadiScreen extends StatefulWidget {
  const InformasiPribadiScreen({super.key});

  @override
  State<InformasiPribadiScreen> createState() =>
      _InformasiPribadiScreenState();
}

class _InformasiPribadiScreenState extends State<InformasiPribadiScreen> {

  String nama = '-';
  String foto = '';
  String nisn = '-';
  String kelas = '-';

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await SharedPref.getUser();

    if (!mounted) return;

    setState(() {
      nama = user?['name'] ?? '-';
      foto = (user?['foto'] ?? '').toString();
      nisn = user?['nisn'] ?? '-';
      kelas = user?['kelas'] ?? '-';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topSafe = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: _loading
          ? const Center(child: CircularProgressIndicator())

          : Column(
              children: [

                /// ================= HEADER =================
                Container(
                  width: double.infinity,
                  color: const Color(0xFF2E7D32),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    topSafe + 12,
                    16,
                    18,
                  ),

                  child: Row(
                    children: [

                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(30),

                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.18),
                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Text(
                        'Informasi Pribadi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),

                /// ================= CONTENT =================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      children: [

                        const SizedBox(height: 8),

                        /// ================= FOTO =================
                        Container(
                          width: 108,
                          height: 108,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFEAF4EA),
                            border: Border.all(
                              color: const Color(0xFFF5A623),
                              width: 3,
                            ),
                          ),

                          child: ClipOval(
                            child: foto.startsWith('http')
                                ? Image.network(
                                    foto,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _defaultAvatar(),
                                  )
                                : _defaultAvatar(),
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Foto profil siswa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8A8A8A),
                            fontFamily: 'Poppins',
                          ),
                        ),

                        const SizedBox(height: 22),

                        /// ================= CARD INFO =================
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFFEAEAEA),
                            ),
                          ),

                          child: Column(
                            children: [

                              _infoItem('Nama Lengkap', nama),

                              const _DividerLine(),

                              _infoItem('NISN', nisn),

                              const _DividerLine(),

                              _infoItem('Kelas', kelas),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// ================= DEFAULT AVATAR =================
  Widget _defaultAvatar() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.person_rounded,
        size: 56,
        color: Color(0xFF2E7D32),
      ),
    );
  }

  /// ================= INFO ITEM =================
  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8A8A),
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= DIVIDER =================
class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF0F0F0),
      indent: 18,
      endIndent: 18,
    );
  }
}