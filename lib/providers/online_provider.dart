import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnlineProvider extends ChangeNotifier {
  final List<String> _onlineUsers = [];
  List<String> get onlineUsers => _onlineUsers;
  RealtimeChannel? _presenceChannel;

  // 1. الدالة النظامية التي يستدعيها ملف main.dart عند تشغيل التطبيق
  void initPresence() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // إنشاء القناة وتحديد اسم الغرفة أو القناة العامة
    _presenceChannel = Supabase.instance.client.channel('online_users');
    
    listenToPresence(_presenceChannel!);
  }

  // 2. الطريقة القياسية المعتمدة رسميًا في توثيق Supabase Flutter للـ Presence
  void listenToPresence(RealtimeChannel channel) {
    channel.onPresenceSync((payload) {
      _onlineUsers.clear();
      
      // جلب الحالات القياسية المرجعة من الحزمة
      final List<Presence> states = channel.presenceState();
      
      for (var state in states) {
        // قراءة الـ user_id النظامي المخزن داخل خريطة الـ payload للكائن
        final userId = state.payload['user_id'];
        if (userId != null) {
          _onlineUsers.add(userId.toString());
        }
      }
      notifyListeners();
    }).subscribe((status, [error]) {
      // التحقق القياسي من حالة الاشتراك عبر الـ Enum الرسمي RealtimeStatus
      if (status == RealtimeStatus.subscribed) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          // تسجيل وتتبع المستخدم الحالي في قاعدة البيانات اللحظية
          _presenceChannel?.track({'user_id': user.id});
        }
      }
    });
  }

  // 3. الدالة النظامية التي تطلبها شاشة chat_list_screen.dart لفحص حالة اتصال المستخدم
  bool isUserOnline(String userId) {
    return _onlineUsers.contains(userId);
  }

  @override
  void dispose() {
    _presenceChannel?.unsubscribe();
    super.dispose();
  }
}
