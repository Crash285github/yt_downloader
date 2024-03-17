import 'dart:io';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Downloader {
  static final YoutubeExplode _yt = YoutubeExplode();

  static Future<bool> downloadAudio(Video video, String? directory) async {
    try {
      StreamManifest streamManifest =
          await _yt.videos.streamsClient.getManifest(video.id);

      AudioOnlyStreamInfo audioStreamInfo =
          streamManifest.audioOnly.withHighestBitrate();

      Stream<List<int>> audioStream =
          _yt.videos.streamsClient.get(audioStreamInfo);

      final title = video.title
          .replaceAll('\\', "")
          .replaceAll(':', "")
          .replaceAll('*', "")
          .replaceAll('?', "")
          .replaceAll('<', "")
          .replaceAll('>', "")
          .replaceAll('|', "")
          .replaceAll('/', "");

      IOSink audioFileStream = File("$directory/$title.flac").openWrite();

      await audioStream.pipe(audioFileStream);
      await audioFileStream.flush();
      await audioFileStream.close();
    } on Exception {
      return false;
    }

    return true;
  }

  static Future<bool> downloadVideo(Video video, String? directory) async {
    try {
      StreamManifest streamManifest =
          await _yt.videos.streamsClient.getManifest(video.id);

      MuxedStreamInfo muxedStreamInfo =
          streamManifest.muxed.withHighestBitrate();

      Stream<List<int>> muxedStream =
          _yt.videos.streamsClient.get(muxedStreamInfo);

      final title = video.title
          .replaceAll('\\', "")
          .replaceAll(':', "")
          .replaceAll('*', "")
          .replaceAll('?', "")
          .replaceAll('<', "")
          .replaceAll('>', "")
          .replaceAll('|', "")
          .replaceAll('/', "");

      IOSink muxedFileStream = File("$directory/$title.mp4").openWrite();

      await muxedStream.pipe(muxedFileStream);
      await muxedFileStream.flush();
      await muxedFileStream.close();
    } on Exception {
      return false;
    }

    return true;
  }
}
