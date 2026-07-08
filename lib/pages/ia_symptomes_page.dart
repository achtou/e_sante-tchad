import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../services/language_service.dart';

class IaSymptomesPage extends StatefulWidget {
  const IaSymptomesPage({super.key});

  @override
  State<IaSymptomesPage> createState() => _IaSymptomesPageState();
}

class _IaSymptomesPageState extends State<IaSymptomesPage> with TickerProviderStateMixin {
  final _symptomeController = TextEditingController();
  final List<String> _symptomes = [];
  Map<String, dynamic> _diagnostic = {};
  bool _isAnalyzing = false;
  String _profilSelectionne = 'adulte'; // 'bebe' | 'enfant' | 'enceinte' | 'adulte'
  final ScrollController _scrollController = ScrollController();
  late AnimationController _pulseController;

  // Symptômes groupés par catégorie
  final Map<String, List<String>> _symptomesParCategorie = {
    '🌡️ Température': ['Fièvre', 'Frissons', 'Sueurs nocturnes'],
    '🤢 Digestif': ['Nausées', 'Vomissements', 'Diarrhée', 'Douleurs abdominales', 'Perte d\'appétit'],
    '🤕 Douleurs': ['Maux de tête', 'Douleurs articulaires', 'Douleurs thoraciques', 'Douleurs musculaires'],
    '😮‍💨 Respiratoire': ['Toux', 'Essoufflement', 'Gorge irritée', 'Congestion nasale'],
    '😴 Général': ['Fatigue', 'Vertiges', 'Insomnie', 'Anxiété'],
    '🩺 Visible': ['Éruption cutanée', 'Yeux jaunes', 'Gonflement', 'Saignement'],
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _symptomeController.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _ajouterSymptome(String symptome) {
    if (symptome.isNotEmpty && !_symptomes.contains(symptome)) {
      setState(() => _symptomes.add(symptome));
      _symptomeController.clear();
    }
  }

  void _supprimerSymptome(String symptome) {
    setState(() => _symptomes.remove(symptome));
  }

  void _demarrerAnalyse() {
    if (_symptomes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LanguageService.isArabic ? 'أضف على الأقل عرضاً واحداً' : 'Veuillez ajouter au moins un symptôme'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _diagnostic = {};
    });

    // Simulation d'analyse IA
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isAnalyzing = false;
        _diagnostic = _analyserSymptomes(_symptomes, _profilSelectionne);
      });
      // Scroll vers le résultat
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  Map<String, dynamic> _analyserSymptomes(List<String> symptomes, String profil) {
    
    // ═══════════════════════════════════════════════════════════════
    // CAS BÉBÉ (0-2 ans)
    // ═══════════════════════════════════════════════════════════════
    if (profil == 'bebe') {
      
      // Fièvre chez bébé = TOUJOURS URGENT
      if (symptomes.contains('Fièvre')) {
        return {
          'fr': {
            'maladie': 'Fièvre du nourrisson',
            'description': 'Toute fièvre chez un bébé de moins de 2 ans est une URGENCE médicale. Risque de convulsions fébriles.',
            'urgence': 'CRITIQUE',
            'probabilite': 95,
            'alertes_speciales': [
              '⚠️ Bébé de moins de 3 mois + fièvre = SAMU 1313 immédiatement',
              '⚠️ Ne jamais donner aspirine à un bébé',
              '⚠️ Déshabiller le bébé pour faire baisser la fièvre',
            ],
            'premiers_secours': [
              'Déshabiller le bébé',
              'Lingette fraîche sur le front',
              'Paracétamol sirop selon poids',
              'Allaiter souvent pour hydrater',
              'CONSULTER IMMÉDIATEMENT',
            ],
            'action': 'URGENCE - Allez à la maternité ou hôpital maintenant',
            'centre': 'Pédiatrie ou urgences',
            'eviter': 'Aspirine - mortelle pour les bébés',
            'dose_medicament': 'Paracétamol : 15mg par kg toutes les 6 heures',
          },
          'ar': {
            'maladie': 'حمى الرضيع',
            'description': 'أي حمى عند رضيع أقل من سنتين هي حالة طوارئ طبية. خطر التشنجات الحمّوية.',
            'urgence': 'حرج جداً',
            'alertes_speciales': [
              '⚠️ رضيع أقل من 3 أشهر + حمى = اتصل بـ 1313 فوراً',
              '⚠️ لا تعطِ الأسبرين للرضيع أبداً',
              '⚠️ خلّع ملابس الرضيع لتخفيض الحرارة',
            ],
            'premiers_secours': [
              'خلّع ملابس الرضيع',
              'منشفة باردة على الجبهة',
              'باراسيتامول شراب حسب الوزن',
              'أرضع كثيراً للترطيب',
              'راجع الطبيب فوراً',
            ],
            'action': 'طوارئ - اذهب للمستشفى الآن',
            'centre': 'قسم الأطفال أو الطوارئ',
            'eviter': 'الأسبرين - قاتل للرضع',
          }
        };
      }

      // Diarrhée bébé = DÉSHYDRATATION RAPIDE
      if (symptomes.contains('Diarrhée') || symptomes.contains('Vomissements')) {
        return {
          'fr': {
            'maladie': 'Gastro-entérite du nourrisson',
            'description': 'Très dangereuse chez le bébé. Déshydratation en quelques heures.',
            'urgence': 'CRITIQUE',
            'probabilite': 88,
            'alertes_speciales': [
              '⚠️ Fontanelle enfoncée = urgence',
              '⚠️ Pas de larmes quand pleure = danger',
              '⚠️ Yeux enfoncés = déshydratation grave',
              '⚠️ Couche sèche depuis 6h = danger',
            ],
            'premiers_secours': [
              'SRO en petites quantités souvent',
              '1 cuillère SRO toutes les 2 minutes',
              'Continuer allaitement maternel',
              'NE PAS donner eau pure seule',
              'Peser le bébé si possible',
            ],
            'action': 'Urgences pédiatriques maintenant',
            'centre': 'CRENI ou pédiatrie',
            'eviter': 'Eau seule sans SRO',
          },
          'ar': {
            'maladie': 'التهاب معوي عند الرضيع',
            'description': 'خطير جداً عند الرضيع. جفاف في ساعات قليلة.',
            'urgence': 'حرج جداً',
            'alertes_speciales': [
              '⚠️ اليافوخ غائر = طوارئ',
              '⚠️ لا دموع عند البكاء = خطر',
              '⚠️ عيون غائرة = جفاف شديد',
              '⚠️ حفاضة جافة 6 ساعات = خطر',
            ],
            'premiers_secours': [
              'ORS بكميات صغيرة متكررة',
              'ملعقة ORS كل دقيقتين',
              'استمر في الرضاعة الطبيعية',
              'لا تعطِ ماءً صافياً وحده',
            ],
            'action': 'طوارئ الأطفال الآن',
            'centre': 'CRENI أو قسم الأطفال',
            'eviter': 'الماء وحده بدون ORS',
          }
        };
      }
    }

    // ═══════════════════════════════════════════════════════════════
    // CAS ENFANT (2-12 ans)
    // ═══════════════════════════════════════════════════════════════
    if (profil == 'enfant') {
      
      if (symptomes.contains('Fièvre') &&
         (symptomes.contains('Maux de tête') || symptomes.contains('Frissons'))) {
        return {
          'fr': {
            'maladie': 'Paludisme de l\'enfant',
            'description': 'Première cause de mortalité infantile au Tchad. Test TDR obligatoire et urgent.',
            'urgence': 'ÉLEVÉ',
            'probabilite': 85,
            'alertes_speciales': [
              '⚠️ Enfant qui convulse = 1313 urgent',
              '⚠️ Enfant inconscient = 1313 urgent',
              '⚠️ Respiration rapide = danger',
              '⚠️ Refus de boire = danger',
            ],
            'premiers_secours': [
              'Paracétamol selon l\'âge et poids',
              'Faire un test TDR paludisme',
              'Donner à boire souvent',
              'Enlever vêtements épais',
              'Si convulsion : position latérale',
            ],
            'dose_medicament': '6-10 ans : Paracétamol 250mg\n2-5 ans : Paracétamol 125mg\nToutes les 6 heures si fièvre',
            'action': 'Centre de santé aujourd\'hui',
            'centre': 'Pédiatrie ou centre santé',
            'eviter': 'Couvertures épaisses sur enfant fiévreux',
          },
          'ar': {
            'maladie': 'ملاريا الطفل',
            'description': 'السبب الأول لوفيات الأطفال في تشاد. اختبار TDR ضروري وعاجل.',
            'urgence': 'مرتفع',
            'alertes_speciales': [
              '⚠️ طفل يتشنج = 1313 فوراً',
              '⚠️ طفل فاقد الوعي = 1313 فوراً',
              '⚠️ تنفس سريع = خطر',
              '⚠️ رفض الشرب = خطر',
            ],
            'premiers_secours': [
              'باراسيتامول حسب العمر والوزن',
              'اختبار TDR للملاريا',
              'اسقِه الماء كثيراً',
              'انزع الملابس الثقيلة',
              'إذا تشنّج: وضعية جانبية',
            ],
            'action': 'مركز الصحة اليوم',
            'centre': 'قسم الأطفال أو مركز الصحة',
            'eviter': 'الأغطية الثقيلة على طفل محموم',
          }
        };
      }

      // Malnutrition enfant
      if (symptomes.contains('Perte d\'appétit') &&
          symptomes.contains('Fatigue') &&
          symptomes.contains('Gonflement')) {
        return {
          'fr': {
            'maladie': 'Malnutrition sévère',
            'description': 'Urgence nutritionnelle. Le CRENI/CRENAS prend en charge gratuitement au Tchad.',
            'urgence': 'CRITIQUE',
            'probabilite': 80,
            'alertes_speciales': [
              '⚠️ Cheveux roux/cassants = danger',
              '⚠️ Peau qui se décolle = danger',
              '⚠️ Regard absent = danger',
              '⚠️ Périmètre brachial < 11cm = urgence',
            ],
            'premiers_secours': [
              'Allaitement maternel intensif',
              'Aliments riches : œufs, lait, viande',
              'Aller au CRENI ou CRENAS',
              'Prise en charge GRATUITE',
            ],
            'action': 'CRENI ou CRENAS maintenant',
            'centre': 'Centre de récupération nutritionnelle (CRENI/CRENAS)',
            'eviter': 'Attendre - urgence nutritionnelle',
          },
          'ar': {
            'maladie': 'سوء التغذية الحاد',
            'description': 'طوارئ غذائية. CRENI/CRENAS يعالج مجاناً في تشاد.',
            'urgence': 'حرج جداً',
            'premiers_secours': [
              'رضاعة طبيعية مكثفة',
              'أطعمة غنية: بيض، حليب، لحم',
              'اذهب لـ CRENI أو CRENAS',
              'العلاج مجاني',
            ],
            'action': 'CRENI أو CRENAS الآن',
            'centre': 'مركز التعافي التغذوي',
            'eviter': 'الانتظار - طوارئ غذائية',
          }
        };
      }
    }

    // ═══════════════════════════════════════════════════════════════
    // CAS FEMME ENCEINTE
    // ═══════════════════════════════════════════════════════════════
    if (profil == 'enceinte') {
      
      // Fièvre femme enceinte
      if (symptomes.contains('Fièvre')) {
        return {
          'fr': {
            'maladie': 'Fièvre pendant la grossesse',
            'description': 'DANGER pour la mère ET le bébé. Risque accouchement prématuré et paludisme grave.',
            'urgence': 'CRITIQUE',
            'probabilite': 90,
            'alertes_speciales': [
              '⚠️ Fièvre = risque paludisme grave',
              '⚠️ Paludisme enceinte = mort possible',
              '⚠️ Risque accouchement prématuré',
              '⚠️ NE PAS prendre certains médicaments',
            ],
            'medicaments_interdits': [
              '❌ Aspirine interdite',
              '❌ Ibuprofène interdit',
              '❌ Tétracyclines interdites',
              '❌ Artemether 1er trimestre : prudence',
            ],
            'premiers_secours': [
              '✅ Paracétamol autorisé pour fièvre',
              'Test TDR paludisme urgent',
              'Boire beaucoup d\'eau',
              'Consulter AUJOURD\'HUI',
              'Apporter carnet CPN',
            ],
            'action': 'Maternité ou urgences maintenant',
            'centre': 'Maternité ou hôpital',
            'eviter': 'Aspirine et ibuprofène strictement interdits',
          },
          'ar': {
            'maladie': 'حمى أثناء الحمل',
            'description': 'خطر على الأم والجنين. خطر الولادة المبكرة والملاريا الشديدة.',
            'urgence': 'حرج جداً',
            'alertes_speciales': [
              '⚠️ الحمى = خطر ملاريا شديدة',
              '⚠️ ملاريا الحامل = وفاة محتملة',
              '⚠️ خطر الولادة المبكرة',
              '⚠️ لا تأخذي بعض الأدوية',
            ],
            'medicaments_interdits': [
              '❌ الأسبرين ممنوع',
              '❌ الإيبوبروفين ممنوع',
              '❌ التتراسيكلين ممنوع',
            ],
            'premiers_secours': [
              '✅ الباراسيتامول مسموح للحمى',
              'اختبار TDR للملاريا عاجل',
              'اشربي الكثير من الماء',
              'راجعي الطبيب اليوم',
              'أحضري دفتر CPN',
            ],
            'action': 'مستشفى الولادة أو الطوارئ الآن',
            'centre': 'مستشفى الولادة',
            'eviter': 'الأسبرين والإيبوبروفين ممنوعان',
          }
        };
      }

      // Saignement enceinte
      if (symptomes.contains('Saignement')) {
        return {
          'fr': {
            'maladie': 'Urgence obstétricale',
            'description': 'Tout saignement pendant la grossesse est une URGENCE ABSOLUE.',
            'urgence': 'CRITIQUE',
            'probabilite': 95,
            'premiers_secours': [
              'APPELEZ 1313 IMMÉDIATEMENT',
              'Allongez-vous sur le côté gauche',
              'Ne bougez pas inutilement',
              'Emportez votre carnet CPN',
            ],
            'action': 'SAMU 1313 MAINTENANT',
            'centre': 'Maternité urgences',
            'eviter': 'Attendre - urgence vitale',
          },
          'ar': {
            'maladie': 'طوارئ التوليد',
            'description': 'أي نزيف أثناء الحمل هو طوارئ مطلقة.',
            'urgence': 'حرج جداً',
            'premiers_secours': [
              'اتصلي بـ 1313 فوراً',
              'استلقي على جانبك الأيسر',
              'لا تتحركي بلا داعٍ',
              'خذي معكِ دفتر CPN',
            ],
            'action': 'اتصلي بـ 1313 الآن',
            'centre': 'طوارئ مستشفى الولادة',
            'eviter': 'الانتظار - خطر على الحياة',
          }
        };
      }
    }

    // ═══════════════════════════════════════════════════════════════
    // CAS ADULTE (+12 ans) - Logique existante
    // ═══════════════════════════════════════════════════════════════
    
    // PALUDISME
    if (symptomes.contains('Fièvre') && 
       (symptomes.contains('Maux de tête') || symptomes.contains('Frissons')) &&
       (symptomes.contains('Fatigue') || symptomes.contains('Douleurs articulaires'))) {
      return {
        'fr': {
          'maladie': 'Paludisme (Malaria)',
          'description': 'Maladie parasitaire transmise par les moustiques, très fréquente au Tchad en saison des pluies.',
          'urgence': 'ÉLEVÉ',
          'probabilite': 82,
          'premiers_secours': [
            'Faites un test TDR immédiatement',
            'Prenez du paracétamol pour la fièvre',
            'Buvez beaucoup d\'eau',
            'Ne prenez PAS d\'antipaludéens sans test',
            'Consultez un centre de santé rapidement',
          ],
          'action': 'Consultez un médecin aujourd\'hui',
          'centre': 'Centre de santé ou hôpital',
          'eviter': 'Automédication sans diagnostic',
        },
        'ar': {
          'maladie': 'الملاريا (البُرداء)',
          'description': 'مرض طفيلي تنقله البعوض، شائع جداً في تشاد خلال موسم الأمطار. يُعرف محلياً بـ "حمى الجنوب".',
          'urgence': 'مرتفع',
          'probabilite': 82,
          'premiers_secours': [
            'أجرِ اختبار TDR فوراً',
            'خذ الباراسيتامول للحمى',
            'اشرب كثيراً من الماء',
            'لا تأخذ أدوية الملاريا بدون فحص',
            'راجع مركز الصحة بسرعة',
          ],
          'action': 'راجع الطبيب اليوم',
          'centre': 'مركز الصحة أو المستشفى',
          'eviter': 'العلاج الذاتي بدون تشخيص',
        }
      };
    }

    // MÉNINGITE - CRITIQUE
    if (symptomes.contains('Fièvre') && symptomes.contains('Maux de tête') &&
       (symptomes.contains('Vomissements') || symptomes.contains('Vertiges'))) {
      return {
        'fr': {
          'maladie': 'Méningite (suspicion)',
          'description': 'Infection grave des membranes du cerveau. Urgence absolue ! Fréquente au Tchad pendant l\'harmattan.',
          'urgence': 'CRITIQUE',
          'probabilite': 75,
          'premiers_secours': [
            'APPELEZ LE 1313 IMMÉDIATEMENT',
            'Allongez le malade dans le calme',
            'Évitez la lumière vive',
            'Ne donnez RIEN par la bouche',
            'Ne perdez pas une seconde !',
          ],
          'action': 'URGENCE - Appelez 1313 maintenant',
          'centre': 'Urgences Hôpital National',
          'eviter': 'Attendre - chaque minute compte',
        },
        'ar': {
          'maladie': 'التهاب السحايا (مشتبه به)',
          'description': 'عدوى خطيرة في أغشية الدماغ. طوارئ مطلقة! شائعة في تشاد خلال الهرمطان.',
          'urgence': 'حرج جداً',
          'probabilite': 75,
          'premiers_secours': [
            'اتصل بـ 1313 فوراً',
            'أضجع المريض في هدوء',
            'تجنب الضوء الساطع',
            'لا تعطِ شيئاً عن طريق الفم',
            'لا تضيع دقيقة واحدة!',
          ],
          'action': 'طوارئ - اتصل بـ 1313 الآن',
          'centre': 'طوارئ المستشفى الوطني',
          'eviter': 'الانتظار - كل دقيقة مهمة',
        }
      };
    }

    // TYPHOÏDE / DYSENTERIE
    if ((symptomes.contains('Vomissements') || symptomes.contains('Nausées')) && 
        symptomes.contains('Diarrhée') &&
       (symptomes.contains('Fatigue') || symptomes.contains('Douleurs abdominales'))) {
      return {
        'fr': {
          'maladie': 'Gastro-entérite / Typhoïde',
          'description': 'Infection digestive probablement liée à l\'eau ou aux aliments contaminés. Fréquente au Tchad.',
          'urgence': 'MODÉRÉ',
          'probabilite': 70,
          'premiers_secours': [
            'Préparez le SRO : 1L eau + 6 cuillères sucre + ½ sel',
            'Buvez le SRO toutes les 15 minutes',
            'Mangez du riz blanc et bananes',
            'Évitez les aliments gras et épicés',
            'Consultez si fièvre dépasse 38.5°C',
          ],
          'action': 'Consultez si pas d\'amélioration en 24h',
          'centre': 'Centre de santé ou pharmacie',
          'eviter': 'Eau non bouillie, aliments de rue',
        },
        'ar': {
          'maladie': 'التهاب معوي / حمى التيفوئيد',
          'description': 'عدوى هضمية مرتبطة بالمياه أو الأغذية الملوثة. شائعة في تشاد.',
          'urgence': 'متوسط',
          'probabilite': 70,
          'premiers_secours': [
            'حضّر محلول الإماهة ORS: 1 لتر ماء + 6 ملاعق سكر + ½ ملعقة ملح',
            'اشرب كل 15 دقيقة',
            'كُل الأرز الأبيض والموز',
            'تجنب الأطعمة الدهنية والحارة',
            'راجع الطبيب إذا تجاوزت الحمى 38.5',
          ],
          'action': 'راجع الطبيب إذا لم تتحسن خلال 24 ساعة',
          'centre': 'مركز الصحة أو الصيدلية',
          'eviter': 'الماء غير المغلي وطعام الشارع',
        }
      };
    }

    // CHOLÉRA
    if (symptomes.contains('Diarrhée') && symptomes.contains('Vomissements') &&
        symptomes.contains('Vertiges')) {
      return {
        'fr': {
          'maladie': 'Choléra (suspicion)',
          'description': 'Infection bactérienne grave causant une déshydratation rapide. Épidémies fréquentes au Tchad.',
          'urgence': 'CRITIQUE',
          'probabilite': 72,
          'premiers_secours': [
            'SRO EN URGENCE - boire sans arrêt',
            'Allez immédiatement au centre de santé',
            'Isolez le malade des autres',
            'Désinfectez tout ce qu\'il touche',
            'Appelez le 1313 si très grave',
          ],
          'action': 'URGENCE - Centre de santé maintenant',
          'centre': 'Hôpital de référence cholera',
          'eviter': 'Déshydratation - mortelle en heures',
        },
        'ar': {
          'maladie': 'الكوليرا (مشتبه به)',
          'description': 'عدوى بكتيرية خطيرة تسبب جفافاً سريعاً. أوبئة متكررة في تشاد.',
          'urgence': 'حرج جداً',
          'probabilite': 72,
          'premiers_secours': [
            'محلول ORS بشكل عاجل - اشرب باستمرار',
            'اذهب فوراً لمركز الصحة',
            'عزل المريض عن الآخرين',
            'عقّم كل ما يلمسه',
            'اتصل بـ 1313 إذا كان الوضع خطيراً',
          ],
          'action': 'طوارئ - مركز الصحة الآن',
          'centre': 'مستشفى مرجعي للكوليرا',
          'eviter': 'الجفاف - قاتل في ساعات',
        }
      };
    }

    // TUBERCULOSE
    if (symptomes.contains('Toux') && symptomes.contains('Fatigue') &&
       (symptomes.contains('Perte d\'appétit') || symptomes.contains('Sueurs nocturnes'))) {
      return {
        'fr': {
          'maladie': 'Tuberculose (suspicion)',
          'description': 'Infection bactérienne pulmonaire grave. Le traitement est GRATUIT au Tchad.',
          'urgence': 'ÉLEVÉ',
          'probabilite': 65,
          'premiers_secours': [
            'Couvrez votre bouche en toussant',
            'Portez un masque si possible',
            'Consultez RAPIDEMENT un médecin',
            'Le traitement est GRATUIT au Tchad',
            'Aérez bien votre logement',
          ],
          'action': 'Consultez un médecin cette semaine',
          'centre': 'Programme National Tuberculose',
          'eviter': 'Tousser sans se couvrir la bouche',
        },
        'ar': {
          'maladie': 'السل (مشتبه به)',
          'description': 'عدوى بكتيرية رئوية خطيرة. العلاج مجاني في تشاد.',
          'urgence': 'مرتفع',
          'probabilite': 65,
          'premiers_secours': [
            'غطِّ فمك عند السعال',
            'ارتدِ كمامة إن أمكن',
            'راجع الطبيب بسرعة',
            'العلاج مجاني في تشاد',
            'هوّد مسكنك جيداً',
          ],
          'action': 'راجع الطبيب هذا الأسبوع',
          'centre': 'البرنامج الوطني للسل',
          'eviter': 'السعال بدون تغطية الفم',
        }
      };
    }

    // DEFAULT
    return {
      'fr': {
        'maladie': 'Analyse insuffisante',
        'description': 'Ajoutez plus de symptômes pour un diagnostic plus précis.',
        'urgence': 'FAIBLE',
        'probabilite': 0,
        'premiers_secours': [
          'Reposez-vous bien',
          'Buvez beaucoup d\'eau',
          'Consultez si ça empire',
        ],
        'action': 'Ajoutez d\'autres symptômes',
        'centre': 'Médecin généraliste',
        'eviter': 'Automédication',
      },
      'ar': {
        'maladie': 'تحليل غير كافٍ',
        'description': 'أضف المزيد من الأعراض للحصول على تشخيص أدق.',
        'urgence': 'منخفض',
        'probabilite': 0,
        'premiers_secours': [
          'استرح جيداً',
          'اشرب الكثير من الماء',
          'راجع الطبيب إذا ساءت حالتك',
        ],
        'action': 'أضف أعراضاً أخرى',
        'centre': 'طبيب عام',
        'eviter': 'العلاج الذاتي',
      }
    };
  }

  Color _getCouleurUrgence(String urgence) {
    switch (urgence) {
      case 'FAIBLE':
      case 'منخفض':
        return Colors.green;
      case 'MODÉRÉ':
      case 'متوسط':
        return Colors.orange;
      case 'ÉLEVÉ':
      case 'مرتفع':
        return Colors.red[300]!;
      case 'CRITIQUE':
      case 'حرج جداً':
        return Colors.red[700]!;
      default:
        return Colors.green;
    }
  }

  String _getTexteUrgence(String urgence, bool isArabic) {
    if (isArabic) {
      switch (urgence) {
        case 'FAIBLE':
        case 'منخفض':
          return '✅ لا توجد طوارئ فورية';
        case 'MODÉRÉ':
        case 'متوسط':
          return '⚠️ راجع خلال 24-48 ساعة';
        case 'ÉLEVÉ':
        case 'مرتفع':
          return '🚨 راجع بسرعة';
        case 'CRITIQUE':
        case 'حرج جداً':
          return '🆘 طوارئ - اتصل بـ 1313 الآن';
        default:
          return '✅ لا توجد طوارئ فورية';
      }
    }
    switch (urgence) {
      case 'FAIBLE':
        return '✅ Pas d\'urgence immédiate';
      case 'MODÉRÉ':
        return '⚠️ Consultez dans les 24-48h';
      case 'ÉLEVÉ':
        return '🚨 Consultez rapidement';
      case 'CRITIQUE':
        return '🆘 URGENCE - Appelez 1313 maintenant';
      default:
        return '✅ Pas d\'urgence immédiate';
    }
  }

  Color _getCouleurFondUrgence(String urgence) {
    switch (urgence) {
      case 'FAIBLE':
      case 'منخفض':
        return const Color(0xFFE8F5E9);
      case 'MODÉRÉ':
      case 'متوسط':
        return const Color(0xFFFFF3E0);
      case 'ÉLEVÉ':
      case 'مرتفع':
        return const Color(0xFFFFEBEE);
      case 'CRITIQUE':
      case 'حرج جداً':
        return Colors.red;
      default:
        return const Color(0xFFE8F5E9);
    }
  }

  Future<void> _appeler1313() async {
    final url = 'tel:1313';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Widget _buildProfilButton({
    required IconData icon,
    required String titleFR,
    required String titleAR,
    required String subtitleFR,
    required String subtitleAR,
    required String value,
  }) {
    final isSelected = _profilSelectionne == value;
    return InkWell(
      onTap: () {
        setState(() {
          _profilSelectionne = value;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00C853) : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: isSelected ? const Color(0xFF00C853) : Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  LanguageService.isArabic ? titleAR : titleFR,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF00C853) : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  LanguageService.isArabic ? subtitleAR : subtitleFR,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C853),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assistant IA Santé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Analyse de symptômes',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte Assistant
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C853),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.medical_services, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. Santé IA',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00C853),
                          ),
                        ),
                        Text(
                          'Décrivez vos symptômes',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      FadeTransition(
                        opacity: _pulseController,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.circle, color: Color(0xFF00C853), size: 8),
                              SizedBox(width: 4),
                              Text(
                                'Actif',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF00C853),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════════
            // SÉLECTION DU PROFIL PATIENT
            // ═══════════════════════════════════════════════════════════════
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LanguageService.isArabic ? 'لمن هذه الاستشارة؟' : 'Pour qui est cette consultation ?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0d3b6e),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _buildProfilButton(
                        icon: Icons.baby_changing_station,
                        titleFR: 'Bébé',
                        titleAR: 'طفل رضيع',
                        subtitleFR: '0 - 2 ans',
                        subtitleAR: '0-2 سنة',
                        value: 'bebe',
                      ),
                      _buildProfilButton(
                        icon: Icons.child_care,
                        titleFR: 'Enfant',
                        titleAR: 'طفل',
                        subtitleFR: '2 - 12 ans',
                        subtitleAR: '2-12 سنة',
                        value: 'enfant',
                      ),
                      _buildProfilButton(
                        icon: Icons.pregnant_woman,
                        titleFR: 'Enceinte',
                        titleAR: 'حامل',
                        subtitleFR: 'Femme enceinte',
                        subtitleAR: 'حامل',
                        value: 'enceinte',
                      ),
                      _buildProfilButton(
                        icon: Icons.person,
                        titleFR: 'Adulte',
                        titleAR: 'بالغ',
                        subtitleFR: '+12 ans',
                        subtitleAR: '+12 سنة',
                        value: 'adulte',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section saisie symptômes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Vos symptômes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_symptomes.length} sélectionné(s)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF00C853),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Chips sélectionnés
            if (_symptomes.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _symptomes.map((symptome) {
                  return Chip(
                    label: Text(symptome, style: const TextStyle(fontSize: 13)),
                    deleteIcon: const Icon(Icons.close, size: 18, color: Colors.white),
                    onDeleted: () => _supprimerSymptome(symptome),
                    backgroundColor: const Color(0xFF00C853),
                    deleteIconColor: Colors.white,
                    labelStyle: const TextStyle(color: Colors.white),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Champ de saisie
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.search, color: Color(0xFF00C853)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _symptomeController,
                      decoration: const InputDecoration(
                        hintText: 'Tapez un symptôme...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: AppColors.textMedium),
                      ),
                      onSubmitted: _ajouterSymptome,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      onPressed: () => _ajouterSymptome(_symptomeController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Symptômes par catégorie
            ..._symptomesParCategorie.entries.map((entry) {
              final categorie = entry.key;
              final symptomes = entry.value;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categorie,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: symptomes.map((symptome) {
                      final isSelected = _symptomes.contains(symptome);
                      return InkWell(
                        onTap: () {
                          if (isSelected) {
                            _supprimerSymptome(symptome);
                          } else {
                            _ajouterSymptome(symptome);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF00C853) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00C853),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                const Icon(Icons.check, color: Colors.white, size: 16),
                              if (isSelected) const SizedBox(width: 4),
                              Text(
                                symptome,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected ? Colors.white : const Color(0xFF00C853),
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),

            const SizedBox(height: 24),

            // Bouton analyser
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _demarrerAnalyse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C853),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF00C853).withOpacity(0.4),
                ),
                child: _isAnalyzing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Analyse en cours...'),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics),
                              SizedBox(width: 8),
                              Text(
                                'Analyser mes symptômes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Résultat en quelques secondes',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Résultat d'analyse
            if (_diagnostic.isNotEmpty) ...[
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: _buildResultatAnalyse(),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultatAnalyse() {
    final lang = LanguageService.isArabic ? 'ar' : 'fr';
    final diagnosticData = _diagnostic[lang] as Map<String, dynamic>;
    final urgence = diagnosticData['urgence'] as String;
    final couleurUrgence = _getCouleurUrgence(urgence);
    final fondUrgence = _getCouleurFondUrgence(urgence);
    final texteUrgence = _getTexteUrgence(urgence, LanguageService.isArabic);
    final maladie = diagnosticData['maladie'] as String;
    final description = diagnosticData['description'] as String;
    final probabilite = diagnosticData['probabilite'] as int;
    final premiersSecours = diagnosticData['premiers_secours'] as List<String>;
    final eviter = diagnosticData['eviter'] as String;
    final alertesSpeciales = diagnosticData['alertes_speciales'] as List<String>?;
    final medicamentsInterdits = diagnosticData['medicaments_interdits'] as List<String>?;
    final doseMedicament = diagnosticData['dose_medicament'] as String?;

    // Badge profil
    String profilBadge = '';
    Color profilBadgeColor = Colors.grey;
    switch (_profilSelectionne) {
      case 'bebe':
        profilBadge = LanguageService.isArabic ? '👶 تشخيص الرضيع' : '👶 Diagnostic Bébé';
        profilBadgeColor = Colors.blue;
        break;
      case 'enfant':
        profilBadge = LanguageService.isArabic ? '🧒 تشخيص الطفل' : '🧒 Diagnostic Enfant';
        profilBadgeColor = Colors.green;
        break;
      case 'enceinte':
        profilBadge = LanguageService.isArabic ? '🤰 تشخيص الحمل' : '🤰 Diagnostic Grossesse';
        profilBadgeColor = Colors.pink;
        break;
      case 'adulte':
        profilBadge = LanguageService.isArabic ? '🧑 تشخيص البالغ' : '🧑 Diagnostic Adulte';
        profilBadgeColor = Colors.grey;
        break;
    }

    // Bouton urgence toujours visible pour bébé et enceinte
    final showEmergencyButton = _profilSelectionne == 'bebe' || _profilSelectionne == 'enceinte';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle langue
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Résultat d\'analyse',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    // Badge profil
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: profilBadgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: profilBadgeColor, width: 1),
                      ),
                      child: Text(
                        profilBadge,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: profilBadgeColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        await LanguageService.toggleLanguage();
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.translate, size: 18, color: Color(0xFF00C853)),
                            const SizedBox(width: 4),
                            Text(
                              LanguageService.isArabic ? '🌐 Français' : '🌐 عربي',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF00C853),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bandeau urgence
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: fondUrgence,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: urgence == 'CRITIQUE' || urgence == 'حرج جداً' ? Colors.white : couleurUrgence, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    texteUrgence,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: urgence == 'CRITIQUE' || urgence == 'حرج جداً' ? Colors.white : couleurUrgence,
                    ),
                  ),
                ),
                if (urgence == 'CRITIQUE' || urgence == 'حرج جداً')
                  FadeTransition(
                    opacity: _pulseController,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Maladie probable
                Text(
                  LanguageService.isArabic ? 'التشخيص المحتمل' : 'Diagnostic probable',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  maladie,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Barre de probabilité
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1000),
                          tween: Tween(begin: 0.0, end: probabilite / 100),
                          builder: (context, value, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.white,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00C853)),
                                minHeight: 8,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1000),
                        tween: Tween(begin: 0.0, end: probabilite.toDouble()),
                        builder: (context, value, child) {
                          return Text(
                            '${LanguageService.isArabic ? 'الاحتمال' : 'Probabilité'} : ${value.toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00C853),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ═══════════════════════════════════════════════════════════════
                // ALERTES SPÉCIALES (si présentes)
                // ═══════════════════════════════════════════════════════════════
                if (alertesSpeciales != null && alertesSpeciales.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber, color: Colors.orange, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              LanguageService.isArabic ? '⚠️ تحذيرات خاصة' : '⚠️ Alertes spéciales',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...alertesSpeciales.map((alerte) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              alerte,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textDark,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ═══════════════════════════════════════════════════════════════
                // MÉDICAMENTS INTERDITS (si profil enceinte ou bébé)
                // ═══════════════════════════════════════════════════════════════
                if (medicamentsInterdits != null && medicamentsInterdits.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.block, color: Colors.red, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              LanguageService.isArabic ? '❌ أدوية ممنوعة' : '❌ Médicaments interdits',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...medicamentsInterdits.map((medicament) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              medicament,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textDark,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ═══════════════════════════════════════════════════════════════
                // DOSAGE MÉDICAMENTS (si profil enfant ou bébé)
                // ═══════════════════════════════════════════════════════════════
                if (doseMedicament != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.medication, color: Colors.blue, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              LanguageService.isArabic ? '💊 جرعة الدواء' : '💊 Dosage médicament',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doseMedicament,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Section premiers secours
                Text(
                  LanguageService.isArabic ? '💊 الإسعافات الأولية' : '💊 Premiers secours',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C853),
                  ),
                ),
                const SizedBox(height: 12),
                ...premiersSecours.map((conseil) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF00C853), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            conseil,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 24),

                // Carte À éviter
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.yellow[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LanguageService.isArabic ? '⚠️ تجنب' : '⚠️ À éviter',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              eviter,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Naviguer vers CarteScreen
                        },
                        icon: const Icon(Icons.location_on),
                        label: Text(LanguageService.isArabic ? '📍 العثور على مركز' : '📍 Trouver un centre'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C853),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    // Bouton urgence toujours visible pour bébé et enceinte
                    if (showEmergencyButton || urgence == 'ÉLEVÉ' || urgence == 'مرتفع' || urgence == 'CRITIQUE' || urgence == 'حرج جداً') ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _appeler1313,
                          icon: const Icon(Icons.phone),
                          label: const Text('📞 1313'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: showEmergencyButton ? Colors.red[700] : Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Disclaimer
                Center(
                  child: Text(
                    LanguageService.isArabic ? '⚠️ هذا تقدير. استشر دائماً محترفاً.' : '⚠️ Ceci est une estimation. Consultez toujours un professionnel.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
