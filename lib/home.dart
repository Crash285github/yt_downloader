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
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Column(
                    children: [
                      TextField(
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
                    ],
                  ),
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
                  color:
                      Theme.of(context).colorScheme.background.withOpacity(.8),
                ),
                child: Wrap(
                  spacing: 16,
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        final String? dir =
                            await FilePicker.platform.getDirectoryPath();
                        if (dir == null) return;

                        for (var element in videos) {
                          setState(() {
                            counter++;
                          });
                          Downloader.downloadVideo(element, dir)
                              .whenComplete(() => setState(() {
                                    counter--;
                                  }));
                        }
                      },
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
                    TextButton.icon(
                      onPressed: () async {
                        final String? dir =
                            await FilePicker.platform.getDirectoryPath();
                        if (dir == null) return;

                        for (var element in videos) {
                          setState(() {
                            counter++;
                          });
                          Downloader.downloadAudio(element, dir)
                              .whenComplete(() => setState(() {
                                    counter--;
                                  }));
                        }
                      },
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
          Align(
            alignment: Alignment.topCenter,
            child: Text('$counter'),
          )
        ],
      ),
    );
  }

  void search(value) async {
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
      final gotVideos = await _yt.playlists.getVideos(playlistId).toList();
      setState(() {
        searching = false;
        videos.addAll(gotVideos);
      });
    }
  }
}
