import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_finder/models/notification.dart' as app_notification;
import 'package:job_finder/providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationProvider _notificationProvider;

  @override
  void initState() {
    super.initState();
    // Access the provider but don't listen yet
    _notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    // Load notifications when the screen is first shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationProvider.loadNotifications();
    });
  }

  Future<void> _markAsRead(int notificationId) async {
    await _notificationProvider.markAsRead(notificationId);
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'application':
        return Colors.blue;
      case 'job_match':
        return Colors.green;
      case 'candidate_match':
        return Colors.purple;
      case 'application_status':
        return Colors.orange;
      case 'interview':
        return Colors.red;
      case 'feedback':
        return Colors.teal;
      case 'message':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'application':
        return Icons.description;
      case 'job_match':
        return Icons.work;
      case 'candidate_match':
        return Icons.person;
      case 'application_status':
        return Icons.update;
      case 'interview':
        return Icons.calendar_today;
      case 'feedback':
        return Icons.star;
      case 'message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }
  
  void _handleNotificationTap(app_notification.Notification notification) {
    // Navigate based on notification type and related object
    switch (notification.type) {
      case 'application':
        if (notification.relatedObjectId != null) {
          // Navigate to application details
          // Navigator.push(context, MaterialPageRoute(builder: (_) => ApplicationDetailsScreen(applicationId: notification.relatedObjectId!)));
        }
        break;
      case 'job_match':
        if (notification.relatedObjectId != null) {
          // Navigate to job details
          // Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetailsScreen(jobId: notification.relatedObjectId!)));
        }
        break;
      case 'candidate_match':
        if (notification.relatedObjectId != null) {
          // Navigate to job's candidate list
          // Navigator.push(context, MaterialPageRoute(builder: (_) => ApplicantListScreen(jobId: notification.relatedObjectId!)));
        }
        break;
      // Add more cases as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final notifications = provider.notifications;
        final isLoading = provider.isLoading;
        
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Notifications'),
            actions: [
              if (notifications.any((n) => !n.isRead))
                IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Mark all as read',
                  onPressed: () async {
                    await Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All notifications marked as read')),
                      );
                    }
                  },
                ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: () => provider.loadNotifications(),
              ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No notifications yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => provider.loadNotifications(),
                      child: ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Dismissible(
                            key: Key('notification_${notification.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              // Mark as read when dismissed
                              await _markAsRead(notification.id);
                              return false; // Don't actually remove from list
                            },
                            child: Card(
                              elevation: notification.isRead ? 1 : 3,
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getNotificationColor(notification.type),
                                  child: Icon(_getNotificationIcon(notification.type), color: Colors.white),
                                ),
                                title: Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(notification.message),
                                    const SizedBox(height: 4),
                                    Text(
                                      notification.createdAtFormatted,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: notification.isRead
                                    ? null
                                    : Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                onTap: () {
                                  if (!notification.isRead) {
                                    _markAsRead(notification.id);
                                  }
                                  _handleNotificationTap(notification);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        );
      },
    );
  }
}
