import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/models/models.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/services/room_service.dart';
import '../../../core/helpers/logger.dart';
import '../../../core/widgets/responsive_content.dart';
import 'widgets/room_card.dart';
import 'widgets/create_room_button.dart';
import 'widgets/user_name_edit.dart';
import 'dialogs/create_room_dialog.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final roomService = Get.find<RoomService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الغرف'),
        centerTitle: true,
        elevation: 0,
        leadingWidth: 100,
        leading: const UserNameEdit(),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await authService.signOut();
              Get.offAllNamed('/home');
              Get.snackbar(
                'تم',
                'تم تسجيل الخروج بنجاح',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.withValues(alpha: 0.8),
                colorText: Colors.white,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
                duration: const Duration(seconds: 2),
              );
            },
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: 1000,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
              SizedBox(height: 16.h),
              
              // Create room button
              CreateRoomButton(
                onPressed: () => showCreateRoomDialog(context),
              ),
              
              SizedBox(height: 24.h),
              
              // Rooms list
              Expanded(
                child: StreamBuilder<List<Room>>(
                  stream: roomService.streamRooms(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      logger.severe('Rooms stream error: ${snapshot.error}');
                      return Center(
                        child: Text(
                          'حدث خطأ أثناء تحميل الغرف: ${snapshot.error}',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final rooms = snapshot.data ?? const <Room>[];

                    if (rooms.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد غرف متاحة',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: rooms.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        final currentUid = authService.currentUserId;
                        final alreadyInRoom = currentUid != null &&
                            room.playerIds.contains(currentUid);
                        return RoomCard(
                          roomName: room.name,
                          currentPlayers: room.playerCount,
                          maxPlayers: room.maxPlayers,
                          status: room.status,
                          canJoin: alreadyInRoom ||
                              (room.status == 'waiting' &&
                                  room.playerCount < room.maxPlayers),
                          onJoin: () {
                            Get.toNamed(
                              '/room',
                              arguments: {'roomId': room.id},
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
