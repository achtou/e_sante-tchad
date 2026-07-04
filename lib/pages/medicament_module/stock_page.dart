import 'package:flutter/material.dart';
import '../../models/medicament_module/medicament_module.dart';
import '../../utils/colors.dart';

class StockPage extends StatelessWidget {
  final MedicamentModule medicament;
  const StockPage({super.key, required this.medicament});

  @override
  Widget build(BuildContext context) {
    final stock = medicament.stock;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        title: Text('Stock - ${medicament.nom}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progression du stock
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progression du stock',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: stock.pourcentageRestant / 100,
                              strokeWidth: 15,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                stock.estStockBas ? Colors.red : const Color(0xFF00A86B),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${stock.pourcentageRestant.toInt()}%',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${stock.stockActuel}/${stock.stockInitial}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informations détaillées
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Stock initial', '${stock.stockInitial} unités'),
                    _buildInfoRow('Stock actuel', '${stock.stockActuel} unités'),
                    _buildInfoRow('Restant', '${stock.stockInitial - stock.stockActuel} utilisés'),
                    _buildInfoRow('Seuil d\'alerte', '${stock.seuilAlerte} unités'),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Dernière mise à jour',
                      '${stock.dateDernierMaj.day}/${stock.dateDernierMaj.month}/${stock.dateDernierMaj.year}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Actions rapides
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Actions rapides',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Décrémenter le stock
                            },
                            icon: const Icon(Icons.remove),
                            label: const Text('-1'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Incrémenter le stock
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('+1'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A86B),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Alerte stock bas
            if (stock.estStockBas)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Stock bas !',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Il ne reste que ${stock.stockActuel} unités. Allez à la pharmacie !',
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Estimation de fin
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimation',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Prises par jour',
                      '${medicament.frequenceParJour}',
                    ),
                    _buildInfoRow(
                      'Jours restants',
                      '${(stock.stockActuel / medicament.frequenceParJour).toInt()}',
                    ),
                    _buildInfoRow(
                      'Date de fin estimée',
                      _formatDate(DateTime.now().add(Duration(days: (stock.stockActuel / medicament.frequenceParJour).toInt()))),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
