import 'package:employee_manager_app/classes.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementDetailsScreen extends StatefulWidget {
  final Announcement announcement;
  final Future<void> Function() markAsReadCallback;
  final Future<void> Function() markAsUnreadCallback;

  const AnnouncementDetailsScreen({
    super.key,
    required this.announcement,
    required this.markAsReadCallback,
    required this.markAsUnreadCallback,
  });

  @override
  _AnnouncementDetailsScreenState createState() =>
      _AnnouncementDetailsScreenState();
}

class _AnnouncementDetailsScreenState extends State<AnnouncementDetailsScreen> {
  bool _isRead = false; // ✅ افتراضيًا الكتاب مقروء

  Future<void> openUrl(String? url) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الرابط غير متوفر')));
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذر فتح الرابط: $url')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل في فتح الرابط: $e')));
    }
  }

  void _toggleReadStatus() async {
    setState(() {
      _isRead = !_isRead;
    });
    if (_isRead) {
      await widget.markAsReadCallback();
    } else {
      await widget.markAsUnreadCallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.announcement.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.announcement.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.announcement.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // ✅ صورة إذا كانت متوفرة
            if (widget.announcement.image != null &&
                widget.announcement.image!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(widget.announcement.image!),
              ),

            const SizedBox(height: 20),

            // ✅ تحديد كـ مقروء أو غير مقروء باستخدام CheckboxListTile
            CheckboxListTile(
              title: const Text('تحديد كمقروء'),
              value: _isRead,
              onChanged: (bool? value) {
                if (value != null) {
                  _toggleReadStatus();
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 20),

            // ✅ زر فتح الصورة فقط إذا كان الرابط متوفرًا
            if (widget.announcement.image != null &&
                widget.announcement.image!.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => openUrl(widget.announcement.image),
                icon: const Icon(Icons.image),
                label: const Text('عرض الصورة'),
              ),

            const SizedBox(height: 10),

            // ✅ زر فتح الملف فقط إذا كان الرابط متوفرًا
            if (widget.announcement.file != null &&
                widget.announcement.file!.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => openUrl(widget.announcement.file),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('فتح الملف'),
              ),
          ],
        ),
      ),
    );
  }
}
