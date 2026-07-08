import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicament_model.dart';
import '../models/medicament_module/medicament_module.dart';

class MedicamentNotificationService {
  static final MedicamentNotificationService _instance = MedicamentNotificationService._internal();
  factory MedicamentNotificationService() => _instance;
  MedicamentNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'medicaments_channel',
    'Rappels médicaments',
    channelDescription: 'Notifications pour les rappels de prise de médicaments',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _isInitialized = true;
  }

  Future<void> planifierNotificationsMedicament(Medicament medicament) async {
    if (!_isInitialized) await initialize();
    await annulerNotificationsMedicament(medicament.id);
    for (int i = 0; i < medicament.heuresPrise.length; i++) {
      final heureString = medicament.heuresPrise[i];
      await _planifierNotificationQuotidienne(
        medicamentId: medicament.id,
        nomMedicament: medicament.nom,
        dosage: medicament.dosage,
        heureString: heureString,
        index: i,
        dateFin: medicament.dateFin,
      );
    }
  }

  Future<void> planifierNotificationsMedicamentModule(MedicamentModule medicament) async {
    if (!_isInitialized) await initialize();
    await annulerNotificationsMedicament(medicament.id);
    for (int i = 0; i < medicament.horairesPrise.length; i++) {
      final horaire = medicament.horairesPrise[i];
      await _planifierNotificationQuotidienne(
        medicamentId: medicament.id,
        nomMedicament: medicament.nom,
        dosage: medicament.dosage,
        heureString: horaire.heure,
        index: i,
        dateFin: medicament.dateFin,
      );
    }
  }

  Future<void> _planifierNotificationQuotidienne({
    required String medicamentId,
    required String nomMedicament,
    required String dosage,
    required String heureString,
    required int index,
    required DateTime dateFin,
  }) async {
    final heureParts = heureString.split(':');
    final heure = int.parse(heureParts[0]);
    final minute = int.parse(heureParts[1]);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, heure, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final lastScheduledDate = scheduledDate;

    if (lastScheduledDate.isAfter(dateFin)) {
      return;
    }

    final notificationId = _generateNotificationId(medicamentId, index);

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      '💊 Rappel médicament',
      '⏰ Prendre $dosage de $nomMedicament à $heureString',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicaments_channel',
          'Rappels médicaments',
          channelDescription: 'Notifications pour les rappels de prise de médicaments',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'medicament|$medicamentId|$index',
    );
  }

  Future<void> annulerNotificationsMedicament(String medicamentId) async {
    await _notificationsPlugin.cancel(medicamentId.hashCode);
    for (int i = 0; i < 10; i++) {
      final notificationId = _generateNotificationId(medicamentId, i);
      await _notificationsPlugin.cancel(notificationId);
    }
  }

  int _generateNotificationId(String medicamentId, int index) {
    return (medicamentId.hashCode + index).abs() % 0x7FFFFFFF;
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final parts = payload.split('|');
      if (parts[0] == 'medicament') {
        final medicamentId = parts[1];
        print('Notification tapée pour médicament: $medicamentId');
      }
    }
  }

  Future<void> requestNotificationPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }
}
