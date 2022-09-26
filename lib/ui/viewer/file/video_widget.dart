// @dart=2.9

import 'dart:io' as io;

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:photos/core/constants.dart';
import 'package:photos/models/file.dart';
import 'package:photos/services/files_service.dart';
import 'package:photos/ui/viewer/file/thumbnail_widget.dart';
import 'package:photos/ui/viewer/file/video_controls.dart';
import 'package:photos/utils/file_util.dart';
import 'package:photos/utils/toast_util.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoWidget extends StatefulWidget {
  final File file;
  final bool autoPlay;
  final String tagPrefix;
  final Function(bool) playbackCallback;

  const VideoWidget(
    this.file, {
    this.autoPlay = false,
    this.tagPrefix,
    this.playbackCallback,
    Key key,
  }) : super(key: key);

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  final _logger = Logger("VideoWidget");
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  double _progress;
  bool _isPlaying;

  @override
  void initState() {
    super.initState();
    if (widget.file.isRemoteFile) {
      _loadNetworkVideo();
      _setFileSizeIfNull();
    } else if (widget.file.isSharedMediaToAppSandbox) {
      final localFile = io.File(getSharedMediaFilePath(widget.file));
      if (localFile.existsSync()) {
        _logger.fine("loading from app cache");
        _setVideoPlayerController(file: localFile);
      } else if (widget.file.uploadedFileID != null) {
        _loadNetworkVideo();
      }
    } else {
      widget.file.getAsset.then((asset) async {
        if (asset == null || !(await asset.exists)) {
          if (widget.file.uploadedFileID != null) {
            _loadNetworkVideo();
          }
        } else {
          asset.getMediaUrl().then((url) {
            _setVideoPlayerController(url: url);
          });
        }
      });
    }
  }

  void _setFileSizeIfNull() {
    if (widget.file.fileSize == null) {
      FilesService.instance
          .getFileSize(widget.file.uploadedFileID)
          .then((value) {
        widget.file.fileSize = value;
        setState(() {});
      });
    }
  }

  void _loadNetworkVideo() {
    getFileFromServer(
      widget.file,
      progressCallback: (count, total) {
        if (mounted) {
          setState(() {
            _progress = count / (widget.file.fileSize ?? total);
            if (_progress == 1) {
              showShortToast(context, "Decrypting video...");
            }
          });
        }
      },
    ).then((file) {
      if (file != null) {
        _setVideoPlayerController(file: file);
      }
    });
  }

  @override
  void dispose() {
    if (_videoPlayerController != null) {
      _videoPlayerController.dispose();
    }
    if (_chewieController != null) {
      _chewieController.dispose();
    }
    super.dispose();
  }

  VideoPlayerController _setVideoPlayerController({String url, io.File file}) {
    VideoPlayerController videoPlayerController;
    if (url != null) {
      videoPlayerController = VideoPlayerController.network(url);
    } else {
      videoPlayerController = VideoPlayerController.file(file);
    }
    return _videoPlayerController = videoPlayerController
      ..initialize().whenComplete(() {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    final content = _videoPlayerController != null &&
            _videoPlayerController.value.isInitialized
        ? _getVideoPlayer()
        : _getLoadingWidget();
    final contentWithDetector = GestureDetector(
      child: content,
      onVerticalDragUpdate: (d) => {
        if (d.delta.dy > dragSensitivity) {Navigator.of(context).pop()}
      },
    );
    return VisibilityDetector(
      key: Key(widget.file.tag),
      onVisibilityChanged: (info) {
        if (info.visibleFraction < 1) {
          if (mounted && _chewieController != null) {
            _chewieController.pause();
          }
        }
      },
      child: Hero(
        tag: widget.tagPrefix + widget.file.tag,
        child: contentWithDetector,
      ),
    );
  }

  Widget _getLoadingWidget() {
    return Stack(
      children: [
        _getThumbnail(),
        Container(
          color: Colors.black12,
          constraints: const BoxConstraints.expand(),
        ),
        Center(
          child: SizedBox.fromSize(
            size: const Size.square(30),
            child: _progress == null || _progress == 1
                ? const CupertinoActivityIndicator(
                    color: Colors.white,
                  )
                : CircularProgressIndicator(
                    backgroundColor: Colors.black,
                    value: _progress,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color.fromRGBO(45, 194, 98, 1.0),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _getThumbnail() {
    return Container(
      color: Colors.black,
      constraints: const BoxConstraints.expand(),
      child: ThumbnailWidget(
        widget.file,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _getVideoPlayer() {
    _videoPlayerController.addListener(() {
      if (_isPlaying != _videoPlayerController.value.isPlaying) {
        _isPlaying = _videoPlayerController.value.isPlaying;
        if (widget.playbackCallback != null) {
          widget.playbackCallback(_isPlaying);
        }
      }
    });
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      autoPlay: widget.autoPlay,
      autoInitialize: true,
      looping: true,
      allowMuting: true,
      allowFullScreen: false,
      customControls: const VideoControls(),
    );
    return Container(
      color: Colors.black,
      child: Chewie(controller: _chewieController),
    );
  }
}
