import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/services/room_service.dart';

Future<void> showCreateRoomDialog(BuildContext context) async {
  final roomService = Get.find<RoomService>();
  String roomName = 'غرفة';
  int maxPlayers = 4;
  bool isLoading = false;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('إنشاء غرفة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'اسم الغرفة',
                hintText: 'غرفة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                roomName = value.isNotEmpty ? value : 'غرفة';
              },
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<int>(
              value: maxPlayers,
              decoration: InputDecoration(
                labelText: 'عدد اللاعبين',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [2, 3, 4]
                  .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  maxPlayers = value;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    setState(() => isLoading = true);
                    try {
                      final roomId = await roomService.createRoom(
                        name: roomName,
                        maxPlayers: maxPlayers,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        Get.toNamed('/room', arguments: {'roomId': roomId});
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('خطأ: $e')),
                        );
                      }
                    } finally {
                      if (context.mounted) {
                        setState(() => isLoading = false);
                      }
                    }
                  },
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('إنشاء'),
          ),
        ],
      ),
    ),
  );
}
