import 'package:flutter/material.dart';
import '../../setup_initial_data.dart';

class DatabaseDebugScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Database Management')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  await DatabaseSetup.setupCompleteDatabase();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Database setup completed')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Setup failed: $e')),
                  );
                }
              },
              child: Text('Setup Database'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Reset Database'),
                    content: Text('This will delete all data. Continue?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Reset'),
                      ),
                    ],
                  ),
                );
                
                if (confirmed == true) {
                  try {
                    await DatabaseSetup.resetDatabase();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Database reset completed')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reset failed: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Reset Database'),
            ),
          ],
        ),
      ),
    );
  }
}
