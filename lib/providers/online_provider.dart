import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnlineProvider extends ChangeNotifier {
  final List<String> _onlineUsers = [];
  List<String> get onlineUsers => _onlineUsers;
  RealtimeChannel? _presenceChannel;

  // 1. الدالة التي يطلبها ملف main.dart
  void initPresence() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // إنشاء القناة واستهداف الـ presence
    _presenceChannel = Supabase.instance.client.channel('online_users');
    
    listenToPresence(_presenceChannel!);
  }

  // 2. دالة الاستماع والمزامنة بدون استخدام الكلاسات المفقودة
  void listenToPresence(RealtimeChannel channel) {
    // استخدمنا طريقة التمرير الديناميكي للأحداث بنصوص صريحة لتفادي مشاكل الحزم
    (channel as dynamic).on(
      'presence',
      {'event': 'sync'},
      (payload, [ref]) {
        _onlineUsers.clear();
        
        try {
          final List<dynamic> states = channel.presenceState();
          
          for (var state in states) {
            if (state is Map) {
              final userId = state['user_id'];
              if (userId != null) _onlineUsers.add(userId.toString());
            } else {
              // محاولة قراءة الـ payload في حال كان الكائن يمرر بصيغة مخصصة
              final dynamic payloadData = (state as dynamic).payload;
              if (payloadData != null && payloadData['user_id'] != null) {
                _onlineUsers.add(payloadData['user_id'].toString());
              }
            }
          }
        } catch (e) {
          debugPrint('Error parsing presence: $e');
        }
        
        notifyListeners();
      },
    );

    // الاشتراك في القناة وتتبع المستخدم الحالي
    channel.subscribe((status, [error]) {
      // قراءة حالة الاشتراك بنصها الصريح لضمان الأمان والتوافق
      if (status.toString().contains('SUBSCRIBED') || status.name.toUpperCase() == 'SUBSCRIBED') {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          _presenceChannel?.track({'user_id': user.id});
        }
      }
    });
  }

  // 3. الدالة التي تطلبها شاشة الدردشات chat_list_screen.dart
  bool isUserOnline(String userId) {
    return _onlineUsers.contains(userId);
  }

  @override
  void dispose() {
    _presenceChannel?.unsubscribe();
    super.dispose();
  }
}
