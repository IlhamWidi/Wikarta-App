import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/glassmorph_card.dart';


// ==== MODEL ====
class Customer {
  final String id;
  final String name;
  final String email;
  final String address;
  final String phone;
  final String status;
  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.status,
  });
}

// ==== PROVIDER ====
class CustomerProvider extends ChangeNotifier {
  List<Customer> _allCustomers = [
    Customer(id: "C001", name: "Andi Wijaya", email: "andi@mail.com", address: "Jl. Mawar 1", phone: "0812345678", status: "Aktif"),
    Customer(id: "C002", name: "Budi Santoso", email: "budi@mail.com", address: "Jl. Melati 3", phone: "0812345679", status: "Aktif"),
    Customer(id: "C003", name: "Citra Dewi", email: "citra@mail.com", address: "Jl. Kenanga 9", phone: "0812345680", status: "Nonaktif"),
    Customer(id: "C004", name: "Dewi Lestari", email: "dewi@mail.com", address: "Jl. Dahlia 12", phone: "0812345681", status: "Aktif"),
    Customer(id: "C005", name: "Eka Pratama", email: "eka@mail.com", address: "Jl. Anggrek 5", phone: "0812345682", status: "Aktif"),
    // ... bisa tambah dummy data sebanyak mungkin
  ];

  List<Customer> _filteredCustomers = [];
  String _search = "";
  String _statusFilter = "Semua";
  bool _loading = false;
  String? _error;

  int _page = 1;
  int _pageSize = 10;

  CustomerProvider() {
    _filteredCustomers = _allCustomers;
  }

  List<Customer> get customers => _filteredCustomers.take(_page * _pageSize).toList();
  bool get loading => _loading;
  String? get error => _error;
  bool get hasMore => _filteredCustomers.length > _page * _pageSize;
  String get search => _search;
  String get statusFilter => _statusFilter;

  void searchCustomer(String value) {
    _search = value;
    _applyFilter();
  }

  void filterStatus(String status) {
    _statusFilter = status;
    _applyFilter();
  }

  void _applyFilter() {
    _filteredCustomers = _allCustomers.where((c) {
      final matchName = c.name.toLowerCase().contains(_search.toLowerCase());
      final matchStatus = _statusFilter == "Semua" ? true : c.status == _statusFilter;
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

  void addCustomer(Customer c) {
    _allCustomers.insert(0, c);
    _applyFilter();
  }

  void editCustomer(Customer c) {
    final idx = _allCustomers.indexWhere((x) => x.id == c.id);
    if (idx >= 0) {
      _allCustomers[idx] = c;
      _applyFilter();
    }
  }

  void deleteCustomer(String id) {
    _allCustomers.removeWhere((c) => c.id == id);
    _applyFilter();
  }
}

// ==== MAIN SCREEN ====
class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CustomerProvider(),
  child: _CustomerListSection(),
    );
  }
}



class _CustomerListSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<CustomerProvider>(context);
    if (prov.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.error != null) {
      return Center(child: Text(prov.error!, style: TextStyle(color: Colors.red)));
    }
    if (prov.customers.isEmpty) {
      return Center(child: Text("Tidak ada pelanggan ditemukan"));
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
        itemCount: prov.customers.length + (prov.hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == prov.customers.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final c = prov.customers[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => CustomerDetailSheet(customer: c),
              ),
              child: GlassmorphCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: c.status == "Aktif" ? Colors.green : Colors.red,
                    child: Text(c.name[0], style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${c.email}\n${c.address}"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(status: c.status),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => CustomerFormDialog(editCustomer: c),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => DeleteConfirmDialog(customer: c),
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

// ==== CUSTOMER BADGE ====
class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status == "Aktif" ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: status == "Aktif" ? Colors.green[800] : Colors.red[800],
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ==== CUSTOMER DETAIL SHEET ====
class CustomerDetailSheet extends StatelessWidget {
  final Customer customer;
  const CustomerDetailSheet({super.key, required this.customer});
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
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: customer.status == "Aktif" ? Colors.green : Colors.red,
                    child: Text(customer.name[0], style: const TextStyle(fontSize: 36, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
                _detailRow(Icons.person, "Nama", customer.name),
                _detailRow(Icons.email, "Email", customer.email),
                _detailRow(Icons.phone, "Telepon", customer.phone),
                _detailRow(Icons.home, "Alamat", customer.address),
                _detailRow(Icons.verified_user, "Status", customer.status),
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

// ==== CUSTOMER FORM DIALOG ====
class CustomerFormDialog extends StatefulWidget {
  final Customer? editCustomer;
  CustomerFormDialog({super.key, this.editCustomer});

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _email, _address, _phone;
  String _status = "Aktif";
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.editCustomer?.name ?? "");
    _email = TextEditingController(text: widget.editCustomer?.email ?? "");
    _address = TextEditingController(text: widget.editCustomer?.address ?? "");
    _phone = TextEditingController(text: widget.editCustomer?.phone ?? "");
    _status = widget.editCustomer?.status ?? "Aktif";
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      final prov = Provider.of<CustomerProvider>(context, listen: false);
      if (widget.editCustomer == null) {
        prov.addCustomer(
          Customer(
            id: "C${DateTime.now().millisecondsSinceEpoch % 100000}",
            name: _name.text,
            email: _email.text,
            phone: _phone.text,
            address: _address.text,
            status: _status,
          ),
        );
      } else {
        prov.editCustomer(
          Customer(
            id: widget.editCustomer!.id,
            name: _name.text,
            email: _email.text,
            phone: _phone.text,
            address: _address.text,
            status: _status,
          ),
        );
      }
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editCustomer == null ? "Tambah Pelanggan" : "Edit Pelanggan"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 350,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: "Nama"),
                  validator: (v) => v == null || v.isEmpty ? "Nama wajib diisi" : null,
                ),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Email wajib diisi" : (!v.contains("@") ? "Format email salah" : null),
                ),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: "No. Telepon"),
                  validator: (v) => v == null || v.length < 8 ? "No. telepon tidak valid" : null,
                ),
                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(labelText: "Alamat"),
                  validator: (v) => v == null || v.isEmpty ? "Alamat wajib diisi" : null,
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: ["Aktif", "Nonaktif"]
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

// ==== HAPUS CUSTOMER DIALOG ====
class DeleteConfirmDialog extends StatelessWidget {
  final Customer customer;
  const DeleteConfirmDialog({super.key, required this.customer});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Konfirmasi Hapus"),
      content: Text("Yakin ingin menghapus pelanggan '${customer.name}'?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            Provider.of<CustomerProvider>(context, listen: false).deleteCustomer(customer.id);
            Navigator.pop(context);
          },
          child: const Text("Hapus"),
        ),
      ],
    );
  }
}