import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/theme/app_colors.dart';
import 'package:chat_app/widgets/room_tile.dart';
import 'package:chat_app/widgets/glass_container.dart';
import 'package:chat_app/providers/online_provider.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('chat_rooms')
          .select('*, room_members!inner(user_id)')
          .eq('room_members.user_id', userId)
          .order('updated_at', ascending: false);

      setState(() {
        rooms = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الغرف: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final onlineProvider = Provider.of<OnlineProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rooms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد محادثات بعد',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRooms,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      final roomId = room['id'];
                      final isOnline = onlineProvider.isUserOnline(roomId);
                      
                      return GlassContainer(
                        margin: const EdgeInsets.only(bottom: 8),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/chat',
                            arguments: {'roomId': roomId},
                          );
                        },
                        child: RoomTile(
                          room: {
                            ...room,
                            'is_online': isOnline,
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          // انشاء غرفة جديدة
          Navigator.pushNamed(context, '/search');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
