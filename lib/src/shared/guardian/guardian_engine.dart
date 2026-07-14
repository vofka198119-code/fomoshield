// ---------------------------------------------------------------------------
// GuardianIntelligenceEngine — Emotional UX Module (Design Bible Part 10)
// ---------------------------------------------------------------------------
// 300+ сообщений, память решений, детекция milestone'ов.
//
// Принципы:
//   1. Guardian никогда не оценивает человека ("You were wrong" — запрещено)
//   2. Guardian не даёт советов Buy/Sell/Hold
//   3. Guardian всегда говорит спокойно
//   4. Связывает прошлое поведение с текущим результатом
//   5. max 2 строки на экране
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/guardian/guardian_data.dart';

// ═══════════════════════════════════════════════════════════════════════════
//  UserAction — действия пользователя, на которые Guardian реагирует
// ═══════════════════════════════════════════════════════════════════════════

/// Действие пользователя, к которому Guardian подбирает фразу.
enum UserAction {
  /// Продажа в панике на дне рынка
  panicSell,

  /// Покупка на хаях (FOMO)
  boughtOnHype,

  /// Следование стратегии (не поддался эмоциям)
  followsStrategy,

  /// Удержание позиции во время просадки
  heldDrawdown,

  /// Высокий FS Score в вердикте
  highFSScore,

  /// Покупка актива (обычная)
  boughtAsset,

  /// Продажа актива (обычная)
  soldAsset,

  /// Завершение стресс-теста
  completedTest,

  /// Старт нового стресс-теста
  startedTest,
}

// ═══════════════════════════════════════════════════════════════════════════
//  GuardianMilestone — особые события
// ═══════════════════════════════════════════════════════════════════════════

/// Особое событие, которое отмечает Guardian.
enum GuardianMilestone {
  /// 50 завершённых стресс-тестов
  fiftyTests,

  /// 100 завершённых стресс-тестов
  hundredTests,

  /// 1 год использования приложения
  oneYearUsage,
}

// ═══════════════════════════════════════════════════════════════════════════
//  GuardianMemoryData — состояние памяти Guardian
// ═══════════════════════════════════════════════════════════════════════════

/// Состояние памяти Guardian, сохраняемое в SharedPreferences.
class GuardianMemoryData {
  /// Сколько всего стресс-тестов завершено.
  final int completedTests;

  /// Счётчики по каждому типу действий.
  final Map<String, int> actionCounts;

  /// Дата первого использования приложения (millisecondsSinceEpoch).
  final int firstUsedMs;

  /// Последняя дата активности.
  final int lastActiveMs;

  /// Какие milestones уже были показаны.
  final Set<String> shownMilestones;

  const GuardianMemoryData({
    this.completedTests = 0,
    this.actionCounts = const {},
    this.firstUsedMs = 0,
    this.lastActiveMs = 0,
    this.shownMilestones = const {},
  });

  Map<String, dynamic> toJson() => {
    'completedTests': completedTests,
    'actionCounts': actionCounts,
    'firstUsedMs': firstUsedMs,
    'lastActiveMs': lastActiveMs,
    'shownMilestones': shownMilestones.toList(),
  };

  factory GuardianMemoryData.fromJson(Map<String, dynamic> json) =>
      GuardianMemoryData(
        completedTests: (json['completedTests'] as num?)?.toInt() ?? 0,
        actionCounts: Map<String, int>.from(
          (json['actionCounts'] as Map?)?.map(
                (k, v) => MapEntry(k, (v as num).toInt()),
              ) ??
              {},
        ),
        firstUsedMs: (json['firstUsedMs'] as num?)?.toInt() ?? 0,
        lastActiveMs: (json['lastActiveMs'] as num?)?.toInt() ?? 0,
        shownMilestones: Set<String>.from(
          (json['shownMilestones'] as List?)?.cast<String>() ?? [],
        ),
      );

  GuardianMemoryData copyWith({
    int? completedTests,
    Map<String, int>? actionCounts,
    int? firstUsedMs,
    int? lastActiveMs,
    Set<String>? shownMilestones,
  }) => GuardianMemoryData(
    completedTests: completedTests ?? this.completedTests,
    actionCounts: actionCounts ?? this.actionCounts,
    firstUsedMs: firstUsedMs ?? this.firstUsedMs,
    lastActiveMs: lastActiveMs ?? this.lastActiveMs,
    shownMilestones: shownMilestones ?? this.shownMilestones,
  );
}

// ═══════════════════════════════════════════════════════════════════════════
//  GuardianIntelligenceEngine — центральный модуль
// ═══════════════════════════════════════════════════════════════════════════

/// Центральный модуль Emotional UX.
///
/// Использование:
/// ```dart
/// final engine = GuardianIntelligenceEngine(sp);
/// final msg = engine.selectMessage(
///   state: GuardianState.bull,
///   action: UserAction.boughtOnHype,
///   temperature: 45,
/// );
/// engine.recordAction(UserAction.completedTest);
/// ```
class GuardianIntelligenceEngine {
  final SharedPreferences _prefs;
  static const _storageKey = 'guardian_memory';

  GuardianMemoryData _memory;

  GuardianIntelligenceEngine(this._prefs) : _memory = GuardianMemoryData() {
    _load();
  }

  // ── Публичное API ─────────────────────────────────────────────────

  /// Текущая память Guardian.
  GuardianMemoryData get memory => _memory;

  /// Выбрать фразу для данного состояния рынка + действия пользователя.
  ///
  /// Сначала проверяет milestones, затем ищет по (action, temperature).
  /// Если action не указан — возвращает сообщение о состоянии рынка.
  String selectMessage({
    required GuardianState state,
    UserAction? action,
    double temperature = 0,
  }) {
    // 1. Проверяем milestones
    final milestone = _checkMilestone();
    if (milestone != null) {
      return _milestoneMessage(milestone);
    }

    // 2. Если есть действие — выбираем из action-специфичных сообщений
    if (action != null) {
      final band = _temperatureBand(temperature);
      final actionMessages = _actionMessages(action, band);
      if (actionMessages.isNotEmpty) {
        return _pick(actionMessages, temperature);
      }
    }

    // 3. Fallback — сообщение о состоянии рынка
    return GuardianMessages.forTemperature(temperature, state);
  }

  /// Записать действие пользователя в память Guardian.
  Future<void> recordAction(UserAction action) async {
    final key = action.name;
    final counts = Map<String, int>.from(_memory.actionCounts);
    counts[key] = (counts[key] ?? 0) + 1;

    _memory = _memory.copyWith(
      actionCounts: counts,
      lastActiveMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _save();
  }

  /// Записать завершение стресс-теста.
  Future<void> recordTestCompleted() async {
    _memory = _memory.copyWith(
      completedTests: _memory.completedTests + 1,
      lastActiveMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _save();
  }

  /// Отметить milestone как показанный.
  Future<void> markMilestoneShown(GuardianMilestone milestone) async {
    final shown = Set<String>.from(_memory.shownMilestones);
    shown.add(milestone.name);
    _memory = _memory.copyWith(shownMilestones: shown);
    await _save();
  }

  /// Получить количество повторений действия.
  int actionCount(UserAction action) => _memory.actionCounts[action.name] ?? 0;

  /// Проверить, был ли milestone уже показан.
  bool isMilestoneShown(GuardianMilestone milestone) =>
      _memory.shownMilestones.contains(milestone.name);

  /// Проверить, является ли эта сессия первой для пользователя.
  bool get isFirstSession => _memory.completedTests == 0;

  // ── Приватные методы ───────────────────────────────────────────────

  String _temperatureBand(double t) {
    if (t >= 60) return 'euphoria';
    if (t >= 30) return 'greedy';
    if (t >= 10) return 'optimistic';
    if (t >= -10) return 'neutral';
    if (t >= -30) return 'anxious';
    if (t >= -60) return 'fear';
    return 'panic';
  }

  /// Выбрать сообщение из списка, используя детерминированный выбор
  /// на основе температуры (чтобы не было чисто random).
  String _pick(List<String> messages, double temperature) {
    if (messages.isEmpty) return '';
    final idx = (temperature.abs() * 100).round() % messages.length;
    return messages[idx];
  }

  GuardianMilestone? _checkMilestone() {
    final ct = _memory.completedTests;
    if (ct >= 100 && !_memory.shownMilestones.contains('hundredTests')) {
      return GuardianMilestone.hundredTests;
    }
    if (ct >= 50 && !_memory.shownMilestones.contains('fiftyTests')) {
      return GuardianMilestone.fiftyTests;
    }
    if (_memory.firstUsedMs > 0) {
      final first = DateTime.fromMillisecondsSinceEpoch(_memory.firstUsedMs);
      final now = DateTime.now();
      if (now.difference(first).inDays >= 365 &&
          !_memory.shownMilestones.contains('oneYearUsage')) {
        return GuardianMilestone.oneYearUsage;
      }
    }
    return null;
  }

  String _milestoneMessage(GuardianMilestone milestone) => switch (milestone) {
    GuardianMilestone.fiftyTests =>
      'Fifty simulations. Fifty lessons. You are building a discipline '
          'that most investors never develop.',
    GuardianMilestone.hundredTests =>
      'One hundred stress tests. You have seen more market cycles than '
          'most retail investors see in a lifetime.',
    GuardianMilestone.oneYearUsage =>
      'One year of training. The habits you build here will serve you '
          'for a lifetime of investing.',
  };

  // ── Message library ────────────────────────────────────────────────

  /// Получить сообщения для (action, temperatureBand).
  List<String> _actionMessages(UserAction action, String band) {
    return switch (action) {
      UserAction.panicSell => _panicSellMessages[band] ?? [],
      UserAction.boughtOnHype => _boughtOnHypeMessages[band] ?? [],
      UserAction.followsStrategy => _followsStrategyMessages[band] ?? [],
      UserAction.heldDrawdown => _heldDrawdownMessages[band] ?? [],
      UserAction.highFSScore => _highFSScoreMessages[band] ?? [],
      UserAction.boughtAsset => _boughtAssetMessages[band] ?? [],
      UserAction.soldAsset => _soldAssetMessages[band] ?? [],
      UserAction.completedTest => _completedTestMessages[band] ?? [],
      UserAction.startedTest => _startedTestMessages[band] ?? [],
    };
  }

  // ── PANIC SELL (49 messages) ───────────────────────────────────────
  static final Map<String, List<String>> _panicSellMessages = {
    'euphoria': [
      'Selling at the top takes discipline. You recognized the euphoria.',
      'Taking profits in a euphoric market is a sign of maturity.',
      'You sold while others were still dreaming. That takes strength.',
      'In euphoria, the smartest move is often to step back.',
      'Exiting during euphoria protects your capital from the hangover.',
      'Some of the most profitable exits happen when others are still buying.',
      'Discipline in euphoria is rare. You showed it today.',
    ],
    'greedy': [
      'You sold when greed was peaking. That is self-awareness.',
      'Greed makes us hold too long. You broke the pattern.',
      'Recognizing when greed has taken over is a skill.',
      'Selling during greed requires more courage than buying during fear.',
      'Taking money off the table when others chase — wise.',
      'Greed whispers "just a little more." You chose to listen to reason.',
      'Exiting in a greedy market protects your gains.',
    ],
    'optimistic': [
      'You sold while optimism was still high. Prudent.',
      'Optimism can blind us to risk. You kept your eyes open.',
      'Selling into strength is a classic disciplined move.',
      'When optimism peaks, disciplined sellers take profits.',
      'Optimistic markets reward those who know when to stop.',
      'You did not let optimism override your strategy.',
      'Selling in optimism is not pessimism. It is protection.',
    ],
    'neutral': [
      'You executed a sale in a calm market. No drama, just discipline.',
      'Selling is not giving up. It is making room for the next opportunity.',
      'A well-timed exit is as important as a well-timed entry.',
      'You sold because your strategy said so. That is the right reason.',
      'Detached decision-making is the hallmark of a good investor.',
      'Every sale is a lesson. What did you learn from this one?',
      'You followed your plan. That is what matters.',
    ],
    'anxious': [
      'Anxiety can trigger premature selling. Breathe and review your plan.',
      'When anxiety rises, the temptation to sell grows. You chose to act.',
      'Selling from anxiety can be a signal to re-evaluate your strategy.',
      'Anxious markets reward patience, not impulsiveness.',
      'Did you sell because of the news or because of your plan?',
      'Anxiety is loud. A clear strategy helps cut through the noise.',
      'When unsure, zoom out. The long-term trend is your friend.',
    ],
    'fear': [
      'Fear makes us sell low. Reflect on what triggered this decision.',
      'Selling in fear often locks in losses. Review your rationale.',
      'Fear is a powerful force. Those who learn to pause often make clearer decisions.',
      'The market tests your resolve in moments of fear.',
      'Selling during fear can be protective or costly. Only time tells.',
      'When fear is high, ask: "Would I buy at this price?"',
      'Fear fades. Losses from panic selling can last much longer.',
    ],
    'panic': [
      'Panic sells can lock in losses. Take a breath and review.',
      'Extreme fear creates extreme opportunity — if you can stay calm.',
      'You sold in panic. This is exactly why you are training here.',
      'Panic is the enemy of reason. Every simulation teaches this.',
      'In panic, the mind races. An anchor helps find the way back.',
      'Remember: markets recover. Panic decisions often do not.',
      'This simulation is a safe place to experience panic and learn from it.',
    ],
  };

  // ── BOUGHT ON HYPE (49 messages) ──────────────────────────────────
  static final Map<String, List<String>> _boughtOnHypeMessages = {
    'euphoria': [
      'Buying in euphoria is tempting. Excitement feels like certainty.',
      'Euphoria makes every price look reasonable. Be careful.',
      'Many seasoned investors buy in fear, not in euphoria.',
      'When everyone is euphoric, prices already reflect the good news.',
      'Euphoria buying can work — but the risk is highest here.',
      'Remember: what goes up fast can come down faster.',
      'Euphoria is the most expensive emotion in investing.',
    ],
    'greedy': [
      'Greed makes every green candle look like an opportunity.',
      'Buying when others are greedy requires a strong exit plan.',
      'The line between opportunity and greed is thin.',
      'Greed whispers "this is different." It rarely is.',
      'Chasing momentum can work. An exit plan helps define the risk.',
      'Greed blinds us to valuation. Check the fundamentals.',
      'Momentum looks attractive today. Remember to separate excitement from opportunity.',
    ],
    'optimistic': [
      'Optimism is good. Overpaying is not.',
      'Buying in optimism is natural. Just check your entry price.',
      'Optimistic markets can continue higher — or reverse without warning.',
      'Buys that pair optimism with a margin of safety tend to age well.',
      'You bought because you see potential. That is valid.',
      'Optimism without analysis is just hope.',
      'A disciplined buyer in optimism still sets limits.',
    ],
    'neutral': [
      'You bought in a calm market. Good — decisions are clearest here.',
      'Neutral markets reward research and patience.',
      'Buying without emotional pressure leads to better entries.',
      'Trades that feel boring at the time are often the wisest.',
      'You bought because your analysis said so. Trust the process.',
      'Calm markets are where disciplined investors build positions.',
      'Every purchase is a thesis. What is yours?',
    ],
    'anxious': [
      'Buying when anxious? Make sure it is strategy, not impulse.',
      'Anxiety can make us act too quickly. Review your timing.',
      'When the market feels uneasy, smaller positions are safer.',
      'Anxious buying can be a hedge against regret. Check your motives.',
      'In anxious markets, incremental buys tend to age better than all-in bets.',
      'Anxiety and urgency are not the same thing.',
      'Breathe. Then decide if this buy fits your plan.',
    ],
    'fear': [
      'Buying when others are fearful — this is where fortunes are made.',
      'Fear often creates attractive entry points for long-term investors.',
      'You bought into fear. That takes courage and conviction.',
      'The most feared sectors sometimes hide the deepest bargains.',
      'Fear prices in the worst outcome. Reality is usually better.',
      'Buying in fear requires a strong stomach and a long timeline.',
      'You bought while others ran. That is the investor\'s edge.',
    ],
    'panic': [
      'Buying during panic is high risk, high reward. Keep position small.',
      'Panic can create once-in-a-decade buying opportunities.',
      'You bought in panic. Make sure you have a plan for further drops.',
      'Catching a falling knife is dangerous. Average in slowly.',
      'Panic buying requires the strongest conviction.',
      'Panic buys made with a list tend to outperform emotional ones.',
      'In panic, prices disconnect from value. That is where opportunity hides.',
    ],
  };

  // ── FOLLOWS STRATEGY (42 messages) ─────────────────────────────────
  static final Map<String, List<String>> _followsStrategyMessages = {
    'euphoria': [
      'Following your strategy in euphoria — the hardest discipline.',
      'When everyone chases, you stuck to the plan. Respect.',
      'Euphoria tests every investor. Your strategy passed.',
      'The crowd runs. You follow your compass.',
      'Strategy over emotion — even when emotion feels so good.',
      'This is what discipline looks like: calm in the chaos.',
      'You ignored the noise and followed the plan.',
    ],
    'greedy': [
      'Discipline in greed is rare. You have it.',
      'Greed tempts. Your strategy protects.',
      'You could have chased. You chose to wait.',
      'Sticking to the plan when green candles are everywhere — that is strength.',
      'Investors who last are not the smartest. They are the most disciplined.',
      'Greed fades. Strategy endures.',
      'You followed your rules when it was easier to break them.',
    ],
    'optimistic': [
      'You stuck to the strategy even when optimism felt safe.',
      'Optimism can lead to overconfidence. You stayed grounded.',
      'Following the plan in good times builds habits for bad times.',
      'Discipline is doing what you said you would do.',
      'Your strategy worked because you let it work.',
      'Optimistic markets reward the disciplined, not the reckless.',
      'You trusted your process. That is the foundation of success.',
    ],
    'neutral': [
      'You followed the strategy. No drama, just execution.',
      'Neutral markets are where good habits are built.',
      'The plan worked because you worked the plan.',
      'Boring is beautiful in investing.',
      'Consistency matters more than perfect timing.',
      'You did what you set out to do. That is enough.',
      'Every time you follow the plan, the plan gets stronger.',
    ],
    'anxious': [
      'You stuck to the strategy despite the anxiety. Well done.',
      'Anxiety makes us want to change everything. You held steady.',
      'Following the plan when nervous is the ultimate test.',
      'The strategy is your anchor in anxious waters.',
      'You felt the fear and followed the plan anyway.',
      'Anxious markets separate followers from leaders.',
      'Your discipline in uncertainty is your greatest asset.',
    ],
    'fear': [
      'Following the strategy in fear — this is where champions are made.',
      'Fear screams "do something." You did the right thing: nothing.',
      'In fear, staying the course has often rewarded those who could hold.',
      'You trusted your strategy when it was hardest to trust anything.',
      'Fear tests every plan. Yours held up.',
      'In fear, the strategy is your only reliable guide.',
      'You did not let fear rewrite your rules.',
    ],
    'panic': [
      'Following the strategy in panic is heroic discipline.',
      'Panic breaks most plans. Yours survived.',
      'You kept your head while others lost theirs.',
      'The strategy works in panic too — if you let it.',
      'Panic is the ultimate test of conviction. You passed.',
      'You proved that discipline beats panic every time.',
      'In the chaos, you found your center. That is the goal.',
    ],
  };

  // ── HELD DRAWDOWN (35 messages) ───────────────────────────────────
  static final Map<String, List<String>> _heldDrawdownMessages = {
    'euphoria': [
      'Holding during drawdown in euphoria — you know cycles repeat.',
      'You held because you understood this is temporary.',
      'Euphoria can hide drawdowns. You saw through it.',
    ],
    'greedy': [
      'Holding when everyone sells takes conviction.',
      'Drawdowns test patience. You held.',
      'Greed wants action. You chose stillness.',
      'You held because your thesis did not change.',
      'Recoveries are built by those who hold through the drawdown.',
    ],
    'optimistic': [
      'You held during the dip. Optimism backed by patience.',
      'Drawdowns are entry points for the prepared.',
      'Holding is not passive. It is an active decision.',
      'You knew the drawdown would pass. It will.',
      'Patience during drawdown is the mark of a mature investor.',
    ],
    'neutral': [
      'You held steady. Drawdowns are part of the journey.',
      'Markets go down. You stayed the course.',
      'Holding through a drawdown is not doing nothing. It is choosing.',
      'Patience during routine drawdowns tends to be rewarded over time.',
      'You did not panic. That is half the battle.',
    ],
    'anxious': [
      'Holding during drawdown when anxious — this is growth.',
      'Anxiety says sell. Wisdom says wait.',
      'You felt the drop and stayed. That is courage.',
      'Every drawdown you survive makes you stronger.',
      'The market rewards those who can sit still.',
    ],
    'fear': [
      'Holding in fear is the hardest thing to do. You did it.',
      'Fear says "get out." You said "stay the course."',
      'Drawdowns in fear are the ultimate patience test.',
      'You held when every instinct said run. That is discipline.',
      'The recovery belongs to those who hold through the fear.',
    ],
    'panic': [
      'Holding in panic — this is what the training is for.',
      'Panic drawdowns end. Holders survive to see the recovery.',
      'You held through the storm. The calm will come.',
      'This simulation teaches you: panic passes, losses can recover.',
      'You did what most cannot: hold during panic.',
    ],
  };

  // ── HIGH FS SCORE (35 messages) ────────────────────────────────────
  static final Map<String, List<String>> _highFSScoreMessages = {
    'euphoria': [
      'High score in euphoria — you kept your head while prices soared.',
      'Balance in euphoria is rare. You achieved it.',
      'Your score reflects discipline, not just returns.',
    ],
    'greedy': [
      'A strong score in a greedy market — you stayed grounded.',
      'Greed did not corrupt your judgment. That is the win.',
      'Your FS score proves discipline beats impulse.',
      'High score. High discipline. Well played.',
    ],
    'optimistic': [
      'Your FS score reflects calm, consistent decision-making.',
      'Optimism is good. Your score shows you balanced it with discipline.',
      'A high score means your strategy is working.',
      'You are building the habits of a successful investor.',
    ],
    'neutral': [
      'Solid FS score. Consistency is your superpower.',
      'Your score shows steady, rational decisions.',
      'No drama, just discipline. The score proves it.',
      'This is what good investing looks like.',
    ],
    'anxious': [
      'High score despite anxiety — you controlled your emotions.',
      'Anxiety did not break your discipline. Impressive.',
      'You scored well because you stayed calm under pressure.',
      'Decisions made in calm tend to be clearer than those made in panic.',
    ],
    'fear': [
      'A strong score in a fearful market — exceptional discipline.',
      'Fear did not control your decisions. You did.',
      'High score in fear means your strategy is rock solid.',
      'You kept fear in check. That is the whole point of this.',
    ],
    'panic': [
      'High FS score during panic — this is mastery.',
      'Panic breaks most traders. You thrived.',
      'You scored high when it mattered most. Outstanding.',
      'Panic could not shake your discipline. Excellent.',
    ],
  };

  // ── BOUGHT ASSET (35 messages) ────────────────────────────────────
  static final Map<String, List<String>> _boughtAssetMessages = {
    'euphoria': [
      'You bought in euphoria. Have a clear exit plan.',
      'Buying in euphoria can work if you know when to sell.',
      'Euphoria buys need the strongest conviction.',
      'Make sure your purchase is based on value, not hype.',
      'Euphoric markets reverse quickly. A clear exit plan helps you stay calm.',
    ],
    'greedy': [
      'You added a position. Make sure it fits your allocation plan.',
      'Buying in greed — size matters. Keep positions reasonable.',
      'New position means new commitment. Review your thesis.',
      'Greed can make us over-allocate. Check your portfolio balance.',
      'A good buy in greed is one you would also hold in fear.',
    ],
    'optimistic': [
      'You opened a new position. Optimism backed by research.',
      'Buying in optimism is natural. Just keep your targets clear.',
      'New positions bring new opportunities. And new risks.',
      'Optimism is a good backdrop for entry. Stay diversified.',
      'Every buy is a bet on the future. What is your timeframe?',
    ],
    'neutral': [
      'New position acquired. Clean entry in a neutral market.',
      'Neutral markets offer fair entries. Good timing.',
      'You bought without emotional pressure. Ideal conditions.',
      'A calm entry is a gift. Use it wisely.',
      'Every position starts with a single buy. This one looks clean.',
    ],
    'anxious': [
      'You bought in an anxious market. Keep your position size in check.',
      'Anxious markets can turn quickly. Consider a smaller entry.',
      'Buying in uncertainty — dollar-cost average if unsure.',
      'Anxiety in the market means higher volatility ahead.',
      'You bought despite the uncertainty. Have a plan for both outcomes.',
    ],
    'fear': [
      'Buying in fear — you see opportunity where others see danger.',
      'Fear creates discounts. You recognized one.',
      'Buying when others are fearful is the investor\'s edge.',
      'Fear prices in the worst. You bet on recovery.',
      'Purchases made in fear and sold in euphoria have a long track record of success.',
    ],
    'panic': [
      'You bought in panic. High risk, high potential reward.',
      'Panic purchases require the strongest stomach.',
      'Catching a falling knife — start small.',
      'You saw opportunity in the chaos. Keep your position manageable.',
      'Panic buys are for the brave. Have your exit ready.',
    ],
  };

  // ── SOLD ASSET (35 messages) ──────────────────────────────────────
  static final Map<String, List<String>> _soldAssetMessages = {
    'euphoria': [
      'You sold in euphoria. Profit-taking can lock in gains.',
      'Taking profits when everyone is greedy — textbook discipline.',
      'Selling in euphoria locks in gains. Well executed.',
      'The hardest sales are the ones that could have gone higher.',
      'You took money off the table. Smart.',
    ],
    'greedy': [
      'You sold while greed was still high. Good profit discipline.',
      'Selling in greed requires more courage than buying in fear.',
      'Taking profits is part of a healthy discipline.',
      'You locked in gains while others chased more.',
      'Every sale that follows your plan is a good sale.',
    ],
    'optimistic': [
      'You sold in optimism. Taking profits is part of the process.',
      'Selling into strength is a classic strategy.',
      'Optimistic markets reward sellers too.',
      'You exited with a profit. Every gain contributes to your track record.',
      'Selling when you have a gain aligns with discipline.',
    ],
    'neutral': [
      'You closed a position. Clean exit, no drama.',
      'A sale in a neutral market — executed without emotion.',
      'Every exit teaches something about your process.',
      'You sold because the plan said so. That is the right reason.',
      'Closing a position creates space for new opportunities.',
    ],
    'anxious': [
      'You sold in an anxious market. Review if it was plan or emotion.',
      'Anxiety can trigger exits. Make sure it was strategy.',
      'Selling when uneasy can protect capital. Or lock in losses.',
      'Did you sell because of fear or because of your thesis?',
      'Anxious exits deserve a post-mortem.',
    ],
    'fear': [
      'You sold in fear. Sometimes protection is the right call.',
      'Fear-based selling often locks in losses. Review your plan.',
      'Selling in fear can be smart risk management.',
      'Sells planned beforehand tend to fare better than reactive ones in fear.',
      'Fear fades. Make sure your sale was based on more than emotion.',
    ],
    'panic': [
      'You sold in panic. Use this as a learning moment.',
      'Panic exits are rarely optimal. Reflect on your triggers.',
      'Selling in panic can stop the bleeding. Or lock in losses.',
      'This is why we simulate — to learn without real cost.',
      'Panic teaches us what to do differently next time.',
    ],
  };

  // ── COMPLETED TEST (35 messages) ──────────────────────────────────
  static final Map<String, List<String>> _completedTestMessages = {
    'euphoria': [
      'Test complete. You experienced euphoria and survived it.',
      'Another simulation finished. Euphoria is dangerous — you know now.',
      'You completed a test in euphoric conditions. Valuable experience.',
      'The lesson: euphoria feels good but can be costly.',
      'You saw euphoria from the inside. That awareness is power.',
    ],
    'greedy': [
      'Test complete. Greed was tested. How did you do?',
      'Another simulation in the books. Greed is a tough opponent.',
      'You finished a test where greed was a factor. Reflect on it.',
      'Greed tempts every investor. You experienced it safely.',
      'The simulation showed you how greed affects decisions.',
    ],
    'optimistic': [
      'Test complete. Optimism is pleasant — but check your discipline.',
      'You finished. Optimism made it easy. Did it make you careless?',
      'Another simulation done. Review your choices in optimism.',
      'Optimistic markets are comfortable. Comfort can lead to complacency.',
      'After a good test is a natural time to review your strategy.',
    ],
    'neutral': [
      'Test complete. Steady conditions, steady decisions.',
      'Another simulation finished. Boring is beautiful.',
      'You completed a test in calm conditions. Solid execution.',
      'Neutral markets build good habits. Review your trades.',
      'Every test teaches something. What did this one teach you?',
    ],
    'anxious': [
      'Test complete. Anxious markets test your resolve.',
      'You finished despite the uncertainty. Well done.',
      'Anxiety makes every decision harder. You made them anyway.',
      'Another test survived. Anxiety did not stop you.',
      'Calm decisions tend to be the clearest. How did you handle it?',
    ],
    'fear': [
      'Test complete. Fear was present. You kept going.',
      'You finished a test in fear. That is real progress.',
      'Fear tests every strategy. Yours survived.',
      'Another simulation in fear. Each one builds resilience.',
      'You proved fear does not control your actions.',
    ],
    'panic': [
      'Test complete. You navigated panic and finished. That is growth.',
      'Another simulation survived. Panic is the hardest teacher.',
      'You finished a test in panic. Most people would quit.',
      'Panic did not defeat you. That is the lesson.',
      'Every panic test you complete makes you stronger.',
    ],
  };

  // ── STARTED TEST (21 messages) ────────────────────────────────────
  static final Map<String, List<String>> _startedTestMessages = {
    'euphoria': [
      'A new test begins in euphoria. Stay grounded.',
      'Euphoria is in the air. Let your strategy lead.',
      'Starting in euphoria — remember what brought you here.',
    ],
    'greedy': [
      'New test. Greed will tempt you. Stay disciplined.',
      'Starting fresh. The market is greedy. You stay focused.',
      'A new simulation. Greed is the enemy. You know this.',
    ],
    'optimistic': [
      'A new chapter begins. Optimism is your backdrop.',
      'Starting a test in optimism — a good mindset for learning.',
      'Fresh start. Optimistic markets are kind. Stay sharp.',
    ],
    'neutral': [
      'New simulation. Neutral markets are ideal for learning.',
      'Starting fresh. No emotional bias. Perfect for discipline.',
      'A clean slate. Let your strategy guide you.',
    ],
    'anxious': [
      'Starting in an anxious market. Every decision matters.',
      'New test. Uncertainty ahead. Your strategy is your anchor.',
      'Anxious markets reward the prepared. You are ready.',
    ],
    'fear': [
      'A new test in fear. This is where growth happens.',
      'Starting in fear — the hardest but most valuable conditions.',
      'Fear is a powerful teacher. This test will challenge you.',
    ],
    'panic': [
      'New test in panic. Extreme conditions build extreme resilience.',
      'Starting in panic. This is why you are here.',
      'Panic is the ultimate training ground. Let us begin.',
    ],
  };

  // ── Persistence ───────────────────────────────────────────────────

  void _load() {
    final raw = _prefs.getString(_storageKey);
    if (raw != null) {
      try {
        _memory = GuardianMemoryData.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        _memory = GuardianMemoryData();
      }
    }
    // Set firstUsed if not set
    if (_memory.firstUsedMs == 0) {
      _memory = _memory.copyWith(
        firstUsedMs: DateTime.now().millisecondsSinceEpoch,
      );
      _save();
    }
  }

  Future<void> _save() async {
    await _prefs.setString(_storageKey, jsonEncode(_memory.toJson()));
  }
}
