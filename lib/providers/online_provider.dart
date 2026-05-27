import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnlineProvider extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  final Map<String, bool> _onlineUsers = {};

  Map<String, bool> get onlineUsers => _onlineUsers;

  bool isUserOnline(String userId) {
    return _onlineUsers[userId]?? false;
  }

  void initPresence() {
    final currentUserId = supabase.auth.currentUser?.id;
    if (currentUserId == null) return;

    _channel = supabase.channel('online_users');

    _channel!
       .onPresenceSync((payload) {
          final newState = _channel!.presenceState();
          _onlineUsers.clear();
          
          for (final presence in newState) {
            final userId = presence.presenceData['user_id'] as String?;
            if (userId!= null) {
              _onlineUsers[userId] = true;
            }
          }
          notifyListeners();
        })
       .onPresenceJoin((payload) {
          final userId = payload.presenceData['user_id'] as String?;
          if (userId!= null) {
            _onlineUsers[userId] = true;
            notifyListeners();
          }
        })
       .onPresenceLeave((payload) {
          final userId = payload.presenceData['user_id'] as String?;
          if (userId!= null) {
            _onlineUsers[userId] = false;
            notifyListeners();
          }
        })
       .subscribe((status, error) async {
          if (status == RealtimeChannelStates.joined) {
            await _channel!.track({
              'user_id': currentUserId,
              'online_at': DateTime.now().toIso8601String(),
            });
          }
        });
  }

  void disposePresence() {
    _channel?.unsubscribe();
    _channel = null;
  }

  @override
  void dispose() {
    disposePresence();
    super.dispose();
  }
}
