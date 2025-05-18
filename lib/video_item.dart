import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt_downloader/downloader.dart';

class VideoItem extends StatefulWidget {
  final Video video;
  const VideoItem({super.key, required this.video});

  @override
  State<VideoItem> createState() => _VideoItemState();
}

class _VideoItemState extends State<VideoItem> {
  bool downloading = false;

  Future<void> downloadVideo() async {
    final String? dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) return;

    setState(() => downloading = true);
    bool succ = false;
    try {
      succ = await Downloader.downloadVideo(widget.video, dir);
    } finally {
      setState(() => downloading = false);
    }
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: Text(
          succ
              ? "Downloaded ${widget.video.title}"
              : "Failed: ${widget.video.title}",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }

  Future<void> downloadAudio() async {
    final String? dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) return;

    setState(() => downloading = true);
    bool succ = false;
    try {
      succ = await Downloader.downloadAudio(widget.video, dir);
    } finally {
      setState(() => downloading = false);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: Text(
          succ
              ? "Downloaded ${widget.video.title}"
              : "Failed: ${widget.video.title}",
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            ShaderMask(
              blendMode: BlendMode.dstOut,
              shaderCallback: (final rect) => const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black87,
                    Colors.black,
                  ],
                  stops: [
                    0,
                    1
                  ]).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  widget.video.thumbnails.mediumResUrl,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    widget.video.author,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(.4),
                        ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Wrap(
                    children: [
                      if (downloading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      if (!downloading)
                        TextButton.icon(
                          onPressed: downloadVideo,
                          icon: const Icon(Icons.video_file_outlined),
                          label: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Download video",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceTint,
                                  ),
                            ),
                          ),
                        ),
                      if (!downloading)
                        TextButton.icon(
                          onPressed: downloadAudio,
                          icon: const Icon(Icons.audio_file_outlined),
                          label: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Download audio",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceTint,
                                  ),
                            ),
                          ),
                        )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
