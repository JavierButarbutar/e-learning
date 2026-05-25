import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/notifikasi_guru_provider.dart';
import '../widgets/notifikasi_guru_item.dart';

// Tidak buat provider baru — pakai yang sudah ada dari MainGuruScaffold
class NotifikasiGuruScreen extends StatelessWidget {
  const NotifikasiGuruScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _NotifikasiGuruView();
  }
}

class _NotifikasiGuruView extends StatefulWidget {
  const _NotifikasiGuruView();

  @override
  State<_NotifikasiGuruView> createState() => _NotifikasiGuruViewState();
}

class _NotifikasiGuruViewState extends State<_NotifikasiGuruView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotifikasiGuruProvider>().loadNotifikasi(refresh: true);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<NotifikasiGuruProvider>().loadNotifikasi();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifikasi',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
                fontFamily: 'Poppins')),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () =>
                context.read<NotifikasiGuruProvider>().bacaSemua(),
            child: const Text('Tandai dibaca',
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2E7D32),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Consumer<NotifikasiGuruProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading && prov.list.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (prov.error != null && prov.list.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 8),
                Text(prov.error!,
                    style: const TextStyle(fontFamily: 'Poppins')),
                TextButton(
                    onPressed: () => prov.loadNotifikasi(refresh: true),
                    child: const Text('Coba Lagi')),
              ]),
            );
          }

          if (prov.list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_outlined,
                      size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Belum ada notifikasi jadwal',
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => prov.loadNotifikasi(refresh: true),
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(14),
              itemCount: prov.list.length + (prov.hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                if (i == prov.list.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ));
                }
                final notif = prov.list[i];
                return NotifikasiGuruItem(
                  notif: notif,
                  onTap: () => prov.bacaNotifikasi(notif.idNotifikasi),
                );
              },
            ),
          );
        },
      ),
    );
  }
}