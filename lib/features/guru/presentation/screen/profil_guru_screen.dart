import 'package:flutter/material.dart';
import '../../../../core/storage/shared_pref.dart';

class ProfilGuruScreen extends StatefulWidget {
  const ProfilGuruScreen({super.key});

  @override
  State<ProfilGuruScreen> createState() => _ProfilGuruScreenState();
}

class _ProfilGuruScreenState extends State<ProfilGuruScreen> {
  Map<String, dynamic>? user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await SharedPref.getUser();

    print("DATA PROFIL GURU:");
    print(data);

    if (!mounted) return;

    setState(() {
      user = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = user?['name'] ?? '-';
    final foto = user?['foto'] ?? '';
    final mapel = user?['nama_mapel'] ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )

          : Column(
              children: [

                // ================= HEADER =================
                Container(
                  width: double.infinity,
                  color: const Color(0xFF2E7D32),

                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 16,
                    20,
                    28,
                  ),

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

                      const SizedBox(height: 12),

                      // NAMA
                      Text(
                        name,
                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      const SizedBox(height: 4),

                      // MAPEL
                      Text(
                        mapel,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.75),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= MENU =================
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      children: [

                        _MenuCard(
                          icon: Icons.person_outline_rounded,
                          label: 'Informasi Pribadi',
                          sublabel: 'Detail akun & profil guru',

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const InformasiPribadiGuruScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // LOGOUT
                        GestureDetector(
                          onTap: () => _showLogoutDialog(context),

                          child: Container(
                            width: double.infinity,

                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),

                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(16),

                              border: Border.all(
                                color: const Color(0xFFFFCDD2),
                              ),
                            ),

                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [

                                Icon(
                                  Icons.logout_rounded,
                                  color: Color(0xFFE53935),
                                ),

                                SizedBox(width: 8),

                                Text(
                                  'Keluar Akun',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
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

  // ================= LOGOUT =================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text('Keluar Akun?'),

        content: const Text(
          'Apakah kamu yakin ingin keluar?',
        ),

        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),

            child: const Text('Batal'),
          ),

          ElevatedButton(
            onPressed: () async {
              await SharedPref.logout();

              if (!context.mounted) return;

              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
            },

            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

// ================= MENU CARD =================
class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),

          border: Border.all(
            color: const Color(0xFFEEEEEE),
          ),
        ),

        child: Row(
          children: [

            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),

              child: Icon(
                icon,
                color: const Color(0xFF2E7D32),
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(
                    label,

                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    sublabel,

                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCCCCCC),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// INFORMASI PRIBADI GURU
// =======================================================
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

                // HEADER
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
                        'Informasi Pribadi',

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

                        Text(
                          name,

                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins',
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'NIP: $nip',

                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF777777),
                            fontFamily: 'Poppins',
                          ),
                        ),

                        const SizedBox(height: 24),

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