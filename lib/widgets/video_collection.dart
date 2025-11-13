import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shape_mobile/db/app_database.dart';
import 'package:shape_mobile/models/VideoModel.dart';
import 'package:shape_mobile/models/LessonModel.dart';
import 'video_player_screen.dart';
import 'package:shape_mobile/utils.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Map<String, List<Video>> _groupedVideos = {};

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  String getYoutubeVideoUrl(String url) {
    try {
      final uri = Uri.parse(url);

      // Handle youtu.be short links
      if (uri.host.contains('youtu.be')) {
        final videoId = uri.pathSegments.isNotEmpty
            ? uri.pathSegments[0]
            : null;
        if (videoId != null) return 'https://www.youtube.com/watch?v=$videoId';
      }

      // Handle regular youtube.com links
      if (uri.host.contains('youtube.com')) {
        final videoId = uri.queryParameters['v'];
        if (videoId != null && videoId.isNotEmpty) {
          return 'https://www.youtube.com/watch?v=$videoId';
        }
      }

      // Fallback to original URL
      return url;
    } catch (e) {
      return url;
    }
  }

  Future<void> launchYoutubeUrl(String url) async {
    final safeUrl = getYoutubeVideoUrl(url);
    final uri = Uri.parse(safeUrl);

    try {
      // Try launching in external application (YouTube app)
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: launch in default browser
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      // Show error if everything fails
      print('Could not launch YouTube URL: $e');
    }
  }

  Future<void> _handleVideoTap(Video video) async {
    final url = video.url;

    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      await launchYoutubeUrl(url);
    } else {
      // For other video URLs, open in-app player
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

    // Group videos by lesson's subject name
    final db = AppDatabase.instance;
    Map<String, List<Video>> grouped = {};

    for (final video in videos) {
      // Directly fetch the lesson (no null check)
      final result = await (await db.database).query(
        AppDatabase.lessonsTable,
        where: 'id = ?',
        whereArgs: [video.lessonId],
      );

      Lesson lesson;
      if (result.isNotEmpty) {
        lesson = Lesson.fromJson(result.first);
      } else {
        continue;
      } // skip if lesson not found

      final subject = lesson.subjectName ?? 'No Subject';
      if (!grouped.containsKey(subject)) grouped[subject] = [];
      grouped[subject]!.add(video);
    }

    if (!mounted) return;

    setState(() {
      _videos = videos;
      _groupedVideos = grouped;
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
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 18,
            children: _groupedVideos.entries.map((entry) {
              final subject = entry.key;
              final videos = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  if (widget.lessonId == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        toTitleCase(subject),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 18,
                    childAspectRatio: widget.lessonId == null ? 1.1 : 1.3,
                    children: videos.map((video) {
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
                                padding: const EdgeInsets.all(8.0),
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
                                          fontSize: 14,
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
            }).toList(),
          ),
      ],
    );
  }
}
