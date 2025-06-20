import 'package:flutter/material.dart';

class EmployerNotificationsTab extends StatelessWidget {
  const EmployerNotificationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo notifications
    final notifications = [
      {
        'title': '5 new applicants! 🎉',
        'subtitle': 'Check out the latest applications to your jobs.',
        'icon': Icons.person_add,
        'color': Colors.green,
        'time': '2 min ago',
      },
      {
        'title': 'Job posting expiring soon',
        'subtitle': '"Flutter Developer" closes in 2 days.',
        'icon': Icons.timer,
        'color': Colors.orange,
        'time': '1 hr ago',
      },
      {
        'title': 'Profile updated',
        'subtitle': 'Your company profile changes are live.',
        'icon': Icons.verified,
        'color': Colors.blue,
        'time': 'Yesterday',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications', style: TextStyle(fontSize: 18)))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final notif = notifications[i];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: (notif['color'] as Color).withAlpha(38),
                      child: Icon(notif['icon'] as IconData, color: notif['color'] as Color),
                    ),
                    title: Text(notif['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(notif['subtitle'] as String),
                    trailing: Text(notif['time'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                );
              },
            ),
    );
  }
}
