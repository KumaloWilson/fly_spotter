import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/fly_identification.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_card.dart';
import 'species_detail_screen.dart';

class SpeciesGuideScreen extends StatefulWidget {
  const SpeciesGuideScreen({super.key});

  @override
  State<SpeciesGuideScreen> createState() => _SpeciesGuideScreenState();
}

class _SpeciesGuideScreenState extends State<SpeciesGuideScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool isLoading = true;
  String errorMessage = '';
  List<FlySpecies> allSpecies = [];
  List<FlySpecies> filteredSpecies = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSpecies();
  }

  Future<void> loadSpecies() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      allSpecies = await _firestoreService.getAllSpecies();
      filteredSpecies = List.from(allSpecies);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterSpecies(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSpecies = List.from(allSpecies);
      } else {
        filteredSpecies = allSpecies
            .where((species) =>
        species.name.toLowerCase().contains(query.toLowerCase()) ||
            species.scientificName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fly Species Guide'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search species...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    filterSpecies('');
                  },
                )
                    : null,
              ),
              onChanged: filterSpecies,
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading species',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(errorMessage),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: loadSpecies,
                    child: Text('Try Again'),
                  ),
                ],
              ),
            )
                : filteredSpecies.isEmpty
                ? Center(
              child: Text(
                'No species found',
                style: TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredSpecies.length,
              itemBuilder: (context, index) {
                final species = filteredSpecies[index];
                return CustomCard(
                  // margin: EdgeInsets.only(bottom: 12),
                  onTap: () {
                    Get.to(() => SpeciesDetailScreen(species: species));
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: species.imageUrl != null
                            ? Image.network(
                          species.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                            : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.bug_report,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              species.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              species.scientificName,
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              species.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

