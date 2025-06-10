import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userQuery.docs.first;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        
        return {
          'success': true,
          'userId': userDoc.id,
          'role': userData['role'] ?? 'user',
          'userName': userData['name'] ?? username,
          'message': 'تم تسجيل الدخول بنجاح'
        };
      } else {
        return {
          'success': false,
          'message': 'اسم المستخدم أو كلمة المرور غير صحيحة'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء تسجيل الدخول: $e'
      };
    }
  }

  Future<void> saveLoginCredentials(String username, String password, bool rememberMe) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (rememberMe) {
      await prefs.setString('saved_username', username);
      await prefs.setString('saved_password', password);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  Future<Map<String, String?>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('saved_username'),
      'password': prefs.getString('saved_password'),
    };
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('remember_me') ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_username');
    await prefs.remove('saved_password');
    await prefs.setBool('remember_me', false);
  }

  Future<Map<String, dynamic>> createUser({
    required String username,
    required String password,
    required String name,
    required String role,
    required String phone,
  }) async {
    try {
      // Check if username already exists
      QuerySnapshot existingUser = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (existingUser.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'اسم المستخدم موجود بالفعل'
        };
      }

      // Create new user
      DocumentReference userRef = await _firestore.collection('users').add({
        'username': username,
        'password': password,
        'name': name,
        'role': role,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      return {
        'success': true,
        'userId': userRef.id,
        'message': 'تم إنشاء المستخدم بنجاح'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ أثناء إنشاء المستخدم: $e'
      };
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      QuerySnapshot usersSnapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return usersSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  Future<bool> updateUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating user status: $e');
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
}