
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/wikarta_appbar.dart';
import '../widgets/wikarta_navbar.dart';
import '../widgets/glassmorph_card.dart';
import '../theme/app_colors.dart';

// ==== MODEL ====
class Package {
  final String id;
  final String name;
  final String description;
  final int subscribePrice;
  final int registrationPrice;
  final String status; // "Published" | "Draft"
  final int sequence;
  Package({
    required this.id,
    required this.name,
    required this.description,
    required this.subscribePrice,
    required this.registrationPrice,
    required this.status,
    required this.sequence,
  });
}


// ==== PROVIDER ====
class PackagesProvider extends ChangeNotifier {
  List<Package> _allPackages = [
    Package(
      id: "P001",
      name: "Paket 10Mbps",
      description: "Unlimited, up to 10Mbps",
      subscribePrice: 150000,
      registrationPrice: 50000,
      status: "Published",
      sequence: 1,
    ),
    Package(
      id: "P002",
      name: "Paket 20Mbps",
      description: "Unlimited, up to 20Mbps",
      subscribePrice: 250000,
      registrationPrice: 75000,
      status: "Published",
      sequence: 2,
    ),
    Package(
      id: "P003",
      name: "Paket 50Mbps",
      description: "Unlimited, up to 50Mbps",
      subscribePrice: 450000,
      registrationPrice: 100000,
      status: "Draft",
      sequence: 3,
    ),
    // Tambahkan dummy data lain sesuai kebutuhan
  ];

  List<Package> _filteredPackages = [];
  String _search = "";
  String _statusFilter = "Semua";
  bool _loading = false;
  String? _error;

  int _page = 1;
  int _pageSize = 10;

  PackagesProvider() {
    _filteredPackages = _allPackages;
  }

  List<Package> get packages => _filteredPackages.take(_page * _pageSize).toList();
  bool get loading => _loading;
  String? get error => _error;
  bool get hasMore => _filteredPackages.length > _page * _pageSize;
  String get search => _search;
  String get statusFilter => _statusFilter;

  void searchPackage(String value) {
    _search = value;
    _applyFilter();
  }

  void filterStatus(String status) {
    _statusFilter = status;
    _applyFilter();
  }

  void _applyFilter() {
    _filteredPackages = _allPackages.where((p) {
      final matchName = p.name.toLowerCase().contains(_search.toLowerCase());
      final matchStatus = _statusFilter == "Semua" ? true : p.status == _statusFilter;
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

  void addPackage(Package p) {
    _allPackages.insert(0, p);
    _applyFilter();
  }

  void editPackage(Package p) {
    final idx = _allPackages.indexWhere((x) => x.id == p.id);
    if (idx >= 0) {
      _allPackages[idx] = p;
      _applyFilter();
    }
  }


  void deletePackage(String id) {
    _allPackages.removeWhere((p) => p.id == id);
    _applyFilter();
  }
}

// ==== MAIN SCREEN ====
class PackagesScreen extends StatelessWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PackagesProvider(),
      child: const _PackagesView(),
    );
  }
}

class _PackagesView extends StatelessWidget {
  const _PackagesView();
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<PackagesProvider>(context);
    return Scaffold(
      appBar: const WikartaAppBar(title: "Daftar Paket Internet"),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.coolGray,
        child: const Icon(Icons.add_box),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => PackageFormDialog(),
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
                      hintText: "Cari nama paket...",
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                    onChanged: prov.searchPackage,
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: prov.statusFilter,
                  items: ["Semua", "Published", "Draft"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => prov.filterStatus(v!),
                  underline: Container(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _PackagesListSection(),
          ),
        ],
      ),
      bottomNavigationBar: WikartaNavbar(
        selectedIndex: 2,
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

class _PackagesListSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<PackagesProvider>(context);
    if (prov.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.error != null) {
      return Center(child: Text(prov.error!, style: TextStyle(color: Colors.red)));
    }
    if (prov.packages.isEmpty) {
      return Center(child: Text("Tidak ada paket ditemukan"));
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
        itemCount: prov.packages.length + (prov.hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == prov.packages.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final p = prov.packages[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => PackageDetailSheet(pkg: p),
              ),
              child: GlassmorphCard(
                child: ListTile(
                  leading: Icon(Icons.wifi, color: Colors.blueAccent),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${p.description}\nLangganan: Rp ${p.subscribePrice}\nRegistrasi: Rp ${p.registrationPrice}"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusPkgBadge(status: p.status),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => PackageFormDialog(editPackage: p),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => DeletePkgConfirmDialog(pkg: p),
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

// === BADGE STATUS PAKET ===
class StatusPkgBadge extends StatelessWidget {
  final String status;
  const StatusPkgBadge({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status == "Published" ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: status == "Published" ? Colors.green[800] : Colors.red[800],
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ==== DETAIL SHEET ====
class PackageDetailSheet extends StatelessWidget {
  final Package pkg;
  const PackageDetailSheet({super.key, required this.pkg});
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
                  child: Icon(Icons.wifi, size: 54, color: Colors.blueAccent),
                ),
                const SizedBox(height: 20),
                _detailRow(Icons.label, "Nama Paket", pkg.name),
                _detailRow(Icons.description, "Deskripsi", pkg.description),
                _detailRow(Icons.price_change, "Harga Langganan", "Rp ${pkg.subscribePrice}"),
                _detailRow(Icons.add_card, "Harga Registrasi", "Rp ${pkg.registrationPrice}"),
                _detailRow(Icons.verified, "Status", pkg.status),
                _detailRow(Icons.sort, "Sequence", pkg.sequence.toString()),
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
class PackageFormDialog extends StatefulWidget {
  final Package? editPackage;
  PackageFormDialog({super.key, this.editPackage});

  @override
  State<PackageFormDialog> createState() => _PackageFormDialogState();
}

class _PackageFormDialogState extends State<PackageFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _desc, _subscribe, _register, _sequence;
  String _status = "Published";
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.editPackage?.name ?? "");
    _desc = TextEditingController(text: widget.editPackage?.description ?? "");
    _subscribe = TextEditingController(text: widget.editPackage?.subscribePrice.toString() ?? "");
    _register = TextEditingController(text: widget.editPackage?.registrationPrice.toString() ?? "");
    _sequence = TextEditingController(text: widget.editPackage?.sequence.toString() ?? "");
    _status = widget.editPackage?.status ?? "Published";
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _subscribe.dispose();
    _register.dispose();
    _sequence.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      final prov = Provider.of<PackagesProvider>(context, listen: false);
      if (widget.editPackage == null) {
        prov.addPackage(
          Package(
            id: "P${DateTime.now().millisecondsSinceEpoch % 100000}",
            name: _name.text,
            description: _desc.text,
            subscribePrice: int.parse(_subscribe.text),
            registrationPrice: int.parse(_register.text),
            status: _status,
            sequence: int.parse(_sequence.text),
          ),
        );
      } else {
        prov.editPackage(
          Package(
            id: widget.editPackage!.id,
            name: _name.text,
            description: _desc.text,
            subscribePrice: int.parse(_subscribe.text),
            registrationPrice: int.parse(_register.text),
            status: _status,
            sequence: int.parse(_sequence.text),
          ),
        );
      }
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editPackage == null ? "Tambah Paket" : "Edit Paket"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 350,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: "Nama Paket"),
                  validator: (v) => v == null || v.isEmpty ? "Nama wajib diisi" : null,
                ),
                TextFormField(
                  controller: _desc,
                  decoration: const InputDecoration(labelText: "Deskripsi"),
                  validator: (v) => v == null || v.isEmpty ? "Deskripsi wajib diisi" : null,
                ),
                TextFormField(
                  controller: _subscribe,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Harga Langganan"),
                  validator: (v) => v == null || int.tryParse(v) == null ? "Harga langganan tidak valid" : null,
                ),
                TextFormField(
                  controller: _register,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Harga Registrasi"),
                  validator: (v) => v == null || int.tryParse(v) == null ? "Harga registrasi tidak valid" : null,
                ),
                TextFormField(
                  controller: _sequence,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Sequence"),
                  validator: (v) => v == null || int.tryParse(v) == null ? "Sequence tidak valid" : null,
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: ["Published", "Draft"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _status = v!),
                  decoration: const InputDecoration(labelText: "Status"),
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
class DeletePkgConfirmDialog extends StatelessWidget {
  final Package pkg;
  const DeletePkgConfirmDialog({super.key, required this.pkg});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Konfirmasi Hapus"),
      content: Text("Yakin ingin menghapus paket '${pkg.name}'?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Provider.of<PackagesProvider>(context, listen: false).deletePackage(pkg.id);
            Navigator.pop(context);
          },
          child: const Text("Hapus"),
        ),
      ],
    );
  }
}