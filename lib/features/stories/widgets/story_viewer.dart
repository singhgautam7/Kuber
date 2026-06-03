import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_theme.dart';
import '../models/story_icons.dart';
import '../models/story_models.dart';
import 'story_slide_view.dart';

const _slideDuration = Duration(seconds: 5);

/// A single slide within a bubble's flattened sequence, paired with the story
/// it belongs to (so we can mark the right story's slide as seen).
class _FlatSlide {
  final StoryViewData story;
  final int localIndex;
  final StorySlide slide;
  const _FlatSlide(this.story, this.localIndex, this.slide);
}

/// Full-screen viewer over a list of [bubbles]. It plays the bubble at
/// [initialBubbleIndex] from its first unread slide, and on reaching the end of
/// a bubble auto-advances to the next one (WhatsApp-style) instead of closing.
class StoryViewer extends StatefulWidget {
  final List<StoryBubble> bubbles;
  final int initialBubbleIndex;

  /// Home ring: `true` — advancing skips fully-read bubbles and closes once no
  /// unread bubble remains ahead. Archive: `false` — advance through every
  /// bubble in order.
  final bool advanceUnreadOnly;
  final void Function(String storyId, int slideIndex)? onSeen;

  const StoryViewer({
    super.key,
    required this.bubbles,
    this.initialBubbleIndex = 0,
    this.advanceUnreadOnly = false,
    this.onSeen,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;
  late int _bubbleIndex;
  List<_FlatSlide> _slides = const [];
  int _slideIndex = 0;

  _FlatSlide get _current => _slides[_slideIndex];

  @override
  void initState() {
    super.initState();
    _bubbleIndex = widget.bubbles.isEmpty
        ? 0
        : widget.initialBubbleIndex.clamp(0, widget.bubbles.length - 1);
    _loadBubble();
    _progress = AnimationController(vsync: this, duration: _slideDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _next();
      });
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _markSeen();
    _progress.dispose();
    super.dispose();
  }

  /// Flattens the current bubble's stories into one slide sequence and positions
  /// at the first unread slide (or the last, when arriving from a "previous").
  void _loadBubble({bool fromEnd = false}) {
    if (widget.bubbles.isEmpty) {
      _slides = const [];
      _slideIndex = 0;
      return;
    }
    final bubble = widget.bubbles[_bubbleIndex];
    _slides = [
      for (final s in bubble.stories)
        for (var i = 0; i < s.slides.length; i++) _FlatSlide(s, i, s.slides[i]),
    ];
    if (_slides.isEmpty) {
      _slideIndex = 0;
      return;
    }
    if (fromEnd) {
      _slideIndex = _slides.length - 1;
    } else {
      final firstUnseen = _slides.indexWhere(
        (f) => !f.story.seenSlides.contains(f.localIndex),
      );
      _slideIndex = firstUnseen >= 0 ? firstUnseen : 0;
    }
  }

  void _markSeen() {
    if (_slides.isEmpty) return;
    widget.onSeen?.call(_current.story.id.toString(), _current.localIndex);
  }

  void _start() {
    if (_slides.isEmpty) {
      Navigator.of(context).maybePop();
      return;
    }
    _markSeen();
    _progress
      ..reset()
      ..forward();
    if (mounted) setState(() {});
  }

  void _next() {
    if (_slideIndex < _slides.length - 1) {
      setState(() => _slideIndex++);
      _markSeen();
      _progress
        ..reset()
        ..forward();
    } else {
      _nextBubble();
    }
  }

  /// Advance to the next bubble. On the home ring, skip fully-read bubbles and
  /// close when none with unread remain; in the archive, just go to the next.
  void _nextBubble() {
    for (var i = _bubbleIndex + 1; i < widget.bubbles.length; i++) {
      final hasUnread = widget.bubbles[i].stories.any((s) => !s.seen);
      if (!widget.advanceUnreadOnly || hasUnread) {
        setState(() {
          _bubbleIndex = i;
          _loadBubble();
        });
        _markSeen();
        _progress
          ..reset()
          ..forward();
        return;
      }
    }
    Navigator.of(context).maybePop();
  }

  void _prev() {
    if (_slideIndex > 0) {
      setState(() => _slideIndex--);
      _progress
        ..reset()
        ..forward();
    } else if (_bubbleIndex > 0) {
      setState(() {
        _bubbleIndex--;
        _loadBubble(fromEnd: true);
      });
      _progress
        ..reset()
        ..forward();
    } else {
      _progress
        ..reset()
        ..forward();
    }
  }

  void _onTapUp(TapUpDetails details, BoxConstraints constraints) {
    if (details.localPosition.dx < constraints.maxWidth * 0.32) {
      _prev();
    } else {
      _next();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_slides.isEmpty) return const SizedBox.shrink();
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: StorySlideView(
                      key: ValueKey('${_bubbleIndex}_$_slideIndex'),
                      slide: _current.slide,
                    ),
                  ),
                  _ProgressBars(
                    count: _slides.length,
                    currentIndex: _slideIndex,
                    controller: _progress,
                  ),
                  _TopChrome(
                    story: _current.story,
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
      right: 18,
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
                    style: AppTextStyles.inter.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  story.timeLabel,
                  style: AppTextStyles.inter.copyWith(
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
