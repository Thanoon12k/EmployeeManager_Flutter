import 'package:emp_manager_front_end/classes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class FormalBookDetailScreen extends StatelessWidget {
  final FormalBook book;
  final VoidCallback markAsReadCallback;
  final VoidCallback markAsUnreadCallback;

  const FormalBookDetailScreen({
    Key? key,
    required this.book,
    required this.markAsReadCallback,
    required this.markAsUnreadCallback,
  }) : super(key: key);

  Future<void> saveImageToGallery(String imageUrl, BuildContext context) async {
    try {
      if (await _checkAndRequestPermissions(Permission.storage)) {
        var appDir = await getTemporaryDirectory();
        String savePath = "${appDir.path}/temp_image.jpg";

        var response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          File file = File(savePath);
          await file.writeAsBytes(response.bodyBytes);
        } else {
          throw Exception('Failed to download image');
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Image saved to gallery')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission not granted')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save image: $e')));
      print("Failed to save image: $e");
    }
  }

  Future<void> downloadFile(String fileUrl, BuildContext context) async {
    try {
      if (await _checkAndRequestPermissions(Permission.storage)) {
        var downloadsDir = await getExternalStorageDirectory();
        if (downloadsDir != null) {
          String savePath = "${downloadsDir.path}/downloaded_file.pdf";

          var response = await http.get(Uri.parse(fileUrl));
          if (response.statusCode == 200) {
            File file = File(savePath);
            await file.writeAsBytes(response.bodyBytes);
          } else {
            throw Exception('Failed to download file');
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File downloaded to $savePath')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to access downloads directory'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission not granted')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to download file: $e')));
      print("Failed to download file: $e");
    }
  }

  Future<bool> _checkAndRequestPermissions(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      final result = await permission.request();
      return result.isGranted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              book.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(book.description),
            const SizedBox(height: 20),
            Image.network(book.image),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                markAsReadCallback();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Marked as read')));
                Navigator.pop(context);
              },
              child: const Text('Mark as Read'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                markAsUnreadCallback();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Marked as unread')),
                );
                Navigator.pop(context);
              },
              child: const Text('Mark as Unread'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => saveImageToGallery(book.image, context),
              child: const Text('Save Image to Gallery'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => downloadFile(book.image, context),
              child: const Text('Download File'),
            ),
          ],
        ),
      ),
    );
  }
}
