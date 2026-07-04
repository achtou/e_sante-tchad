import 'package:flutter/material.dart';
import '../../models/medicament_module/medicament_module.dart';
import '../../utils/colors.dart';

class MedDetailPage extends StatefulWidget {
  final MedicamentModule medicament;
  final ProfilFamille? profil;
  const MedDetailPage({super.key, required this.medicament, this.profil});

  @override
  State<MedDetailPage> createState() => _MedDetailPageState();
}

class _MedDetailPageState extends State<MedDetailPage> {
  @override
  Widget build(BuildContext context) {
    final medicament = widget.medicament;
    final profil = widget.profil;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        title: Text(medicament.nom),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _partagerMedecin(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo de la boîte
            if (medicament.photoBoite != null)
              Card(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    medicament.photoBoite!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Informations de base
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medication, color: Color(0xFF00A86B)),
                        const SizedBox(width: 8),
                        Text(
                          medicament.forme.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00A86B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      medicament.dosage,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (profil != null)
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 4),
                          Text('Pour: ${profil.nom} (${profil.relation})'),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Posologie
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Posologie',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text('${medicament.frequenceParJour} fois par jour'),
                    const SizedBox(height: 8),
                    Text('Durée: ${medicament.dureeJours} jours'),
                    const SizedBox(height: 12),
                    const Text('Heures de prise:'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: medicament.horairesPrise.map((horaire) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A86B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF00A86B)),
                          ),
                          child: Text(horaire.heure),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Stock
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Stock',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        if (medicament.estStockBas)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Stock bas !',
                              style: TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${medicament.stock.stockActuel}/${medicament.stock.stockInitial}'),
                        Text('${medicament.stock.pourcentageRestant.toInt()}%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: medicament.stock.pourcentageRestant / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          medicament.estStockBas ? Colors.red : const Color(0xFF00A86B),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    if (medicament.estStockBas) ...[
                      const SizedBox(height: 8),
                      const Text(
                        '⚠️ Allez à la pharmacie !',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Observance
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Observance',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${medicament.prisesRealisees}/${medicament.totalPrisesPrevues} prises'),
                        Text('${medicament.tauxObservance.toInt()}%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: medicament.tauxObservance / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          medicament.tauxObservance >= 70 ? const Color(0xFF00A86B) : Colors.orange,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getMessageObservance(medicament.tauxObservance),
                      style: TextStyle(
                        fontSize: 12,
                        color: medicament.tauxObservance >= 70 ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Notes médecin
            if (medicament.notesMedecin.isNotEmpty || medicament.prescritPar != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations médicales',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      if (medicament.prescritPar != null) ...[
                        Text('Prescrit par: ${medicament.prescritPar}'),
                        const SizedBox(height: 8),
                      ],
                      if (medicament.notesMedecin.isNotEmpty)
                        Text(medicament.notesMedecin),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Période
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Période de traitement',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text('Du: ${_formatDate(medicament.dateDebut)}'),
                    const SizedBox(height: 4),
                    Text('Au: ${_formatDate(medicament.dateFin)}'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getMessageObservance(double taux) {
    if (taux >= 90) return '🌟 Excellent ! Continuez comme ça !';
    if (taux >= 70) return '👍 Bien ! Vous pouvez faire mieux.';
    if (taux >= 50) return '⚠️ Attention, essayez d\'être plus régulier.';
    return '❌ Critique ! Consultez votre médecin.';
  }

  void _partagerMedecin(BuildContext context) {
    // TODO: Générer PDF et partager via WhatsApp
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Génération du PDF en cours...')),
    );
  }
}
