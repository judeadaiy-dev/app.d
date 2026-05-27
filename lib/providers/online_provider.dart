import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnlineProvider extends ChangeNotifier {
  final List<String> _onlineUsers = [];
  List<String> get onlineUsers => _onlineUsers;

  void listenToPresence(RealtimeChannel channel) {
    channel.onRealtimeStatusChanged((status) {
      // الاستخدام المتوافق والمثالي مع حزمتك
      if (status == RealtimeStatus.subscribed) {
        debugPrint('تم الاتصال بالـ Presence بنجاح');
      }
    });

    channel.onPresenceSync((payload) {
      _onlineUsers.clear();

      // جلب الحالات بطريقة ديناميكية آمنة 100% لتفادي مشاكل المسميات الداخلية للـ Getters
      final Map<String, List<dynamic>> states = channel.presenceState();

      states.forEach((key, value) {
        for (var item in value) {
          if (item is Map && item['user_id']!= null) {
            _onlineUsers.add(item['user_id'].toString());
          } else if (item is Presence) {
            // حل احتياطي في حال كان الكائن يمرر كـ Presence object
            final userId = item.payload?['user_id']?? key;
            _onlineUsers.add(userId.toString());
          }
        }
      });

      notifyListeners();
    }).subscribe();
  }
}
