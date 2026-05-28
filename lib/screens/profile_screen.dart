import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:chat_app/widgets/glass_container.dart';
import 'package:chat_app/theme/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileScreen extends StatefulWidget {
  final String? userId; // اذا null يعني بروفايلي
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  
  Map<String, dynamic>? profile;
  bool isLoading = true;
  bool isUploading = false;
  bool isFollowing = false;
  bool isMyProfile = false;

  // قوائم الاختيارات
  final List<String> zodiacSigns = [
    'غير محدد', 'الحمل', 'الثور', 'الجوزاء', 'السرطان', 'الأسد', 'العذراء',
    'الميزان', 'العقرب', 'القوس', 'الجدي', 'الدلو', 'الحوت'
  ];
  
  final List<String> genders = ['غير محدد', 'ذكر', 'أنثى'];
  
  final List<Map<String, String>> reportTypes = [
    {'id': 'spam', 'title': 'محتوى مزعج'},
    {'id': 'harassment', 'title': 'تحرش أو تنمر'},
    {'id': 'impersonation', 'title': 'انتحال شخصية'},
    {'id': 'inappropriate', 'title': 'محتوى غير لائق'},
    {'id': 'other', 'title': 'أخرى'},
  ];

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final currentUserId = supabase.auth.currentUser?.id;
      final targetUserId = widget.userId?? currentUserId;
      
      if (targetUserId == null) {
        setState(() => isLoading = false);
        return;
      }

      isMyProfile = targetUserId == currentUserId;

      final response = await supabase
        .from('profiles')
        .select()
        .eq('id', targetUserId)
        .single();

      // تحقق من المتابعة
      if (!isMyProfile && currentUserId!= null) {
        final followCheck = await supabase
          .from('follows')
          .select()
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId)
          .maybeSingle();
        isFollowing = followCheck!= null;
      }

      setState(() {
        profile = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل الملف الشخصي: $e')),
        );
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    if (!isMyProfile) return;
    
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;
      setState(() => isUploading = true);

      final File imageFile = File(image.path);
      await uploadAvatar(imageFile);
      await _loadProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الصورة بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في رفع الصورة: $e')),
        );
      }
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> uploadAvatar(File imageFile) async {
    final userId = supabase.auth.currentUser!.id;
    final fileExt = imageFile.path.split('.').last;
    final fileName = '$userId.$fileExt';
    final filePath = 'avatars/$fileName';

    await supabase.storage.from('avatars').upload(
          filePath,
          imageFile,
          fileOptions: FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );

    final imageUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
    
    await supabase.from('profiles').update({
      'avatar_url': imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  Future<void> _toggleFollow() async {
    if (isMyProfile) return;
    final currentUserId = supabase.auth.currentUser!.id;
    final targetUserId = widget.userId!;

    try {
      if (isFollowing) {
        await supabase
          .from('follows')
          .delete()
          .eq('follower_id', currentUserId)
          .eq('following_id', targetUserId);
      } else {
        await supabase.from('follows').insert({
          'follower_id': currentUserId,
          'following_id': targetUserId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      setState(() => isFollowing =!isFollowing);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  void _showReportDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'اختر سبب البلاغ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
           ...reportTypes.map((type) => ListTile(
              leading: const Icon(Icons.report_outlined, color: Colors.red),
              title: Text(type['title']!),
              onTap: () {
                Navigator.pop(context);
                _submitReport(type['id']!);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport(String reason) async {
    try {
      await supabase.from('reports').insert({
        'reporter_id': supabase.auth.currentUser!.id,
        'reported_user_id': widget.userId,
        'reason': reason,
        'created_at': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال البلاغ بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الإبلاغ: $e')),
        );
      }
    }
  }

  Future<void> _blockUser() async {
    try {
      await supabase.from('blocks').insert({
        'blocker_id': supabase.auth.currentUser!.id,
        'blocked_id': widget.userId,
        'created_at': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حظر المستخدم')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الحظر: $e')),
        );
      }
    }
  }

  void _showEditDialog() {
    final usernameController = TextEditingController(text: profile?['username']?? '');
    final bioController = TextEditingController(text: profile?['bio']?? '');
    final ageController = TextEditingController(text: profile?['age']?.toString()?? '');
    String selectedZodiac = profile?['zodiac']?? 'غير محدد';
    String selectedGender = profile?['gender']?? 'غير محدد';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تعديل الملف الشخصي'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'اليوزر المميز @username',
                    prefixText: '@',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(
                    labelText: 'النبذة التعريفية (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'العمر (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'الجنس (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  items: genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) => setDialogState(() => selectedGender = val!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedZodiac,
                  decoration: const InputDecoration(
                    labelText: 'البرج (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                  items: zodiacSigns.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                  onChanged: (val) => setDialogState(() => selectedZodiac = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                await _updateProfile(
                  username: usernameController.text.trim(),
                  bio: bioController.text.trim(),
                  age: int.tryParse(ageController.text),
                  gender: selectedGender,
                  zodiac: selectedZodiac,
                );
                if (mounted) Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProfile({
    String? username,
    String? bio,
    int? age,
    String? gender,
    String? zodiac,
  }) async {
    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('profiles').update({
        if (username!= null && username.isNotEmpty) 'username': username,
        if (bio!= null) 'bio': bio,
        if (age!= null) 'age': age,
        if (gender!= null && gender!= 'غير محدد') 'gender': gender,
        if (zodiac!= null && zodiac!= 'غير محدد') 'zodiac': zodiac,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      await _loadProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الملف الشخصي')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String name = profile?['name']?? profile?['username']?? 'مستخدم';
    final String username = profile?['username']?? '';
    final String email = profile?['email']?? '';
    final String bio = profile?['bio']?? '';
    final String? avatarUrl = profile?['avatar_url'];
    final int? age = profile?['age'];
    final String? gender = profile?['gender'];
    final String? zodiac = profile?['zodiac'];
    final String joinedAt = profile?['created_at']!= null
      ? timeago.format(DateTime.parse(profile!['created_at']), locale: 'ar')
        : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        actions: [
          if (!isMyProfile)
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [Icon(Icons.block, color: Colors.red), SizedBox(width: 8), Text('حظر')],
                  ),
                  onTap: _blockUser,
                ),
                PopupMenuItem(
                  child: const Row(
                    children: [Icon(Icons.report, color: Colors.orange), SizedBox(width: 8), Text('إبلاغ')],
                  ),
                  onTap: _showReportDialog,
                ),
              ],
            ),
          if (isMyProfile)
            IconButton(icon: const Icon(Icons.edit), onPressed: _showEditDialog),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // كرت البروفايل الجميل
            GlassContainer(
              width: double.infinity,
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primary.withOpacity(0.2),
                        backgroundImage: avatarUrl!= null? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null
                          ? Text(name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary))
                            : null,
                      ),
                      if (isUploading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                          ),
                        ),
                      if (isMyProfile)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickAndUploadAvatar,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  if (username.isNotEmpty)...[
                    const SizedBox(height: 4),
                    Text('@$username', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  ],
                  const SizedBox(height: 12),
                  // البرج والعمر والجنس
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      if (age!= null) _buildInfoChip(Icons.cake, '$age سنة'),
                      if (gender!= null && gender!= 'غير محدد') _buildInfoChip(Icons.person, gender),
                      if (zodiac!= null && zodiac!= 'غير محدد') _buildInfoChip(Icons.stars, zodiac),
                    ],
                  ),
                  if (bio.isNotEmpty)...[
                    const SizedBox(height: 16),
                    Text(bio, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5)),
                  ],
                  const SizedBox(height: 16),
                  Text('انضم $joinedAt', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  const SizedBox(height: 20),
                  // أزرار المتابعة والمراسلة
                  if (!isMyProfile)...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _toggleFollow,
                            icon: Icon(isFollowing? Icons.person_remove : Icons.person_add),
                            label: Text(isFollowing? 'إلغاء المتابعة' : 'متابعة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing? Colors.grey[300] : AppColors.primary,
                              foregroundColor: isFollowing? Colors.black87 : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/chat', arguments: {'roomId': widget.userId});
                            },
                            icon: const Icon(Icons.message),
                            label: const Text('مراسلة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // معلومات إضافية
            if (isMyProfile)...[
              GlassContainer(
                width: double.infinity,
                child: Column(
                  children: [
                    _buildInfoTile(Icons.email_outlined, 'البريد الإلكتروني', email),
                    const Divider(),
                    _buildInfoTile(Icons.badge_outlined, 'المعرف', supabase.auth.currentUser!.id.substring(0, 8)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await supabase.auth.signOut();
                    if (mounted) Navigator.of(context).pushReplacementNamed('/');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
