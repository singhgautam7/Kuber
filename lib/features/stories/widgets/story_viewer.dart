import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_theme.dart';
import '../models/story_icons.dart';
import '../models/story_models.dart';
import 'story_slide_view.dart';

// Matches `applicationId` in android/app/build.gradle.kts. Appended to text
// shares so recipients can download Kuber directly.
const _playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.grs.kuber';

const _slideDuration = Duration(seconds: 5);
const _bubbleTransition = Duration(milliseconds: 300);

/// A single slide within a bubble's flattened sequence, paired with the story
/// it belongs to (so we can mark the right story's slide as seen).
class _FlatSlide {
  final StoryViewData story;
  final int localIndex;
  final StorySlide slide;
  const _FlatSlide(this.story, this.localIndex, this.slide);
}

/// Full-screen viewer over [bubbles].
///
/// Gestures (kept deliberately simple):
///  - tap right third  -> next slide  (crosses into the next bubble at the end)
///  - tap left third   -> previous slide / previous bubble
///  - swipe left/right  -> next / previous bubble (animated)
///  - long-press        -> pause; release resumes
///  - swipe down        -> dismiss
///
/// Forward (auto-advance, tap-at-end, swipe-left) moves to the next bubble that
/// still has an unread story and closes when none remain ahead — unless
/// [advanceUnreadOnly] is false (archive), where it walks every bubble in order.
class StoryViewer extends StatefulWidget {
  final List<StoryBubble> bubbles;
  final int initialBubbleIndex;
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
  late final PageController _pageController;
  late final AnimationController _progress;
  late int _bubbleIndex;
  List<_FlatSlide> _slides = const [];
  int _slideIndex = 0;

  /// Wraps the active slide so it can be captured to an image for sharing.
  final GlobalKey _shareBoundaryKey = GlobalKey();
  bool _sharing = false;

  _FlatSlide get _current => _slides[_slideIndex];

  @override
  void initState() {
    super.initState();
    _bubbleIndex = widget.bubbles.isEmpty
        ? 0
        : widget.initialBubbleIndex.clamp(0, widget.bubbles.length - 1);
    _pageController = PageController(initialPage: _bubbleIndex);
    _loadActiveBubble();
    _progress = AnimationController(vsync: this, duration: _slideDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _nextSlide();
      });
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _markSeen();
    _pageController.dispose();
    _progress.dispose();
    super.dispose();
  }

  List<_FlatSlide> _flatten(StoryBubble bubble) => [
    for (final s in bubble.stories)
      for (var i = 0; i < s.slides.length; i++) _FlatSlide(s, i, s.slides[i]),
  ];

  /// Loads the active bubble's slides and positions at its first unread slide.
  void _loadActiveBubble() {
    if (widget.bubbles.isEmpty) {
      _slides = const [];
      _slideIndex = 0;
      return;
    }
    _slides = _flatten(widget.bubbles[_bubbleIndex]);
    final firstUnseen = _slides.indexWhere(
      (f) => !f.story.seenSlides.contains(f.localIndex),
    );
    _slideIndex = firstUnseen >= 0 ? firstUnseen : 0;
  }

  void _markSeen() {
    if (_slides.isEmpty) return;
    widget.onSeen?.call(_current.story.id.toString(), _current.localIndex);
  }

  // ── Sharing ──────────────────────────────────────────────────────────
  /// Composes a plain-text summary of the current story (one line per slide)
  /// plus the Play Store link.
  String _composeShareText(StoryViewData story) {
    final buf = StringBuffer();
    final header = story.timeLabel.trim().isEmpty
        ? story.label
        : '${story.label} · ${story.timeLabel}';
    buf.writeln(header);
    buf.writeln();
    for (final s in story.slides) {
      final title = s.title.trim();
      final subtitle = s.subtitle?.trim() ?? '';
      if (title.isEmpty && subtitle.isEmpty) continue;
      buf.writeln(subtitle.isEmpty ? title : '$title: $subtitle');
    }
    buf.writeln();
    buf.write('Track your finances with Kuber: $_playStoreUrl');
    return buf.toString();
  }

  /// Captures the active slide's [RepaintBoundary] to PNG bytes.
  Future<Uint8List?> _captureSlideImage() async {
    final boundary = _shareBoundaryKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final image = await boundary.toImage(pixelRatio: dpr);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  /// Shares the current slide as an image with the text summary as caption.
  /// share_plus accepts both in one invocation, so the system sheet lets the
  /// recipient app use whichever it supports. Falls back to text-only if the
  /// capture fails. Progress is paused while the share sheet is open.
  Future<void> _shareCurrentStory() async {
    if (_sharing || _slides.isEmpty) return;
    _sharing = true;
    _progress.stop();
    final story = _current.story;
    final text = _composeShareText(story);
    try {
      final bytes = await _captureSlideImage();
      final params = bytes != null
          ? ShareParams(
              text: text,
              files: [
                XFile.fromData(
                  bytes,
                  name: 'kuber_story.png',
                  mimeType: 'image/png',
                ),
              ],
            )
          : ShareParams(text: text);
      await SharePlus.instance.share(params);
    } catch (_) {
      try {
        await SharePlus.instance.share(ShareParams(text: text));
      } catch (_) {
        // Sharing unavailable; nothing more we can do.
      }
    } finally {
      _sharing = false;
      if (mounted) _progress.forward();
    }
  }

  void _restartProgress() => _progress
    ..reset()
    ..forward();

  void _start() {
    if (_slides.isEmpty) {
      Navigator.of(context).maybePop();
      return;
    }
    _markSeen();
    _restartProgress();
    if (mounted) setState(() {});
  }

  // ── Slide navigation ─────────────────────────────────────────────────
  void _nextSlide() {
    if (_slideIndex < _slides.length - 1) {
      setState(() => _slideIndex++);
      _markSeen();
      _restartProgress();
    } else {
      _forwardBubble();
    }
  }

  void _prevSlide() {
    if (_slideIndex > 0) {
      setState(() => _slideIndex--);
      _restartProgress();
    } else {
      _backwardBubble();
    }
  }

  // ── Bubble navigation ────────────────────────────────────────────────
  void _forwardBubble() {
    if (_bubbleIndex >= widget.bubbles.length - 1) {
      Navigator.of(context).maybePop();
      return;
    }
    final currentUnread = widget.bubbles[_bubbleIndex].stories.any((s) => !s.seen);
    final nextUnread = widget.bubbles[_bubbleIndex + 1].stories.any((s) => !s.seen);
    // From an unread bubble we only continue into more unread bubbles; once
    // there is nothing unread ahead, close. From a read bubble (or archive),
    // walk to the next bubble regardless.
    if (widget.advanceUnreadOnly && currentUnread && !nextUnread) {
      Navigator.of(context).maybePop();
      return;
    }
    _pageController.nextPage(duration: _bubbleTransition, curve: Curves.easeOutCubic);
  }

  void _backwardBubble({bool closeAtStart = false}) {
    if (_bubbleIndex > 0) {
      _pageController.previousPage(
        duration: _bubbleTransition,
        curve: Curves.easeOutCubic,
      );
    } else if (closeAtStart) {
      Navigator.of(context).maybePop(); // swiped back past the first bubble
    } else {
      _restartProgress(); // tapped back at the very start
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _bubbleIndex = index;
      _loadActiveBubble();
    });
    _markSeen();
    _restartProgress();
  }

  void _onTapUp(TapUpDetails details, BoxConstraints constraints) {
    if (details.localPosition.dx < constraints.maxWidth * 0.32) {
      _prevSlide();
    } else {
      _nextSlide();
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final v = details.primaryVelocity ?? 0;
    if (v < -100) {
      _forwardBubble(); // swipe right-to-left (closes past the last bubble)
    } else if (v > 100) {
      _backwardBubble(closeAtStart: true); // swipe left-to-right (closes before the first)
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
              onHorizontalDragEnd: _onHorizontalDragEnd,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: _onPageChanged,
                    itemCount: widget.bubbles.length,
                    itemBuilder: (context, i) {
                      final isActive = i == _bubbleIndex;
                      final flat = isActive
                          ? _slides
                          : _flatten(widget.bubbles[i]);
                      if (flat.isEmpty) return const ColoredBox(color: Colors.black);
                      final slideIndex = isActive ? _slideIndex : 0;
                      final switcher = AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: StorySlideView(
                          key: ValueKey('${i}_$slideIndex'),
                          slide: flat[slideIndex].slide,
                        ),
                      );
                      // Only the active page is captured for sharing.
                      return isActive
                          ? RepaintBoundary(
                              key: _shareBoundaryKey,
                              child: switcher,
                            )
                          : switcher;
                    },
                  ),
                  _ProgressBars(
                    count: _slides.length,
                    currentIndex: _slideIndex,
                    controller: _progress,
                  ),
                  _TopChrome(
                    story: _current.story,
                    onClose: () => Navigator.of(context).maybePop(),
                    onShare: _shareCurrentStory,
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
  final VoidCallback onShare;

  const _TopChrome({
    required this.story,
    required this.onClose,
    required this.onShare,
  });

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
            onTap: onShare,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.ios_share_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
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
