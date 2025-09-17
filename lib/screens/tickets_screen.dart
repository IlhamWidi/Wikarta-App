import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/wikarta_appbar.dart';
import '../widgets/wikarta_navbar.dart';
import '../widgets/glassmorph_card.dart';
import '../theme/app_colors.dart';

// ==== MODEL ====
class Ticket {
  final String id;
  final String user;
  final String subject;
  final String desc;
  final String status; // "Baru" | "Proses" | "Selesai" | "Dibatalkan"
  final String createdAt;
  Ticket({
    required this.id,
    required this.user,
    required this.subject,
    required this.desc,
    required this.status,
    required this.createdAt,
  });
}

// ==== PROVIDER ====
class TicketsProvider extends ChangeNotifier {
  List<Ticket> _allTickets = [
    Ticket(
      id: "TKT-001",
      user: "Andi Wijaya",
      subject: "Internet mati total",
      desc: "Sudah 2 hari tidak ada koneksi.",
      status: "Proses",
      createdAt: "2025-09-10 10:21",
    ),
    Ticket(
      id: "TKT-002",
      user: "Citra Dewi",
      subject: "Tagihan salah",
      desc: "Nominal tagihan saya tidak sesuai.",
      status: "Selesai",
      createdAt: "2025-09-12 12:01",
    ),
    Ticket(
      id: "TKT-003",
      user: "Dewi Lestari",
      subject: "Wifi sering putus",
      desc: "Koneksi kadang hilang tiap malam.",
      status: "Baru",
      createdAt: "2025-09-15 08:10",
    ),
    // Tambah dummy ticket lain...
  ];

  List<Ticket> _filteredTickets = [];
  String _search = "";
  String _statusFilter = "Semua";
  bool _loading = false;
  String? _error;

  int _page = 1;
  int _pageSize = 10;

  TicketsProvider() {
    _filteredTickets = _allTickets;
  }

  List<Ticket> get tickets => _filteredTickets.take(_page * _pageSize).toList();
  bool get loading => _loading;
  String? get error => _error;
  bool get hasMore => _filteredTickets.length > _page * _pageSize;
  String get search => _search;
  String get statusFilter => _statusFilter;

  void searchTicket(String value) {
    _search = value;
    _applyFilter();
  }

  void filterStatus(String status) {
    _statusFilter = status;
    _applyFilter();
  }

  void _applyFilter() {
    _filteredTickets = _allTickets.where((t) {
      final matchName = t.user.toLowerCase().contains(_search.toLowerCase()) ||
          t.subject.toLowerCase().contains(_search.toLowerCase());
      final matchStatus = _statusFilter == "Semua" ? true : t.status == _statusFilter;
      return matchName && matchStatus;
    }).toList();
    _page = 1;
    notifyListeners();
  }

  void nextPage() {
    if (hasMore) {
      _page++;
      notifyListeners();
    }
  }

  void addTicket(Ticket t) {
    _allTickets.insert(0, t);
    _applyFilter();
  }

  void editTicket(Ticket t) {
    final idx = _allTickets.indexWhere((x) => x.id == t.id);
    if (idx >= 0) {
      _allTickets[idx] = t;
      _applyFilter();
    }
  }

  void deleteTicket(String id) {
    _allTickets.removeWhere((t) => t.id == id);
    _applyFilter();
  }
}

// ==== MAIN SCREEN ====
class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TicketsProvider(),
      child: const _TicketsView(),
    );
  }
}

class _TicketsView extends StatelessWidget {
  const _TicketsView({super.key});
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TicketsProvider>(context);
    return Scaffold(
      appBar: const WikartaAppBar(title: "Daftar Tiket Bantuan"),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.coolGray,
        child: const Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => TicketFormDialog(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Cari nama/subject...",
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: prov.searchTicket,
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: prov.statusFilter,
                  items: ["Semua", "Baru", "Proses", "Selesai", "Dibatalkan"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => prov.filterStatus(v!),
                  underline: Container(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _TicketsListSection(),
          ),
        ],
      ),
      bottomNavigationBar: WikartaNavbar(
        selectedIndex: 4,
        onTap: (i) {
          final routes = [
            '/dashboard', '/customers', '/packages', '/invoices', '/tickets', '/profile'
          ];
          Navigator.of(context).pushReplacementNamed(routes[i]);
        },
      ),
    );
  }
}

// ==== LIST SECTION ====
class _TicketsListSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TicketsProvider>(context);
    if (prov.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.error != null) {
      return Center(child: Text(prov.error!, style: TextStyle(color: Colors.red)));
    }
    if (prov.tickets.isEmpty) {
      return Center(child: Text("Tidak ada tiket ditemukan"));
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notif) {
        if (notif.metrics.pixels >= notif.metrics.maxScrollExtent - 50 && prov.hasMore) {
          prov.nextPage();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: prov.tickets.length + (prov.hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == prov.tickets.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final t = prov.tickets[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => TicketDetailSheet(ticket: t),
              ),
              child: GlassmorphCard(
                child: ListTile(
                  leading: Icon(Icons.support_agent, color: _iconColor(t.status)),
                  title: Text(t.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "${t.user} | ${t.createdAt}\n${t.desc}",
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TicketStatusBadge(status: t.status),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => TicketFormDialog(editTicket: t),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => DeleteTicketDialog(ticket: t),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Color _iconColor(String status) {
  switch (status) {
    case "Selesai":
      return Colors.green;
    case "Baru":
      return Colors.blue;
    case "Proses":
      return Colors.orange;
    case "Dibatalkan":
      return Colors.grey;
    default:
      return Colors.blueGrey;
  }
}

// ==== BADGE STATUS ====
class TicketStatusBadge extends StatelessWidget {
  final String status;
  const TicketStatusBadge({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    Color? color;
    switch (status) {
      case "Selesai":
        color = Colors.green[100];
        break;
      case "Baru":
        color = Colors.blue[100];
        break;
      case "Proses":
        color = Colors.orange[100];
        break;
      case "Dibatalkan":
        color = Colors.grey[300];
        break;
      default:
        color = Colors.blue[100];
    }
    Color? textColor;
    switch (status) {
      case "Selesai":
        textColor = Colors.green[800];
        break;
      case "Baru":
        textColor = Colors.blue[800];
        break;
      case "Proses":
        textColor = Colors.orange[800];
        break;
      case "Dibatalkan":
        textColor = Colors.grey[800];
        break;
      default:
        textColor = Colors.blue[800];
    }
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ==== DETAIL SHEET ====
class TicketDetailSheet extends StatelessWidget {
  final Ticket ticket;
  const TicketDetailSheet({super.key, required this.ticket});
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return GlassmorphCard(
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(Icons.support_agent, size: 54, color: _iconColor(ticket.status)),
                ),
                const SizedBox(height: 20),
                _detailRow(Icons.confirmation_number, "ID Tiket", ticket.id),
                _detailRow(Icons.person, "Pengadu", ticket.user),
                _detailRow(Icons.subject, "Subject", ticket.subject),
                _detailRow(Icons.description, "Deskripsi", ticket.desc),
                _detailRow(Icons.verified, "Status", ticket.status),
                _detailRow(Icons.calendar_today, "Dibuat", ticket.createdAt),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text("Tutup"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 10),
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ==== FORM DIALOG ====
class TicketFormDialog extends StatefulWidget {
  final Ticket? editTicket;
  TicketFormDialog({super.key, this.editTicket});

  @override
  State<TicketFormDialog> createState() => _TicketFormDialogState();
}

class _TicketFormDialogState extends State<TicketFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _user, _subject, _desc, _createdAt;
  String _status = "Baru";
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _user = TextEditingController(text: widget.editTicket?.user ?? "");
    _subject = TextEditingController(text: widget.editTicket?.subject ?? "");
    _desc = TextEditingController(text: widget.editTicket?.desc ?? "");
    _createdAt = TextEditingController(text: widget.editTicket?.createdAt ?? "");
    _status = widget.editTicket?.status ?? "Baru";
  }

  @override
  void dispose() {
    _user.dispose();
    _subject.dispose();
    _desc.dispose();
    _createdAt.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      final prov = Provider.of<TicketsProvider>(context, listen: false);
      if (widget.editTicket == null) {
        prov.addTicket(
          Ticket(
            id: "TKT-${DateTime.now().millisecondsSinceEpoch % 100000}",
            user: _user.text,
            subject: _subject.text,
            desc: _desc.text,
            status: _status,
            createdAt: _createdAt.text.isEmpty
                ? DateTime.now().toString().substring(0, 16)
                : _createdAt.text,
          ),
        );
      } else {
        prov.editTicket(
          Ticket(
            id: widget.editTicket!.id,
            user: _user.text,
            subject: _subject.text,
            desc: _desc.text,
            status: _status,
            createdAt: _createdAt.text,
          ),
        );
      }
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editTicket == null ? "Buat Tiket" : "Edit Tiket"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 350,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _user,
                  decoration: const InputDecoration(labelText: "Nama Pengadu"),
                  validator: (v) => v == null || v.isEmpty ? "Nama pengadu wajib diisi" : null,
                ),
                TextFormField(
                  controller: _subject,
                  decoration: const InputDecoration(labelText: "Subject"),
                  validator: (v) => v == null || v.isEmpty ? "Subject wajib diisi" : null,
                ),
                TextFormField(
                  controller: _desc,
                  decoration: const InputDecoration(labelText: "Deskripsi"),
                  validator: (v) => v == null || v.isEmpty ? "Deskripsi wajib diisi" : null,
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: ["Baru", "Proses", "Selesai", "Dibatalkan"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v!),
                  decoration: const InputDecoration(labelText: "Status"),
                ),
                TextFormField(
                  controller: _createdAt,
                  decoration: const InputDecoration(labelText: "Tanggal (YYYY-MM-DD HH:mm)"),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Simpan"),
        ),
      ],
    );
  }
}

// ==== HAPUS DIALOG ====
class DeleteTicketDialog extends StatelessWidget {
  final Ticket ticket;
  const DeleteTicketDialog({super.key, required this.ticket});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Konfirmasi Hapus"),
      content: Text("Yakin ingin menghapus tiket '${ticket.subject}' dari '${ticket.user}'?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Provider.of<TicketsProvider>(context, listen: false).deleteTicket(ticket.id);
            Navigator.pop(context);
          },
          child: const Text("Hapus"),
        ),
      ],
    );
  }
}