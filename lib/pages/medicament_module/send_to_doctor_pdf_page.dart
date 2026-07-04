import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/medicament_module/medicament_module.dart';
import '../../utils/colors.dart';

class SendToDoctorPDFPage extends StatefulWidget {
  final MedicamentModule medicament;
  final ProfilFamille profil;
  const SendToDoctorPDFPage({super.key, required this.medicament, required this.profil});

  @override
  State<SendToDoctorPDFPage> createState() => _SendToDoctorPDFPageState();
}

class _SendToDoctorPDFPageState extends State<SendToDoctorPDFPage> {
  bool _isGenerating = false;
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final medicament = widget.medicament;
    final profil = widget.profil;
    final rapport = medicament.genererRapportObservance(profil.id);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        title: const Text('Rapport pour médecin'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aperçu du rapport
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            'eSanté Tchad',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00A86B)),
                          ),
                          Text('Rapport d\'observance médicamenteuse'),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),

                    // Informations patient
                    _buildSection('Patient', [
                      _buildRow('Nom', profil.nom),
                      _buildRow('Relation', profil.relation),
                      _buildRow('Date de naissance', '${profil.dateNaissance.day}/${profil.dateNaissance.month}/${profil.dateNaissance.year}'),
                    ]),

                    const SizedBox(height: 16),

                    // Informations médicament
                    _buildSection('Médicament', [
                      _buildRow('Nom', medicament.nom),
                      _buildRow('Forme', medicament.forme),
                      _buildRow('Dosage', medicament.dosage),
                      _buildRow('Fréquence', '${medicament.frequenceParJour} fois/jour'),
                      _buildRow('Durée', '${medicament.dureeJours} jours'),
                      if (medicament.prescritPar != null) _buildRow('Prescrit par', medicament.prescritPar!),
                    ]),

                    const SizedBox(height: 16),

                    // Période
                    _buildSection('Période de traitement', [
                      _buildRow('Du', '${rapport.periodeDebut.day}/${rapport.periodeDebut.month}/${rapport.periodeDebut.year}'),
                      _buildRow('Au', '${rapport.periodeFin.day}/${rapport.periodeFin.month}/${rapport.periodeFin.year}'),
                    ]),

                    const SizedBox(height: 16),

                    // Statistiques
                    _buildSection('Statistiques', [
                      _buildRow('Prises prévues', '${rapport.prisesPrevues}'),
                      _buildRow('Prises réalisées', '${rapport.prisesRealisees}'),
                      _buildRow('Prises manquées', '${rapport.prisesManquees}'),
                      _buildRow('Taux d\'observance', '${rapport.tauxObservance.toInt()}%'),
                    ]),

                    const SizedBox(height: 16),

                    // Message motivation
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: rapport.tauxObservance >= 70 ? Colors.green[50] : Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: rapport.tauxObservance >= 70 ? Colors.green : Colors.orange,
                        ),
                      ),
                      child: Text(
                        rapport.messageMotivation,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: rapport.tauxObservance >= 70 ? Colors.green : Colors.orange,
                        ),
                      ),
                  ),

                    const SizedBox(height: 16),

                    // Détail des prises
                    _buildSection('Détail des prises récentes', [
                      ...rapport.detailsPrises.take(10).map((prise) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${prise.datePrevue.day}/${prise.datePrevue.month} ${prise.datePrevue.hour}:${prise.datePrevue.minute}'),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatutColor(prise.statut),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  prise.statut.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ]),

                    const SizedBox(height: 16),

                    // Footer
                    Center(
                      child: Column(
                        children: [
                          const Text('Généré par eSanté Tchad'),
                          Text('Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _genererPDF,
                    icon: _isGenerating
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.picture_as_pdf),
                    label: Text(_isGenerating ? 'Génération...' : 'Générer PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A86B),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSharing ? null : _partagerWhatsApp,
                    icon: _isSharing
                        ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.message),
                    label: Text(_isSharing ? 'Envoi...' : 'WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF00A86B)),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Color _getStatutColor(String statut) {
    switch (statut) {
      case 'pris':
        return const Color(0xFF00A86B);
      case 'manque':
        return Colors.red;
      case 'reporte':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _genererPDF() {
    setState(() => _isGenerating = true);
    
    // TODO: Implémenter la génération réelle du PDF
    // Utiliser pdf package ou flutter_pdfview
    
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF généré avec succès !')),
      );
    });
  }

  void _partagerWhatsApp() async {
    setState(() => _isSharing = true);

    final medicament = widget.medicament;
    final profil = widget.profil;
    final rapport = medicament.genererRapportObservance(profil.id);

    // Construire le message pour WhatsApp
    final message = '''
📋 *Rapport d'observance - eSanté Tchad*

*Patient:* ${profil.nom} (${profil.relation})
*Médicament:* ${medicament.nom} (${medicament.dosage})
*Période:* ${rapport.periodeDebut.day}/${rapport.periodeDebut.month}/${rapport.periodeDebut.year} - ${rapport.periodeFin.day}/${rapport.periodeFin.month}/${rapport.periodeFin.year}

📊 *Statistiques:*
• Prises prévues: ${rapport.prisesPrevues}
• Prises réalisées: ${rapport.prisesRealisees}
• Prises manquées: ${rapport.prisesManquees}
• Taux d'observance: ${rapport.tauxObservance.toInt()}%

${rapport.messageMotivation}

_Généré par eSanté Tchad_
''';

    final whatsappUrl = 'https://wa.me/?text=${Uri.encodeComponent(message)}';

    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Impossible d\'ouvrir WhatsApp';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isSharing = false);
    }
  }
}
