import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shape_mobile/db/app_database.dart';
import 'package:shape_mobile/models/VideoModel.dart';
import 'video_player_screen.dart';
import 'package:shape_mobile/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toastification/toastification.dart';

class VideoCollectionWidget extends StatefulWidget {
  final String title;
  final int? lessonId;

  const VideoCollectionWidget({super.key, required this.title, this.lessonId});

  @override
  State<VideoCollectionWidget> createState() => _VideoCollectionWidgetState();
}

class _VideoCollectionWidgetState extends State<VideoCollectionWidget> {
  List<Video> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _handleVideoTap(Video video) async {
    final url = video.url;

    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        toastification.showError(
          context: context,
          title: 'Could not open YouTube link.',
          autoCloseDuration: const Duration(seconds: 5),
          padding: const EdgeInsets.all(10),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoUrl: url)),
      );
    }
  }

  Future<void> _fetchVideos() async {
    List<Video> videos;

    if (widget.lessonId != null) {
      videos = await AppDatabase.instance.fetchVideosByLessonId(
        widget.lessonId!,
      );
    } else {
      videos = await AppDatabase.instance.fetchAllVideosSortedByLatest();
    }

    // await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() {
      _videos = videos;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 150),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [CircularProgressIndicator()],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          widget.title,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),

        if (_videos.isEmpty)
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.video_collection, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No Videos Available",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 18,
            childAspectRatio: widget.lessonId == null ? 1.2 : 1.4,
            children: _videos.map((video) {
              return Material(
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                color: Colors.white,
                child: InkWell(
                  onTap: () => _handleVideoTap(video),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: double.infinity,
                              height: 100,
                              child: Image.file(
                                File(video.thumbnail!),
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.75),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              toTitleCase(video.title),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            if (widget.lessonId == null)
                              Text(
                                toTitleCase(video.lessonTitle!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
