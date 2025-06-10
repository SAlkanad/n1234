import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  static Future<bool> sendMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Clean phone number (remove spaces, dashes, etc.)
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Add country code if not present (assuming Saudi Arabia +966)
      if (cleanPhone.startsWith('0')) {
        cleanPhone = '966${cleanPhone.substring(1)}';
      } else if (!cleanPhone.startsWith('+') && !cleanPhone.startsWith('966')) {
        cleanPhone = '966$cleanPhone';
      }
      
      // Remove + if present for URL
      if (cleanPhone.startsWith('+')) {
        cleanPhone = cleanPhone.substring(1);
      }

      // Encode message for URL
      String encodedMessage = Uri.encodeComponent(message);
      
      // Create WhatsApp URL
      String whatsappUrl = 'https://wa.me/$cleanPhone?text=$encodedMessage';
      
      // Try to launch WhatsApp
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        return await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        print('Could not launch WhatsApp');
        return false;
      }
    } catch (e) {
      print('Error sending WhatsApp message: $e');
      return false;
    }
  }

  static Future<bool> makeCall(String phoneNumber) async {
    try {
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      if (cleanPhone.startsWith('0')) {
        cleanPhone = '+966${cleanPhone.substring(1)}';
      } else if (!cleanPhone.startsWith('+')) {
        cleanPhone = '+966$cleanPhone';
      }

      String telUrl = 'tel:$cleanPhone';
      
      if (await canLaunchUrl(Uri.parse(telUrl))) {
        return await launchUrl(Uri.parse(telUrl));
      } else {
        print('Could not make call');
        return false;
      }
    } catch (e) {
      print('Error making call: $e');
      return false;
    }
  }

  static Future<bool> sendSMS({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      if (cleanPhone.startsWith('0')) {
        cleanPhone = '+966${cleanPhone.substring(1)}';
      } else if (!cleanPhone.startsWith('+')) {
        cleanPhone = '+966$cleanPhone';
      }

      String encodedMessage = Uri.encodeComponent(message);
      String smsUrl = 'sms:$cleanPhone?body=$encodedMessage';
      
      if (await canLaunchUrl(Uri.parse(smsUrl))) {
        return await launchUrl(Uri.parse(smsUrl));
      } else {
        print('Could not send SMS');
        return false;
      }
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  static String formatPhoneNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.startsWith('966')) {
      cleaned = '0${cleaned.substring(3)}';
    }
    
    if (cleaned.length == 10 && cleaned.startsWith('05')) {
      return '${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6)}';
    }
    
    return phoneNumber;
  }

  static bool isValidSaudiNumber(String phoneNumber) {
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid Saudi mobile number
    if (cleaned.startsWith('966')) {
      cleaned = cleaned.substring(3);
    } else if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }
    
    // Saudi mobile numbers start with 5 and are 9 digits long
    return cleaned.length == 9 && cleaned.startsWith('5');
  }
}