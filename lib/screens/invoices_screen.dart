import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/wikarta_appbar.dart';
import '../widgets/wikarta_navbar.dart';
import '../widgets/glassmorph_card.dart';
import '../theme/app_colors.dart';

// ==== MODEL ====
class Invoice {
  final String id;
  final String customerName;
  final int amount;
  final String due;
  final String status; // "Lunas" | "Belum Bayar" | "Jatuh Tempo" | "Dibatalkan"
  final String packageName;
  final String notes;
  Invoice({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.due,
    required this.status,
    required this.packageName,
    required this.notes,
  });
}

// ==== PROVIDER ====
class InvoicesProvider extends ChangeNotifier {
  List<Invoice> _allInvoices = [
    Invoice(
      id: "INV-0001",
      customerName: "Andi Wijaya",
      amount: 150000,
      due: "2025-09-25",
      status: "Belum Bayar",
      packageName: "Paket 10Mbps",
      notes: "Tagihan bulan September",
    ),
    Invoice(
      id: "INV-0002",
      customerName: "Budi Santoso",
      amount: 250000,
      due: "2025-09-15",
      status: "Lunas",
      packageName: "Paket 20Mbps",
      notes: "Tagihan bulan September",
    ),
    Invoice(
      id: "INV-0003",
      customerName: "Citra Dewi",
      amount: 450000,
      due: "2025-09-10",
      status: "Jatuh Tempo",
      packageName: "Paket 50Mbps",
      notes: "Tagihan bulan September",
    ),
    Invoice(
      id: "INV-0004",
      customerName: "Dewi Lestari",
      amount: 150000,
      due: "2025-08-10",
      status: "Dibatalkan",
      packageName: "Paket 10Mbps",
      notes: "Dibatalkan admin",
    ),
    // Tambahkan lebih banyak dummy data jika perlu
  ];

  List<Invoice> _filteredInvoices = [];
  String _search = "";
  String _statusFilter = "Semua";
  bool _loading = false;
  String? _error;

  int _page = 1;
  int _pageSize = 10;

  InvoicesProvider() {
    _filteredInvoices = _allInvoices;
  }

  List<Invoice> get invoices => _filteredInvoices.take(_page * _pageSize).toList();
  bool get loading => _loading;
  String? get error => _error;
  bool get hasMore => _filteredInvoices.length > _page * _pageSize;
  String get search => _search;
  String get statusFilter => _statusFilter;

  void searchInvoice(String value) {
    _search = value;
    _applyFilter();
  }

  void filterStatus(String status) {
    _statusFilter = status;
    _applyFilter();
  }

  void _applyFilter() {
    _filteredInvoices = _allInvoices.where((inv) {
      final matchName = inv.customerName.toLowerCase().contains(_search.toLowerCase());
      final matchStatus = _statusFilter == "Semua" ? true : inv.status == _statusFilter;
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

  void addInvoice(Invoice i) {
    _allInvoices.insert(0, i);
    _applyFilter();
  }

  void editInvoice(Invoice i) {
    final idx = _allInvoices.indexWhere((x) => x.id == i.id);
    if (idx >= 0) {
      _allInvoices[idx] = i;
      _applyFilter();
    }
  }

  void deleteInvoice(String id) {
    _allInvoices.removeWhere((i) => i.id == id);
    _applyFilter();
  }
}

// ==== MAIN SCREEN ====
class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InvoicesProvider(),
      child: const _InvoicesView(),
    );
  }
}

class _InvoicesView extends StatelessWidget {
  const _InvoicesView({super.key});
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<InvoicesProvider>(context);
    return Scaffold(
      appBar: const WikartaAppBar(title: "Daftar Invoice"),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.coolGray,
        child: const Icon(Icons.add),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => InvoiceFormDialog(),
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
                      hintText: "Cari pelanggan...",
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: prov.searchInvoice,
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: prov.statusFilter,
                  items: ["Semua", "Lunas", "Belum Bayar", "Jatuh Tempo", "Dibatalkan"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => prov.filterStatus(v!),
                  underline: Container(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _InvoiceListSection(),
          ),
        ],
      ),
      bottomNavigationBar: WikartaNavbar(
        selectedIndex: 3,
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
class _InvoiceListSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<InvoicesProvider>(context);
    if (prov.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.error != null) {
      return Center(child: Text(prov.error!, style: TextStyle(color: Colors.red)));
    }
    if (prov.invoices.isEmpty) {
      return Center(child: Text("Tidak ada invoice ditemukan"));
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
        itemCount: prov.invoices.length + (prov.hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == prov.invoices.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final inv = prov.invoices[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => InvoiceDetailSheet(invoice: inv),
              ),
              child: GlassmorphCard(
                child: ListTile(
                  leading: Icon(Icons.receipt_long, color: _iconColor(inv.status)),
                  title: Text(inv.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "${inv.customerName} | Paket: ${inv.packageName}\nRp ${inv.amount} | Jatuh tempo: ${inv.due}",
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InvoiceStatusBadge(status: inv.status),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => InvoiceFormDialog(editInvoice: inv),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => DeleteInvoiceDialog(invoice: inv),
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
    case "Lunas":
      return Colors.green;
    case "Belum Bayar":
      return Colors.orange;
    case "Jatuh Tempo":
      return Colors.redAccent;
    case "Dibatalkan":
      return Colors.grey;
    default:
      return Colors.blueGrey;
  }
}

// ==== BADGE STATUS ====
class InvoiceStatusBadge extends StatelessWidget {
  final String status;
  const InvoiceStatusBadge({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    Color? color;
    switch (status) {
      case "Lunas":
        color = Colors.green[100];
        break;
      case "Belum Bayar":
        color = Colors.orange[100];
        break;
      case "Jatuh Tempo":
        color = Colors.red[100];
        break;
      case "Dibatalkan":
        color = Colors.grey[300];
        break;
      default:
        color = Colors.blue[100];
    }
    Color? textColor;
    switch (status) {
      case "Lunas":
        textColor = Colors.green[800];
        break;
      case "Belum Bayar":
        textColor = Colors.orange[800];
        break;
      case "Jatuh Tempo":
        textColor = Colors.red[800];
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
class InvoiceDetailSheet extends StatelessWidget {
  final Invoice invoice;
  const InvoiceDetailSheet({super.key, required this.invoice});
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.98,
      builder: (context, scrollController) {
        return GlassmorphCard(
          padding: const EdgeInsets.all(28),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(Icons.receipt_long, size: 54, color: _iconColor(invoice.status)),
                ),
                const SizedBox(height: 18),
                _detailRow(Icons.confirmation_number, "ID Invoice", invoice.id),
                _detailRow(Icons.person, "Pelanggan", invoice.customerName),
                _detailRow(Icons.wifi, "Paket", invoice.packageName),
                _detailRow(Icons.price_change, "Nominal", "Rp ${invoice.amount}"),
                _detailRow(Icons.calendar_today, "Jatuh Tempo", invoice.due),
                _detailRow(Icons.verified, "Status", invoice.status),
                _detailRow(Icons.notes, "Catatan", invoice.notes),
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
class InvoiceFormDialog extends StatefulWidget {
  final Invoice? editInvoice;
  InvoiceFormDialog({super.key, this.editInvoice});

  @override
  State<InvoiceFormDialog> createState() => _InvoiceFormDialogState();
}

class _InvoiceFormDialogState extends State<InvoiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customer, _amount, _due, _package, _notes;
  String _status = "Belum Bayar";
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _customer = TextEditingController(text: widget.editInvoice?.customerName ?? "");
    _amount = TextEditingController(text: widget.editInvoice?.amount.toString() ?? "");
    _due = TextEditingController(text: widget.editInvoice?.due ?? "");
    _package = TextEditingController(text: widget.editInvoice?.packageName ?? "");
    _notes = TextEditingController(text: widget.editInvoice?.notes ?? "");
    _status = widget.editInvoice?.status ?? "Belum Bayar";
  }

  @override
  void dispose() {
    _customer.dispose();
    _amount.dispose();
    _due.dispose();
    _package.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      final prov = Provider.of<InvoicesProvider>(context, listen: false);
      if (widget.editInvoice == null) {
        prov.addInvoice(
          Invoice(
            id: "INV-${DateTime.now().millisecondsSinceEpoch % 100000}",
            customerName: _customer.text,
            amount: int.parse(_amount.text),
            due: _due.text,
            status: _status,
            packageName: _package.text,
            notes: _notes.text,
          ),
        );
      } else {
        prov.editInvoice(
          Invoice(
            id: widget.editInvoice!.id,
            customerName: _customer.text,
            amount: int.parse(_amount.text),
            due: _due.text,
            status: _status,
            packageName: _package.text,
            notes: _notes.text,
          ),
        );
      }
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editInvoice == null ? "Tambah Invoice" : "Edit Invoice"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 350,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _customer,
                  decoration: const InputDecoration(labelText: "Nama Pelanggan"),
                  validator: (v) => v == null || v.isEmpty ? "Nama pelanggan wajib diisi" : null,
                ),
                TextFormField(
                  controller: _package,
                  decoration: const InputDecoration(labelText: "Nama Paket"),
                  validator: (v) => v == null || v.isEmpty ? "Nama paket wajib diisi" : null,
                ),
                TextFormField(
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Nominal"),
                  validator: (v) => v == null || int.tryParse(v) == null ? "Nominal tidak valid" : null,
                ),
                TextFormField(
                  controller: _due,
                  decoration: const InputDecoration(labelText: "Jatuh Tempo (YYYY-MM-DD)"),
                  validator: (v) => v == null || v.length < 8 ? "Tanggal jatuh tempo wajib diisi" : null,
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: ["Lunas", "Belum Bayar", "Jatuh Tempo", "Dibatalkan"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v!),
                  decoration: const InputDecoration(labelText: "Status"),
                ),
                TextFormField(
                  controller: _notes,
                  decoration: const InputDecoration(labelText: "Catatan"),
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
class DeleteInvoiceDialog extends StatelessWidget {
  final Invoice invoice;
  const DeleteInvoiceDialog({super.key, required this.invoice});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Konfirmasi Hapus"),
      content: Text("Yakin ingin menghapus invoice '${invoice.id}' untuk '${invoice.customerName}'?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Provider.of<InvoicesProvider>(context, listen: false).deleteInvoice(invoice.id);
            Navigator.pop(context);
          },
          child: const Text("Hapus"),
        ),
      ],
    );
  }
}