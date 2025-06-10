import 'package:flutter/material.dart';
import '../../models/client_model.dart';
import '../../services/whatsapp_service.dart';
import 'status_card.dart';

class ClientCard extends StatelessWidget {
  final ClientModel client;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(ClientStatus)? onStatusChange;

  const ClientCard({
    Key? key,
    required this.client,
    this.onEdit,
    this.onDelete,
    this.onStatusChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    client.clientName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                StatusCard(
                  status: client.status,
                  daysRemaining: client.daysRemaining,
                ),
              ],
            ),
            SizedBox(height: 8),
            if (client.clientPhone.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('الهاتف: ${client.clientPhone}'),
                ],
              ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.card_membership, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('نوع التأشيرة: ${_getVisaTypeText(client.visaType)}'),
              ],
            ),
            if (client.agentName != null && client.agentName!.isNotEmpty) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.support_agent, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('الوكيل: ${client.agentName}'),
                ],
              ),
            ],
            SizedBox(height: 12),
            Row(
              children: [
                if (!client.hasExited && client.clientPhone.isNotEmpty) ...[
                  IconButton(
                    icon: Icon(Icons.message, color: Colors.green),
                    onPressed: () => _sendWhatsApp(context),
                    tooltip: 'إرسال واتساب',
                  ),
                  IconButton(
                    icon: Icon(Icons.call, color: Colors.blue),
                    onPressed: () => _makeCall(),
                    tooltip: 'اتصال',
                  ),
                ],
                Spacer(),
                if (onEdit != null)
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.orange),
                    onPressed: onEdit,
                    tooltip: 'تعديل',
                  ),
                if (onStatusChange != null && !client.hasExited)
                  IconButton(
                    icon: Icon(Icons.exit_to_app, color: Colors.grey),
                    onPressed: () => onStatusChange!(ClientStatus.white),
                    tooltip: 'تحديد كخارج',
                  ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context),
                    tooltip: 'حذف',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getVisaTypeText(VisaType type) {
    switch (type) {
      case VisaType.visit:
        return 'زيارة';
      case VisaType.work:
        return 'عمل';
      case VisaType.umrah:
        return 'عمرة';
      case VisaType.hajj:
        return 'حج';
    }
  }

  void _sendWhatsApp(BuildContext context) async {
    try {
      await WhatsAppService.sendClientMessage(
        phoneNumber: client.clientPhone,
        country: client.phoneCountry,
        message: 'عزيزي العميل {clientName}، تنتهي صلاحية تأشيرتك قريباً.',
        clientName: client.clientName,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في فتح الواتساب: ${e.toString()}')),
      );
    }
  }

  void _makeCall() async {
    try {
      await WhatsAppService.callClient(
        phoneNumber: client.clientPhone,
        country: client.phoneCountry,
      );
    } catch (e) {
      // Handle error silently or show message
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف هذا العميل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
