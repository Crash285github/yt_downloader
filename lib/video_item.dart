import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:yt_downloader/downloader.dart';

class VideoItem extends StatelessWidget {
  final Video video;
  const VideoItem({super.key, required this.video});

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
                  video.thumbnails.mediumResUrl,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    video.author,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(.4),
                        ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          final String? dir =
                              await FilePicker.platform.getDirectoryPath();
                          if (dir == null) return;

                          Downloader.downloadVideo(video, dir);
                        },
                        icon: const Icon(Icons.video_file_outlined),
                        label: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Download video",
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

                          Downloader.downloadAudio(video, dir).then((value) {
                            if (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.background,
                                  content: Text(
                                    "Downloaded ${video.title}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.background,
                                  content: Text(
                                    "Failed: ${video.title}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground),
                                  ),
                                ),
                              );
                            }
                          });
                        },
                        icon: const Icon(Icons.audio_file_outlined),
                        label: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Download audio",
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
