import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/wikarta_appbar.dart';
import '../widgets/wikarta_navbar.dart';
import '../widgets/glassmorph_card.dart';
import '../widgets/cloud_background.dart';
import '../theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WikartaAppBar(title: "Dashboard"),
      body: CloudBackground(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 700),
              child: Text(
                "Selamat Datang di Wikarta App!",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            const SizedBox(height: 26),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statCard("Pelanggan", 123, Icons.people, AppColors.deepBlue, 0),
                _statCard("Paket", 4, Icons.wifi, AppColors.accent, 1),
                _statCard("Invoice", 27, Icons.receipt_long, Colors.amber[800]!, 2),
                _statCard("Tiket", 3, Icons.support_agent, AppColors.error, 3),
              ],
            ),
            const SizedBox(height: 36),
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: GlassmorphCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Grafik Omzet Bulanan", style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 170,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const months = ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(months[value.toInt() % 12], style: const TextStyle(fontSize: 11)),
                                  );
                                },
                              )),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: AppColors.skyBlue.withOpacity(0.17)),
                          ),
                          minX: 0,
                          maxX: 11,
                          minY: 0,
                          maxY: 15,
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                FlSpot(0, 7),
                                FlSpot(1, 8),
                                FlSpot(2, 6),
                                FlSpot(3, 7.5),
                                FlSpot(4, 10),
                                FlSpot(5, 12),
                                FlSpot(6, 11),
                                FlSpot(7, 13),
                                FlSpot(8, 12),
                                FlSpot(9, 14),
                                FlSpot(10, 13),
                                FlSpot(11, 15),
                              ],
                              isCurved: true,
                              color: AppColors.deepBlue,
                              barWidth: 3,
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.skyBlue.withOpacity(0.18),
                              ),
                              dotData: FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: GlassmorphCard(
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.person_add_alt_1,
                        label: "Tambah\nPelanggan",
                        onTap: () => Navigator.of(context).pushNamed('/customers'),
                      ),
                    ),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.add_box_rounded,
                        label: "Tambah\nPaket",
                        onTap: () => Navigator.of(context).pushNamed('/packages'),
                      ),
                    ),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.post_add_rounded,
                        label: "Tambah\nInvoice",
                        onTap: () => Navigator.of(context).pushNamed('/invoices'),
                      ),
                    ),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.support_agent,
                        label: "Tiket\nBaru",
                        onTap: () => Navigator.of(context).pushNamed('/tickets'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: WikartaNavbar(selectedIndex: 0, onTap: (i) {
        final routes = ['/dashboard', '/customers', '/packages', '/invoices', '/tickets', '/profile'];
        Navigator.of(context).pushReplacementNamed(routes[i]);
      }),
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color, int delay) {
    return BounceInUp(
      delay: Duration(milliseconds: 160 * delay),
      child: GlassmorphCard(
        width: 92, height: 110,
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 31),
            const SizedBox(height: 8),
            Text('$value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23)),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ElasticIn(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.skyBlue.withOpacity(0.17),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: AppColors.deepBlue),
            ),
          ),
          const SizedBox(height: 5),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))
        ],
      ),
    );
  }
}