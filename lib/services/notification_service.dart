import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getNotificationMessages() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('settings')
          .doc('notifications')
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return List<String>.from(data['messages'] ?? [
          'تم التواصل معك من قبل مكتب حجوزات الطيران',
          'يرجى التواصل مع مكتب الحجوزات لإكمال الحجز',
          'عرض خاص من مكتب حجوزات الطيران',
          'تأكيد حجز الطيران'
        ]);
      }

      return [
        'تم التواصل معك من قبل مكتب حجوزات الطيران',
        'يرجى التواصل مع مكتب الحجوزات لإكمال الحجز',
        'عرض خاص من مكتب حجوزات الطيران',
        'تأكيد حجز الطيران'
      ];
    } catch (e) {
      print('Error getting notification messages: $e');
      return [
        'تم التواصل معك من قبل مكتب حجوزات الطيران',
        'يرجى التواصل مع مكتب الحجوزات لإكمال الحجز',
      ];
    }
  }

  Future<bool> updateNotificationMessages(List<String> messages) async {
    try {
      await _firestore
          .collection('settings')
          .doc('notifications')
          .set({
        'messages': messages,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating notification messages: $e');
      return false;
    }
  }

  Future<Map<String, bool>> getNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'enableNotifications': prefs.getBool('enable_notifications') ?? true,
        'enableWhatsApp': prefs.getBool('enable_whatsapp') ?? true,
        'enableAutoSchedule': prefs.getBool('enable_auto_schedule') ?? false,
      };
    } catch (e) {
      print('Error getting notification settings: $e');
      return {
        'enableNotifications': true,
        'enableWhatsApp': true,
        'enableAutoSchedule': false,
      };
    }
  }

  Future<bool> updateNotificationSettings({
    required bool enableNotifications,
    required bool enableWhatsApp,
    required bool enableAutoSchedule,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('enable_notifications', enableNotifications);
      await prefs.setBool('enable_whatsapp', enableWhatsApp);
      await prefs.setBool('enable_auto_schedule', enableAutoSchedule);
      return true;
    } catch (e) {
      print('Error updating notification settings: $e');
      return false;
    }
  }

  Future<Map<String, int>> getClientStatusSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'newClientDays': prefs.getInt('new_client_days') ?? 1,
        'contactedClientDays': prefs.getInt('contacted_client_days') ?? 30,
        'interestedClientDays': prefs.getInt('interested_client_days') ?? 30,
      };
    } catch (e) {
      print('Error getting client status settings: $e');
      return {
        'newClientDays': 1,
        'contactedClientDays': 30,
        'interestedClientDays': 30,
      };
    }
  }

  Future<bool> updateClientStatusSettings({
    required int newClientDays,
    required int contactedClientDays,
    required int interestedClientDays,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('new_client_days', newClientDays);
      await prefs.setInt('contacted_client_days', contactedClientDays);
      await prefs.setInt('interested_client_days', interestedClientDays);
      return true;
    } catch (e) {
      print('Error updating client status settings: $e');
      return false;
    }
  }

  Future<Map<String, int>> getNotificationLevelSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'firstLevelDays': prefs.getInt('first_level_days') ?? 10,
        'firstLevelRepeat': prefs.getInt('first_level_repeat') ?? 2,
      };
    } catch (e) {
      print('Error getting notification level settings: $e');
      return {
        'firstLevelDays': 10,
        'firstLevelRepeat': 2,
      };
    }
  }

  Future<bool> updateNotificationLevelSettings({
    required int firstLevelDays,
    required int firstLevelRepeat,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('first_level_days', firstLevelDays);
      await prefs.setInt('first_level_repeat', firstLevelRepeat);
      return true;
    } catch (e) {
      print('Error updating notification level settings: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getClientNotifications(String userId, String userRole) async {
    try {
      Query query;
      
      if (userRole == 'admin') {
        query = _firestore
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .limit(50);
      } else {
        query = _firestore
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .limit(50);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  Future<bool> addNotification({
    required String clientId,
    required String clientName,
    required String message,
    required String userId,
    required String type,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'clientId': clientId,
        'clientName': clientName,
        'message': message,
        'userId': userId,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error adding notification: $e');
      return false;
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      return true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
}