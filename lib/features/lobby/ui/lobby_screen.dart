import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/models/models.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/widgets/responsive_content.dart';
import 'widgets/room_card.dart';
import 'widgets/create_room_button.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  // Mock data
  late List<Room> rooms;
  late List<int> roomPlayers;

  @override
  void initState() {
    super.initState();
    _initializeMockRooms();
  }

  void _initializeMockRooms() {
    rooms = [
      Room(
        id: '1',
        name: 'الغرفة 1',
        createdBy: 'user1',
        status: 'waiting',
        currentWord: 'كتب',
        currentTurn: 'user1',
        maxPlayers: 4,
        turnStartedAt: DateTime.now().subtract(const Duration(minutes: 1)),
        winnerId: null,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        finishedAt: null,
      ),
      Room(
        id: '2',
        name: 'الغرفة 2',
        createdBy: 'user3',
        status: 'playing',
        currentWord: 'جمل',
        currentTurn: 'user3',
        maxPlayers: 4,
        turnStartedAt: DateTime.now().subtract(const Duration(minutes: 3)),
        winnerId: null,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        finishedAt: null,
      ),
      Room(
        id: '3',
        name: 'الغرفة 3',
        createdBy: 'user7',
        status: 'waiting',
        currentWord: 'نجم',
        currentTurn: 'user7',
        maxPlayers: 4,
        turnStartedAt: DateTime.now().subtract(const Duration(minutes: 1)),
        winnerId: null,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        finishedAt: null,
      ),
      Room(
        id: '4',
        name: 'الغرفة 4',
        createdBy: 'user8',
        status: 'playing',
        currentWord: 'قمر',
        currentTurn: 'user8',
        maxPlayers: 4,
        turnStartedAt: DateTime.now().subtract(const Duration(minutes: 4)),
        winnerId: null,
        createdAt: DateTime.now(),
        finishedAt: null,
      ),
    ];

    roomPlayers = [2, 4, 1, 3];
  }

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الغرف'),
        centerTitle: true,
        elevation: 0,
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
                onPressed: () {
                  // TODO: Show create room dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('إنشاء غرفة جديدة')),
                  );
                },
              ),
              
              SizedBox(height: 24.h),
              
              // Rooms list
              Expanded(
                child: rooms.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد غرف متاحة',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.separated(
                        itemCount: rooms.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final room = rooms[index];
                          return RoomCard(
                            roomName: room.name,
                            currentPlayers: roomPlayers[index],
                            maxPlayers: room.maxPlayers,
                            status: room.status,
                            onJoin: () {
                              Get.toNamed('/room');
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
