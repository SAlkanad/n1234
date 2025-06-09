import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../core/constants/firebase_constants.dart';

class AuthService {
  static UserModel? _currentUser;
  static UserModel? get currentUser => _currentUser;

  static Future<UserModel> login(String username, String password) async {
    try {
      final hashedPassword = _hashPassword(password);
      final querySnapshot = await FirebaseFirestore.instance
          .collection(FirebaseConstants.usersCollection)
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: hashedPassword)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('اسم المستخدم أو كلمة المرور غير صحيحة');
      }

      final userData = querySnapshot.docs.first.data();
      final user = UserModel.fromMap(userData);

      if (!user.isActive) {
        throw Exception('الحساب غير مفعل');
      }

      if (user.validationEndDate != null && 
          user.validationEndDate!.isBefore(DateTime.now())) {
        throw Exception('انتهت صلاحية الحساب');
      }

      _currentUser = user;
      return user;
    } catch (e) {
      throw Exception('خطأ في تسجيل الدخول: ${e.toString()}');
    }
  }

  static Future<void> logout() async {
    _currentUser = null;
  }

  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}
