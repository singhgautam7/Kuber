import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../models/story_icons.dart';
import '../models/story_models.dart';
import 'story_slide_view.dart';

const _slideDuration = Duration(seconds: 5);

class StoryViewer extends StatefulWidget {
  final List<StoryViewData> stories;
  final int initialIndex;
  final void Function(String storyId, int slideIndex)? onSeen;

  const StoryViewer({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    this.onSeen,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _progress;
  int _storyIndex = 0;
  int _slideIndex = 0;

  StoryViewData get _story => widget.stories[_storyIndex];

  @override
  void initState() {
    super.initState();
    _storyIndex = widget.initialIndex.clamp(0, widget.stories.length - 1);
    _pageController = PageController(initialPage: _storyIndex);
    _progress = AnimationController(vsync: this, duration: _slideDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _nextSlide();
      });
    WidgetsBinding.instance.addPostFrameCallback((_) => _startStory());
  }

  @override
  void dispose() {
    widget.onSeen?.call(_story.id.toString(), _slideIndex);
    _pageController.dispose();
    _progress.dispose();
    super.dispose();
  }

  void _startStory({bool fromPrevious = false}) {
    if (fromPrevious) {
      _slideIndex = _story.slides.length - 1;
    } else {
      _slideIndex = 0;
      for (int i = 0; i < _story.slides.length; i++) {
        if (!_story.seenSlides.contains(i)) {
          _slideIndex = i;
          break;
        }
      }
    }
    widget.onSeen?.call(_story.id.toString(), _slideIndex);
    _progress
      ..reset()
      ..forward();
    if (mounted) setState(() {});
  }

  void _nextSlide() {
    if (_slideIndex < _story.slides.length - 1) {
      setState(() => _slideIndex++);
      widget.onSeen?.call(_story.id.toString(), _slideIndex);
      _progress
        ..reset()
        ..forward();
      return;
    }
    _nextStory();
  }

  void _prevSlide() {
    if (_slideIndex > 0) {
      setState(() => _slideIndex--);
      _progress
        ..reset()
        ..forward();
      return;
    }
    _prevStory();
  }

  void _nextStory() {
    if (_storyIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _prevStory() {
    if (_storyIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _progress
        ..reset()
        ..forward();
    }
  }

  void _onPageChanged(int index) {
    final backward = index < _storyIndex;
    _storyIndex = index;
    _startStory(fromPrevious: backward);
  }

  void _onTapUp(TapUpDetails details, BoxConstraints constraints) {
    if (details.localPosition.dx < constraints.maxWidth * 0.32) {
      _prevSlide();
    } else {
      _nextSlide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Dismissible(
        key: const Key('story_viewer_dismissible'),
        direction: DismissDirection.down,
        resizeDuration: null,
        onDismissed: (_) => Navigator.of(context).maybePop(),
        child: Container(
          color: Colors.black,
          child: LayoutBuilder(
            builder: (context, constraints) => GestureDetector(
              onTapUp: (details) => _onTapUp(details, constraints),
              onLongPressStart: (_) => _progress.stop(),
              onLongPressEnd: (_) => _progress.forward(),
              child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: widget.stories.length,
                itemBuilder: (context, storyIndex) {
                  final isActive = storyIndex == _storyIndex;
                  final slide = widget
                      .stories[storyIndex]
                      .slides[isActive ? _slideIndex : 0];
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: StorySlideView(
                      key: ValueKey(
                        '$storyIndex-${isActive ? _slideIndex : 0}',
                      ),
                      slide: slide,
                    ),
                  );
                },
              ),
              _ProgressBars(
                count: _story.slides.length,
                currentIndex: _slideIndex,
                controller: _progress,
              ),
              _TopChrome(
                story: _story,
                onClose: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }
}

class _ProgressBars extends StatelessWidget {
  final int count;
  final int currentIndex;
  final AnimationController controller;

  const _ProgressBars({
    required this.count,
    required this.currentIndex,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 14,
      right: 14,
      child: Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            Expanded(
              child: Container(
                height: 2.5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.30),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: i < currentIndex
                    ? _bar(1)
                    : i == currentIndex
                    ? AnimatedBuilder(
                        animation: controller,
                        builder: (_, __) => _bar(controller.value),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            if (i < count - 1) const SizedBox(width: 5),
          ],
        ],
      ),
    );
  }

  Widget _bar(double value) => FractionallySizedBox(
    alignment: Alignment.centerLeft,
    widthFactor: value.clamp(0, 1),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class _TopChrome extends StatelessWidget {
  final StoryViewData story;
  final VoidCallback onClose;

  const _TopChrome({required this.story, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 22,
      left: 18,
      right: 4,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(KuberRadius.md),
            ),
            alignment: Alignment.center,
            child: Icon(storyIcon(story.icon), size: 15, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    story.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  story.timeLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
