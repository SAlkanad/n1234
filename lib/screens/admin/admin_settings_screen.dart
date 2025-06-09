import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/settings_controller.dart';
import '../../core/widgets/custom_text_field.dart';

class AdminSettingsScreen extends StatefulWidget {
  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Status Settings Controllers
  final _greenDaysController = TextEditingController();
  final _yellowDaysController = TextEditingController();
  final _redDaysController = TextEditingController();
  
  // Client Notification Controllers
  final _clientTier1DaysController = TextEditingController();
  final _clientTier1FreqController = TextEditingController();
  final _clientTier1MessageController = TextEditingController();
  final _clientTier2DaysController = TextEditingController();
  final _clientTier2FreqController = TextEditingController();
  final _clientTier2MessageController = TextEditingController();
  final _clientTier3DaysController = TextEditingController();
  final _clientTier3FreqController = TextEditingController();
  final _clientTier3MessageController = TextEditingController();
  
  // User Notification Controllers
  final _userTier1DaysController = TextEditingController();
  final _userTier1FreqController = TextEditingController();
  final _userTier1MessageController = TextEditingController();
  final _userTier2DaysController = TextEditingController();
  final _userTier2FreqController = TextEditingController();
  final _userTier2MessageController = TextEditingController();
  final _userTier3DaysController = TextEditingController();
  final _userTier3FreqController = TextEditingController();
  final _userTier3MessageController = TextEditingController();
  
  // WhatsApp Message Controllers
  final _clientWhatsappController = TextEditingController();
  final _userWhatsappController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    final settingsController = Provider.of<SettingsController>(context, listen: false);
    await settingsController.loadAdminSettings();
    _populateFields();
  }

  void _populateFields() {
    final settings = Provider.of<SettingsController>(context, listen: false).adminSettings;
    
    // Status Settings
    final statusSettings = settings['clientStatusSettings'] ?? {};
    _greenDaysController.text = (statusSettings['greenDays'] ?? 30).toString();
    _yellowDaysController.text = (statusSettings['yellowDays'] ?? 30).toString();
    _redDaysController.text = (statusSettings['redDays'] ?? 1).toString();
    
    // Client Notification Settings
    final clientSettings = settings['clientNotificationSettings'] ?? {};
    final clientTier1 = clientSettings['firstTier'] ?? {};
    final clientTier2 = clientSettings['secondTier'] ?? {};
    final clientTier3 = clientSettings['thirdTier'] ?? {};
    
    _clientTier1DaysController.text = (clientTier1['days'] ?? 10).toString();
    _clientTier1FreqController.text = (clientTier1['frequency'] ?? 2).toString();
    _clientTier1MessageController.text = clientTier1['message'] ?? 'تنبيه: تنتهي تأشيرة العميل {clientName} خلال 10 أيام';
    
    _clientTier2DaysController.text = (clientTier2['days'] ?? 5).toString();
    _clientTier2FreqController.text = (clientTier2['frequency'] ?? 4).toString();
    _clientTier2MessageController.text = clientTier2['message'] ?? 'تحذير: تنتهي تأشيرة العميل {clientName} خلال 5 أيام';
    
    _clientTier3DaysController.text = (clientTier3['days'] ?? 2).toString();
    _clientTier3FreqController.text = (clientTier3['frequency'] ?? 8).toString();
    _clientTier3MessageController.text = clientTier3['message'] ?? 'عاجل: تنتهي تأشيرة العميل {clientName} خلال يومين';
    
    // User Notification Settings
    final userSettings = settings['userNotificationSettings'] ?? {};
    final userTier1 = userSettings['firstTier'] ?? {};
    final userTier2 = userSettings['secondTier'] ?? {};
    final userTier3 = userSettings['thirdTier'] ?? {};
    
    _userTier1DaysController.text = (userTier1['days'] ?? 10).toString();
    _userTier1FreqController.text = (userTier1['frequency'] ?? 1).toString();
    _userTier1MessageController.text = userTier1['message'] ?? 'تنبيه: ينتهي حسابك خلال 10 أيام';
    
    _userTier2DaysController.text = (userTier2['days'] ?? 5).toString();
    _userTier2FreqController.text = (userTier2['frequency'] ?? 1).toString();
    _userTier2MessageController.text = userTier2['message'] ?? 'تحذير: ينتهي حسابك خلال 5 أيام';
    
    _userTier3DaysController.text = (userTier3['days'] ?? 2).toString();
    _userTier3FreqController.text = (userTier3['frequency'] ?? 1).toString();
    _userTier3MessageController.text = userTier3['message'] ?? 'عاجل: ينتهي حسابك خلال يومين';
    
    // WhatsApp Messages
    final whatsappMessages = settings['whatsappMessages'] ?? {};
    _clientWhatsappController.text = whatsappMessages['clientMessage'] ?? 'عزيزي العميل {clientName}، تنتهي صلاحية تأشيرتك قريباً.';
    _userWhatsappController.text = whatsappMessages['userMessage'] ?? 'تنبيه: ينتهي حسابك قريباً. يرجى التجديد.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إعدادات النظام'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: Consumer<SettingsController>(
        builder: (context, settingsController, child) {
          if (settingsController.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatusSettingsCard(),
                  SizedBox(height: 16),
                  _buildClientNotificationCard(),
                  SizedBox(height: 16),
                  _buildUserNotificationCard(),
                  SizedBox(height: 16),
                  _buildWhatsappMessagesCard(),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('حفظ جميع الإعدادات', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusSettingsCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إعدادات حالة العملاء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _greenDaysController,
                    label: 'أيام الحالة الخضراء',
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'مطلوب' : null,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: CustomTextField(
                    controller: _yellowDaysController,
                    label: 'أيام الحالة الصفراء',
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'مطلوب' : null,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: CustomTextField(
                    controller: _redDaysController,
                    label: 'أيام الحالة الحمراء',
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty ? 'مطلوب' : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientNotificationCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إعدادات إشعارات العملاء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildNotificationTier('المستوى الأول', _clientTier1DaysController, _clientTier1FreqController, _clientTier1MessageController),
            SizedBox(height: 16),
            _buildNotificationTier('المستوى الثاني', _clientTier2DaysController, _clientTier2FreqController, _clientTier2MessageController),
            SizedBox(height: 16),
            _buildNotificationTier('المستوى الثالث', _clientTier3DaysController, _clientTier3FreqController, _clientTier3MessageController),
          ],
        ),
      ),
    );
  }

  Widget _buildUserNotificationCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إعدادات إشعارات المستخدمين', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildNotificationTier('المستوى الأول', _userTier1DaysController, _userTier1FreqController, _userTier1MessageController),
            SizedBox(height: 16),
            _buildNotificationTier('المستوى الثاني', _userTier2DaysController, _userTier2FreqController, _userTier2MessageController),
            SizedBox(height: 16),
            _buildNotificationTier('المستوى الثالث', _userTier3DaysController, _userTier3FreqController, _userTier3MessageController),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTier(String title, TextEditingController daysController, TextEditingController freqController, TextEditingController messageController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: daysController,
                label: 'الأيام',
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'مطلوب' : null,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: CustomTextField(
                controller: freqController,
                label: 'التكرار يومياً',
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'مطلوب' : null,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        CustomTextField(
          controller: messageController,
          label: 'نص الرسالة',
          maxLines: 2,
          validator: (value) => value == null || value.isEmpty ? 'مطلوب' : null,
        ),
      ],
    );
  }

  Widget _buildWhatsappMessagesCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('رسائل الواتساب الافتراضية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            CustomTextField(
              controller: _clientWhatsappController,
              label: 'رسالة العملاء',
              maxLines: 3,
              validator: (value) => value == null || value.isEmpty ? 'مطلوب' : null,
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _userWhatsappController,
              label: 'رسالة المستخدمين',
              maxLines: 3,
              validator: (value) => value == null || value.isEmpty ? 'مطلوب' : null,
            ),
            SizedBox(height: 8),
            Text(
              'يمكن استخدام {clientName} أو {userName} في الرسائل',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      try {
        final settingsController = Provider.of<SettingsController>(context, listen: false);
        
        final settings = {
          'clientStatusSettings': {
            'greenDays': int.parse(_greenDaysController.text),
            'yellowDays': int.parse(_yellowDaysController.text),
            'redDays': int.parse(_redDaysController.text),
          },
          'clientNotificationSettings': {
            'firstTier': {
              'days': int.parse(_clientTier1DaysController.text),
              'frequency': int.parse(_clientTier1FreqController.text),
              'message': _clientTier1MessageController.text,
            },
            'secondTier': {
              'days': int.parse(_clientTier2DaysController.text),
              'frequency': int.parse(_clientTier2FreqController.text),
              'message': _clientTier2MessageController.text,
            },
            'thirdTier': {
              'days': int.parse(_clientTier3DaysController.text),
              'frequency': int.parse(_clientTier3FreqController.text),
              'message': _clientTier3MessageController.text,
            },
          },
          'userNotificationSettings': {
            'firstTier': {
              'days': int.parse(_userTier1DaysController.text),
              'frequency': int.parse(_userTier1FreqController.text),
              'message': _userTier1MessageController.text,
            },
            'secondTier': {
              'days': int.parse(_userTier2DaysController.text),
              'frequency': int.parse(_userTier2FreqController.text),
              'message': _userTier2MessageController.text,
            },
            'thirdTier': {
              'days': int.parse(_userTier3DaysController.text),
              'frequency': int.parse(_userTier3FreqController.text),
              'message': _userTier3MessageController.text,
            },
          },
          'whatsappMessages': {
            'clientMessage': _clientWhatsappController.text,
            'userMessage': _userWhatsappController.text,
          },
        };

        await settingsController.updateAdminSettings(settings);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حفظ الإعدادات بنجاح')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في حفظ الإعدادات: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _greenDaysController.dispose();
    _yellowDaysController.dispose();
    _redDaysController.dispose();
    _clientTier1DaysController.dispose();
    _clientTier1FreqController.dispose();
    _clientTier1MessageController.dispose();
    _clientTier2DaysController.dispose();
    _clientTier2FreqController.dispose();
    _clientTier2MessageController.dispose();
    _clientTier3DaysController.dispose();
    _clientTier3FreqController.dispose();
    _clientTier3MessageController.dispose();
    _userTier1DaysController.dispose();
    _userTier1FreqController.dispose();
    _userTier1MessageController.dispose();
    _userTier2DaysController.dispose();
    _userTier2FreqController.dispose();
    _userTier2MessageController.dispose();
    _userTier3DaysController.dispose();
    _userTier3FreqController.dispose();
    _userTier3MessageController.dispose();
    _clientWhatsappController.dispose();
    _userWhatsappController.dispose();
    super.dispose();
  }
}
