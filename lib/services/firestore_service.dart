import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:specifier/utiils/logs.dart';

import '../models/fly_identification.dart';
import '../models/user_Model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _identificationsCollection => _firestore.collection('identifications');
  CollectionReference get _speciesCollection => _firestore.collection('species');

  // Check if user exists
  Future<bool> checkUserExists(String uid) async {
    DocumentSnapshot doc = await _usersCollection.doc(uid).get();
    return doc.exists;
  }

  // Create user
  Future<void> createUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).set(user.toJson());
    } catch (e) {
      throw e;
    }
  }

  // Get user
  Future<UserModel> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        throw 'User not found';
      }
    } catch (e) {
      throw e;
    }
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.uid).update(user.toJson());
    } catch (e) {
      throw e;
    }
  }

  // Save identification result
  Future<void> saveIdentificationResult(IdentificationResult result) async {
    try {
      // Add to identifications collection
      DocumentReference docRef = await _identificationsCollection.add(result.toJson());

      // Update user's identification history
      await _usersCollection.doc(result.userId).update({
        'identificationHistory': FieldValue.arrayUnion([docRef.id])
      });
    } catch (e) {
      throw e;
    }
  }

  // Get user's identification history
  Future<List<IdentificationResult>> getUserIdentificationHistory(String uid) async {
    try {
      QuerySnapshot snapshot = await _identificationsCollection
          .where('userId', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return IdentificationResult.fromJson(data);
      }).toList();
    } catch (e) {
      throw e;
    }
  }

  // Get all fly species
  Future<List<FlySpecies>> getAllSpecies() async {
    try {
      QuerySnapshot snapshot = await _speciesCollection.get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return FlySpecies.fromJson(data);
      }).toList();
    } catch (e) {
      throw e;
    }
  }


  Future<FlySpecies> getSpecies(String id) async {
    try {
      // Log the species ID being fetched for debugging
      DevLogs.logInfo('Attempting to fetch species with ID: $id');

      DocumentSnapshot doc = await _speciesCollection.doc(id).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return FlySpecies.fromJson(data);
      } else {
        // Log all available species IDs for debugging
        QuerySnapshot allSpecies = await _speciesCollection.get();
        List<String> availableSpeciesIds = allSpecies.docs.map((doc) => doc.id).toList();

        DevLogs.logError('Species not found. Available species IDs: $availableSpeciesIds');

        throw 'Species not found. ID: $id. Available species: $availableSpeciesIds';
      }
    } catch (e) {
      DevLogs.logError('Error fetching species: $e');
      throw e;
    }
  }


  Future<void> importSpeciesFromLabelFile(List<String> speciesList) async {
    for (String speciesEntry in speciesList) {
      // Split the entry into parts
      List<String> parts = speciesEntry.trim().split(' ');

      // Determine how to parse the species name
      String id = parts[0];
      String name = parts.length > 1 ? parts.sublist(1).join(' ') : 'Unknown Species';

      // Create a more descriptive scientific name
      String scientificName = name;

      // Create a basic description based on the name
      String description = 'A fly species classified in the $name group.';

      // Create a FlySpecies object
      FlySpecies species = FlySpecies(
          id: id,
          name: name,
          scientificName: scientificName,
          description: description,
          characteristics: {
            'taxonomicGroup': parts.length > 1 ? parts[0] : 'Unknown',
            'identificationNotes': 'Imported from label file'
          }
      );

      try {
        // Save to Firestore using the ID as the document ID
        await _speciesCollection.doc(id).set(species.toJson());
        DevLogs.logInfo('Successfully imported species: $id - $name');
      } catch (e) {
        DevLogs.logError('Failed to import species $id: $e');
      }
    }
  }
}

