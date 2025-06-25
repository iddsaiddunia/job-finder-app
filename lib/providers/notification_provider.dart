import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:job_finder/models/notification.dart';
import 'package:job_finder/services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<Notification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  Timer? _refreshTimer;
  
  List<Notification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  
  NotificationProvider() {
    // Initial load
    loadNotifications();
    
    // Set up periodic refresh (every 30 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refreshUnreadCount();
    });
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _notifications = await _notificationService.getNotifications();
      _updateUnreadCount();
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> refreshUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      print('Error refreshing unread count: $e');
    }
  }
  
  Future<bool> markAsRead(int notificationId) async {
    final success = await _notificationService.markAsRead(notificationId);
    
    if (success) {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index].isRead = true;
        _updateUnreadCount();
        notifyListeners();
      }
    }
    
    return success;
  }
  
  Future<bool> markAllAsRead() async {
    final success = await _notificationService.markAllAsRead();
    
    if (success) {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
      _unreadCount = 0;
      notifyListeners();
    }
    
    return success;
  }
  
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }
}
