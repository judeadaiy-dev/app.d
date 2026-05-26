import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/providers/chat_provider.dart';
import 'package:chat_app/widgets/glass_container.dart';
import 'package:chat_app/widgets/room_tile.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    _initRealtime();
  }

  void _initRealtime() {
    final chatProvider = context.read<ChatProvider>();
    final supabase = Supabase.instance.client;

    supabase
       .channel('public:messages')
       .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            chatProvider.fetchRooms();
          },
        )
       .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات'),
        centerTitle: true,
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          if (chatProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (chatProvider.rooms.isEmpty) {
            return const Center(
              child: Text('لا توجد محادثات بعد'),
            );
          }

          return ListView.builder(
            itemCount: chatProvider.rooms.length,
            itemBuilder: (context, index) {
              final room = chatProvider.rooms[index];
              return GlassContainer(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: RoomTile(room: room),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/rooms'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
