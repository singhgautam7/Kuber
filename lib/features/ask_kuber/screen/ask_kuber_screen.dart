import 'dart:async';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/chat_message.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../providers/ask_kuber_providers.dart';
import 'ask_kuber_chrome.dart';
import 'ask_kuber_help.dart';
import 'chip_strip.dart';
import 'greeting.dart';
import 'message_bubble.dart';
import 'typing_indicator.dart';
import 'welcome_view.dart';

class AskKuberScreen extends ConsumerStatefulWidget {
  const AskKuberScreen({super.key});

  @override
  ConsumerState<AskKuberScreen> createState() => _AskKuberScreenState();
}

class _AskKuberScreenState extends ConsumerState<AskKuberScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isProcessing = false;
  bool _isInitializing = true;
  bool _isTyping = false;
  bool _pulseThinking = false;
  Timer? _typingTimer;
  String _greeting = 'Hello.';

  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _initialize();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _pulseCtrl.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final repo = ref.read(askKuberRepositoryProvider);
    final history = await repo.loadAll();
    final settings = await ref.read(settingsProvider.future);
    if (!mounted) return;
    setState(() {
      _messages
        ..clear()
        ..addAll(history);
      _greeting = composeAskGreeting(settings.userName, DateTime.now().hour);
      _isInitializing = false;
    });
    if (_messages.isNotEmpty) _scrollToBottom();
  }

  /// Single pulse controller; swaps to the faster, deeper "thinking" pulse.
  void _applyPulse(bool thinking) {
    if (thinking == _pulseThinking) return;
    _pulseThinking = thinking;
    _pulseCtrl.duration = Duration(milliseconds: thinking ? 900 : 1800);
    _pulseCtrl.repeat(reverse: true);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send([String? override]) async {
    final input = (override ?? _controller.text).trim();
    if (input.isEmpty || _isProcessing || _isTyping) return;
    if (override == null) _controller.clear();

    final repo = ref.read(askKuberRepositoryProvider);
    final userMsg =
        ChatMessage(text: input, isUser: true, time: DateTime.now());
    setState(() {
      _messages.add(userMsg);
      _isProcessing = true;
    });
    _applyPulse(true);
    _scrollToBottom();
    unawaited(repo.append(userMsg));

    final results = await Future.wait([
      _process(input),
      Future<void>.delayed(const Duration(milliseconds: 1000)),
    ]);
    final result = results.first as HandlerResult;
    if (!mounted) return;

    final kuberMsg = ChatMessage(
      text: '',
      isUser: false,
      time: DateTime.now(),
      thinking: result.thinking,
      vizPayload: result.vizPayload,
      followUps: result.followUps,
    );
    setState(() {
      _messages.add(kuberMsg);
      _isProcessing = false;
      _isTyping = true;
    });
    _scrollToBottom();
    _startTyping(kuberMsg, result.text);
  }

  Future<HandlerResult> _process(String input) async {
    final repo = ref.read(askKuberRepositoryProvider);
    final orchestrator = ref.read(queryOrchestratorProvider);
    final ctx = await QueryContext.build(input, ref);
    return orchestrator.process(
      ctx,
      onUnhandled: (raw) => unawaited(repo.logUnhandled(raw)),
    );
  }

  void _startTyping(ChatMessage msg, String full) {
    int i = 0;
    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      i = math.min(i + 4, full.length);
      setState(() => msg.text = full.substring(0, i));
      if (i >= full.length) {
        timer.cancel();
        setState(() => _isTyping = false);
        _applyPulse(false);
        // Persist the Kuber message once, with its final text.
        unawaited(ref.read(askKuberRepositoryProvider).append(msg));
      }
      if (i % 60 == 0) _scrollToBottom();
    });
  }

  void _navigate(String route) {
    try {
      context.go(route);
    } catch (_) {
      showKuberSnackBar(context, "That's no longer available", isError: true);
    }
  }

  void _howItWorks() =>
      KuberInfoBottomSheet.show(context, askKuberInfoConfig);

  Future<void> _copyLast() async {
    final last = _messages
        .lastWhereOrNull((m) => !m.isUser && m.text.trim().isNotEmpty);
    if (last == null) return;
    await Clipboard.setData(ClipboardData(text: last.text));
    if (mounted) showKuberSnackBar(context, 'Copied to clipboard');
  }

  Future<void> _clearChat() async {
    if (await _confirmClear() != true) return;
    await ref.read(askKuberRepositoryProvider).clear();
    _typingTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _messages.clear();
      _isProcessing = false;
      _isTyping = false;
    });
    _applyPulse(false);
  }

  Future<bool?> _confirmClear() {
    final cs = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        title: Text('Clear chat?',
            style: localeFont(
                fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
        content: Text('This removes the whole conversation.',
            style: localeFont(fontSize: 14, color: cs.onSurfaceVariant)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child:
                  Text('Cancel', style: localeFont(color: cs.onSurfaceVariant))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Clear', style: localeFont(color: cs.error))),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final thinking = _isProcessing || _isTyping;
    final showWelcome = !_isInitializing && _messages.every((m) => !m.isUser);
    final lastKuber = _messages.lastWhereOrNull((m) => !m.isUser);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          AskKuberHeader(
            pulse: _pulseCtrl,
            thinking: thinking,
            onHowItWorks: _howItWorks,
            onCopy: _copyLast,
            onClear: _clearChat,
          ),
          Divider(height: 1, color: cs.outline.withValues(alpha: 0.3)),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0, 0.02), end: Offset.zero)
                      .animate(anim),
                  child: child,
                ),
              ),
              child: _isInitializing
                  ? const SizedBox.shrink()
                  : showWelcome
                      ? WelcomeView(
                          key: const ValueKey('welcome'),
                          greeting: _greeting,
                          pulse: _pulseCtrl,
                          onSend: _send,
                        )
                      : _buildChatList(),
            ),
          ),
          // Suggestion chips reflect the latest response; hidden while typing or
          // when the input has text.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              final canShow = lastKuber != null &&
                  lastKuber.followUps.isNotEmpty &&
                  !_isProcessing &&
                  !_isTyping &&
                  value.text.trim().isEmpty;
              if (!canShow) return const SizedBox.shrink();
              return ChipStrip(
                key: ValueKey(lastKuber.time),
                actions: lastKuber.followUps,
                onAsk: _send,
                onNavigate: _navigate,
              );
            },
          ),
          ChatInputBar(
            controller: _controller,
            isProcessing: _isProcessing,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      key: const ValueKey('chat'),
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg, vertical: KuberSpacing.md),
      itemCount: _messages.length + (_isProcessing ? 1 : 0),
      itemBuilder: (context, i) {
        if (_isProcessing && i == _messages.length) {
          return const TypingIndicator();
        }
        final msg = _messages[i];
        final showDate =
            i == 0 || !_isSameDay(_messages[i - 1].time, msg.time);
        return Column(
          children: [
            if (showDate) DateSeparator(date: msg.time),
            MessageBubble(message: msg),
          ],
        );
      },
    );
  }
}
