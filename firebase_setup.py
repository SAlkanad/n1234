import firebase_admin
from firebase_admin import credentials, firestore
import hashlib
import time
from datetime import datetime, timedelta
from typing import Dict, Any

class DatabaseSetup:
    def __init__(self, service_account_path: str = None):
        """
        Initialize Firebase connection
        
        Args:
            service_account_path: Path to service account JSON file
                                If None, uses default credentials or environment variables
        """
        if not firebase_admin._apps:
            if service_account_path:
                cred = credentials.Certificate(service_account_path)
                firebase_admin.initialize_app(cred)
            else:
                # Use default credentials (set GOOGLE_APPLICATION_CREDENTIALS env var)
                firebase_admin.initialize_app()
        
        self.db = firestore.client()
    
    @staticmethod
    def _hash_password(password: str) -> str:
        """Hash password using SHA-256"""
        return hashlib.sha256(password.encode()).hexdigest()
    
    async def is_already_setup(self) -> bool:
        """Check if database is already initialized"""
        try:
            admin_ref = self.db.collection('users').document('admin001')
            doc = admin_ref.get()
            return doc.exists
        except Exception as e:
            print(f"Error checking setup status: {e}")
            return False
    
    def setup_complete_database(self):
        """Setup the complete database with all collections"""
        try:
            # Check if already setup
            admin_ref = self.db.collection('users').document('admin001')
            if admin_ref.get().exists:
                print('✅ Database already initialized')
                return
            
            print('🚀 Starting database initialization...')
            
            # Setup admin user
            self._setup_admin_user()
            
            # Setup default settings
            self._setup_admin_settings()
            
            # Setup sample users for testing
            self._setup_sample_users()
            
            # Setup sample clients for testing
            self._setup_sample_clients()
            
            # Setup sample notifications
            self._setup_sample_notifications()
            
            print('✅ Database initialization completed successfully!')
            print('📱 Login credentials:')
            print('   Admin: admin / admin123')
            print('   User: testuser / test123')
            print('   Agency: testagency / test123')
            
        except Exception as e:
            print(f'❌ Database setup failed: {e}')
            raise
    
    def _setup_admin_user(self):
        """Create admin user"""
        print('👤 Creating admin user...')
        
        admin_data = {
            "id": "admin001",
            "username": "admin",
            "password": self._hash_password("admin123"),
            "role": "admin",
            "name": "المدير العام",
            "phone": "966501234567",
            "email": "admin@example.com",
            "isActive": True,
            "isFrozen": False,
            "createdAt": int(time.time() * 1000),
            "createdBy": "system"
        }
        
        self.db.collection('users').document('admin001').set(admin_data)
    
    def _setup_admin_settings(self):
        """Setup default admin configurations"""
        print('⚙️ Setting up default configurations...')
        
        settings_data = {
            "clientStatusSettings": {
                "greenDays": 30,
                "yellowDays": 30,
                "redDays": 1
            },
            "clientNotificationSettings": {
                "firstTier": {
                    "days": 10,
                    "frequency": 2,
                    "message": "تنبيه: تنتهي تأشيرة العميل {clientName} خلال 10 أيام"
                },
                "secondTier": {
                    "days": 5,
                    "frequency": 4,
                    "message": "تحذير: تنتهي تأشيرة العميل {clientName} خلال 5 أيام"
                },
                "thirdTier": {
                    "days": 2,
                    "frequency": 8,
                    "message": "عاجل: تنتهي تأشيرة العميل {clientName} خلال يومين"
                }
            },
            "userNotificationSettings": {
                "firstTier": {
                    "days": 10,
                    "frequency": 1,
                    "message": "تنبيه: ينتهي حسابك خلال 10 أيام"
                },
                "secondTier": {
                    "days": 5,
                    "frequency": 1,
                    "message": "تحذير: ينتهي حسابك خلال 5 أيام"
                },
                "thirdTier": {
                    "days": 2,
                    "frequency": 1,
                    "message": "عاجل: ينتهي حسابك خلال يومين"
                }
            },
            "whatsappMessages": {
                "clientMessage": "عزيزي العميل {clientName}، تنتهي صلاحية تأشيرتك قريباً. يرجى التواصل معنا.",
                "userMessage": "تنبيه: ينتهي حسابك قريباً. يرجى التجديد."
            },
            "systemSettings": {
                "autoFreeze": True,
                "notificationsEnabled": True,
                "backgroundServiceEnabled": True,
                "lastUpdated": int(time.time() * 1000)
            }
        }
        
        self.db.collection('adminSettings').document('config').set(settings_data)
    
    def _setup_sample_users(self):
        """Create sample users for testing"""
        print('👥 Creating sample users for testing...')
        
        now = datetime.now()
        validation_end = now + timedelta(days=90)
        now_ms = int(now.timestamp() * 1000)
        validation_end_ms = int(validation_end.timestamp() * 1000)
        
        # Sample regular user
        user_data = {
            "id": "user001",
            "username": "testuser",
            "password": self._hash_password("test123"),
            "role": "user",
            "name": "محمد أحمد",
            "phone": "966551234567",
            "email": "user@example.com",
            "isActive": True,
            "isFrozen": False,
            "validationEndDate": validation_end_ms,
            "createdAt": now_ms,
            "createdBy": "admin001"
        }
        
        self.db.collection('users').document('user001').set(user_data)
        
        # Sample agency user
        agency_data = {
            "id": "agency001",
            "username": "testagency",
            "password": self._hash_password("test123"),
            "role": "agency",
            "name": "وكالة النور للسفر",
            "phone": "966551234568",
            "email": "agency@example.com",
            "isActive": True,
            "isFrozen": False,
            "validationEndDate": validation_end_ms,
            "createdAt": now_ms,
            "createdBy": "admin001"
        }
        
        self.db.collection('users').document('agency001').set(agency_data)
    
    def _setup_sample_clients(self):
        """Create sample clients for testing"""
        print('📋 Creating sample clients for testing...')
        
        now = datetime.now()
        entry_date = now - timedelta(days=20)  # 70 days remaining
        critical_entry_date = now - timedelta(days=87)  # 3 days remaining
        now_ms = int(now.timestamp() * 1000)
        
        # Sample client with good status
        client1_data = {
            "id": "client001",
            "clientName": "عبدالله محمد السعدي",
            "clientPhone": "966551111111",
            "phoneCountry": "saudi",
            "visaType": "umrah",
            "agentName": "أحمد الوكيل",
            "agentPhone": "966552222222",
            "entryDate": int(entry_date.timestamp() * 1000),
            "notes": "عميل مميز - تجديد التأشيرة",
            "status": "green",
            "daysRemaining": 70,
            "hasExited": False,
            "createdBy": "user001",
            "createdAt": now_ms,
            "updatedAt": now_ms
        }
        
        self.db.collection('clients').document('client001').set(client1_data)
        
        # Sample client with critical status
        client2_data = {
            "id": "client002",
            "clientName": "فاطمة أحمد اليمني",
            "clientPhone": "967771111111",
            "phoneCountry": "yemen",
            "visaType": "visit",
            "agentName": "",
            "agentPhone": "",
            "entryDate": int(critical_entry_date.timestamp() * 1000),
            "notes": "تحتاج متابعة عاجلة",
            "status": "red",
            "daysRemaining": 3,
            "hasExited": False,
            "createdBy": "agency001",
            "createdAt": now_ms,
            "updatedAt": now_ms
        }
        
        self.db.collection('clients').document('client002').set(client2_data)
        
        # Sample exited client
        client3_data = {
            "id": "client003",
            "clientName": "سعد عبدالرحمن",
            "clientPhone": "966553333333",
            "phoneCountry": "saudi",
            "visaType": "hajj",
            "agentName": "مكتب الرحمة",
            "agentPhone": "966554444444",
            "entryDate": int((now - timedelta(days=30)).timestamp() * 1000),
            "notes": "أكمل الحج بنجاح",
            "status": "white",
            "daysRemaining": 60,
            "hasExited": True,
            "createdBy": "user001",
            "createdAt": now_ms,
            "updatedAt": now_ms
        }
        
        self.db.collection('clients').document('client003').set(client3_data)
    
    def _setup_sample_notifications(self):
        """Create sample notifications for testing"""
        print('📊 Setting up sample notifications...')
        
        now_ms = int(time.time() * 1000)
        
        # Client expiring notification
        notif1_data = {
            "id": "notif001",
            "type": "clientExpiring",
            "title": "تنبيه انتهاء تأشيرة",
            "message": "تنتهي تأشيرة العميل فاطمة أحمد اليمني خلال 3 أيام",
            "targetUserId": "agency001",
            "clientId": "client002",
            "isRead": False,
            "priority": "high",
            "createdAt": now_ms
        }
        
        self.db.collection('notifications').document('notif001').set(notif1_data)
        
        # User validation expiring notification
        notif2_data = {
            "id": "notif002",
            "type": "userValidationExpiring",
            "title": "تنبيه انتهاء صلاحية الحساب",
            "message": "ينتهي حسابك خلال 90 يوم",
            "targetUserId": "user001",
            "isRead": False,
            "priority": "low",
            "createdAt": now_ms
        }
        
        self.db.collection('notifications').document('notif002').set(notif2_data)
    
    def reset_database(self):
        """Reset database by deleting all documents"""
        print('🗑️ Resetting database...')
        
        try:
            collections = ['users', 'clients', 'notifications', 'adminSettings', 'userSettings']
            
            for collection_name in collections:
                docs = self.db.collection(collection_name).stream()
                for doc in docs:
                    doc.reference.delete()
            
            print('✅ Database reset completed')
            
            # Re-setup after reset
            self.setup_complete_database()
            
        except Exception as e:
            print(f'❌ Database reset failed: {e}')
            raise


def main():
    """Main function to run the database setup"""
    # Use the service account file in the same directory
    setup = DatabaseSetup('umrah-visa-manager-50d91-firebase-adminsdk-fbsvc-2384544386.json')
    
    # Setup the database
    setup.setup_complete_database()
    
    # Uncomment to reset database (use with caution!)
    # setup.reset_database()


if __name__ == "__main__":
    main()