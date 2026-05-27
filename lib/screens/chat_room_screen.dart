import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/widgets/glass_container.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  const ChatRoomScreen({super.key, required this.roomId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupRealtime();
  }

  Future<void> _loadMessages() async {
    try {
      final response = await supabase
         .from('messages')
         .select()
         .eq('room_id', widget.roomId)
         .order('created_at', ascending: true);

      setState(() {
        messages = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _setupRealtime() {
    _channel = supabase.channel('room_${widget.roomId}');

    _channel!
       .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: widget.roomId,
          ),
          callback: (payload) {
            if (payload.eventType == PostgresChangeEventType.insert) {
              setState(() {
                messages.add(payload.newRecord);
              });
            }
          },
        )
       .subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثة'),
      ),
      body: isLoading
         ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return GlassContainer(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(msg['content']?? ''),
                );
              },
            ),
    );
  }
}
