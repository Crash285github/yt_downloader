import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt_downloader/video_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final YoutubeExplode _yt;
  final List<Video> videos = [];

  @override
  void initState() {
    super.initState();
    _yt = YoutubeExplode();
  }

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 32.0),
        itemBuilder: (context, index) {
          if (index == 0) {
            return TextField(
              onSubmitted: search,
            );
          }
          return VideoItem(video: videos[index - 1]);
        },
        itemCount: videos.length + 1,
      ),
    );
  }

  void search(value) async {
    setState(() => videos.clear());
    final videoId = VideoId.parseVideoId(value);
    if (videoId != null) {
      final video = await _yt.videos.get(videoId);
      setState(() => videos.add(video));
      return;
    }

    final playlistId = PlaylistId.parsePlaylistId(value);
    if (playlistId != null) {
      final gotVideos = await _yt.playlists.getVideos(playlistId).toList();
      setState(() => videos.addAll(gotVideos));
    }
  }
}
