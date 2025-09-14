import 'package:flutter/material.dart';
import 'package:shorts_example/widgets/action_button.dart';
import 'package:video_player/video_player.dart';

class ShortItem extends StatefulWidget {
  final String videoUrl;
  final bool isPlaying;

  const ShortItem({super.key, required this.videoUrl, required this.isPlaying});

  @override
  State<ShortItem> createState() => _ShortItemState();
}

class _ShortItemState extends State<ShortItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  double _opacity = 0.0;

  void _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();
      _controller.setLooping(true);
      setState(() {
        _isInitialized = true;
      });
      _controller.play();
    } catch (e) {
      setState(() {
        _isInitialized = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _onIconTap() {
    if (_isInitialized) {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }

      setState(() {
        _opacity = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 비디오 플레이어
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: _isInitialized
              ? FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : Center(child: CircularProgressIndicator(color: Colors.white)),
        ),

        // 재생/일시정지 버튼 (탭으로 토글)
        GestureDetector(
          onTap: _onIconTap,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: AnimatedOpacity(
              onEnd: () {
                setState(() {
                  _opacity = 0.0;
                });
              },
              opacity: _opacity,
              duration: Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              child: Center(
                child: _isInitialized && _controller.value.isPlaying
                    ? Icon(
                        Icons.pause,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.8),
                      )
                    : Icon(
                        Icons.play_arrow,
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
              ),
            ),
          ),
        ),
        // 오른쪽 사이드 UI (좋아요, 댓글, 공유 등)
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              ActionButton(
                icon: Icons.favorite,
                count: '1.2K',
                onClick: () {
                  print("click1");
                },
              ),
              SizedBox(height: 20),
              ActionButton(
                icon: Icons.comment,
                count: '128',
                onClick: () {
                  print("click2");
                },
              ),
              SizedBox(height: 20),
              ActionButton(
                icon: Icons.share,
                count: '64',
                onClick: () {
                  print("click3");
                },
              ),
            ],
          ),
        ),
        // 하단 정보 (제목, 설명 등)
        Positioned(
          left: 16,
          bottom: 80,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@username',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '비디오 설명이 여기에 표시됩니다. 재미있는 쇼츠 비디오!',
                style: TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
