import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/colors.dart';

class CentreSante {
  final String id;
  final String nom;
  final String type;
  final String ville;
  final String quartier;
  final String telephone;
  final String horaires;
  final String services;
  final double latitude;
  final double longitude;

  CentreSante({
    required this.id,
    required this.nom,
    required this.type,
    required this.ville,
    required this.quartier,
    required this.telephone,
    required this.horaires,
    required this.services,
    required this.latitude,
    required this.longitude,
  });
}

class CarteStructuresPage extends StatefulWidget {
  const CarteStructuresPage({super.key});

  @override
  State<CarteStructuresPage> createState() => _CarteStructuresPageState();
}

class _CarteStructuresPageState extends State<CarteStructuresPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'Tous';
  String _selectedVille = 'Toutes';

  final List<CentreSante> _centres = [
    CentreSante(
      id: '1',
      nom: 'Hôpital Général de Référence N\'Djamena',
      type: 'Hôpital',
      ville: 'N\'Djamena',
      quartier: 'Chagoua',
      telephone: '+235 66 00 00 00',
      horaires: '24h/24',
      services: 'Urgences, Chirurgie, Pédiatrie, Maternité',
      latitude: 12.1136,
      longitude: 15.0494,
    ),
    CentreSante(
      id: '2',
      nom: 'Centre de Santé de Moursal',
      type: 'Centre de Santé',
      ville: 'N\'Djamena',
      quartier: 'Moursal',
      telephone: '+235 66 01 01 01',
      horaires: '08h-18h',
      services: 'Consultations, Vaccination, PMI',
      latitude: 12.1200,
      longitude: 15.0600,
    ),
    CentreSante(
      id: '3',
      nom: 'Hôpital de l\'Amitié',
      type: 'Hôpital',
      ville: 'N\'Djamena',
      quartier: 'Ari Djollé',
      telephone: '+235 66 02 02 02',
      horaires: '24h/24',
      services: 'Urgences, Cardiologie, Neurologie',
      latitude: 12.1050,
      longitude: 15.0400,
    ),
    CentreSante(
      id: '4',
      nom: 'Dispensaire de Diguel',
      type: 'Dispensaire',
      ville: 'N\'Djamena',
      quartier: 'Diguel',
      telephone: '+235 66 03 03 03',
      horaires: '08h-17h',
      services: 'Soins primaires, Pharmacie',
      latitude: 12.1300,
      longitude: 15.0700,
    ),
    CentreSante(
      id: '5',
      nom: 'Centre Hospitalier Universitaire',
      type: 'Hôpital',
      ville: 'N\'Djamena',
      quartier: 'Farcha',
      telephone: '+235 66 04 04 04',
      horaires: '24h/24',
      services: 'Spécialités, Recherche, Enseignement',
      latitude: 12.0950,
      longitude: 15.0300,
    ),
    CentreSante(
      id: '9',
      nom: 'Hôpital Central N\'Djamena',
      type: 'Hôpital',
      ville: 'N\'Djamena',
      quartier: 'Hadjer Issoa',
      telephone: '+235 66 08 08 08',
      horaires: '24h/24',
      services: 'Urgences, Médecine interne, Pédiatrie',
      latitude: 12.1250,
      longitude: 15.0550,
    ),
    CentreSante(
      id: '10',
      nom: 'Hôpital Militaire N\'Djamena',
      type: 'Hôpital',
      ville: 'N\'Djamena',
      quartier: 'Kousseri',
      telephone: '+235 66 09 09 09',
      horaires: '24h/24',
      services: 'Urgences, Traumatologie, Chirurgie',
      latitude: 12.1000,
      longitude: 15.0450,
    ),
    CentreSante(
      id: '11',
      nom: 'Centre de Santé de Walia',
      type: 'Centre de Santé',
      ville: 'N\'Djamena',
      quartier: 'Walia',
      telephone: '+235 66 10 10 10',
      horaires: '08h-18h',
      services: 'Consultations, Prévention, PMI',
      latitude: 12.1400,
      longitude: 15.0750,
    ),
    CentreSante(
      id: '12',
      nom: 'Clinique Renaissance',
      type: 'Hôpital',
      ville: 'N\'Djamena',
      quartier: 'Ngaragba',
      telephone: '+235 66 11 11 11',
      horaires: '24h/24',
      services: 'Urgences, Gynécologie, Obstétrique',
      latitude: 12.1150,
      longitude: 15.0650,
    ),
    CentreSante(
      id: '6',
      nom: 'Centre de Santé de Sarh',
      type: 'Centre de Santé',
      ville: 'Sarh',
      quartier: 'Centre-ville',
      telephone: '+235 66 05 05 05',
      horaires: '08h-18h',
      services: 'Consultations, Urgences, Maternité',
      latitude: 9.1450,
      longitude: 18.3800,
    ),
    CentreSante(
      id: '7',
      nom: 'Hôpital Régional de Moundou',
      type: 'Hôpital',
      ville: 'Moundou',
      quartier: 'Zone industrielle',
      telephone: '+235 66 06 06 06',
      horaires: '24h/24',
      services: 'Chirurgie, Pédiatrie, Urgences',
      latitude: 8.5667,
      longitude: 16.0833,
    ),
    CentreSante(
      id: '8',
      nom: 'Centre de Santé de Doba',
      type: 'Centre de Santé',
      ville: 'Doba',
      quartier: 'Centre',
      telephone: '+235 66 07 07 07',
      horaires: '08h-18h',
      services: 'Consultations, Vaccination, PMI',
      latitude: 8.6500,
      longitude: 16.0833,
    ),
    CentreSante(
      id: '13',
      nom: 'Hôpital Régional d\'Abéché',
      type: 'Hôpital',
      ville: 'Abéché',
      quartier: 'Centre-ville',
      telephone: '+235 66 12 12 12',
      horaires: '24h/24',
      services: 'Urgences, Chirurgie, Pédiatrie, Maternité',
      latitude: 13.8433,
      longitude: 20.8311,
    ),
    CentreSante(
      id: '14',
      nom: 'Centre de Santé d\'Abéché',
      type: 'Centre de Santé',
      ville: 'Abéché',
      quartier: 'Arada',
      telephone: '+235 66 13 13 13',
      horaires: '08h-18h',
      services: 'Consultations, Vaccination, PMI',
      latitude: 13.8500,
      longitude: 20.8400,
    ),
    CentreSante(
      id: '15',
      nom: 'Dispensaire d\'Abéché',
      type: 'Dispensaire',
      ville: 'Abéché',
      quartier: 'Hadjer Marfain',
      telephone: '+235 66 14 14 14',
      horaires: '08h-17h',
      services: 'Soins primaires, Pharmacie',
      latitude: 13.8350,
      longitude: 20.8250,
    ),
  ];

  List<CentreSante> get _filteredCentres {
    return _centres.where((centre) {
      final matchesSearch = centre.nom.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          centre.ville.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          centre.quartier.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesType = _selectedType == 'Tous' || centre.type == _selectedType;
      final matchesVille = _selectedVille == 'Toutes' || centre.ville == _selectedVille;
      return matchesSearch && matchesType && matchesVille;
    }).toList();
  }

  List<String> get _types => ['Tous', ..._centres.map((c) => c.type).toSet()];
  List<String> get _villes => ['Toutes', ..._centres.map((c) => c.ville).toSet()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: const Text('Centres de Santé'),
        backgroundColor: const Color(0xFF00A86B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilters(),
          Expanded(
            child: _filteredCentres.isEmpty
                ? _buildEmptyState()
                : _buildCentresList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un centre de santé...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00A86B)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00A86B), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              label: 'Type',
              value: _selectedType,
              items: _types,
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdown(
              label: 'Ville',
              value: _selectedVille,
              items: _villes,
              onChanged: (value) => setState(() => _selectedVille = value!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Aucun centre de santé trouvé',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos critères de recherche',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentresList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCentres.length,
      itemBuilder: (context, index) {
        final centre = _filteredCentres[index];
        return _buildCentreCard(centre);
      },
    );
  }

  Widget _buildCentreCard(CentreSante centre) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () => _showCentreDetails(centre),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00A86B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getTypeIcon(centre.type),
                      color: const Color(0xFF00A86B),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          centre.nom,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${centre.quartier}, ${centre.ville}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor(centre.type),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      centre.type,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    centre.telephone,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    centre.horaires,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCentreDetails(CentreSante centre) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00A86B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getTypeIcon(centre.type),
                            color: const Color(0xFF00A86B),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                centre.nom,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(centre.type),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  centre.type,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow(
                      Icons.location_on,
                      'Adresse',
                      '${centre.quartier}, ${centre.ville}',
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.phone,
                      'Téléphone',
                      centre.telephone,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.access_time,
                      'Horaires',
                      centre.horaires,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.medical_services,
                      'Services',
                      centre.services,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final Uri phoneUri = Uri(
                                scheme: 'tel',
                                path: centre.telephone.replaceAll(' ', ''),
                              );
                              if (await canLaunchUrl(phoneUri)) {
                                await launchUrl(phoneUri);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Impossible de passer l\'appel'),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.phone),
                            label: const Text('Appeler'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00A86B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final Uri mapUri = Uri(
                                scheme: 'https',
                                host: 'www.google.com',
                                path: 'maps/search/',
                                query: 'api=1&query=${centre.latitude},${centre.longitude}',
                              );
                              if (await canLaunchUrl(mapUri)) {
                                await launchUrl(mapUri, mode: LaunchMode.externalApplication);
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Impossible d\'ouvrir la carte'),
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.directions),
                            label: const Text('Itinéraire'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF00A86B),
                              side: const BorderSide(color: Color(0xFF00A86B)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF00A86B), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Hôpital':
        return Icons.local_hospital;
      case 'Centre de Santé':
        return Icons.health_and_safety;
      case 'Dispensaire':
        return Icons.medication;
      default:
        return Icons.medical_services;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Hôpital':
        return const Color(0xFFE53935);
      case 'Centre de Santé':
        return const Color(0xFF00A86B);
      case 'Dispensaire':
        return const Color(0xFF1976D2);
      default:
        return Colors.grey;
    }
  }
}
