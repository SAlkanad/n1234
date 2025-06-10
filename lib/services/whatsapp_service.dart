import 'package:url_launcher/url_launcher.dart';
import '../models/client_model.dart';

class WhatsAppService {
  static Future<void> sendClientMessage({
    required String phoneNumber,
    required PhoneCountry country,
    required String message,
    required String clientName,
  }) async {
    final countryCode = country == PhoneCountry.saudi ? '966' : '967';
    final formattedMessage = message.replaceAll('{clientName}', clientName);
    final encodedMessage = Uri.encodeComponent(formattedMessage);
    final url = 'https://wa.me/$countryCode$phoneNumber?text=$encodedMessage';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'لا يمكن فتح الواتساب';
    }
  }

  static Future<void> sendUserMessage({
    required String phoneNumber,
    required String message,
    required String userName,
  }) async {
    // Remove country code if present
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'^(\+966|\+967|966|967)'), '');
    
    // Determine country based on phone pattern
    String countryCode = '966'; // Default to Saudi
    if (cleanPhone.startsWith('7')) {
      countryCode = '967'; // Yemen
    }
    
    final formattedMessage = message.replaceAll('{userName}', userName);
    final encodedMessage = Uri.encodeComponent(formattedMessage);
    final url = 'https://wa.me/$countryCode$cleanPhone?text=$encodedMessage';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'لا يمكن فتح الواتساب';
    }
  }

  static Future<void> callClient({
    required String phoneNumber,
    required PhoneCountry country,
  }) async {
    final countryCode = country == PhoneCountry.saudi ? '966' : '967';
    final url = 'tel:+$countryCode$phoneNumber';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'لا يمكن إجراء المكالمة';
    }
  }

  static Future<void> callUser({
    required String phoneNumber,
  }) async {
    // Remove country code if present
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'^(\+966|\+967|966|967)'), '');
    
    // Determine country based on phone pattern
    String countryCode = '966'; // Default to Saudi
    if (cleanPhone.startsWith('7')) {
      countryCode = '967'; // Yemen
    }
    
    final url = 'tel:+$countryCode$cleanPhone';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'لا يمكن إجراء المكالمة';
    }
  }
}
