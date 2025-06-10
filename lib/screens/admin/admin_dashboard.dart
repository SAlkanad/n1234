import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/client_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../core/widgets/notification_dropdown.dart';

class UserDashboard extends StatefulWidget {
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final clientController = Provider.of<ClientController>(context, listen: false);
    final notificationController = Provider.of<NotificationController>(context, listen: false);

    try {
      await Future.wait([
        clientController.loadClients(authController.currentUser!.id),
        notificationController.loadNotifications(authController.currentUser!.id),
      ]);
    } catch (e) {
      print('Error loading dashboard data: $e');
    }
  }

  Future<void> _syncData() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);

    try {
      await _loadDashboardData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث البيانات بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحديث البيانات: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة تحكم المستخدم'),
        actions: [
          NotificationDropdown(),
          IconButton(
            icon: _isSyncing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.sync),
            onPressed: _isSyncing ? null : _syncData,
            tooltip: 'تحديث البيانات',
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthController>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _syncData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(user!),
              SizedBox(height: 16),
              _buildUserStatusCard(user),
              SizedBox(height: 24),
              _buildStatsCards(),
              SizedBox(height: 24),
              _buildDashboardGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً بك',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 4),
          Text(
            user.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _getRoleText(user.role),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatusCard(user) {
    final isValid = user.validationEndDate == null || 
                   user.validationEndDate!.isAfter(DateTime.now());
    final daysRemaining = user.validationEndDate?.difference(DateTime.now()).inDays ?? 0;

    Color statusColor = isValid ? Colors.green : Colors.red;
    String statusText = isValid ? 'نشط' : 'منتهي الصلاحية';
    
    if (user.isFrozen) {
      statusColor = Colors.orange;
      statusText = 'مجمد';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            user.isFrozen 
                ? Icons.block 
                : isValid 
                    ? Icons.check_circle 
                    : Icons.warning,
            color: statusColor,
            size: 32,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حالة الحساب: $statusText',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                if (isValid && !user.isFrozen && daysRemaining > 0)
                  Text(
                    'ينتهي خلال $daysRemaining يوم',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (user.isFrozen && user.freezeReason != null)
                  Text(
                    'السبب: ${user.freezeReason}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Consumer<ClientController>(
      builder: (context, clientController, child) {
        return Container(
          height: 100,
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'العملاء',
                  clientController.getClientsCount().toString(),
                  Icons.people,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'نشط',
                  clientController.getActiveClientsCount().toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'تحذيرات',
                  clientController.getRedClients().length.toString(),
                  Icons.warning,
                  Colors.red,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Consumer<NotificationController>(
                  builder: (context, notificationController, child) {
                    return _buildStatCard(
                      'إشعارات',
                      notificationController.getUnreadCount().toString(),
                      Icons.notifications,
                      Colors.orange,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildDashboardCard(
          title: 'إدخال العملاء',
          icon: Icons.person_add,
          color: Colors.green,
          onTap: () => Navigator.pushNamed(context, '/user/add_client').then((_) => _loadDashboardData()),
        ),
        _buildDashboardCard(
          title: 'إدارة العملاء',
          icon: Icons.people,
          color: Colors.blue,
          onTap: () => Navigator.pushNamed(context, '/user/manage_clients'),
        ),
        _buildDashboardCard(
          title: 'الاشعارات',
          icon: Icons.notifications,
          color: Colors.red,
          onTap: () => Navigator.pushNamed(context, '/user/notifications'),
        ),
        _buildDashboardCard(
          title: 'الاعدادات',
          icon: Icons.settings,
          color: Colors.purple,
          onTap: () => Navigator.pushNamed(context, '/user/settings'),
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleText(role) {
    switch (role.toString()) {
      case 'UserRole.admin':
        return 'مدير';
      case 'UserRole.agency':
        return 'وكالة';
      case 'UserRole.user':
        return 'مستخدم';
      default:
        return 'مستخدم';
    }
  }
}