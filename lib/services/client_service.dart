import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';

class ClientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Map<String, dynamic>> addClient({
    required String name,
    required String phone,
    String? secondPhone,
    required String createdBy,
    required String createdByName,
    List<File>? images,
  }) async {
    try {
      List<String> imageUrls = [];
      
      if (images != null && images.isNotEmpty) {
        imageUrls = await _uploadAndCompressImages(images);
      }

      DocumentReference clientRef = await _firestore.collection('clients').add({
        'name': name,
        'phone': phone,
        'secondPhone': secondPhone,
        'status': 'جديد',
        'createdBy': createdBy,
        'createdByName': createdByName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'images': imageUrls,
        'lastContact': null,
        'notes': '',
      });

      return {
        'success': true,
        'clientId': clientRef.id,
        'message': 'تم إضافة العميل بنجاح'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء إضافة العميل: $e'
      };
    }
  }

  Future<List<String>> _uploadAndCompressImages(List<File> images) async {
    List<String> urls = [];
    
    for (File imageFile in images) {
      try {
        // Read and compress image
        Uint8List imageBytes = await imageFile.readAsBytes();
        img.Image? image = img.decodeImage(imageBytes);
        
        if (image != null) {
          // Resize if too large
          if (image.width > 1024 || image.height > 1024) {
            image = img.copyResize(image, width: 1024);
          }
          
          // Compress with quality 80
          Uint8List compressedBytes = Uint8List.fromList(
            img.encodeJpg(image, quality: 80)
          );
          
          // Upload to Firebase Storage
          String fileName = 'client_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
          Reference ref = _storage.ref().child(fileName);
          
          UploadTask uploadTask = ref.putData(compressedBytes);
          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();
          
          urls.add(downloadUrl);
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
    
    return urls;
  }

  Future<List<Map<String, dynamic>>> getClientsByUser(String userId, String userRole) async {
    try {
      Query query;
      
      if (userRole == 'admin') {
        // Admin can see all clients
        query = _firestore
            .collection('clients')
            .orderBy('createdAt', descending: true);
      } else {
        // Regular users see only their clients
        query = _firestore
            .collection('clients')
            .where('createdBy', isEqualTo: userId)
            .orderBy('createdAt', descending: true);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting clients: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchClients(String userId, String userRole, String searchTerm) async {
    try {
      List<Map<String, dynamic>> allClients = await getClientsByUser(userId, userRole);
      
      if (searchTerm.isEmpty) {
        return allClients;
      }

      return allClients.where((client) {
        String name = (client['name'] ?? '').toString().toLowerCase();
        String phone = (client['phone'] ?? '').toString();
        String secondPhone = (client['secondPhone'] ?? '').toString();
        String searchLower = searchTerm.toLowerCase();
        
        return name.contains(searchLower) || 
               phone.contains(searchTerm) || 
               secondPhone.contains(searchTerm);
      }).toList();
    } catch (e) {
      print('Error searching clients: $e');
      return [];
    }
  }

  Future<bool> updateClientStatus(String clientId, String status) async {
    try {
      await _firestore.collection('clients').doc(clientId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastContact': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating client status: $e');
      return false;
    }
  }

  Future<bool> updateClient({
    required String clientId,
    required String name,
    required String phone,
    String? secondPhone,
    String? status,
    String? notes,
    List<File>? newImages,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'name': name,
        'phone': phone,
        'secondPhone': secondPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (status != null) {
        updateData['status'] = status;
      }

      if (notes != null) {
        updateData['notes'] = notes;
      }

      if (newImages != null && newImages.isNotEmpty) {
        List<String> newImageUrls = await _uploadAndCompressImages(newImages);
        
        // Get existing images
        DocumentSnapshot clientDoc = await _firestore.collection('clients').doc(clientId).get();
        if (clientDoc.exists) {
          Map<String, dynamic> clientData = clientDoc.data() as Map<String, dynamic>;
          List<String> existingImages = List<String>.from(clientData['images'] ?? []);
          existingImages.addAll(newImageUrls);
          updateData['images'] = existingImages;
        } else {
          updateData['images'] = newImageUrls;
        }
      }

      await _firestore.collection('clients').doc(clientId).update(updateData);
      return true;
    } catch (e) {
      print('Error updating client: $e');
      return false;
    }
  }

  Future<bool> deleteClient(String clientId) async {
    try {
      // Get client data to delete associated images
      DocumentSnapshot clientDoc = await _firestore.collection('clients').doc(clientId).get();
      if (clientDoc.exists) {
        Map<String, dynamic> clientData = clientDoc.data() as Map<String, dynamic>;
        List<String> images = List<String>.from(clientData['images'] ?? []);
        
        // Delete images from storage
        for (String imageUrl in images) {
          try {
            Reference ref = _storage.refFromURL(imageUrl);
            await ref.delete();
          } catch (e) {
            print('Error deleting image: $e');
          }
        }
      }

      // Delete client document
      await _firestore.collection('clients').doc(clientId).delete();
      return true;
    } catch (e) {
      print('Error deleting client: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getClientById(String clientId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('clients').doc(clientId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting client: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getClientsByStatus(String userId, String userRole, String status) async {
    try {
      Query query;
      
      if (userRole == 'admin') {
        query = _firestore
            .collection('clients')
            .where('status', isEqualTo: status)
            .orderBy('createdAt', descending: true);
      } else {
        query = _firestore
            .collection('clients')
            .where('createdBy', isEqualTo: userId)
            .where('status', isEqualTo: status)
            .orderBy('createdAt', descending: true);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting clients by status: $e');
      return [];
    }
  }
}