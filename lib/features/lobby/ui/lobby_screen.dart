import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/models.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeMockRooms();
  }

  void _initializeMockRooms() {
    rooms = [
      Room(
        id: '1',
        status: 'Waiting',
        currentWord: 'كتب',
        currentTurn: 'user1',
        playerIds: ['user1', 'user2'],
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Room(
        id: '2',
        status: 'Playing',
        currentWord: 'جمل',
        currentTurn: 'user3',
        playerIds: ['user3', 'user4', 'user5', 'user6'],
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      Room(
        id: '3',
        status: 'Waiting',
        currentWord: 'نجم',
        currentTurn: 'user7',
        playerIds: ['user7'],
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
      Room(
        id: '4',
        status: 'Playing',
        currentWord: 'قمر',
        currentTurn: 'user8',
        playerIds: ['user8', 'user9', 'user10'],
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الغرف'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
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
                            roomName: 'الغرفة ${index + 1}',
                            currentPlayers: room.playerIds.length,
                            maxPlayers: 4,
                            status: room.status,
                            onJoin: () {
                              // TODO: Join room
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('جاري الانضمام للغرفة ${room.id}'),
                                ),
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
    );
  }
}
