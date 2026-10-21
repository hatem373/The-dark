import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DayThreeVideoBackground extends StatefulWidget {
  const DayThreeVideoBackground({
    required this.videoPath,
    required this.onComplete,
    super.key,
  });

  final String videoPath;
  final VoidCallback onComplete;

  @override
  State<DayThreeVideoBackground> createState() =>
      _DayThreeVideoBackgroundState();
}

class _DayThreeVideoBackgroundState extends State<DayThreeVideoBackground> {
  late final VideoPlayerController _controller;
  bool _failed = false;
  bool _completionSent = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      widget.videoPath,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    )..addListener(_checkProgress);
    unawaited(_initializeVideo());
  }

  Future<void> _initializeVideo() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(false);
      await _controller.setPlaybackSpeed(0.65);
      await _controller.setVolume(1);
      await _controller.play();
      if (mounted) setState(() {});
    } catch (error) {
      debugPrint('Day three video failed: $error');
      _failed = true;
      if (mounted) {
        setState(() {});
        _completeVideo();
      }
    }
  }

  void _checkProgress() {
    if (_controller.value.isInitialized && _controller.value.isCompleted) {
      _completeVideo();
    }
  }

  void _completeVideo() {
    if (_completionSent) return;
    _completionSent = true;
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.removeListener(_checkProgress);
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || !_controller.value.isInitialized) {
      return const ColoredBox(color: Colors.black);
    }

    final videoSize = _controller.value.size;
    return ColoredBox(
      color: Colors.black,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: videoSize.width,
            height: videoSize.height,
            child: VideoPlayer(_controller),
          ),
        ),
      ),
    );
  }
}