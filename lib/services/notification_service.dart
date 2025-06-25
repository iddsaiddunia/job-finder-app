import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job_finder/models/notification.dart';
import 'package:job_finder/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  
  // Get all notifications for the current user
  Future<List<Notification>> getNotifications() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/notifications/');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Notification.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }
  
  // Mark a notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/notifications/$notificationId/read/');
      final headers = await _getHeaders();
      
      final response = await http.post(url, headers: headers);
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
  
  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/notifications/mark-all-read/');
      final headers = await _getHeaders();
      
      final response = await http.post(url, headers: headers);
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }
  
  // Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/notifications/count/');
      final headers = await _getHeaders();
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['unread_count'] ?? 0;
      } else {
        throw Exception('Failed to get unread count: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
  
  // Helper method to get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
