import 'package:flutter/material.dart';
import '../../models/medicament_module/medicament_module.dart';

/// Contenu de notification pour les rappels de médicaments
class ReminderNotificationContent {
  static Map<String, dynamic> buildNotificationPayload(MedicamentModule medicament, ProfilFamille profil, HorairePrise horaire) {
    return {
      'medicamentId': medicament.id,
      'medicamentNom': medicament.nom,
      'medicamentDosage': medicament.dosage,
      'medicamentPhoto': medicament.photoBoite,
      'profilNom': profil.nom,
      'profilRelation': profil.relation,
      'horaire': horaire.heure,
      'timestamp': DateTime.now().toIso8601String(),
      'action': 'prise', // 'prise' ou 'relance'
    };
  }

  static String buildNotificationTitle(MedicamentModule medicament, ProfilFamille profil) {
    return '💊 ${medicament.nom} - ${profil.nom}';
  }

  static String buildNotificationBody(MedicamentModule medicament, ProfilFamille profil, HorairePrise horaire, bool isRelance) {
    if (isRelance) {
      return '⏰ Rappel: ${medicament.dosage} à ${horaire.heure} pour ${profil.relation}';
    }
    return '⏰ ${medicament.dosage} à ${horaire.heure} pour ${profil.relation}';
  }

  /// Widget pour afficher le contenu de notification dans l'app
  static Widget buildNotificationCard({
    required MedicamentModule medicament,
    required ProfilFamille profil,
    required HorairePrise horaire,
    required bool isRelance,
    required Function(String action) onAction,
  }) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo du médicament (pour les analphabètes)
            if (medicament.photoBoite != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  medicament.photoBoite!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 12),

            // Informations
            Row(
              children: [
                if (medicament.photoBoite == null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A86B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.medication, color: Color(0xFF00A86B)),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicament.nom,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text('${medicament.dosage} à ${horaire.heure}'),
                      Text('Pour: ${profil.nom} (${profil.relation})'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Badge de relance
            if (isRelance)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '⏰ Rappel (30 min)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),

            const SizedBox(height: 16),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onAction('j_ai_pris'),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('J\'ai pris'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A86B),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onAction('+30min'),
                    icon: const Icon(Icons.schedule),
                    label: const Text('+30 min'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onAction('ignore'),
                    icon: const Icon(Icons.close),
                    label: const Text('❌'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
