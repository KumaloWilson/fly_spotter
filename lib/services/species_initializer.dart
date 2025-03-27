import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:specifier/services/firestore_service.dart';

import '../utiils/logs.dart';

class SpeciesInitializer {
  static final SpeciesInitializer _instance = SpeciesInitializer._internal();
  bool _hasImportedSpecies = false;

  factory SpeciesInitializer() {
    return _instance;
  }

  SpeciesInitializer._internal();

  Future<void> importSpeciesIfNeeded() async {
    try {
      // Fetch the import status document
      DocumentSnapshot importCheckDoc = await FirebaseFirestore.instance
          .collection('app_metadata')
          .doc('species_import')
          .get();

      // Ensure the data exists and check 'imported' safely
      bool isImported = (importCheckDoc.data() as Map<String, dynamic>?)?['imported'] ?? false;

      if (!isImported) {
        List<String> speciesList = [
          '0 Eristalinus spp',
          '1 Hermetia illucens',
          '2 Tabanus astrus',
          '3 Pangoniinae phololiche',
          '4 Tabanidae Tabanus',
          '5 Tachinidae hystricia',
          '6 Platystomatidae spp',
          '7 Asilidae Asilinae sp',
          '8 Asilidae spp',
          '9 Tabanidae Tabunus',
          '10 Systoechus spp',
          '11 Diopsidae spp',
          '12 Syrphidae spp',
          '13 Bombyliidae spp',
          '14 Bombyliidae Anthrax spp',
          '15 Calliphora spp',
          '16 Tachina spp',
          '17 Asilinae',
          '18 Bromophia caffra',
          '19 Asilidae A sp',
          '20 Stratiomydae spp',
          '21 Sarcophaga spp',
          '22 Tachina fera spp',
          '23 Tabanidae s',
          '24 Poecilantrax spp',
          '25 Conopidae spp',
          '26 Coremacera spp',
          '27 Assilinae sppp',
          '28 Syrphidae s',
          '29 Tabanidae spppp',
          '30 Tabanidae spp',
          '31 Hystrica spp',
          '32 Asilidae A. spp',
          '33 Syrphidae sp',
          '34 Tabanidae sppp',
          '35 Diopsidae sp',
          '36 Muscidae spp',
          '37 Tabanidae',
          '38 Notolomatidae pietipennis',
          '39 Calliphoridae spp',
          '40 Tachinidae sp',
          '41 Tachina sp',
          '42 Calliphoridae sp',
        ];

        await FirestoreService().importSpeciesFromLabelFile(speciesList);

        // Mark as imported
        await FirebaseFirestore.instance
            .collection('app_metadata')
            .doc('species_import')
            .set({'imported': true}, SetOptions(merge: true));

        DevLogs.logInfo('Species successfully imported');
      }
    } catch (e) {
      DevLogs.logError('Species import failed: $e');
    }
  }
}