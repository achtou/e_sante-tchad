/// Service de gestion des notifications pour les rappels de médicaments
/// 
/// NOTE: Ce service nécessite les packages suivants à ajouter dans pubspec.yaml:
/// - flutter_local_notifications: ^16.3.0
/// - timezone: ^0.9.2
/// 
/// Après installation, décommentez les imports et le code ci-dessous.

/*
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/medicament_module/medicament_module.dart';
*/

class MedicamentNotificationService {
  static final MedicamentNotificationService _instance = MedicamentNotificationService._internal();
  factory MedicamentNotificationService() => _instance;
  MedicamentNotificationService._internal();

  /*
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// Initialiser le service de notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Planifier les notifications pour un médicament
  Future<void> planifierNotifications(MedicamentModule medicament, ProfilFamille profil) async {
    if (!_isInitialized) await initialize();

    // Annuler les notifications existantes pour ce médicament
    await annulerNotificationsMedicament(medicament.id);

    // Planifier une notification pour chaque horaire
    for (final horaire in medicament.horairesPrise) {
      await _planifierNotificationQuotidienne(
        medicament: medicament,
        profil: profil,
        horaire: horaire,
      );
    }
  }

  /// Planifier une notification quotidienne
  Future<void> _planifierNotificationQuotidienne({
    required MedicamentModule medicament,
    required ProfilFamille profil,
    required HorairePrise horaire,
  }) async {
    final heureParts = horaire.heure.split(':');
    final heure = int.parse(heureParts[0]);
    final minute = int.parse(heureParts[1]);

    // Notification principale
    await _notificationsPlugin.zonedSchedule(
      '${medicament.id}_${horaire.id}_principal',
      '💊 ${medicament.nom} - ${profil.nom}',
      '⏰ ${medicament.dosage} à ${horaire.heure} pour ${profil.relation}',
      _nextOccurrence(heure, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicaments_channel',
          'Rappels médicaments',
          channelDescription: 'Notifications pour les rappels de prise de médicaments',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: '${medicament.id}|${horaire.id}|principal',
    );

    // Notification de relance (30 min après)
    await _notificationsPlugin.zonedSchedule(
      '${medicament.id}_${horaire.id}_relance',
      '⏰ RAPPEL: ${medicament.nom} - ${profil.nom}',
      '⏰ ${medicament.dosage} à ${horaire.heure} pour ${profil.relation} (Relance)',
      _nextOccurrence(heure, minute + 30),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicaments_channel',
          'Rappels médicaments',
          channelDescription: 'Notifications pour les rappels de prise de médicaments',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: '${medicament.id}|${horaire.id}|relance',
    );
  }

  /// Annuler toutes les notifications pour un médicament
  Future<void> annulerNotificationsMedicament(String medicamentId) async {
    await _notificationsPlugin.cancel(medicamentId.hashCode);
  }

  /// Enregistrer une action utilisateur sur une notification
  Future<void> enregistrerAction({
    required String medicamentId,
    required String horaireId,
    required String action, // 'j_ai_pris', '+30min', 'ignore'
  }) async {
    // TODO: Sauvegarder dans la base de données
    // Mettre à jour le statut de la prise dans PriseStatut
    print('Action enregistrée: $action pour médicament $medicamentId, horaire $horaireId');
  }

  /// Calculer la prochaine occurrence à une heure donnée
  tz.TZDateTime _nextOccurrence(int heure, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, heure, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// Gérer le tap sur une notification
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final parts = payload.split('|');
      final medicamentId = parts[0];
      final horaireId = parts[1];
      final type = parts[2]; // 'principal' ou 'relance'

      print('Notification tapée: médicament=$medicamentId, horaire=$horaireId, type=$type');

      // TODO: Naviguer vers l'écran de réponse à la notification
      // Afficher les boutons d'action: [J'ai pris] [+30min] [❌]
    }
  }

  /// Obtenir les notifications programmées
  Future<List<PendingNotificationRequest>> getNotificationsProgrammees() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
  */

  /// Version simplifiée sans dépendances (pour démonstration)
  void planifierNotificationsDemo(String medicamentId, String nomMedicament) {
    print('🔔 Notification planifiée pour: $nomMedicament');
    print('   - Notification principale à chaque horaire configuré');
    print('   - Relance automatique après 30 min si non répondu');
    print('   - Boutons d\'action: [J\'ai pris] [+30min] [❌]');
  }
}
