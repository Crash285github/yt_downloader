import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt_downloader/downloader.dart';
import 'package:yt_downloader/video_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static bool mp3 = false;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final YoutubeExplode _yt;
  late final TextEditingController _controller;
  final List<Video> videos = [];

  String? playlistTitle;

  bool searching = false;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    _yt = YoutubeExplode();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            padding:
                const EdgeInsets.symmetric(vertical: 64.0, horizontal: 32.0),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Switch(
                          value: HomeScreen.mp3,
                          onChanged: (value) =>
                              setState(() => HomeScreen.mp3 = value),
                        ),
                        Text(
                          "Audio: ${HomeScreen.mp3 ? "mp3" : "flac"}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          label: const Text('Search for a video or playlist'),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                              onPressed: () => search(_controller.text),
                              icon: const Icon(Icons.search)),
                        ),
                        onSubmitted: search,
                      ),
                    ),
                  ],
                );
              }
              return VideoItem(video: videos[index - 1]);
            },
            itemCount: videos.length + 1,
          ),
          if (videos.length > 1)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surface.withOpacity(.8),
                ),
                child: Wrap(
                  spacing: 16,
                  children: [
                    if (counter > 0)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          value: (videos.length - counter) / videos.length,
                        ),
                      ),
                    if (counter == 0)
                      TextButton.icon(
                        onPressed: downloadAllVideos,
                        icon: const Icon(Icons.video_file_outlined),
                        label: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Download all Videos",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.surfaceTint,
                                ),
                          ),
                        ),
                      ),
                    if (counter == 0)
                      TextButton.icon(
                        onPressed: downloadAllAudios,
                        icon: const Icon(Icons.audio_file_outlined),
                        label: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Download all Audios",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color:
                                      Theme.of(context).colorScheme.surfaceTint,
                                ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          if (searching) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Future<void> downloadAllAudios() async {
    final String? dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) return;

    final targetDir = Directory("$dir/${playlistTitle ?? "youtube"}");
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    for (final element in videos) {
      setState(() => counter++);
      try {
        Downloader.downloadAudio(element, targetDir.path)
            .whenComplete(() => setState(() => counter--));
      } catch (e) {
        //
      }
    }
  }

  Future<void> downloadAllVideos() async {
    final String? dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) return;

    final targetDir = Directory("$dir/${playlistTitle ?? "youtube"}");
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    for (final element in videos) {
      setState(() => counter++);
      try {
        Downloader.downloadVideo(element, targetDir.path).whenComplete(
          () => setState(() => counter--),
        );
      } catch (e) {
        //
      }
    }
  }

  void search(final String value) async {
    setState(() {
      searching = true;
      videos.clear();
    });

    final videoId = VideoId.parseVideoId(value);
    if (videoId != null) {
      final video = await _yt.videos.get(videoId);
      setState(() {
        searching = false;
        videos.add(video);
      });
      return;
    }

    final playlistId = PlaylistId.parsePlaylistId(value);
    if (playlistId != null) {
      final title = (await _yt.playlists.get(playlistId)).title;
      final gotVideos = await _yt.playlists.getVideos(playlistId).toList();
      setState(() {
        searching = false;

        final filteredTitle = title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
        playlistTitle = filteredTitle;
        videos.addAll(gotVideos);
      });
    }
  }
}
