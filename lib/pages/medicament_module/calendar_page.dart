import 'package:flutter/material.dart';
import '../../models/medicament_module/medicament_module.dart';
import '../../utils/colors.dart';

class CalendarPage extends StatefulWidget {
  final MedicamentModule medicament;
  const CalendarPage({super.key, required this.medicament});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _moisCourant = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final medicament = widget.medicament;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        title: Text('Calendrier - ${medicament.nom}'),
      ),
      body: Column(
        children: [
          // Sélecteur de mois
          _buildMonthSelector(),

          // Calendrier
          Expanded(
            child: _buildCalendar(medicament),
          ),

          // Taux d'observance
          _buildObservanceCard(medicament),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _moisCourant = DateTime(_moisCourant.year, _moisCourant.month - 1);
              });
            },
          ),
          Text(
            '${_getMoisNom(_moisCourant.month)} ${_moisCourant.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _moisCourant = DateTime(_moisCourant.year, _moisCourant.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(MedicamentModule medicament) {
    final premierJourDuMois = DateTime(_moisCourant.year, _moisCourant.month, 1);
    final dernierJourDuMois = DateTime(_moisCourant.year, _moisCourant.month + 1, 0);
    final nombreJours = dernierJourDuMois.day;
    final premierJourSemaine = premierJourDuMois.weekday;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: premierJourSemaine + nombreJours,
      itemBuilder: (context, index) {
        if (index < premierJourSemaine) {
          return const SizedBox.shrink();
        }

        final jour = index - premierJourSemaine + 1;
        final date = DateTime(_moisCourant.year, _moisCourant.month, jour);
        final statut = _getStatutJour(medicament, date);

        return Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _getCouleurStatut(statut),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Center(
            child: Text(
              '$jour',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: statut == 'futur' ? Colors.grey[600] : Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildObservanceCard(MedicamentModule medicament) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Taux d\'observance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${medicament.tauxObservance.toInt()}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A86B),
                ),
              ),
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
              fontSize: 14,
              color: medicament.tauxObservance >= 70 ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatutJour(MedicamentModule medicament, DateTime date) {
    if (date.isAfter(DateTime.now())) return 'futur';
    if (date.isAtSameMomentAs(DateTime.now())) return 'aujourd\'hui';

    // Vérifier si toutes les prises du jour ont été effectuées
    final prisesDuJour = medicament.historiquePrises.where((p) =>
      p.datePrevue.year == date.year &&
      p.datePrevue.month == date.month &&
      p.datePrevue.day == date.day
    ).toList();

    if (prisesDuJour.isEmpty) return 'manque';
    if (prisesDuJour.every((p) => p.statut == 'pris')) return 'pris';
    return 'partiel';
  }

  Color _getCouleurStatut(String statut) {
    switch (statut) {
      case 'pris':
        return const Color(0xFF00A86B);
      case 'manque':
        return Colors.red;
      case 'partiel':
        return Colors.orange;
      case 'futur':
        return Colors.grey[200]!;
      default:
        return Colors.grey[200]!;
    }
  }

  String _getMoisNom(int mois) {
    const moisNoms = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return moisNoms[mois - 1];
  }

  String _getMessageObservance(double taux) {
    if (taux >= 90) return '🌟 Excellent ! Continuez comme ça !';
    if (taux >= 70) return '👍 Bien ! Vous pouvez faire mieux.';
    if (taux >= 50) return '⚠️ Attention, essayez d\'être plus régulier.';
    return '❌ Critique ! Consultez votre médecin.';
  }
}
