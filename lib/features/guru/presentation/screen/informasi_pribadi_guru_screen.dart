import 'package:flutter/material.dart';
import '../../../../core/storage/shared_pref.dart';

class InformasiPribadiGuruScreen extends StatefulWidget {
  const InformasiPribadiGuruScreen({super.key});

  @override
  State<InformasiPribadiGuruScreen> createState() =>
      _InformasiPribadiGuruScreenState();
}

class _InformasiPribadiGuruScreenState
    extends State<InformasiPribadiGuruScreen> {

  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await SharedPref.getUser();

    print("DATA GURU:");
    print(data);

    if (!mounted) return;

    setState(() {
      user = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    final name = user?['name'] ?? '-';
    final nip = user?['nip'] ?? '-';
    final mapel = user?['nama_mapel'] ?? '-';
    final email = user?['email'] ?? '-';
    final noTelp = user?['no_telp'] ?? '-';
    final alamat = user?['alamat'] ?? '-';
    final foto = user?['foto'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )

          : Column(
              children: [

                // ================= HEADER =================
                Container(
                  color: const Color(0xFF2E7D32),

                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.of(context).padding.top + 10,
                    16,
                    16,
                  ),

                  child: Row(
                    children: [

                      GestureDetector(
                        onTap: () => Navigator.pop(context),

                        child: Container(
                          width: 34,
                          height: 34,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),

                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      const Text(
                        'Pengaturan Profil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= CONTENT =================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      children: [

                        // FOTO
                        Container(
                          width: 90,
                          height: 90,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFF5A623),
                              width: 3,
                            ),
                          ),

                          child: ClipOval(
                            child: foto.toString().startsWith('http')
                                ? Image.network(
                                    foto,
                                    fit: BoxFit.cover,

                                    errorBuilder: (_, __, ___) {
                                      return _defaultAvatar();
                                    },
                                  )
                                : _defaultAvatar(),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // NAMA
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins',
                          ),
                        ),

                        const SizedBox(height: 4),

                        // NIP
                        Text(
                          'NIP: $nip',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF777777),
                            fontFamily: 'Poppins',
                          ),
                        ),

                        const SizedBox(height: 24),

                        // CARD INFO
                        _infoCard([

                          _infoItem(
                            'Nama Lengkap',
                            name,
                          ),

                          _infoItem(
                            'NIP',
                            nip,
                          ),

                          _infoItem(
                            'Mata Pelajaran',
                            mapel,
                          ),

                          _infoItem(
                            'Email',
                            email,
                            Icons.email_outlined,
                          ),

                          _infoItem(
                            'Nomor Telepon',
                            noTelp,
                            Icons.phone_outlined,
                          ),

                          _infoItem(
                            'Alamat',
                            alamat,
                            Icons.location_on_outlined,
                          ),
                        ]),

                        const SizedBox(height: 16),

                        // INFO
                        Container(
                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFFE082),
                            ),
                          ),

                          child: const Row(
                            children: [

                              Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFFF5A623),
                                size: 18,
                              ),

                              SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  'Informasi profil dikelola oleh admin sekolah dan tidak dapat diubah melalui aplikasi.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF856404),
                                    fontFamily: 'Poppins',
                                    height: 1.5,
                                  ),
                                ),
                              ),
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

  // ================= DEFAULT AVATAR =================
  Widget _defaultAvatar() {
    return Container(
      color: Colors.grey.shade200,

      child: const Icon(
        Icons.person_rounded,
        size: 45,
        color: Color(0xFF2E7D32),
      ),
    );
  }

  // ================= CARD =================
  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
        ),
      ),

      child: Column(
        children: children,
      ),
    );
  }

  // ================= ITEM =================
  Widget _infoItem(
    String label,
    String value, [
    IconData? icon,
  ]) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF2E7D32),
            ),

            const SizedBox(width: 8),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF888888),
                    fontFamily: 'Poppins',
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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