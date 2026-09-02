// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get navHome => 'Главная';

  @override
  String get navSearch => 'Поиск';

  @override
  String get navPortfolio => 'Портфель';

  @override
  String get navStressTest => 'Симуляция рынка';

  @override
  String get navProfile => 'Профиль';

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageSystemDefault => 'Как в системе';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languagePickerSubtitle => 'Выберите язык интерфейса приложения.';

  @override
  String get themeTitle => 'Тема';

  @override
  String get themePickerSubtitle =>
      'Выберите визуальную тему приложения. Пока доступно только в admin-превью.';

  @override
  String get themeOptionStandard => 'Стандартная';

  @override
  String get themeOptionLuxuryGold => 'Luxury Gold';

  @override
  String get themeOptionBlackWhite => 'Black & White';

  @override
  String get themeOptionLightLime => 'Light Lime';

  @override
  String get themeOptionMidnightSea => 'Midnight Sea';

  @override
  String get authWelcomeBack => 'С возвращением';

  @override
  String get authCreateAccount => 'Создать аккаунт';

  @override
  String get authSignInSubtitle =>
      'Войдите, чтобы продолжить инвестировать осознанно';

  @override
  String get authSignUpSubtitle =>
      'Начните путь к дисциплинированным инвестициям';

  @override
  String get authEmailHint => 'Email';

  @override
  String get authPasswordHint => 'Пароль';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authRememberMe => 'Запомнить меня';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authCreateAccountButton => 'Создать аккаунт';

  @override
  String get authOr => 'или';

  @override
  String get authContinueWithGoogle => 'Продолжить через Google';

  @override
  String get authNoAccount => 'Нет аккаунта?';

  @override
  String get authHaveAccount => 'Уже есть аккаунт?';

  @override
  String get authSignUp => 'Зарегистрироваться';

  @override
  String get authPleaseFillFields => 'Пожалуйста, заполните все поля';

  @override
  String get authEmailAlreadyRegistered =>
      'Пользователь с таким email уже зарегистрирован.';

  @override
  String get authEmailAlreadyRegisteredGoogle =>
      'Этот email уже зарегистрирован. Попробуйте войти, либо используйте «Продолжить через Google», если вы регистрировались через него.';

  @override
  String get authCheckEmailConfirm =>
      'Проверьте почту, чтобы подтвердить регистрацию.';

  @override
  String get authSomethingWentWrong =>
      'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get authGoogleSignInFailed =>
      'Не удалось войти через Google. Попробуйте ещё раз.';

  @override
  String authTooManyAttempts(int seconds) {
    return 'Слишком много попыток. Повторите через $seconds сек.';
  }

  @override
  String authWaitSeconds(int seconds) {
    return 'Подождите $seconds сек. перед повторной попыткой.';
  }

  @override
  String get profileTitle => 'ПРОФИЛЬ';

  @override
  String get profileNotSignedIn => 'Вход не выполнен';

  @override
  String get profileAdminBadge => 'АДМИН';

  @override
  String get profilePremiumBadge => 'ПРЕМИУМ';

  @override
  String get profilePreferencesSection => 'Настройки';

  @override
  String get profileStatisticsSection => 'Статистика';

  @override
  String get profileStatDays => 'Дней';

  @override
  String get profileStatCompanies => 'Компаний';

  @override
  String get profileStatTests => 'Тестов';

  @override
  String get profileLegalSection => 'Правовая информация';

  @override
  String get profilePrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get profileTermsOfUse => 'Условия использования';

  @override
  String get profileSignOut => 'Выйти';

  @override
  String get profileDeleteAccount => 'Удалить аккаунт';

  @override
  String get profileDeleteAccountTitle => 'Удалить аккаунт?';

  @override
  String get profileDeleteAccountBody =>
      'У вас будет 14 дней, чтобы восстановить аккаунт после этого. Если вы не восстановите его за это время, аккаунт и все данные — портфели, список наблюдения, история симуляций рынка — будут удалены безвозвратно, без возможности восстановления.';

  @override
  String get profileCancel => 'Отмена';

  @override
  String get profileDelete => 'Удалить';

  @override
  String get profileDeleteFailed =>
      'Не удалось удалить аккаунт. Попробуйте ещё раз.';

  @override
  String get premiumActive => 'Премиум активен';

  @override
  String get premiumLifetime => 'Бессрочная подписка';

  @override
  String get premiumExpired => 'Подписка истекла';

  @override
  String premiumDaysRemaining(int days) {
    return 'Осталось $days дн.';
  }

  @override
  String get premiumExpiredBadge => 'ИСТЕКЛА';

  @override
  String premiumDaysBadge(int days) {
    return '$days дн.';
  }

  @override
  String get premiumBenefitSearches => 'Неограниченный поиск каждый день';

  @override
  String get premiumBenefitPortfolios => 'Стартовый капитал портфеля \$10 000';

  @override
  String get premiumBenefitCapital =>
      'Стартовый капитал симуляции рынка \$15 000';

  @override
  String get premiumBenefitStressTests => 'До 3 симуляций рынка';

  @override
  String get premiumBenefitAdFree => 'Без рекламы';

  @override
  String get premiumBenefitWeeklyPayout =>
      'Пополнение портфеля на \$180 каждую неделю';

  @override
  String get premiumBenefitStressTestDca =>
      'Симулированное еженедельное пополнение в симуляции рынка';

  @override
  String get tradeBuy => 'ПОКУПКА';

  @override
  String get tradeSell => 'ПРОДАЖА';

  @override
  String get tradeDetailTitle => 'ДЕТАЛИ СДЕЛКИ';

  @override
  String get tradeNotFound => 'Сделка не найдена';

  @override
  String get tradeOrderTypeLabel => 'Тип ордера';

  @override
  String get tradeMarketType => 'Рыночный';

  @override
  String get tradeLimitPriceLabel => 'Лимитная цена';

  @override
  String get tradeStopPriceLabel => 'Стоп-цена';

  @override
  String get tradeSharesBoughtLabel => 'Куплено акций';

  @override
  String get tradeSharesSoldLabel => 'Продано акций';

  @override
  String get tradePricePerShareLabel => 'Цена за акцию';

  @override
  String get tradeTotalValueLabel => 'Общая сумма';

  @override
  String get tradeDateLabel => 'Дата';

  @override
  String get tradeCommissionLabel => 'Комиссия';

  @override
  String get tradeSimulationLabel => 'Симуляция';

  @override
  String get orderConfirmTitle => 'Подтверждение ордера';

  @override
  String get orderConfirmSubtotalLabel => 'Сумма сделки';

  @override
  String get orderConfirmTotalLabel => 'Итого';

  @override
  String get orderConfirmCancelButton => 'Отмена';

  @override
  String get tradeRealizedPnlLabel => 'Реализ. P&L';

  @override
  String get disclaimerFooter =>
      'Дисклеймер: F.O.M.O. Shield создан исключительно в образовательных и развлекательных целях. Мы не являемся зарегистрированными инвестиционными консультантами. Все торговые решения принимаются исключительно на ваш страх и риск. Результаты в прошлом не гарантируют результатов в будущем.';

  @override
  String get homeAddWidgets => 'Добавить виджеты';

  @override
  String get homeWidgetSettingsTitle => 'Настройка виджетов';

  @override
  String get homeReset => 'Сбросить';

  @override
  String get homeWidgetShieldSignal => 'Сигнал рынка';

  @override
  String get homeWidgetWatchlist => 'Список наблюдения';

  @override
  String get homeWidgetMarketClock => 'Рыночные часы';

  @override
  String get homeWidgetPortfolio => 'Мой портфель';

  @override
  String get commonLoading => 'Загрузка...';

  @override
  String get shieldSignalTitle => 'СИГНАЛ РЫНКА';

  @override
  String get shieldSignalChange => 'ИЗМЕНЕНИЕ';

  @override
  String get shieldSignalChangePercent => 'ИЗМЕНЕНИЕ %';

  @override
  String get moodBullishTitle => 'Бычий импульс';

  @override
  String get moodBullishBody =>
      'Покупатели явно доминируют на рынке сегодня. Сильный спрос толкает цены вверх по многим компаниям, а позитивные новости и растущий оптимизм побуждают инвесторов продолжать покупки. Импульс на стороне быков — но помните: даже сильные тренды рано или поздно замедляются, поэтому не стоит гнаться за ценой на эмоциях.';

  @override
  String get moodSteadyClimbTitle => 'Плавный рост';

  @override
  String get moodSteadyClimbBody =>
      'У покупателей сегодня небольшое преимущество. Спрос немного превышает давление продаж, толкая индекс вверх. Движение здоровое и контролируемое, без признаков паники или чрезмерного ажиотажа — уверенность растёт постепенно.';

  @override
  String get moodWaitingTitle => 'В ожидании направления';

  @override
  String get moodWaitingBody =>
      'Рынок делает паузу. Покупатели и продавцы примерно уравновешены, поэтому цены почти не двигаются. Ничего необычного не происходит — инвесторы просто ждут следующей важной новости, чтобы выбрать направление.';

  @override
  String get moodCautionTitle => 'Растущая осторожность';

  @override
  String get moodCautionBody =>
      'У продавцов небольшое преимущество. Рынок немного снижается, но признаков паники нет. Такие небольшие откаты — нормальная часть инвестирования.';

  @override
  String get moodStormTitle => 'Штормовое предупреждение';

  @override
  String get moodStormBody =>
      'Страх распространяется по рынку. Давление продавцов значительно превышает покупки, из-за чего цены падают быстро. Резкие падения могут ощущаться неприятно, но эмоциональные решения часто делают тяжёлые дни ещё тяжелее.';

  @override
  String get watchlistTitle => 'СПИСОК НАБЛЮДЕНИЯ';

  @override
  String get watchlistEmpty => 'Здесь пока пусто';

  @override
  String get marketClockTitle => 'РЫНОЧНЫЕ ЧАСЫ';

  @override
  String get marketClockNewYorkTime => 'ВРЕМЯ В НЬЮ-ЙОРКЕ';

  @override
  String get portfolioWidgetNoPortfolio => 'Нет портфеля';

  @override
  String get portfolioWidgetTitle => 'ПОРТФЕЛЬ';

  @override
  String get portfolioBalanceLabel => 'БАЛАНС ПОРТФЕЛЯ';

  @override
  String get portfolioCashLabel => 'ДОСТУПНО СРЕДСТВ';

  @override
  String get portfolioUnrealizedPnl => 'НЕРЕАЛИЗ. P&L';

  @override
  String get targetLabel => 'ЦЕЛЬ';

  @override
  String get stressTestWidgetTitle => 'МОЯ СИМУЛЯЦИЯ РЫНКА';

  @override
  String get stressTestActiveTests => 'Активные симуляции';

  @override
  String get stressTestMyResults => 'МОИ РЕЗУЛЬТАТЫ';

  @override
  String stressTestMoreCompleted(int count) {
    return '+ещё $count завершено';
  }

  @override
  String get stressTestNoActiveTests => 'Нет активных симуляций';

  @override
  String get stressTestStartNewTest =>
      'Начните новую симуляцию с нижней панели';

  @override
  String get stressTestGoPremium => 'ПРЕМИУМ';

  @override
  String get stressTestPremiumLowercase => 'премиум';

  @override
  String get stressTestHubTitle => 'СИМУЛЯЦИЯ РЫНКА';

  @override
  String get stressTestCompletedTestsSheetTitle => 'Завершённые симуляции';

  @override
  String get stressTestActiveTestsTitle => 'АКТИВНЫЕ СИМУЛЯЦИИ';

  @override
  String get stressTestCompletedTestsTitle => 'ЗАВЕРШЁННЫЕ СИМУЛЯЦИИ';

  @override
  String get stressTestNoCompletedTestsYet => 'Завершённых симуляций пока нет';

  @override
  String get stressTestNoTestsYet => 'Симуляций рынка пока нет';

  @override
  String get stressTestNoTestsHint =>
      'Нажмите кнопку выше, чтобы начать первую симуляцию';

  @override
  String get stressTestNewTest => 'Новая симуляция рынка';

  @override
  String stressTestActiveCountFree(int active, int max) {
    return '$active/$max активно · Premium = до 5 одновременно';
  }

  @override
  String get stressTestEmotionalResilience =>
      'Проверьте свою устойчивость к эмоциям';

  @override
  String get stressTestLimitReachedTitle => 'Достигнут лимит симуляций рынка';

  @override
  String get stressTestMaxSessionsReached =>
      'Достигнут лимит активных симуляций';

  @override
  String stressTestArchiveSummary(String amount, int holdings, int trades) {
    return 'Итог: $amount · $holdings активов · $trades сделок';
  }

  @override
  String get stressTestSessionNotFound => 'Сессия не найдена';

  @override
  String get stressTestSetupTitle => 'Настройка симуляции рынка';

  @override
  String get stressTestNameSectionTitle => 'НАЗВАНИЕ ТЕСТА (НЕОБЯЗАТЕЛЬНО)';

  @override
  String get stressTestNameHint => 'например, Ставка на ИИ';

  @override
  String get stressTestRenameDialogTitle => 'Переименовать тест';

  @override
  String get stressTestDurationSectionTitle => 'ДЛИТЕЛЬНОСТЬ СИМУЛЯЦИИ';

  @override
  String get stressTestStartButton => 'НАЧАТЬ СИМУЛЯЦИЮ РЫНКА';

  @override
  String get stressTestSlot1Free =>
      'Слот 1/2 бесплатно · Premium — до 5 сразу и без рекламы';

  @override
  String get stressTestSlot2Free =>
      'Слот 2/2 бесплатно · Premium — до 5 сразу, без рекламы';

  @override
  String get stressTestAvailableCash => 'Доступные средства';

  @override
  String stressTestOfTotal(String amount) {
    return 'из $amount всего';
  }

  @override
  String stressTestCustomDays(int days) {
    return 'Свой вариант ($days дн.)';
  }

  @override
  String get stressTestInfiniteMinWeeks => 'Бесконечный — мин. 2 недели';

  @override
  String get stressTestPremiumFeatureTitle => 'Премиум-функция';

  @override
  String get stressTestPremiumFeatureBody =>
      'Эта длительность симуляции доступна только подписчикам Premium. Перейдите на Premium, чтобы открыть неограниченные возможности.';

  @override
  String get stressTestUpgradeToPremium => 'Перейти на Premium';

  @override
  String get stressTestNotNow => 'Не сейчас';

  @override
  String get stressTestCustomDurationTitle => 'Своя длительность симуляции';

  @override
  String get stressTestCustomDurationWarning =>
      'После запуска симуляция со своей длительностью не может быть прервана или остановлена досрочно. Она будет выполняться весь выбранный ниже период.';

  @override
  String stressTestDaysCount(int days) {
    return '$days дн.';
  }

  @override
  String get stressTestMinDays => 'Мин.: 14 дней';

  @override
  String get stressTestMaxDays => 'Макс.: 365 дней';

  @override
  String get commonApply => 'Применить';

  @override
  String get stressTestPremiumFeatureAllCaps => 'ПРЕМИУМ-ФУНКЦИЯ';

  @override
  String get stressTestRiskDisclaimerTitle => 'РИСКИ И ДИСКЛЕЙМЕР СИМУЛЯЦИИ';

  @override
  String get stressTestScrollToAgree =>
      'Прокрутите до конца, чтобы согласиться';

  @override
  String get stressTestReadFullDisclaimer =>
      'Вы прочитали дисклеймер полностью';

  @override
  String get stressTestIAgreeStart => 'Согласен — начать симуляцию';

  @override
  String get stressTestDisclaimerIntro =>
      'Эта симуляция рынка использует специализированный алгоритмический движок, который симулирует экстремальные рыночные сценарии, включая затяжные медвежьи тренды, системные кризисы и полные обвалы финансовых рынков.';

  @override
  String get stressTestDisclaimerAck =>
      'Перед началом симуляции, пожалуйста, прочитайте и подтвердите следующее:';

  @override
  String get stressTestBulletScenarios =>
      'Симулированные сценарии — обвалы, кризисы и рыночные движения, генерируемые движком, являются гипотетическими математическими моделями. Они предназначены для проверки устойчивости портфеля в стрессовых условиях и не являются прогнозом реального поведения рынка.';

  @override
  String get stressTestBulletNotAdvice =>
      'Это не финансовая консультация — итоговый вердикт, аналитика и любые выводы, сделанные по результатам этой симуляции, предназначены только для информационных и образовательных целей. Они не являются персональной инвестиционной консультацией, рекомендацией покупать или продавать активы, а также любой формой финансового предложения.';

  @override
  String get stressTestBulletObjective =>
      'Объективная математическая оценка — итоговый вердикт и баллы формируются автоматически. Наш движок построен на признанных научных методах (включая симуляцию Монте-Карло, анализ хвостовых рисков и современные модели стресс-тестирования портфеля). Алгоритм полностью независим: он исключает человеческую предвзятость, эмоции и коммерческие интересы третьих сторон. Тем не менее важно помнить, что любая математическая модель имеет свои ограничения и не может предсказать абсолютно каждый реальный рыночный сценарий.';

  @override
  String get stressTestBulletLiability =>
      'Ограничение ответственности — положительный результат симуляции (то есть успешное «выживание» вашего портфеля при симулированном обвале рынка) не гарантирует аналогичного результата в реальных условиях. Платформа и её разработчики не несут ответственности за ваши инвестиционные решения, а также за любые прямые или косвенные убытки, включая, помимо прочего, потерю капитала на реальных рынках.';

  @override
  String get stressTestBulletPastPerformance =>
      'Прошлые результаты в этом симуляторе не гарантируют, не прогнозируют и не отражают реальные рыночные результаты. Любая торговая деятельность в реальной жизни сопряжена с существенным риском и осуществляется исключительно по вашему собственному усмотрению и под вашу ответственность.';

  @override
  String get stressTestEndOfDisclaimer => '▸ Конец дисклеймера';

  @override
  String get stressTestUnlimitedTesting => 'Неограниченная симуляция';

  @override
  String get stressTestInfiniteUpsellBody =>
      'Симуляция рынка с бесконечной длительностью доступна исключительно подписчикам Premium. Перейдите на Premium, чтобы получить:';

  @override
  String get stressTestUpsellUnlimitedDuration =>
      'Неограниченную длительность симуляции';

  @override
  String get stressTestUpsellFullCrashScenarios =>
      'Полные сценарии обвала рынка';

  @override
  String get stressTestUpsellAdvancedAnalytics =>
      'Расширенную аналитику портфеля';

  @override
  String get stressTestAccessTitle => 'Доступ к симуляции рынка';

  @override
  String get stressTestPortfolioTitle => 'ПОРТФЕЛЬ СИМУЛЯЦИИ РЫНКА';

  @override
  String get stressTestNotStartedYet => 'Симуляция ещё не начата';

  @override
  String get stressTestGoBackToSetup =>
      'Вернитесь к настройке и запустите симуляцию';

  @override
  String get stressTestGoToSetup => 'К настройке';

  @override
  String get stressTestStartBuildingPortfolio => 'Начните собирать портфель';

  @override
  String get stressTestTapToAddFirstPosition =>
      'Нажмите +, чтобы найти акции\nи добавить первую позицию.';

  @override
  String get stressTestSearchStocksHint => 'Найти акции для добавления...';

  @override
  String get stressTestGetVerdict => 'ПОЛУЧИТЬ ВЕРДИКТ ПСИХОЛОГА';

  @override
  String get stressTestNoAssetsYet => 'Активов пока нет';

  @override
  String get stressTestNoActivePositions => 'Нет активных позиций';

  @override
  String get stressTestTapToAddFirstAsset =>
      'Нажмите +, чтобы найти и добавить первый актив';

  @override
  String get stressTestTapToBuyAssets => 'Нажмите (+), чтобы купить активы';

  @override
  String get stressTestTestComplete => 'Симуляция завершена';

  @override
  String get stressTestTimeRemaining => 'Осталось времени';

  @override
  String get stressTestElapsedTime => 'Прошло времени';

  @override
  String stressTestCountdown(
    String days,
    String hours,
    String minutes,
    String seconds,
  ) {
    return '$daysд $hoursч $minutesм $secondsс';
  }

  @override
  String stressTestEpochNumber(int number) {
    return 'Эпоха #$number';
  }

  @override
  String get stressTestFinishTestButton => 'ЗАВЕРШИТЬ СИМУЛЯЦИЮ';

  @override
  String get stressTestFinishTest => 'Завершить симуляцию';

  @override
  String get stressTestFinishTestConfirm =>
      'Завершить симуляцию сейчас и получить вердикт? Это действие нельзя отменить.';

  @override
  String get stressTestFinalBalance => 'ИТОГОВЫЙ БАЛАНС';

  @override
  String get stressTestViewVerdict => 'ПОСМОТРЕТЬ ВЕРДИКТ ПСИХОЛОГА';

  @override
  String get stressTestWidgetPortfolioBalance => 'Баланс портфеля';

  @override
  String get stressTestWidgetCashAvailable => 'Доступные средства';

  @override
  String get stressTestWidgetPsychologyMeter => 'Индикатор психологии';

  @override
  String get stressTestWidgetHoldings => 'Активы';

  @override
  String get stressTestWidgetPriceChart => 'График цены';

  @override
  String get stressTestWidgetEpochs => 'Эпохи';

  @override
  String get stressTestWidgetTradeHistory => 'История сделок';

  @override
  String get stressTestWidgetLimitOrders => 'Мои лимитные ордера';

  @override
  String get stressTestWidgetTimer => 'Таймер';

  @override
  String get portfolioWidgetDisplayNameTarget => 'Цель';

  @override
  String get stressTestInvestmentDisclaimerTitle =>
      'ИНВЕСТИЦИОННЫЙ ДИСКЛЕЙМЕР\nИ ОГРАНИЧЕНИЕ ОТВЕТСТВЕННОСТИ';

  @override
  String get stressTestInvestmentDisclaimerBody =>
      'Этот вердикт формируется автоматически математической моделью исключительно на основе вашего смоделированного исторического поведения в этой закрытой симуляционной среде. Он предоставляется только в образовательных и иллюстративных целях и НЕ является персональной инвестиционной, юридической или финансовой консультацией. Прошлые результаты в этом симуляторе не гарантируют, не прогнозируют и не отражают реальные рыночные результаты. Итоговые финансовые решения, покупка активов или торговая деятельность в реальной жизни сопряжены с существенным риском и осуществляются исключительно по вашему собственному усмотрению и под вашу ответственность. Создатели F.O.M.O. Shield не несут ответственности за финансовые убытки, понесённые при реальной торговле.';

  @override
  String get stressTestIUnderstandAccept => 'Понимаю и принимаю';

  @override
  String get stressTestPsychologyMeterTitle => 'ИНДИКАТОР ПСИХОЛОГИИ';

  @override
  String get stressTestStrategyScore => 'Стратегия';

  @override
  String get stressTestPsychologyScore => 'Психология';

  @override
  String get stressTestScoreLabel => 'БАЛЛ';

  @override
  String get stressTestAnalyticsTotalTrades => 'Всего сделок';

  @override
  String get stressTestAnalyticsTradesBuy => 'Покупки';

  @override
  String get stressTestAnalyticsTradesSell => 'Продажи';

  @override
  String get stressTestAnalyticsUnrealizedPnl => 'Нереализ. P&L';

  @override
  String get stressTestAnalyticsRealizedPnl => 'Реализ. P&L';

  @override
  String get stressTestPriceChartTitle => 'ГРАФИК ЦЕНЫ';

  @override
  String get stressTestChartNotEnoughData => 'Пока недостаточно данных';

  @override
  String get stressTestChartNotEnoughDataForPeriod =>
      'Недостаточно данных за этот период';

  @override
  String get chartPeriod1D => '1Д';

  @override
  String get chartPeriod1W => '1Н';

  @override
  String get chartPeriod1M => '1М';

  @override
  String get chartPeriod3M => '3М';

  @override
  String get chartPeriod6M => '6М';

  @override
  String get chartPeriod1Y => '1Г';

  @override
  String get chartPeriod5Y => '5Г';

  @override
  String get chartPeriodAll => 'Все';

  @override
  String get searchTitle => 'ПОИСК';

  @override
  String get searchHint => 'Поиск тикера или компании...';

  @override
  String get searchNoResults => 'Ничего не найдено';

  @override
  String get searchApiExhausted =>
      'Возможно, исчерпан лимит API. Попробуйте чуть позже.';

  @override
  String get searchErrorConnectionTimeout =>
      'Истекло время соединения. Проверьте интернет.';

  @override
  String get searchErrorServerNotResponding =>
      'Сервер не отвечает. Попробуйте ещё раз.';

  @override
  String get searchErrorNoInternet => 'Нет подключения к интернету.';

  @override
  String get searchErrorRateLimited =>
      'Достигнут лимит запросов. Попробуйте позже.';

  @override
  String get searchErrorGeneric =>
      'Не удалось загрузить результаты. Попробуйте ещё раз.';

  @override
  String get searchTopSp500 => 'ТОП S&P 500';

  @override
  String get searchOtherSector => 'ПРОЧИЕ';

  @override
  String get searchRecentlyViewed => 'НЕДАВНО ПРОСМОТРЕННЫЕ';

  @override
  String get searchTopCompaniesBuilding =>
      'Список топ-компаний ещё формируется на сервере.';

  @override
  String get searchTopCompaniesLoadError =>
      'Не удалось загрузить топ-компании. Потяните, чтобы обновить.';

  @override
  String get portfolioRenameMenu => 'Переименовать портфель';

  @override
  String get portfolioResetMenu => 'Сбросить портфель';

  @override
  String get portfolioNoPortfoliosYet => 'Пока нет портфелей';

  @override
  String portfolioCreateFirstMsg(String amount) {
    return 'Создайте свой первый виртуальный портфель\nсо стартовым балансом $amount';
  }

  @override
  String get portfolioCreateButton => 'Создать портфель';

  @override
  String get portfolioNameHint => 'например, Tech Growth';

  @override
  String get portfolioSave => 'Сохранить';

  @override
  String get portfolioResetDialogTitle => 'Сбросить портфель?';

  @override
  String get portfolioResetDialogBody =>
      'Все активы и история будут очищены.\nБаланс будет восстановлен до исходной суммы.';

  @override
  String get portfolioNewDialogTitle => 'Новый портфель';

  @override
  String get portfolioFreeLimitOne =>
      'Лимит FREE: 1 портфель. Перейдите на Premium (3).';

  @override
  String portfolioMaxReached(int max) {
    return 'Достигнут лимит $max портфелей.';
  }

  @override
  String get portfolioCreate => 'Создать';

  @override
  String get portfolioAdditionalPromoTitle => 'Дополнительный портфель';

  @override
  String get portfolioSwitchedPromoTitle => 'Портфель переключён';

  @override
  String get portfolioCreateNewSlot => 'Создать новый портфель';

  @override
  String get commonFailedToLoad => 'Не удалось загрузить';

  @override
  String get commonOther => 'Прочее';

  @override
  String get commonLess => 'Свернуть';

  @override
  String get commonMore => 'Ещё';

  @override
  String commonMoreCount(int count) {
    return 'Ещё ($count)';
  }

  @override
  String get balanceRingLabel => 'БАЛАНС';

  @override
  String get targetGoalLabel => 'ЦЕЛЬ';

  @override
  String get targetLeftToGoal => 'ОСТАЛОСЬ ДО ЦЕЛИ';

  @override
  String get targetChangeGoal => 'Изменить цель';

  @override
  String get targetSelectGoal => 'Выбрать цель';

  @override
  String get holdingsTitle => 'АКТИВЫ';

  @override
  String get holdingsEmpty => 'Активов пока нет';

  @override
  String get holdingsEmptyHint =>
      'Нажмите +, чтобы найти и добавить первый актив';

  @override
  String sharesCount(String count) {
    return '$count акций';
  }

  @override
  String get tradeHistoryTitle => 'ИСТОРИЯ СДЕЛОК';

  @override
  String get setGoalScreenTitleSet => 'УСТАНОВИТЬ ЦЕЛЬ';

  @override
  String get setGoalScreenTitleChange => 'ИЗМЕНИТЬ ЦЕЛЬ';

  @override
  String get setGoalScreenPrompt =>
      'Какого общего размера портфеля вы хотите достичь?';

  @override
  String setGoalScreenSubtitle(String amount) {
    return 'Это ваш целевой общий баланс, а не дополнительная прибыль сверху. Минимум $amount.';
  }

  @override
  String get setGoalScreenSaveButton => 'Сохранить цель';

  @override
  String setGoalScreenMinimumTargetError(String amount) {
    return 'Минимальная цель — $amount';
  }

  @override
  String get setGoalScreenNotifTitleSet => 'Цель установлена';

  @override
  String get setGoalScreenNotifTitleUpdated => 'Цель обновлена';

  @override
  String setGoalScreenNotifDetailSet(String amount) {
    return 'Цель установлена на $amount';
  }

  @override
  String setGoalScreenNotifDetailUpdated(String amount, String signed) {
    return 'Новая цель $amount ($signed)';
  }

  @override
  String get verdictAccessLockedTitle =>
      'Продлите Premium, чтобы посмотреть снова';

  @override
  String get verdictAccessLockedDetail =>
      'Вы уже использовали единственный бесплатный просмотр этого вердикта после истечения Premium. Продлите подписку, чтобы посмотреть его снова.';

  @override
  String get fundingModeTitle => 'Как профинансировать этот тест?';

  @override
  String get fundingModeLumpSumTitle => 'Всё сразу';

  @override
  String get fundingModeLumpSumDetail =>
      'Начать сразу с полной суммой \$15,000.';

  @override
  String get fundingModeDcaTitle => 'Еженедельные пополнения';

  @override
  String get fundingModeDcaDetail =>
      'Начать с \$2,500, затем имитация пополнения на \$200 каждую неделю.';

  @override
  String get dividendSimulationSheetTitle => 'Симулировать выплату дивидендов?';

  @override
  String get dividendSimulationEnableTitle => 'Да, симулировать дивиденды';

  @override
  String get dividendSimulationEnableDetail =>
      'Упрощённая симуляция: REIT выплачивают раз в 2 недели, остальные компании — раз в месяц. Это сжатое приближение, а не точный график конкретной компании. Показанная доходность — это полная годовая ставка, поделённая на количество выплат.';

  @override
  String get dividendSimulationSkipTitle => 'Нет, только движение цены';

  @override
  String get dividendSimulationSkipDetail =>
      'Торговать только на изменении цены, как в остальных режимах теста.';

  @override
  String get dividendPayoutTitle => 'Выплата дивидендов';

  @override
  String dividendPayoutDetail(String amount) {
    return '$amount зачислено от симулированных дивидендов — нажмите, чтобы посмотреть.';
  }

  @override
  String get weeklyPayoutTitle => 'Еженедельное пополнение';

  @override
  String weeklyPayoutDetail(String amount) {
    return '$amount зачислено на ваш портфель — нажмите, чтобы посмотреть.';
  }

  @override
  String get weeklyPayoutPausedTitle => 'Пополнение приостановлено';

  @override
  String get weeklyPayoutDetailTitle => 'Детали пополнения';

  @override
  String get weeklyPayoutDetailAmountLabel => 'Сумма зачисления';

  @override
  String get weeklyPayoutDetailAccountLabel => 'Счёт';

  @override
  String get weeklyPayoutPausedDetail =>
      'Подписка Premium истекла, еженедельное пополнение приостановлено — продлите подписку, чтобы возобновить.';

  @override
  String get subscriptionUpgradedTitle => 'Добро пожаловать в Premium';

  @override
  String get subscriptionUpgradedDetail =>
      'Ваш аккаунт теперь Premium — пользуйтесь дополнительными возможностями.';

  @override
  String get subscriptionDowngradedTitle => 'Premium истёк';

  @override
  String get subscriptionDowngradedDetail =>
      'Ваша подписка Premium закончилась — вы вернулись на тариф Free.';

  @override
  String get portfolioTradeHistoryScreenPortfolioNotFound =>
      'Портфель не найден';

  @override
  String get portfolioTradeHistoryScreenNoTradesYet => 'Сделок пока нет';

  @override
  String get portfolioWidgetsSettingsSheetTitle => 'Виджеты портфеля';

  @override
  String get myLimitOrdersTitle => 'МОИ ЛИМИТНЫЕ ОРДЕРА';

  @override
  String get myLimitOrdersSheetTitle => 'Мои лимитные ордера';

  @override
  String get myLimitOrdersEmpty => 'Сейчас нет активных ордеров';

  @override
  String myLimitOrdersSeeAll(int count) {
    return 'Показать все ордера ($count)';
  }

  @override
  String get gicsSectorTechnology => 'Технологии';

  @override
  String get gicsSectorFinancials => 'Финансы';

  @override
  String get gicsSectorHealthCare => 'Здравоохранение';

  @override
  String get gicsSectorConsumerDiscretionary => 'Потребительский цикл.';

  @override
  String get gicsSectorConsumerStaples => 'Потребительские товары';

  @override
  String get gicsSectorEnergy => 'Энергетика';

  @override
  String get gicsSectorIndustrials => 'Промышленность';

  @override
  String get gicsSectorMaterials => 'Материалы';

  @override
  String get gicsSectorCommunicationServices => 'Телекоммуникации';

  @override
  String get gicsSectorRealEstate => 'Недвижимость';

  @override
  String get gicsSectorUtilities => 'Коммунальные услуги';

  @override
  String get testDuration1Week => '1 неделя';

  @override
  String get testDuration1Month => '1 месяц';

  @override
  String get testDuration3Months => '3 месяца';

  @override
  String get testDurationInfinite => 'Бесконечный';

  @override
  String get testDurationCustom => 'Свой вариант';

  @override
  String get stressTestAddAsset => 'Добавить актив';

  @override
  String get stressTestConfirmPurchase => 'Подтвердите покупку';

  @override
  String get stressTestSearchCompanyHint =>
      'Поиск компании (например, Apple, Cola)...';

  @override
  String get stressTestSearchFailedError =>
      'Ошибка поиска. Проверьте соединение.';

  @override
  String get stressTestTypeMinChars => 'Введите минимум 2 символа для поиска';

  @override
  String get stressTestNoResultsFound => 'Ничего не найдено';

  @override
  String stressTestNoPriceData(String symbol) {
    return 'Нет данных о цене для $symbol.';
  }

  @override
  String stressTestFetchPriceError(String symbol) {
    return 'Не удалось получить цену для $symbol.';
  }

  @override
  String get stressTestNotEnoughCashError =>
      'Недостаточно средств или сделка невозможна.';

  @override
  String stressTestCurrentPriceLabel(String price) {
    return 'Текущая цена: $price';
  }

  @override
  String get stressTestHowMuchInvest => 'Сколько вы хотите вложить?';

  @override
  String stressTestExceedsCash(String cash) {
    return 'Превышает доступные средства ($cash)';
  }

  @override
  String stressTestBuyAmountWorth(String amount) {
    return 'Купить на $amount';
  }

  @override
  String get stressTestChooseAnotherCompany => 'Выбрать другую компанию';

  @override
  String get verdictTradeBreakdownTitle => 'ДЕТАЛИ СДЕЛОК';

  @override
  String get verdictSessionNotFound => 'Сессия не найдена';

  @override
  String get verdictTestDurationLabel => 'Длительность теста';

  @override
  String verdictDurationDays(int days) {
    return '$days дн.';
  }

  @override
  String get verdictStatisticsTitle => 'СТАТИСТИКА';

  @override
  String get verdictTotalTradesLabel => 'Всего сделок';

  @override
  String get verdictBoughtLabel => 'Куплено';

  @override
  String get verdictSoldLabel => 'Продано';

  @override
  String get verdictTotalAssetsTitle => 'ВСЕГО АКТИВОВ';

  @override
  String get verdictAssetsHeldTotalLabel => 'Активов держали (всего)';

  @override
  String get verdictAssetsAtEndLabel => 'Активов на конец теста';

  @override
  String get verdictFinancialSummaryTitle => 'ФИНАНСОВЫЙ ИТОГ';

  @override
  String get verdictStartingAmountLabel => 'Начальная сумма';

  @override
  String get verdictTotalPnlLabel => 'Общий P&L (реализ. + нереализ.)';

  @override
  String verdictProfitableSellsLabel(int count) {
    return 'Прибыльные продажи ($count)';
  }

  @override
  String verdictLosingSellsLabel(int count) {
    return 'Убыточные продажи ($count)';
  }

  @override
  String get verdictFinalBalanceLabel => 'Итоговый баланс';

  @override
  String get verdictScenariosTitle => 'ПРОЙДЕННЫЕ СЦЕНАРИИ';

  @override
  String get verdictScenarioBull => 'Бычий тренд';

  @override
  String get verdictScenarioBear => 'Медвежий тренд';

  @override
  String get verdictScenarioSideways => 'Боковой рынок';

  @override
  String get verdictScenarioVolatility => 'Волатильность';

  @override
  String get verdictScenarioRecovery => 'Восстановление';

  @override
  String get verdictScenarioHype => 'Ажиотаж на рынке';

  @override
  String get verdictScenarioSpeculation => 'Спекуляция';

  @override
  String get verdictScenarioBlackSwan => 'Чёрный лебедь';

  @override
  String get verdictScenarioCrash => 'Обвал';

  @override
  String get verdictCompaniesTitle => 'КОМПАНИИ';

  @override
  String get verdictNoCompaniesTraded => 'Сделок по компаниям не было.';

  @override
  String get verdictNoTradesYet => 'Сделок пока нет.';

  @override
  String get verdictTradeBreakdownDisclaimerTitle => 'Дисклеймер';

  @override
  String get verdictTradeBreakdownDisclaimerBody =>
      'Результаты этой симуляции рынка являются исключительно результатом компьютерного моделирования и предоставлены только в образовательных и учебных целях. Они основаны на заданных моделью сценариях и исторических рыночных событиях и не отражают, не предсказывают и не гарантируют результаты какого-либо портфеля в реальных рыночных условиях.\n\nРеальное поведение рынка, отдельных компаний и финансовых активов может существенно отличаться от результатов симуляции. Прошлые рыночные события и результаты не гарантируют аналогичных результатов в будущем.\n\nЛюбые оценки, рейтинги, вердикты или иные показатели, представленные в симуляции, не являются инвестиционной, финансовой или иной профессиональной консультацией, а также не являются рекомендацией, предложением или побуждением покупать либо продавать какой-либо финансовый актив или основанием для принятия инвестиционных решений.\n\nЛюбое решение, принятое с использованием или с учётом информации, предоставленной приложением, принимается исключительно по усмотрению и на риск пользователя. Мы не гарантируем прибыль и не несём ответственности за какие-либо финансовые потери, убытки или упущенную выгоду, возникшие в результате использования симуляции или её результатов.\n\nЦель симуляции рынка — помочь пользователям изучить рыночные сценарии, принципы инвестирования и собственное поведение в смоделированной среде, а не предсказать будущее.';

  @override
  String get verdictCashBufferNoDataTitle => 'Нет данных о денежном резерве';

  @override
  String get verdictCashBufferNoDataIntro =>
      'Этот тест завершился без единой открытой позиции — оценивать денежный резерв пока не по чему.';

  @override
  String get verdictCashBufferTier1Title => 'Полностью в рынке';

  @override
  String get verdictCashBufferTier1Intro =>
      'Каждый доллар вашего портфеля сейчас вложен в рынок.\n\nНа первый взгляд это может показаться идеальной стратегией.\n\nВедь вложенные деньги способны расти, а наличные, лежащие без дела, — нет.\n\nНо инвестирование — это не только максимизация доходности.\n\nЭто ещё и готовность воспользоваться возможностями.\n\nБез денежного резерва у вашего портфеля очень мало гибкости.\n\nЕсли рынок вдруг резко скорректируется, отличная компания окажется глубоко недооценена или появится неожиданная возможность, у вас может просто не найтись свободного капитала, чтобы действовать.\n\nВместо того чтобы покупать по более привлекательным ценам, вы вынуждены наблюдать со стороны — либо продавать текущие позиции, чтобы высвободить наличные.\n\nНи то, ни другое не назовёшь удачным положением.\n\nНаличные часто понимают неправильно.\n\nОдни инвесторы видят в них «деньги, которые бездельничают».\n\nОпытные инвесторы чаще видят в них деньги, ожидающие подходящего момента.\n\nДенежный резерв существует не для того, чтобы обгонять рынок.\n\nОн даёт вам выбор, когда рынок становится непредсказуемым.';

  @override
  String get verdictCashBufferTier1Section1Label => 'Как это улучшить?';

  @override
  String get verdictCashBufferTier1Section1Body =>
      'Подумайте о том, чтобы держать небольшую часть портфеля в наличных, а не вкладывать каждый доступный доллар сразу.\n\nБольшой резерв не нужен.\n\nДаже скромный денежный резерв даёт ценную гибкость в периоды рыночной волатильности.\n\nКогда появятся привлекательные возможности, вы сможете действовать уверенно, а не жалеть об упущенном.\n\nВоспринимайте наличные как часть инвестиционной стратегии, а не как деньги, которым не нашлось применения.\n\nИногда самое разумное инвестиционное решение — это просто быть готовым к следующему.';

  @override
  String get verdictCashBufferTier1Section2Label => 'И напоследок';

  @override
  String get verdictCashBufferTier1Section2Body =>
      'Быть полностью вложенным может казаться продуктивным.\n\nБыть готовым зачастую ценнее.\n\nНаличные существуют не для того, чтобы максимизировать сегодняшнюю доходность. Они дают вам свободу инвестировать, когда придут завтрашние возможности.';

  @override
  String get verdictCashBufferTier2Title => 'Очень ограниченная гибкость';

  @override
  String get verdictCashBufferTier2Intro =>
      'В вашем портфеле есть небольшой денежный резерв — это шаг в верном направлении.\n\nОднако доступных наличных всё ещё немного.\n\nИх может хватить на небольшую покупку, но вряд ли достаточно, чтобы в полной мере воспользоваться серьёзной коррекцией рынка или редкой инвестиционной возможностью.\n\nОдно из главных преимуществ наличных — не доходность.\n\nЭто возможность действовать тогда, когда другие не могут.\n\nРынки не предупреждают о том, когда появится следующая возможность.\n\nСильная компания может внезапно оказаться временно недооценена из-за разочаровывающих новостей, экономической неопределённости или общего страха на рынке.\n\nУ инвесторов со свободными наличными есть выбор.\n\nИнвесторам, вложившим всё до последнего доллара, часто приходится выбирать между продажей текущих позиций и наблюдением за упущенной возможностью.\n\nПоэтому денежный резерв — это не просто деньги.\n\nЭто гибкость.\n\nЧем больше ваша финансовая подушка, тем больше свободы принимать решения исходя из возможностей, а не из необходимости.';

  @override
  String get verdictCashBufferTier2Section1Label => 'Как это улучшить?';

  @override
  String get verdictCashBufferTier2Section1Body =>
      'Держать большую долю портфеля в наличных не обязательно.\n\nСкромного резерва обычно достаточно.\n\nПо мере роста портфеля старайтесь постепенно откладывать небольшую часть новых взносов, а не вкладывать каждый доллар немедленно.\n\nСо временем это создаст финансовую подушку, которую можно будет использовать при появлении исключительных возможностей.\n\nЦель не в том, чтобы предсказать обвал рынка.\n\nЦель — просто быть готовым, если он случится.';

  @override
  String get verdictCashBufferTier2Section2Label => 'И напоследок';

  @override
  String get verdictCashBufferTier2Section2Body =>
      'Возможности ничего не значат, если у вас нет средств ими воспользоваться.\n\nНебольшой денежный резерв сегодня может казаться скучным и бесполезным — но когда рынок предложит исключительную цену, он способен стать одним из самых сильных активов вашего портфеля.';

  @override
  String get verdictCashBufferTier3Title => 'Формируется защитный резерв';

  @override
  String get verdictCashBufferTier3Intro =>
      'В вашем портфеле начал формироваться здоровый денежный резерв.\n\nВы больше не зависите полностью от текущих вложений в любой рыночной ситуации. Часть капитала остаётся свободной, давая вам больше гибкости, когда появляются возможности или неожиданные события.\n\nЭто важный шаг на пути к дисциплинированной инвестиционной стратегии.\n\nМногие инвесторы думают только о том, чем владеют.\n\nОпытные инвесторы думают ещё и о том, что могут сделать дальше.\n\nРынки редко движутся по прямой.\n\nПериоды неопределённости, страха и волатильности — нормальная часть инвестирования. В такие моменты свободные наличные способны превратить рыночный стресс в потенциальную возможность.\n\nСильная компания временно падает в цене.\n\nШирокая коррекция рынка создаёт привлекательные оценки.\n\nНеожиданное событие вызывает страх среди инвесторов.\n\nТакие ситуации вознаграждают инвесторов, у которых хватает терпения и ресурсов действовать.\n\nДенежный резерв не гарантирует более высокую доходность.\n\nНо он даёт вам нечто чрезвычайно ценное:\n\nВарианты выбора.';

  @override
  String get verdictCashBufferTier3Section1Label => 'Как это улучшить?';

  @override
  String get verdictCashBufferTier3Section1Body =>
      'Ваша текущая позиция в наличных становится полезной, но продолжайте думать о её назначении.\n\nУ наличных должна быть роль в вашей стратегии.\n\nСпросите себя:\n\nЭти деньги отложены для возможностей?\nЭто временная позиция ожидания перед вложением?\nСоответствует ли эта сумма моим личным инвестиционным целям?\n\nЦель не в том, чтобы держать как можно больше наличных.\n\nЦель — найти баланс, при котором вы чувствуете себя готовым, не давая при этом слишком большому капиталу бездействовать подолгу.\n\nХороший инвестор знает, когда вкладывать.\n\nВеликий инвестор знает ещё и когда ждать.';

  @override
  String get verdictCashBufferTier3Section2Label => 'И напоследок';

  @override
  String get verdictCashBufferTier3Section2Body =>
      'Рынок вознаграждает терпение, но терпение требует гибкости.\n\nДенежный резерв не означает, что вы боитесь инвестировать, — он означает, что вы готовы, когда появятся инвестиционные возможности.';

  @override
  String get verdictCashBufferTier4Title => 'Готовы к возможностям';

  @override
  String get verdictCashBufferTier4Intro =>
      'Ваш портфель демонстрирует глубокое понимание одной из самых недооценённых сторон инвестирования: гибкости.\n\nВы создали значимый денежный резерв, сохранив при этом большую часть капитала вложенной.\n\nИменно к такому балансу стремятся многие долгосрочные инвесторы.\n\nВаши деньги работают на рынке, но у вас также есть ресурсы на случай неожиданных возможностей.\n\nРынками движут эмоции.\n\nПериоды воодушевления могут поднимать цены слишком высоко.\n\nПериоды страха способны создавать ситуации, когда отличные компании временно торгуются по привлекательным ценам.\n\nРазница между инвесторами часто не в том, кто способен найти возможность.\n\nА в том, кто способен воспользоваться ею, когда она появится.\n\nДенежный резерв даёт вам эту способность.\n\nОн позволяет принимать решения исходя из стратегии, а не эмоций.\n\nВместо того чтобы думать:\n\n«Хотел бы я купить больше прямо сейчас».\n\nВы можете сказать:\n\n«Я подготовился к этому моменту».\n\nТакой настрой способен сильно повлиять на результат в сложные для рынка периоды.';

  @override
  String get verdictCashBufferTier4Section1Label =>
      'Как сделать это ещё лучше?';

  @override
  String get verdictCashBufferTier4Section1Body =>
      'Продолжайте относиться к наличным как к стратегическому инструменту, а не просто деньгам, ожидающим вложения.\n\nОпределите чёткое назначение своего резерва:\n\nОн на случай коррекций рынка?\nНа докупку ваших самых сильных компаний?\nНа непредвиденные возможности?\n\nСамые эффективные инвесторы держат наличные не потому, что боятся рынка.\n\nОни держат их, потому что уважают неопределённость.\n\nПросто помните: наличные — это инструмент, а не конечная цель.\n\nНа очень долгих горизонтах именно бизнесы и работающие активы обычно являются главным источником роста капитала.\n\nЦель не в том, чтобы держать наличные вечно.\n\nЦель — иметь достаточно гибкости, чтобы использовать их тогда, когда это важнее всего.';

  @override
  String get verdictCashBufferTier4Section2Label => 'И напоследок';

  @override
  String get verdictCashBufferTier4Section2Body =>
      'Подготовленному инвестору не нужно предсказывать следующее движение рынка.\n\nЕму просто нужно быть готовым, когда рынок создаст возможность.\n\nНаличные не заменяют инвестирование — они дают вашей стратегии пространство для манёвра.';

  @override
  String get verdictCashBufferTier5Title => 'Наличные дают вам выбор';

  @override
  String get verdictCashBufferTier5Intro =>
      'Ваш портфель демонстрирует превосходную дисциплину управления наличными.\n\nВы создали значимый резерв, сохранив при этом капитал работающим на рынке.\n\nТакой баланс отражает важный инвестиционный навык, который многие инвесторы упускают из виду.\n\nПриумножение капитала — это не только поиск отличных компаний.\n\nЭто ещё и готовность к неопределённости.\n\nРынки будут переживать периоды воодушевления, страха, коррекций и неожиданных событий.\n\nНи один инвестор не может точно предсказать, когда наступят эти моменты.\n\nНо подготовленным инвесторам не нужен идеальный тайминг.\n\nИм нужна гибкость.\n\nВаш денежный резерв даёт эту гибкость.\n\nОн даёт вам возможность:\n\nвоспользоваться привлекательными возможностями;\nдокупить качественные компании во время падений рынка;\nизбежать эмоциональных решений в периоды неопределённости.\n\nНаличные часто считают слабостью, ведь они не приносят такой же доходности, как вложенные активы.\n\nНо это лишь одна сторона истории.\n\nУ наличных другое предназначение.\n\nОни дают терпение.\n\nОни дают контроль.\n\nОни дают возможность действовать тогда, когда другие вынуждены ждать.';

  @override
  String get verdictCashBufferTier5Section1Label =>
      'Как сделать это ещё лучше?';

  @override
  String get verdictCashBufferTier5Section1Body =>
      'Продолжайте использовать наличные как стратегический инструмент, а не просто позволяйте им накапливаться без цели.\n\nСильный инвестор знает, зачем держит наличные.\n\nЭто на случай рыночных возможностей?\nНа докупку существующих позиций?\nЧтобы сохранять гибкость в неопределённые периоды?\n\nНаличие плана помогает избежать двух распространённых ошибок:\n\nВложить всё из страха упустить возможность.\n\nИли держать слишком много наличных из страха инвестировать.\n\nИдеальная сумма зависит от вашей личной стратегии, целей и отношения к волатильности рынка.\n\nПомните: наличные не призваны заменить инвестирование.\n\nОни призваны поддерживать более качественные инвестиционные решения.';

  @override
  String get verdictCashBufferTier5Section2Label => 'И напоследок';

  @override
  String get verdictCashBufferTier5Section2Body =>
      'Рынок вознаграждает тех, кто остаётся вложенным.\n\nНо возможности чаще вознаграждают тех, кто подготовлен.\n\nНаличные делают ваш портфель сильнее не тем, что просто лежат, — а тем, что делают вашу стратегию сильнее, давая свободу действовать тогда, когда это важнее всего.';

  @override
  String get verdictConcentrationNoDataTitle => 'Пока нет данных о позициях';

  @override
  String get verdictConcentrationNoDataIntro =>
      'Этот тест завершился без единой открытой позиции — оценивать концентрацию пока не по чему.';

  @override
  String get verdictConcentrationTier1Title =>
      'Ваше будущее держится на одной компании';

  @override
  String get verdictConcentrationTier1Intro =>
      'В вашем портфеле может быть несколько отличных вложений — но одна компания заметно превосходит все остальные.\n\nОдна позиция занимает настолько большую долю вложенного капитала, что её успех или неудача непропорционально повлияют на весь портфель.\n\nЭто называется риском концентрации.\n\nСама компания может быть превосходной.\n\nПрибыльной, финансово устойчивой, лидером своей отрасли.\n\nНо ни один бизнес не застрахован от неожиданных трудностей.\n\nРазочаровывающий квартальный отчёт.\n\nСерьёзная задержка продукта.\n\nНовая конкуренция.\n\nИзменения в регулировании.\n\nЭкономическая неопределённость.\n\nЛюбое из этих событий способно заставить даже самые сильные компании потерять значительную часть стоимости за короткое время.\n\nКогда слишком многое в вашем портфеле зависит от одной акции, вы уже не инвестируете в набор бизнесов.\n\nВы ставите значительную часть своего финансового будущего на одно-единственное решение.\n\nДаже легендарные компании переживали трудные годы.\n\nИстория не раз показывала, что сегодняшний лидер рынка не гарантированно останется завтрашним победителем.\n\nОтличные компании заслуживают доверия.\n\nНо они никогда не должны требовать слепой веры.';

  @override
  String get verdictConcentrationTier1Section1Label => 'Как это улучшить?';

  @override
  String get verdictConcentrationTier1Section1Body =>
      'Продавать любимую компанию не обязательно.\n\nЕсли вы действительно верите в её долгосрочное будущее, нет ничего плохого в том, чтобы сделать её одной из крупнейших позиций.\n\nГлавное — убедиться, что она не тащит на себе весь портфель.\n\nПродолжая инвестировать, направляйте новые деньги в другие качественные бизнесы, а не наращивайте и без того крупнейшую позицию.\n\nСо временем портфель естественным образом станет более сбалансированным, при этом ваша самая сильная убеждённость останется важной частью стратегии.\n\nДиверсифицированный портфель не снижает вашу уверенность.\n\nОн снижает последствия ошибки.';

  @override
  String get verdictConcentrationTier1Section2Label => 'И напоследок';

  @override
  String get verdictConcentrationTier1Section2Body =>
      'У каждого великого инвестора есть любимые компании.\n\nРазница в том, что опытные инвесторы редко позволяют одной акции определять судьбу всего портфеля.\n\nВерьте в отличные компании — но никогда не отдавайте своё финансовое будущее в руки одной из них.';

  @override
  String get verdictConcentrationTier2Title =>
      'Слишком много доверия одной акции';

  @override
  String get verdictConcentrationTier2Intro =>
      'Ваш портфель становится более диверсифицированным, но одна позиция по-прежнему занимает намного большую долю капитала, чем остальные.\n\nЭто не обязательно означает, что вы выбрали не ту компанию.\n\nБолее того, это может быть один из самых сильных бизнесов в вашем портфеле.\n\nРиск возникает из-за чрезмерной опоры на одно вложение.\n\nКаким бы успешным ни казался бизнес сегодня, рано или поздно каждая компания сталкивается с трудностями.\n\nРынки меняются.\n\nКонкуренция развивается.\n\nПотребительский спрос смещается.\n\nПоявляются новые технологии.\n\nДаже самые уважаемые компании мира переживали периоды разочаровывающих результатов.\n\nКогда одна акция занимает большую долю портфеля, такие временные неудачи способны непропорционально сильно повлиять на общий результат.\n\nИменно поэтому риск концентрации — вопрос размера позиции, а не качества компании.\n\nОтличный бизнес всё равно может стать рискованным вложением, если от него зависит слишком многое в портфеле.\n\nВладение большим числом акций любимой компании не всегда делает портфель сильнее.\n\nИногда это лишь делает его менее устойчивым.';

  @override
  String get verdictConcentrationTier2Section1Label => 'Как это улучшить?';

  @override
  String get verdictConcentrationTier2Section1Body =>
      'Снижать доверие к своей крупнейшей позиции не нужно.\n\nВместо этого дайте остальному портфелю подрасти.\n\nСовершая будущие вложения, направляйте новый капитал в другие финансово сильные компании, а не продолжайте наращивать самую крупную позицию.\n\nЭто постепенно улучшает баланс без вынужденных продаж.\n\nСо временем результат портфеля будет определяться совокупной силой многих бизнесов, а не результатом одного.';

  @override
  String get verdictConcentrationTier2Section2Label => 'И напоследок';

  @override
  String get verdictConcentrationTier2Section2Body =>
      'Иметь любимую компанию — совершенно нормально.\n\nПросто не позволяйте ей стать всей вашей инвестиционной стратегией.\n\nСамые сильные портфели строятся не вокруг одного выдающегося бизнеса — а вокруг множества отличных компаний, работающих вместе.';

  @override
  String get verdictConcentrationTier3Title => 'Портфель на пути к балансу';

  @override
  String get verdictConcentrationTier3Intro =>
      'Ваш портфель движется к более здоровому балансу.\n\nНи одна компания полностью не доминирует среди ваших вложений, но одна позиция всё же заметно весомее остальных. Хотя это не серьёзная проблема, это означает, что один бизнес по-прежнему влияет на ваш долгосрочный результат сильнее, чем следовало бы.\n\nЭто обычный этап для многих инвесторов.\n\nВ конце концов, когда компания стабильно показывает сильные финансовые результаты, естественно хочется вкладывать в неё больше денег.\n\nУверенность — это важно.\n\nА вот с избыточной самоуверенности начинается риск.\n\nДаже выдающиеся компании переживают трудные периоды.\n\nСмена руководства, замедление роста, усиление конкуренции, изменения в регулировании или неожиданный экономический спад способны временно затронуть даже самые сильные компании.\n\nЕсли одна позиция становится слишком крупной, такие неудачи превращаются из обычных колебаний в события, затрагивающие весь портфель.\n\nК счастью, ваш портфель уже неплохо продвинулся в том, чтобы избежать этой проблемы.\n\nНесколько продуманных вложений в другие качественные компании способны значительно всё изменить, не нарушая общую выстроенную стратегию.';

  @override
  String get verdictConcentrationTier3Section1Label => 'Как это улучшить?';

  @override
  String get verdictConcentrationTier3Section1Body =>
      'Сокращать крупнейшую позицию только потому, что она крупнейшая, не нужно.\n\nВместо этого сосредоточьтесь на постепенном улучшении баланса.\n\nПродолжая инвестировать, уделяйте чуть больше внимания компаниям, которые сейчас занимают меньшую долю портфеля.\n\nПусть ваши будущие вложения — а не эмоциональные реакции — формируют распределение капитала.\n\nТакой подход сохраняет дисциплину вашей стратегии, естественным образом снижая риск концентрации.\n\nПомните: каждое новое вложение — это возможность укрепить портфель, а не просто увеличить любимую позицию.';

  @override
  String get verdictConcentrationTier3Section2Label => 'И напоследок';

  @override
  String get verdictConcentrationTier3Section2Body =>
      'Ваша цель не в том, чтобы найти одну компанию, которая понесёт на себе весь портфель.\n\nВаша цель — собрать коллекцию выдающихся бизнесов, которые преуспевают вместе.\n\nПортфель становится сильнее, когда успех распределён между многими компаниями, а не сосредоточен в одной.';

  @override
  String get verdictConcentrationTier4Title =>
      'Сбалансированный размер позиций';

  @override
  String get verdictConcentrationTier4Intro =>
      'Ваш портфель демонстрирует глубокое понимание управления рисками.\n\nНи одна компания не обладает достаточным влиянием, чтобы определить успех или провал всей вашей инвестиционной стратегии. Хотя некоторые позиции естественным образом крупнее других, капитал распределён так, что вклад в долгосрочный результат вносят сразу несколько бизнесов.\n\nЭто важная веха.\n\nМногие инвесторы годами ищут «идеальную акцию» и постепенно позволяют одной позиции разрастись настолько, что она начинает доминировать в портфеле.\n\nВы пошли другим путём.\n\nВместо того чтобы полагаться на одну компанию как источник будущей доходности, вы построили портфель, где успех может прийти из нескольких источников.\n\nЭто не значит, что все компании покажут одинаково хороший результат.\n\nОдни превзойдут ожидания.\n\nДругие разочаруют.\n\nЭто совершенно нормально.\n\nСила сбалансированного портфеля в том, что неудача одного вложения не становится автоматически неудачей всего финансового плана.\n\nЭто даёт вашему портфелю то, что нужно каждому инвестору:\n\nУстойчивость.';

  @override
  String get verdictConcentrationTier4Section1Label =>
      'Как сделать это ещё лучше?';

  @override
  String get verdictConcentrationTier4Section1Body =>
      'Сейчас важнее всего сохранить уже созданный баланс.\n\nПо мере роста вложений следите за позициями, которые начинают заметно опережать остальной портфель.\n\nИногда риск концентрации нарастает медленно.\n\nКомпания показывает исключительный результат, её акции растут годами, и вскоре она занимает намного большую долю портфеля, чем изначально планировалось.\n\nРегулярный пересмотр помогает убедиться, что сбалансированный сегодня портфель останется таким и в будущем.\n\nИдеальное равенство между позициями не нужно.\n\nВажно лишь не дать одной компании получить слишком большой контроль над вашим долгосрочным результатом.';

  @override
  String get verdictConcentrationTier4Section2Label => 'И напоследок';

  @override
  String get verdictConcentrationTier4Section2Body =>
      'Отличному портфелю не нужен герой.\n\nЕму не нужна одна акция, которая всех спасёт.\n\nВместо этого он опирается на совокупную силу многих тщательно отобранных бизнесов, работающих вместе с течением времени.\n\nКогда ни одна компания не способна в одиночку определить ваше будущее, портфель становится сильнее, стабильнее и лучше подготовлен к неожиданностям.';

  @override
  String get verdictConcentrationTier5Title =>
      'Ваш успех не зависит от одной компании';

  @override
  String get verdictConcentrationTier5Intro =>
      'Ваш портфель отражает дисциплинированный и хорошо сбалансированный подход к инвестированию.\n\nНи одной компании не позволено доминировать среди ваших вложений. Вместо того чтобы вкладывать всю уверенность в один бизнес, вы распределили капитал между множеством качественных компаний, позволив каждой вносить вклад в ваш долгосрочный успех.\n\nЭто один из самых эффективных способов управления инвестиционным риском.\n\nКаким бы успешным ни казался бизнес сегодня, его будущее никогда не гарантировано.\n\nЛидеры рынка могут утратить конкурентное преимущество.\n\nОтрасли меняются.\n\nПотребительские предпочтения смещаются.\n\nНеожиданные события способны бросить вызов даже самым сильным компаниям.\n\nИзбегая чрезмерной концентрации в одной позиции, вы приняли одну из важнейших истин инвестирования:\n\nНи одна компания не заслуживает полного контроля над вашим финансовым будущим.\n\nЭтот подход разделяют многие опытные долгосрочные инвесторы.\n\nОни понимают, что приумножение капитала — это не поиск одной акции, которая всё изменит.\n\nЭто владение коллекцией выдающихся бизнесов, работающих вместе через разные рыночные условия и разные стадии экономики.\n\nВаш портфель отражает именно эту философию.\n\nВместо того чтобы полагаться на одну компанию как источник исключительной доходности, вы построили структуру, в которой успех распределён между многими тщательно отобранными вложениями.';

  @override
  String get verdictConcentrationTier5Section1Label =>
      'Продолжайте беречь баланс';

  @override
  String get verdictConcentrationTier5Section1Body =>
      'По мере роста портфеля помните: риск концентрации может возникнуть даже без единой новой покупки.\n\nКомпания, показывающая исключительный результат, способна естественным образом превратиться в намного более крупную позицию со временем.\n\nПериодически пересматривайте распределение капитала и убеждайтесь, что портфель по-прежнему отражает вашу изначальную стратегию.\n\nЧасто достаточно просто направлять новые вложения в меньшие позиции, чтобы поддерживать здоровый баланс.\n\nЦель не в том, чтобы сделать все позиции одинаковыми.\n\nЦель — в том, чтобы ни одно вложение не стало важнее самого портфеля.';

  @override
  String get verdictConcentrationTier5Section2Label => 'И напоследок';

  @override
  String get verdictConcentrationTier5Section2Body =>
      'Каждая компания рассказывает часть вашей инвестиционной истории.\n\nНи одна из них не должна писать всю концовку целиком.\n\nСамые сильные портфели строятся не вокруг одного блестящего вложения — они строятся вокруг множества отличных решений, работающих вместе с течением времени.';

  @override
  String get verdictDisciplineNoDataTitle => 'Пока нет сделок';

  @override
  String get verdictDisciplineNoDataIntro =>
      'Этот тест завершился без единой сделки на покупку — оценивать поведение при покупке пока не по чему.';

  @override
  String get verdictDisciplineTier1Title => 'Эмоциональный инвестор';

  @override
  String get verdictDisciplineTier1Intro =>
      'Ваши инвестиционные решения демонстрируют сильное влияние рыночных эмоций.\n\nИнвестирование — это не только проверка финансовых знаний.\n\nЭто ещё и проверка терпения, дисциплины и способности сохранять спокойствие, когда рынок становится захватывающим или пугающим.\n\nВаше недавнее поведение при покупках говорит о том, что эмоции иногда управляют решениями сильнее, чем долгосрочная стратегия.\n\nЧасто это происходит в периоды сильного рыночного ажиотажа.\n\nЦены растут.\n\nВсе говорят об одной конкретной компании или тренде.\n\nСМИ полны историй успеха.\n\nКажется, что момент для покупки идеальный.\n\nНо именно в такие моменты многие инвесторы совершают свои главные ошибки.\n\nПокупка после резкого роста цены на волне ажиотажа может означать переплату, когда ожидания уже чрезвычайно завышены.\n\nПроблема не в покупке успешных компаний.\n\nПроблема в том, чтобы покупать их, не спрашивая себя:\n\n«Я инвестирую, потому что этот бизнес привлекателен, или потому что все вокруг о нём говорят?»';

  @override
  String get verdictDisciplineTier1Section1Label => 'Как это улучшить?';

  @override
  String get verdictDisciplineTier1Section1Body =>
      'Перед покупкой выработайте простой процесс принятия решений.\n\nСпросите себя:\n\nКупил бы я эту компанию, если бы о ней никто не говорил?\nПонимаю ли я бизнес, стоящий за котировкой?\nЯ покупаю на основе анализа или из страха упустить возможность?\n\nСильные инвесторы не пытаются избегать любой возможности.\n\nОни пытаются отделять реальные возможности от эмоциональных реакций.\n\nПолезная привычка — научиться ждать.\n\nИногда лучшее инвестиционное решение — не покупать немедленно.\n\nИногда терпение создаёт лучшие возможности, чем ажиотаж.';

  @override
  String get verdictDisciplineTier1Section2Label => 'И напоследок';

  @override
  String get verdictDisciplineTier1Section2Body =>
      'Рынок всегда будет создавать захватывающие истории.\n\nНо успешное инвестирование редко строится на следовании самой громкой из них.\n\nСильнейшие инвесторы — не те, кто реагирует быстрее всех, а те, кто сохраняет рациональность, когда все вокруг поддаются эмоциям.';

  @override
  String get verdictDisciplineTier2Title => 'Осваиваем дисциплину';

  @override
  String get verdictDisciplineTier2Intro =>
      'Ваше инвестиционное поведение показывает, что вы формируете привычки дисциплинированного инвестора, но эмоциональные решения всё ещё влияют на некоторые действия.\n\nВы уже не принимаете чисто импульсивных решений, но ваш инвестиционный процесс всё ещё складывается.\n\nЭтот этап очень распространён.\n\nМногие инвесторы понимают базовые принципы инвестирования:\n\nпокупать качественные бизнесы;\nмыслить на долгий срок;\nизбегать лишних рисков.\n\nНо понимать эти идеи и последовательно им следовать — разные вещи.\n\nРынок постоянно проверяет дисциплину инвестора на прочность.\n\nКогда цены быстро растут, появляется ажиотаж.\n\nКогда цены резко падают, берёт верх страх.\n\nСложность не в том, чтобы знать, как должен поступить дисциплинированный инвестор.\n\nСложность в том, чтобы реально так поступить, когда эмоции сильнее всего.\n\nВаше поведение показывает признаки улучшения, но пространство для более сильного процесса принятия решений ещё есть.';

  @override
  String get verdictDisciplineTier2Section1Label => 'Как это улучшить?';

  @override
  String get verdictDisciplineTier2Section1Body =>
      'Следующий шаг — создать правила, которые защищают от эмоциональных решений.\n\nПеред покупкой спросите себя:\n\nЯ покупаю, потому что бизнес привлекателен, или потому что цена быстро движется?\nПринял бы я это решение, если бы на рынке было тихо?\nЕсть ли у меня причина для этой покупки помимо недавней динамики?\n\nЕщё одна полезная привычка — сохранять определённую гибкость.\n\nОтличные возможности часто появляются, когда рынку становится неуютно.\n\nИнвесторы, готовящиеся заранее, обычно оказываются в лучшем положении, чем те, кто реагирует эмоционально в моменте.\n\nДисциплина не строится на одном идеальном решении.\n\nОна строится через повторение хороших решений с течением времени.';

  @override
  String get verdictDisciplineTier2Section2Label => 'И напоследок';

  @override
  String get verdictDisciplineTier2Section2Body =>
      'Становление дисциплинированным инвестором — это процесс, а не разовое достижение.\n\nЦель не в том, чтобы полностью убрать эмоции, — а в том, чтобы голос вашей стратегии звучал громче, чем голос эмоций.';

  @override
  String get verdictDisciplineTier3Title => 'Инвестор в развитии';

  @override
  String get verdictDisciplineTier3Intro =>
      'Ваше инвестиционное поведение демонстрирует сбалансированный подход.\n\nВы не подчиняетесь рыночным эмоциям постоянно, но при этом ещё не выработали полностью устоявшуюся дисциплину, которая направляла бы каждое решение.\n\nЭто нормальный этап для многих инвесторов.\n\nПостроение успешного инвестиционного процесса требует времени.\n\nОно требует умения отделять:\n\nвозможность от ажиотажа;\nуверенность от самоуверенности;\nтерпение от нерешительности.\n\nВаши решения показывают, что вы начинаете понимать важность тайминга и контекста.\n\nВы не реагируете на каждое движение рынка, но бывают моменты, когда эмоции всё же влияют на выбор.\n\nРынок постоянно создаёт давление.\n\nНа сильных ралли он подталкивает инвесторов гнаться за динамикой.\n\nНа спадах он подталкивает инвесторов ждать «идеальных условий».\n\nОбе реакции способны привести к упущенным возможностям.\n\nДисциплинированный инвестор понимает, что рынки непредсказуемы, но его собственный процесс может оставаться последовательным.';

  @override
  String get verdictDisciplineTier3Section1Label => 'Как это улучшить?';

  @override
  String get verdictDisciplineTier3Section1Body =>
      'Сосредоточьтесь на создании повторяемого инвестиционного распорядка.\n\nПеред каждой покупкой определяйте:\n\nЗачем я покупаю этот актив?\nЧто делает эту компанию или вложение привлекательными?\nЯ следую своей стратегии или реагирую на текущее настроение рынка?\n\nСтарайтесь оценивать решения по логике, стоящей за ними, — а не только по результату впоследствии.\n\nХорошее решение иногда приносит убыток.\n\nПлохое решение иногда приносит прибыль.\n\nДисциплина означает фокус на качестве самого процесса принятия решений.\n\nСо временем последовательные привычки становятся ценнее отдельных выигрышей или проигрышей.';

  @override
  String get verdictDisciplineTier3Section2Label => 'И напоследок';

  @override
  String get verdictDisciplineTier3Section2Body =>
      'Каждый опытный инвестор когда-то учился контролировать эмоции и укреплять уверенность.\n\nДисциплина — не врождённое качество, а навык, выстроенный через тысячи продуманных решений.';

  @override
  String get verdictDisciplineTier4Title => 'Дисциплинированный инвестор';

  @override
  String get verdictDisciplineTier4Intro =>
      'Ваше инвестиционное поведение демонстрирует сильный контроль над эмоциями и продуманный подход к принятию решений.\n\nВы понимаете один из самых сложных уроков инвестирования:\n\nРынок вознаграждает не того инвестора, который реагирует быстрее всех.\n\nОн вознаграждает того, кто способен сохранять терпение, анализировать возможности и следовать чёткой стратегии.\n\nВаши решения о покупке показывают, что на вас меньше влияет краткосрочный ажиотаж и больше — долгосрочная логика.\n\nПохоже, вам комфортнее принимать решения, исходя из возможности, а не эмоции.\n\nКогда рынок становится неопределённым, многие инвесторы замирают.\n\nКогда рынок становится захватывающим, многие инвесторы гонятся за тем, что уже популярно.\n\nВаше поведение демонстрирует лучший баланс.\n\nВы понимаете, что страх способен создавать возможности, а избыточный ажиотаж — создавать лишний риск.\n\nЭто не значит, что каждое решение будет идеальным.\n\nНи один инвестор не может предсказать будущее.\n\nДисциплина не в том, чтобы всегда быть правым.\n\nОна в том, чтобы принимать решения по правильным причинам.';

  @override
  String get verdictDisciplineTier4Section1Label => 'Как это улучшить?';

  @override
  String get verdictDisciplineTier4Section1Body =>
      'Продолжайте укреплять процесс, стоящий за вашими вложениями.\n\nДаже дисциплинированные инвесторы могут совершенствоваться, регулярно пересматривая свои решения.\n\nСпросите себя:\n\nОсталась ли верна моя исходная инвестиционная идея?\nСледую ли я по-прежнему своему долгосрочному плану?\nИзменилась ли причина, по которой я держу этот актив?\n\nПомните, что дисциплина — это не только покупка в нужный момент.\n\nЭто ещё и терпение удерживать качественные вложения в разных рыночных условиях.\n\nСильнейшие инвесторы — не те, кто никогда не ошибается.\n\nЭто те, у кого есть процесс, помогающий им учиться и совершенствоваться.';

  @override
  String get verdictDisciplineTier4Section2Label => 'И напоследок';

  @override
  String get verdictDisciplineTier4Section2Body =>
      'Рынок всегда будет создавать страх и ажиотаж.\n\nВы не можете контролировать эти эмоции вокруг себя.\n\nНо вы можете контролировать свою реакцию.\n\nДисциплинированный инвестор не пытается предсказать каждое движение рынка — он строит привычки, которые помогают принимать более удачные решения независимо от рыночной обстановки.';

  @override
  String get verdictDisciplineTier5Title => 'Мышление против толпы';

  @override
  String get verdictDisciplineTier5Intro =>
      'Ваше инвестиционное поведение демонстрирует высокий уровень дисциплины и эмоционального контроля.\n\nВы понимаете один из самых сложных принципов инвестирования:\n\nЛучшие возможности часто появляются именно тогда, когда действовать наиболее некомфортно.\n\nПока многие инвесторы реагируют на страх продажей, а на ажиотаж — покупкой, ваши решения показывают способность сделать шаг назад, проанализировать ситуацию и действовать в соответствии со стратегией.\n\nВы не просто следуете за толпой.\n\nВы понимаете, что рынками движут эмоции:\n\nСтрах способен опустить качественные компании до привлекательных цен.\n\nАжиотаж способен поднять ожидания выше реалистичного уровня.\n\nДисциплинированный инвестор понимает, что движение цены и стоимость бизнеса — не всегда одно и то же.\n\nКогда другие сосредоточены только на происходящем сегодня, вы, похоже, больше думаете о том, что будет иметь значение через годы.\n\nТакой подход не гарантирует идеальных результатов.\n\nНи один инвестор не может предсказать каждое движение рынка.\n\nДаже самые опытные инвесторы совершают ошибки.\n\nРазница в том, что дисциплинированные инвесторы выстраивают процесс, который помогает избегать эмоциональных решений и оставаться сосредоточенными на долгосрочных целях.';

  @override
  String get verdictDisciplineTier5Section1Label =>
      'Как сделать это ещё лучше?';

  @override
  String get verdictDisciplineTier5Section1Body =>
      'Сохраняйте привычки, которые помогли вам выработать такой уровень дисциплины.\n\nПродолжайте задавать себе важные вопросы перед каждым вложением:\n\nЯ покупаю, потому что возможность привлекательна, или потому что все в ажиотаже?\nОправдывает ли бизнес цену, которую я плачу?\nПринял бы я это решение, если бы рынок отреагировал негативно уже завтра?\n\nПомните, что быть контрарианом не значит всегда идти против толпы.\n\nИногда толпа права.\n\nИстинная дисциплина — это уверенность не соглашаться, когда факты это подтверждают, и скромность менять мнение, когда факты меняются.';

  @override
  String get verdictDisciplineTier5Section2Label => 'И напоследок';

  @override
  String get verdictDisciplineTier5Section2Body =>
      'Рынок вознаграждает терпение, но терпение требует смелости.\n\nВеличайшее преимущество инвестора — не в предсказании будущего, а в дисциплине принимать рациональные решения тогда, когда эмоции сильнее всего.';

  @override
  String get verdictEtfExposureNoDataTitle => 'Пока нет данных об ETF';

  @override
  String get verdictEtfExposureNoDataIntro =>
      'Этот тест завершился без единой открытой позиции — оценивать долю ETF пока не по чему.';

  @override
  String get verdictEtfExposureTier1Title => 'Без страховочной сетки';

  @override
  String get verdictEtfExposureTier1Intro =>
      'Ваш портфель полностью состоит из отдельных акций, без биржевых фондов (ETF), которые дали бы более широкий охват рынка.\n\nЭто не обязательно плохая стратегия.\n\nМногие успешные инвесторы построили впечатляющие портфели, используя только отдельные компании.\n\nСложность в том, что такой подход требует от вас гораздо большего.\n\nКаждое инвестиционное решение становится вашей личной ответственностью.\n\nВам нужно самостоятельно находить сильные бизнесы, избегать слабых, управлять диверсификацией, следить за риском и мириться с тем, что одна-единственная ошибка способна намного сильнее повлиять на ваш долгосрочный результат.\n\nETF работает иначе.\n\nВместо того чтобы полагаться на успех одной компании, он позволяет одной покупкой вложиться сразу в десятки — а то и сотни — бизнесов.\n\nЕсли одна компания испытывает трудности, остальные продолжают вносить вклад в портфель.\n\nИменно эта встроенная диверсификация — одна из главных причин популярности ETF среди долгосрочных инвесторов.\n\nБез хотя бы одного широкого рыночного ETF у вашего портфеля нет автоматической страховочной сетки.\n\nЕго успех полностью зависит от вашей способности год за годом выбирать выигрышные компании.\n\nЭто трудная задача — даже для опытных инвесторов.';

  @override
  String get verdictEtfExposureTier1Section1Label => 'Как это улучшить?';

  @override
  String get verdictEtfExposureTier1Section1Body =>
      'Подумайте о том, чтобы добавить широкий рыночный ETF в качестве основы портфеля.\n\nETF не заменяет инвестирование в отдельные акции.\n\nОн его дополняет.\n\nВоспринимайте его как устойчивое ядро вашей стратегии, а отдельные компании — как возможность искать дополнительный рост.\n\nМногие долгосрочные инвесторы совмещают оба подхода:\n\nДиверсифицированный ETF даёт стабильность.\n\nТщательно отобранные компании дают потенциал обогнать рынок.\n\nВместе они создают портфель, который одновременно устойчив и гибок.';

  @override
  String get verdictEtfExposureTier1Section2Label => 'И напоследок';

  @override
  String get verdictEtfExposureTier1Section2Body =>
      'ETF нужен вам не потому, что отдельные акции — это плохо.\n\nОн нужен, потому что ни один инвестор не способен предугадать всех будущих победителей.\n\nОдин ETF не сделает ваш портфель захватывающим — но он способен значительно повысить его устойчивость на десятилетия вперёд.';

  @override
  String get verdictEtfExposureTier2Title => 'Шаг к устойчивости';

  @override
  String get verdictEtfExposureTier2Intro =>
      'Теперь в вашем портфеле есть ETF — это важный шаг к более устойчивой инвестиционной стратегии.\n\nДобавив широкий охват рынка, вы снизили зависимость от отдельных компаний и включили в портфель инструмент, специально созданный для распределения риска между множеством бизнесов.\n\nИменно это ETF умеют делать лучше всего.\n\nХотя отдельные акции способны приносить исключительную доходность, они также способны разочаровывать по причинам, которые невозможно предсказать.\n\nETF помогает сгладить эту неопределённость, вкладываясь сразу в большую группу компаний, а не полагаясь на успех одной.\n\nВоспринимайте его как прочный фундамент под остальной частью портфеля.\n\nВ то же время один ETF — это только начало.\n\nВаш портфель всё ещё в основном опирается на отбор отдельных акций, а значит, ваш долгосрочный результат по-прежнему будет зависеть от качества выбранных компаний.\n\nETF даёт стабильность.\n\nВаш отбор акций даёт возможность дополнительного роста.\n\nВместе они создают более здоровый баланс, чем каждый из подходов по отдельности.';

  @override
  String get verdictEtfExposureTier2Section1Label => 'Как это улучшить?';

  @override
  String get verdictEtfExposureTier2Section1Body =>
      'Ваш портфель уже движется в верном направлении.\n\nПо мере его роста подумайте, сможет ли второй ETF дополнить уже имеющийся.\n\nНапример, инвесторы часто сочетают широкий рыночный ETF с фондом, ориентированным на международные рынки, компании малой капитализации, облигации или другую пока не представленную область.\n\nЦель не в том, чтобы коллекционировать ETF.\n\nЦель — убедиться, что каждый из них добавляет портфелю что-то по-настоящему новое.\n\nКачество важнее количества.';

  @override
  String get verdictEtfExposureTier2Section2Label => 'И напоследок';

  @override
  String get verdictEtfExposureTier2Section2Body =>
      'Один ETF не устранит инвестиционный риск.\n\nЭтого не может ничто.\n\nНо он способен снизить влияние неожиданных событий, дав вашему портфелю более прочный фундамент для дальнейшего роста.\n\nНадёжная инвестиционная стратегия строится не на одной идеальной компании — она начинается с портфеля, способного пережить самые разные рыночные условия.';

  @override
  String get verdictEtfExposureTier3Title => 'Крепкое ядро';

  @override
  String get verdictEtfExposureTier3Intro =>
      'В вашем портфеле здоровое число ETF, что создаёт прочную основу для долгосрочного инвестирования.\n\nВместо того чтобы полностью полагаться на отбор отдельных акций, вы решили совместить широкий охват рынка с гибкостью вкладываться в компании, в которые верите. Такую стратегию используют многие опытные инвесторы, поскольку она уравновешивает потенциал роста с разумным управлением риском.\n\nETF дают то, чего не могут дать отдельные акции.\n\nМгновенную диверсификацию.\n\nВсего несколькими фондами можно получить доступ к сотням — а то и тысячам — компаний из разных отраслей, стран и секторов экономики.\n\nЭто помогает снизить влияние любой отдельной компании на весь портфель, позволяя широкому рынку со временем работать в вашу пользу.\n\nВаш портфель хорошо отражает эту философию.\n\nПри этом вы избежали ещё одной распространённой ошибки — коллекционирования слишком большого числа ETF.\n\nУ каждого фонда в вашем портфеле, похоже, есть своя цель, а не просто добавление вложений ради самой диверсификации.\n\nЭто важное отличие.\n\nТщательно выбранный ETF должен расширять ваш охват, а не повторять то, чем вы уже владеете.';

  @override
  String get verdictEtfExposureTier3Section1Label =>
      'Как сделать это ещё лучше?';

  @override
  String get verdictEtfExposureTier3Section1Body =>
      'Сейчас главное — не добавлять ещё больше ETF.\n\nГлавное — понимать, что на самом деле держит каждый из них.\n\nПеред покупкой ещё одного фонда спросите себя:\n\nДаёт ли этот ETF охват, которого у меня ещё нет?\nЯ добавляю диверсификацию или просто снова покупаю те же компании?\nЕсть ли у этого фонда чёткая роль в моём портфеле?\n\nНебольшая коллекция удачно подобранных ETF часто эффективнее, чем десятки перекрывающихся фондов.\n\nПомните: у каждого вложения должна быть задача.\n\nЕсли ETF не улучшает портфель сколько-нибудь заметно, возможно, ему там не место.';

  @override
  String get verdictEtfExposureTier3Section2Label => 'И напоследок';

  @override
  String get verdictEtfExposureTier3Section2Body =>
      'Отличные портфели измеряются не количеством ETF в их составе.\n\nОни измеряются тем, насколько хорошо эти ETF работают вместе.\n\nНесколько тщательно отобранных фондов способны стать основой на десятилетия инвестирования — не усложняя портфель без необходимости.';

  @override
  String get verdictEtfExposureTier4Title => 'Широко диверсифицирован';

  @override
  String get verdictEtfExposureTier4Intro =>
      'В вашем портфеле несколько ETF, дающих доступ к широкому кругу компаний и рынков.\n\nЭто хороший знак.\n\nИнвестируя через несколько фондов, вы снизили риск чрезмерной зависимости от отдельных бизнесов и создали портфель, способный выигрывать от разных частей мировой экономики.\n\nОднако наступает момент, когда добавление новых ETF уже не увеличивает диверсификацию.\n\nМногие популярные фонды держат одни и те же компании.\n\nНапример, у нескольких американских ETF на акции нередко есть крупные позиции в таких компаниях, как Apple, Microsoft, NVIDIA, Amazon и других лидерах рынка.\n\nХотя названия фондов различаются, значительная часть их фактического состава может выглядеть на удивление похоже.\n\nЭто называется пересекающимся охватом.\n\nОн создаёт впечатление большей диверсификации, тогда как на деле многие ваши вложения следуют за одной и той же группой компаний.\n\nВаш портфель всё ещё хорошо диверсифицирован, но стоит убедиться, что каждый ETF вносит что-то уникальное, а не повторяет то, чем вы уже владеете.';

  @override
  String get verdictEtfExposureTier4Section1Label =>
      'Как сделать это ещё лучше?';

  @override
  String get verdictEtfExposureTier4Section1Body =>
      'Прежде чем добавлять ещё один ETF, найдите время разобраться, что он на самом деле содержит.\n\nСпросите себя:\n\nВкладывается ли этот фонд в компании, которых у меня ещё нет через другой ETF?\nДаёт ли он доступ к другому региону, сектору или классу активов?\nОн добавляет реальную диверсификацию или просто увеличивает мою долю в тех же бизнесах?\n\nИногда замена двух похожих ETF одним более широким фондом упрощает портфель, сохраняя почти идентичный рыночный охват.\n\nПортфель не становится сильнее просто потому, что в нём больше фондов.\n\nОн становится сильнее, когда у каждого вложения есть чёткая цель.';

  @override
  String get verdictEtfExposureTier4Section2Label => 'И напоследок';

  @override
  String get verdictEtfExposureTier4Section2Body =>
      'Больше ETF не всегда означает больше диверсификации.\n\nИногда это просто означает владение теми же компаниями по несколько раз под разными названиями.\n\nЦель не в том, чтобы коллекционировать фонды, — а в том, чтобы построить портфель, где каждый ETF добавляет что-то ценное, чего ещё не было.';

  @override
  String get verdictEtfExposureTier5Title =>
      'Широкая диверсификация, простая стратегия';

  @override
  String get verdictEtfExposureTier5Intro =>
      'В вашем портфеле большое число ETF, дающих доступ к широкому кругу рынков, отраслей и компаний.\n\nВ этом подходе нет ничего плохого самого по себе.\n\nБолее того, многие инвесторы предпочитают строить весь портфель на ETF, поскольку они дают отличную диверсификацию, не требуют много внимания и открывают широкий доступ к мировой экономике.\n\nОднако большее число ETF не гарантирует автоматически лучший портфель.\n\nПосле определённой точки многие фонды начинают вкладываться в одни и те же компании.\n\nETF на американский рынок, ETF на S&P 500, ETF на компании крупной капитализации и ETF роста могут одновременно держать крупные позиции в таких компаниях, как Apple, Microsoft, NVIDIA, Amazon и других лидерах рынка.\n\nХотя ваш портфель выглядит крайне диверсифицированным, фактические вложения могут пересекаться намного сильнее, чем вы думаете.\n\nЕсть ещё один компромисс, который стоит понимать.\n\nETF созданы, чтобы следовать за рынком, а не обгонять его.\n\nОни дают стабильный диверсифицированный охват, но сами по себе редко приносят исключительную доходность.\n\nИменно поэтому многие инвесторы сочетают небольшое число широких ETF с тщательно отобранными отдельными компаниями.\n\nETF дают стабильность.\n\nОтдельные бизнесы дают возможность обогнать рынок.\n\nНи один из подходов не лучше другого универсально.\n\nОни просто отражают разные инвестиционные философии.';

  @override
  String get verdictEtfExposureTier5Section1Label =>
      'Как сделать это ещё лучше?';

  @override
  String get verdictEtfExposureTier5Section1Body =>
      'Вместо вопроса, нужен ли вам ещё один ETF, спросите, есть ли у каждого из них уникальная роль.\n\nДаёт ли он доступ к рынку, которого у вас ещё нет?\n\nИли это просто ещё один способ купить те же компании?\n\nЕсли ваша цель — простой долгосрочный портфель, горстки тщательно отобранных ETF часто достаточно.\n\nЕсли ваша цель — обогнать рынок за счёт отбора акций, подумайте о том, чтобы дать вашим самым сильным отдельным компаниям более заметную роль, оставив ETF устойчивым ядром портфеля.\n\nЦель не в том, чтобы владеть большим числом фондов.\n\nЦель — чтобы каждый фонд заслуживал своё место.';

  @override
  String get verdictEtfExposureTier5Section2Label => 'И напоследок';

  @override
  String get verdictEtfExposureTier5Section2Body =>
      'Портфель, полностью состоящий из ETF, может быть отличной долгосрочной стратегией.\n\nПортфель, сочетающий ETF и выдающиеся бизнесы, тоже может быть отличной стратегией.\n\nВажный вопрос не в том, сколько ETF вы держите.\n\nА в том, добавляет ли каждый из них что-то, чего у вашего портфеля ещё не было.\n\nДиверсификация — это сила. Сложность не всегда необходима.';

  @override
  String get verdictPanicNoDataTitle => 'Пока нет сделок';

  @override
  String get verdictPanicNoDataIntro =>
      'Этот тест завершился без единой сделки — оценивать поведение при продаже пока не по чему.';

  @override
  String get verdictPanicTier1Title => 'Паническая продажа';

  @override
  String get verdictPanicTier1Intro =>
      'Ваше поведение при продажах показывает, что страх иногда влияет на инвестиционные решения.\n\nИнвестирование — это не только выбор хороших компаний.\n\nЭто ещё и терпение с эмоциональным контролем, чтобы придерживаться своих решений, когда рынок становится некомфортным.\n\nОдин из самых трудных моментов для любого инвестора — наблюдать за падением позиции.\n\nЕстественная реакция — подумать:\n\n«Может, я ошибся. Может, стоит выйти, пока не стало хуже».\n\nИногда продажа — правильное решение.\n\nКомпания может утратить конкурентное преимущество.\n\nУсловия бизнеса могут измениться.\n\nИзначальная инвестиционная идея может перестать быть верной.\n\nНо продажа только потому, что падает цена, — совсем другая ситуация.\n\nКрупнейшие потери у многих инвесторов возникают не из-за покупки плохих компаний.\n\nОни возникают из-за отказа от хороших вложений в самые напряжённые моменты.\n\nПанические продажи часто случаются, когда страх достигает пика.\n\nК сожалению, именно в этот момент многие качественные активы торгуются по самым низким ценам.\n\nВаш результат говорит о том, что некоторые решения о продаже, возможно, принимались под сильным давлением, близко к худшим моментам падения.';

  @override
  String get verdictPanicTier1Section1Label => 'Как это улучшить?';

  @override
  String get verdictPanicTier1Section1Body =>
      'Перед продажей позиции в убыток составьте чёткий чек-лист.\n\nСпросите себя:\n\nБизнес действительно стал хуже?\nИзменилась ли изначальная причина покупки?\nЯ принимаю это решение из-за новой информации или из-за страха?\n\nПостарайтесь отделить котировку акции от самого бизнеса.\n\nПадающая цена не всегда означает сломанную компанию.\n\nИногда рынок просто реагирует эмоционально.\n\nЕщё одна полезная привычка — создавать правила до того, как возникнут проблемы.\n\nНапример:\n\nПочему я продал бы эту компанию?\nКакие условия заставили бы меня изменить мнение?\nСколько волатильности я готов принять?\n\nПлан, составленный в спокойный период, обычно надёжнее решения, принятого в панике.';

  @override
  String get verdictPanicTier1Section2Label => 'И напоследок';

  @override
  String get verdictPanicTier1Section2Body =>
      'Рынок будет испытывать каждого инвестора.\n\nЦены будут падать.\n\nБудут появляться плохие новости.\n\nСтрах будет звучать громко.\n\nЦель не в том, чтобы никогда не чувствовать страх, — а в том, чтобы не позволять страху принимать инвестиционные решения за вас.';

  @override
  String get verdictPanicTier2Title => 'Эмоциональные продажи';

  @override
  String get verdictPanicTier2Intro =>
      'Ваше инвестиционное поведение показывает, что вы учитесь справляться со сложными рыночными ситуациями, но эмоции всё ещё влияют на некоторые решения о продаже.\n\nПродажа — одна из самых трудных частей инвестирования.\n\nПокупка компании часто ощущается воодушевляюще.\n\nДержать позицию в хорошие времена легко.\n\nНо наблюдение за падением позиции проверяет на прочность терпение, уверенность и доверие к собственному анализу.\n\nВаша история говорит о том, что на некоторые решения могло влиять краткосрочное давление, а не полный пересмотр вложения.\n\nЭто не значит, что каждая убыточная сделка была ошибкой.\n\nХорошие инвесторы иногда продают в убыток.\n\nРазница в том, почему они это делают.\n\nДисциплинированный инвестор может принять убыток, потому что:\n\nбизнес изменился;\nизначальная инвестиционная идея больше не верна;\nпоявилась более удачная возможность.\n\nЭмоциональная продажа происходит, когда главная причина звучит так:\n\n«Я больше не могу выносить это падение».\n\nРынок часто создаёт самые сильные эмоции именно в самые трудные моменты.\n\nСтрах становится громче.\n\nУверенность исчезает.\n\nИ многие инвесторы выходят из позиции именно тогда, когда терпение становится самым ценным навыком.';

  @override
  String get verdictPanicTier2Section1Label => 'Как это улучшить?';

  @override
  String get verdictPanicTier2Section1Body =>
      'Перед продажей во время падения постарайтесь замедлить процесс принятия решения.\n\nСпросите себя:\n\nЯ продаю, потому что компания стала слабее?\nИли я продаю, потому что котировка вызывает у меня дискомфорт?\nПринял бы я это решение, если бы не видел ежедневных колебаний цены?\n\nСоздайте правила продажи до того, как появятся эмоции.\n\nХороший инвестиционный план должен включать не только вопрос:\n\n«Когда мне покупать?»\n\nно и:\n\n«Когда мне продавать?»\n\nПомните, что временные падения цены — нормальная часть инвестирования.\n\nВажный вопрос не в том:\n\n«Упала ли цена?»\n\nВажный вопрос в том:\n\n«Изменилась ли причина, по которой я инвестировал?»';

  @override
  String get verdictPanicTier2Section2Label => 'И напоследок';

  @override
  String get verdictPanicTier2Section2Body =>
      'Каждый инвестор испытывает страх.\n\nРазница между опытными инвесторами и новичками не в отсутствии страха.\n\nОна в способности принимать решения с ясной головой даже тогда, когда страх присутствует.';

  @override
  String get verdictPanicTier3Title => 'Осваиваем терпение';

  @override
  String get verdictPanicTier3Intro =>
      'Ваше поведение при продажах показывает, что вы формируете более сильный контроль над эмоциональными решениями, но способность сохранять спокойствие в трудные рыночные периоды всё ещё развивается.\n\nВы уже не реагируете исключительно из страха, но некоторые ситуации всё ещё создают неопределённость и давление.\n\nЭто очень распространённый этап для инвесторов.\n\nНаучиться успешно инвестировать — это не только знать, что покупать.\n\nЭто ещё и умение знать, когда не действовать.\n\nРынки постоянно создают ситуации, испытывающие уверенность:\n\nХорошая компания падает из-за временного рыночного страха.\n\nСильное вложение снижается, потому что под давлением оказывается вся отрасль.\n\nНегативные заголовки создают неопределённость.\n\nВ такие моменты многие инвесторы чувствуют потребность немедленно что-то предпринять.\n\nНо иногда самое дисциплинированное решение — просто подождать и собрать больше информации.\n\nВаше поведение говорит о том, что вы формируете этот навык, но пространство для укрепления терпения ещё есть.';

  @override
  String get verdictPanicTier3Section1Label => 'Как это улучшить?';

  @override
  String get verdictPanicTier3Section1Body =>
      'Перед продажей в трудный период постарайтесь отделить эмоции от фактов.\n\nСпросите себя:\n\nКомпания фундаментально изменилась?\nИнвестиционная идея всё ещё верна?\nЯ реагирую на временный рыночный шум?\n\nПомните, что волатильность — нормальная часть инвестирования.\n\nДаже отличные компании переживают периоды снижения.\n\nПолезная привычка — пересматривать изначальную причину покупки.\n\nЕсли причина всё ещё верна, более низкая цена не обязательно означает ошибку.\n\nТерпение не означает держать всё вечно.\n\nОно означает дать хорошему вложению достаточно времени проявить себя, оставаясь готовым изменить решение, когда факты по-настоящему меняются.';

  @override
  String get verdictPanicTier3Section2Label => 'И напоследок';

  @override
  String get verdictPanicTier3Section2Body =>
      'Успешные инвесторы — это не те, кто никогда не сталкивается с неопределённостью.\n\nЭто те, кто научился справляться с неопределённостью, не принимая поспешных решений.\n\nТерпение — это не бездействие, а тщательный выбор действий, когда рынок пытается на вас давить.';

  @override
  String get verdictPanicTier4Title => 'Устойчивый инвестор';

  @override
  String get verdictPanicTier4Intro =>
      'Ваше поведение при продажах демонстрирует хороший эмоциональный контроль и растущую способность справляться с рыночной неопределённостью.\n\nВы понимаете один из важнейших уроков инвестирования:\n\nПадающая котировка не означает автоматически плохое вложение.\n\nМногие инвесторы сохраняют уверенность, когда рынки растут.\n\nНастоящее испытание наступает в трудные периоды.\n\nКогда цены снижаются, появляются негативные заголовки и растёт неопределённость, эмоциональные решения становятся намного соблазнительнее.\n\nВаше поведение говорит о том, что вы обычно способны избегать панических реакций и давать вложениям время развиться.\n\nПохоже, вы больше сосредоточены на причинах своих вложений, чем на краткосрочных колебаниях цены.\n\nЭто не значит, что каждое решение идеально.\n\nНи один инвестор не избегает ошибок полностью.\n\nРазница в том, что дисциплинированные инвесторы не позволяют временному рыночному страху становиться главной причиной действий.\n\nОни оценивают ситуацию, пересматривают факты и принимают решения на основе своей стратегии.';

  @override
  String get verdictPanicTier4Section1Label => 'Как это улучшить?';

  @override
  String get verdictPanicTier4Section1Body =>
      'Продолжайте укреплять процесс принятия решений.\n\nПеред продажей позиции спросите себя:\n\nИзменился бизнес или только котировка?\nСчитал бы я эту компанию хорошей, если бы рынок закрылся завтра?\nЯ продаю из-за новой информации или из-за временного страха?\n\nПомните, что терпение не означает отказ от продажи.\n\nИногда продажа — правильное решение.\n\nКлючевое отличие — причина, стоящая за ней.\n\nСильный инвестор продаёт, потому что изменился инвестиционный тезис.\n\nЭмоциональный инвестор продаёт, потому что рынок стал некомфортным.';

  @override
  String get verdictPanicTier4Section2Label => 'И напоследок';

  @override
  String get verdictPanicTier4Section2Body =>
      'Рынки всегда будут создавать моменты неопределённости.\n\nСпособность сохранять спокойствие в такие моменты — мощное инвестиционное преимущество.\n\nУстойчивый инвестор не игнорирует риск — он понимает его, оценивает и реагирует с ясной головой, а не со страхом.';

  @override
  String get verdictPanicTier5Title => 'Выживший на рынке';

  @override
  String get verdictPanicTier5Intro =>
      'Ваше инвестиционное поведение демонстрирует очень высокий уровень эмоционального контроля и терпения в трудных рыночных условиях.\n\nВы понимаете один из самых сложных уроков инвестирования:\n\nВременное падение не всегда означает безвозвратную потерю.\n\nМногие инвесторы сохраняют уверенность, когда рынки растут.\n\nНастоящее испытание наступает, когда всё движется в обратном направлении.\n\nЦены падают.\n\nНегативные заголовки доминируют в новостях.\n\nСтрах распространяется среди инвесторов.\n\nВ такие моменты эмоции часто оказываются сильнее анализа.\n\nВаше поведение показывает, что вы способны сохранять концентрацию в периоды крайнего давления.\n\nВместо того чтобы немедленно реагировать на падающие цены, вы, похоже, даёте своим вложениям время и оцениваете ситуации более тщательно.\n\nЭто одно из главных отличий краткосрочных реакций от долгосрочного инвестирования.\n\nСильный инвестор понимает, что обвалы рынка — это не только периоды риска.\n\nОни также способны создавать возможности.\n\nКогда другие вынуждены принимать эмоциональные решения, терпеливые инвесторы часто получают наибольшее преимущество.';

  @override
  String get verdictPanicTier5Section1Label => 'Как сделать это ещё лучше?';

  @override
  String get verdictPanicTier5Section1Body =>
      'Продолжайте оберегать привычки, которые создали этот уровень дисциплины.\n\nДаже опытным инвесторам стоит регулярно пересматривать свои решения.\n\nСпросите себя:\n\nИзменился бизнес или только рыночная цена?\nЯ всё ещё уверен в изначальной инвестиционной идее?\nЯ принимаю это решение на основе фактов или эмоций?\n\nПомните, что терпение не означает держать каждое вложение вечно.\n\nВеликий инвестор не боится изменить мнение, когда меняются факты.\n\nЦель не в том, чтобы избежать каждой ошибки.\n\nЦель — избежать решений, продиктованных временным страхом.';

  @override
  String get verdictPanicTier5Section2Label => 'И напоследок';

  @override
  String get verdictPanicTier5Section2Body =>
      'Каждый рыночный цикл создаёт моменты, испытывающие инвесторов.\n\nОдни реагируют на страх.\n\nДругие используют терпение как своё преимущество.\n\nВеличайшая сила долгосрочного инвестора не в том, чтобы избегать бурь, — а в дисциплине сохранять концентрацию, пока они не пройдут.';

  @override
  String get verdictPatienceNoDataTitle => 'Пока нет сделок';

  @override
  String get verdictPatienceNoDataIntro =>
      'Этот тест завершился без единой сделки — оценивать умение ждать пока не по чему.';

  @override
  String get verdictPatienceTier1Title => 'Нетерпеливый инвестор';

  @override
  String get verdictPatienceTier1Intro =>
      'Ваше инвестиционное поведение показывает, что терпение может быть одной из главных областей для роста.\n\nИнвестирование — это не только поиск хороших возможностей.\n\nЭто ещё и умение дать своим решениям достаточно времени сработать.\n\nРынок постоянно создаёт давление действовать:\n\nЦены двигаются каждый день.\n\nНовости порождают неопределённость.\n\nДругие инвесторы делятся историями успеха.\n\nВ такие моменты может казаться, что действовать всегда лучше, чем ждать.\n\nНо в инвестировании лишние действия иногда становятся самой большой ошибкой.\n\nХорошее вложение не всегда сразу растёт в цене.\n\nДаже сильные компании могут переживать:\n\nвременные падения;\nсложные рыночные условия;\nпериоды, когда инвесторы теряют уверенность.\n\nВаш результат говорит о том, что вы иногда реагируете слишком быстро, не давая своим инвестиционным идеям достаточно времени раскрыться.\n\nПроблема не в том, чтобы вносить изменения.\n\nУспешные инвесторы иногда продают, корректируют и улучшают свои портфели.\n\nВажный вопрос звучит так:\n\n«Я меняю решение, потому что изменились факты, или потому что ситуация стала некомфортной?»';

  @override
  String get verdictPatienceTier1Section1Label => 'Как это улучшить?';

  @override
  String get verdictPatienceTier1Section1Body =>
      'Прежде чем принять быстрое решение, попробуйте установить короткий период ожидания.\n\nСпросите себя:\n\nКомпания действительно стала слабее?\nПроизошло ли что-то фундаментальное?\nЯ реагирую на временный рыночный шум?\nПринял бы я то же решение, если бы не видел сегодняшнего движения цены?\n\nПостарайтесь отделить движение цены от его смысла.\n\nПадающая цена не всегда означает плохое вложение.\n\nРастущая цена не всегда означает хорошее вложение.\n\nСильные инвесторы понимают, что время — важная часть инвестиционного процесса.\n\nЕщё одна полезная привычка — устанавливать правила до появления эмоций:\n\nЧто заставило бы меня продать?\nСколько времени я готов ждать?\nКакие условия изменили бы мою изначальную идею?\n\nСпокойный план, составленный в обычных условиях, намного надёжнее решения, принятого под давлением.';

  @override
  String get verdictPatienceTier1Section2Label => 'И напоследок';

  @override
  String get verdictPatienceTier1Section2Body =>
      'Рынок вознаграждает инвесторов, способных сохранять концентрацию, когда другие теряют терпение.\n\nТерпение не означает бездействие.\n\nОно означает уверенность ждать тогда, когда ожидание — самое разумное решение.';

  @override
  String get verdictPatienceTier2Title => 'Краткосрочное мышление';

  @override
  String get verdictPatienceTier2Intro =>
      'Ваше инвестиционное поведение показывает, что вы вырабатываете терпение, но сложные рыночные ситуации всё ещё способны создавать давление, влияющее на некоторые решения.\n\nВы понимаете важность оставаться вложенным, но ваши действия говорят о том, что неопределённость иногда заставляет вас менять курс слишком быстро.\n\nЭто очень распространённый этап для инвесторов.\n\nМногие понимают идею долгосрочного инвестирования:\n\nпокупать качественные активы;\nоставаться вложенным;\nигнорировать краткосрочный шум.\n\nНо понимать эту концепцию и применять её в стрессовые моменты — разные вещи.\n\nРынок постоянно проверяет терпение на прочность.\n\nУ компании могут быть сильные фундаментальные показатели, но котировка может снижаться из-за:\n\nрыночного страха;\nэкономической неопределённости;\nвременных плохих новостей;\nнегативных настроений.\n\nВ такие периоды легко сосредоточиться только на падающей цене и забыть изначальную причину вложения.\n\nВаш результат говорит о том, что вы иногда позволяете краткосрочным событиям слишком сильно влиять на долгосрочные решения.';

  @override
  String get verdictPatienceTier2Section1Label => 'Как это улучшить?';

  @override
  String get verdictPatienceTier2Section1Body =>
      'Следующий шаг — выстроить более крепкую связь между инвестиционными решениями и изначальной стратегией.\n\nПеред тем как что-то менять, спросите себя:\n\nКомпания действительно стала хуже?\nЭто постоянная проблема или временная ситуация?\nХотел бы я по-прежнему владеть этим бизнесом, если бы не видел движения цены?\n\nПостарайтесь оценивать вложения исходя из бизнеса, а не только из графика.\n\nВременное падение может вызывать дискомфорт.\n\nНо один лишь дискомфорт не всегда повод действовать.\n\nПомните:\n\nДолгосрочного инвестора вознаграждают не за реакцию на каждое движение рынка.\n\nЕго вознаграждают за продуманные решения и за то, что он даёт хорошим идеям достаточно времени сработать.';

  @override
  String get verdictPatienceTier2Section2Label => 'И напоследок';

  @override
  String get verdictPatienceTier2Section2Body =>
      'Рынок движется быстрее, чем любой инвестор способен предсказать.\n\nПопытки реагировать на каждое движение часто порождают лишние ошибки.\n\nТерпение — это способность дать своей стратегии достаточно времени проявить себя, вместо того чтобы постоянно менять курс вслед за каждой рыночной волной.';

  @override
  String get verdictPatienceTier3Title => 'Формируем терпение';

  @override
  String get verdictPatienceTier3Intro =>
      'Ваше инвестиционное поведение показывает, что вы развиваете способность сохранять спокойствие в условиях рыночной неопределённости, но терпение по-прежнему остаётся навыком, который продолжает расти.\n\nВы начинаете понимать важный инвестиционный принцип:\n\nНе каждое движение рынка требует реакции.\n\nУспешное инвестирование часто требует умения ждать.\n\nЖдать подходящей возможности.\n\nЖдать, пока рынок признает ценность.\n\nЖдать, пока хорошее бизнес-решение раскроется со временем.\n\nВаше поведение говорит о том, что вы уже не реагируете эмоционально постоянно, но некоторые ситуации всё ещё создают неопределённость и заставляют сомневаться в решениях.\n\nЭто нормальный этап развития для инвесторов.\n\nРынок редко движется по прямой.\n\nДаже сильные вложения переживают периоды:\n\nмедленного роста;\nвременных падений;\nнегативных настроений;\nнеопределённости.\n\nСложность в том, чтобы научиться понимать, когда действие необходимо, а когда терпение — лучший выбор.';

  @override
  String get verdictPatienceTier3Section1Label => 'Как это улучшить?';

  @override
  String get verdictPatienceTier3Section1Body =>
      'Продолжайте выстраивать чёткий процесс принятия решений перед изменениями.\n\nКогда возникает желание продать или скорректировать портфель, спросите:\n\nБизнес действительно слабеет, или это просто реакция рынка?\nИзменилась ли моя изначальная инвестиционная идея?\nЯ принимаю это решение из-за фактов или из-за дискомфорта?\n\nСтарайтесь оценивать вложения исходя из долгосрочной картины.\n\nВременное падение может ощущаться некомфортно, но дискомфорт не всегда сигнал, что что-то не так.\n\nВ то же время терпение не означает игнорирование проблем.\n\nТерпеливый инвестор всё равно пересматривает решения и меняет курс, когда факты действительно меняются.\n\nЦель не в том, чтобы держать всё вечно.\n\nЦель — избегать лишних действий, вызванных краткосрочными эмоциями.';

  @override
  String get verdictPatienceTier3Section2Label => 'И напоследок';

  @override
  String get verdictPatienceTier3Section2Body =>
      'Терпение формируется через опыт.\n\nКаждое падение рынка, каждый неопределённый момент и каждое трудное решение — это шанс стать лучше.\n\nТерпеливый инвестор — не тот, кто никогда не действует.\n\nТерпеливый инвестор знает, когда действие необходимо, а когда ожидание — самое разумное решение.';

  @override
  String get verdictPatienceTier4Title => 'Терпеливый инвестор';

  @override
  String get verdictPatienceTier4Intro =>
      'Ваше инвестиционное поведение демонстрирует сильную способность сохранять спокойствие и концентрацию в условиях рыночной неопределённости.\n\nВы понимаете один из важнейших уроков долгосрочного инвестирования:\n\nНе каждая проблема на рынке требует немедленного действия.\n\nМногие инвесторы чувствуют давление постоянно принимать решения.\n\nКогда цены растут, им хочется купить ещё.\n\nКогда цены падают, им хочется защититься.\n\nНо опытные инвесторы понимают, что иногда лучшее решение — просто подождать и дать времени сделать своё дело.\n\nВаше поведение говорит о том, что вы способны отделять временные рыночные колебания от реальных изменений в качестве вложения.\n\nВы, скорее всего, оцениваете ситуацию, а не реагируете на эмоции немедленно.\n\nЭто ценный навык, ведь рынки специально устроены так, чтобы испытывать терпение инвестора.\n\nВсегда будут:\n\nнеожиданные падения;\nнегативные заголовки;\nпериоды неопределённости;\nмоменты, испытывающие уверенность.\n\nСпособность сохранять концентрацию в такие периоды может стать одним из главных преимуществ инвестора.';

  @override
  String get verdictPatienceTier4Section1Label => 'Как это улучшить?';

  @override
  String get verdictPatienceTier4Section1Body =>
      'Продолжайте развивать инвестиционный процесс и оберегайте привычки, создавшие этот уровень терпения.\n\nПеред изменениями продолжайте спрашивать:\n\nБизнес действительно изменился?\nИзначальная инвестиционная идея всё ещё верна?\nЯ принимаю это решение из-за новой информации или из-за временных рыночных эмоций?\n\nПомните, что терпение не означает отказ принимать решения.\n\nТерпеливый инвестор всё равно готов продать, когда меняются факты.\n\nРазница в том, что решения исходят из анализа, а не давления.\n\nПродолжайте фокусироваться на долгосрочной картине, а не реагировать на каждое краткосрочное движение.';

  @override
  String get verdictPatienceTier4Section2Label => 'И напоследок';

  @override
  String get verdictPatienceTier4Section2Body =>
      'Рынки всегда будут создавать моменты, испытывающие вашу уверенность.\n\nПреимущество не у того инвестора, кто реагирует на каждое изменение.\n\nОно у того, кто способен сохранять концентрацию, ждать подходящего момента и давать хорошим решениям достаточно времени сработать.';

  @override
  String get verdictPatienceTier5Title => 'Долгосрочное мышление';

  @override
  String get verdictPatienceTier5Intro =>
      'Ваше инвестиционное поведение демонстрирует исключительный уровень терпения и эмоционального контроля.\n\nВы понимаете одно из самых мощных преимуществ в инвестировании:\n\nВремя — это не просто то, чего инвесторы ждут, а то, что они используют.\n\nМногие инвесторы сосредоточены на попытках предсказать следующее движение рынка.\n\nОни пытаются найти идеальную точку входа.\n\nОни реагируют на каждый заголовок.\n\nОни беспокоятся из-за каждого временного падения.\n\nНо долгосрочные инвесторы понимают, что успешное инвестирование чаще строится на последовательности, подготовке и способности сохранять концентрацию, когда рынок становится непредсказуемым.\n\nВаше поведение показывает, что вы способны избегать лишних реакций в трудные периоды.\n\nВместо немедленной реакции на страх или неопределённость вы даёте своим инвестиционным решениям время раскрыться.\n\nЭто особенно важно во время крупных рыночных потрясений.\n\nКогда распространяется страх, многие инвесторы принимают решения на основе эмоций.\n\nОни продают, чтобы остановить дискомфорт.\n\nТерпеливый инвестор понимает, что неопределённость — часть инвестирования.\n\nОн оценивает ситуацию, пересматривает факты и не меняет курс просто потому, что рынок стал напряжённым.';

  @override
  String get verdictPatienceTier5Section1Label => 'Как сделать это ещё лучше?';

  @override
  String get verdictPatienceTier5Section1Body =>
      'Сохранять терпение — это сила, но даже терпеливым инвесторам стоит продолжать пересматривать свои решения.\n\nПомните:\n\nТерпение не означает держать каждое вложение вечно.\n\nСильный долгосрочный инвестор всё равно спрашивает себя:\n\nБизнес изменился?\nИзначальная инвестиционная идея всё ещё верна?\nЯ держу позицию из уверенности или потому что отказываюсь признать ошибку?\n\nЦель не в том, чтобы избежать каждой продажи.\n\nЦель — убедиться, что решения исходят из анализа, а не из эмоций.\n\nПродолжайте уравновешивать терпение осознанностью.\n\nЛучшие инвесторы спокойны, но никогда не беспечны.';

  @override
  String get verdictPatienceTier5Section2Label => 'И напоследок';

  @override
  String get verdictPatienceTier5Section2Body =>
      'Рынок всегда будет создавать моменты страха, воодушевления и неопределённости.\n\nВы не можете контролировать рынок.\n\nНо вы можете контролировать свою реакцию на него.\n\nВеличайшее преимущество долгосрочного инвестора — не предсказание каждого шторма.\n\nЭто терпение и уверенность сохранять концентрацию, пока шторм проходит.';

  @override
  String get verdictSafetyMarkerNoDataTitle => 'Пока недостаточно данных';

  @override
  String get verdictSafetyMarkerNoDataIntro =>
      'Этому тесту не хватает данных, чтобы оценить качество купленного — либо не было открыто ни одной позиции, либо фундаментальные показатели этих компаний не успели загрузиться до конца теста.';

  @override
  String get verdictSafetyMarkerTier1Title =>
      'Ставка на надежды, а не на бизнес';

  @override
  String get verdictSafetyMarkerTier1Intro =>
      'Ваш портфель показывает чёткую закономерность: многие вложения основаны скорее на будущих ожиданиях, чем на силе самих бизнесов.\n\nКаждая компания начинается с идеи. Некоторые из этих идей вырастают в бизнесы, меняющие мир. Другие так и не становятся прибыльными.\n\nСложность в том, что фондовый рынок часто вознаграждает захватывающие истории задолго до того, как эти истории превращаются в успешный бизнес.\n\nКомпании с малой прибылью или без неё, слабым финансовым здоровьем, снижающейся выручкой, чрезмерным долгом или ещё не доказавшими себя бизнес-моделями могут переживать резкие ценовые колебания. Иногда они приносят исключительную доходность — но при этом несут намного более высокий риск безвозвратных потерь.\n\nВладение несколькими такими компаниями одновременно не снижает этот риск. Это лишь распределяет ваши деньги между несколькими неопределёнными исходами.\n\nЭто особенно характерно для крайне спекулятивных отраслей — ранней биотехнологии, технологических компаний без выручки, стартапов в сфере космоса, мем-акций и бизнесов, чья оценка зависит в первую очередь от будущих ожиданий, а не от текущих результатов.\n\nВерить в инновации — это нормально.\n\nМногие сегодняшние гиганты когда-то начинались как амбициозные идеи.\n\nРазница в том, что успешные долгосрочные инвесторы не покупают компанию просто потому, что её история звучит захватывающе. Они ищут доказательства того, что бизнес со временем становится сильнее.\n\nРастущая выручка.\nЗдоровая рентабельность.\nРазумный уровень долга.\nПоложительный денежный поток.\nПоследовательное исполнение стратегии.\n\nЭти фундаментальные показатели часто значат намного больше, чем заголовки или ажиотаж в соцсетях.';

  @override
  String get verdictSafetyMarkerTier1Section1Label => 'Как это улучшить?';

  @override
  String get verdictSafetyMarkerTier1Section1Body =>
      'Прежде чем купить компанию, попробуйте задать себе несколько простых вопросов.\n\nЭта компания уже генерирует устойчивую прибыль?\nПродолжает ли её бизнес расти год за годом?\nСпособна ли она пережить сложные экономические условия?\nЯ инвестирую, потому что понимаю бизнес, — или потому что надеюсь на исключительное будущее?\n\nИногда самое захватывающее вложение — не самое сильное.\n\nА иногда самый сильный бизнес — не тот, что попадает в самые громкие заголовки.\n\nПолностью избегать более рискованных компаний не обязательно.\n\nОднако они должны занимать лишь небольшую долю портфеля, построенного на стабильных, финансово здоровых бизнесах.\n\nПрочный фундамент превращает отличные идеи в возможности, а не в лишние риски.';

  @override
  String get verdictSafetyMarkerTier1Section2Label => 'И напоследок';

  @override
  String get verdictSafetyMarkerTier1Section2Body =>
      'Инновации создают возможности.\n\nСильные бизнесы создают долгосрочное богатство.\n\nСамые успешные инвесторы учатся отличать одно от другого.\n\nНе вкладывайтесь только в то, что может стать великим. Вкладывайтесь в компании, которые уже доказывают, что способны преуспеть.';

  @override
  String get verdictSafetyMarkerTier2Title => 'Высокий риск, высокие ожидания';

  @override
  String get verdictSafetyMarkerTier2Intro =>
      'Ваш портфель сочетает перспективные бизнесы и крайне спекулятивные вложения.\n\nВы начали смотреть дальше заголовков, но многие решения по-прежнему во многом опираются на то, чем компания может стать, а не на то, чего она уже добилась.\n\nИнвестировать в будущий потенциал — это нормально.\n\nКаждая успешная компания когда-то была амбициозной идеей.\n\nСложность в том, что не каждая амбициозная идея становится успешным бизнесом.\n\nМногие компании годами гонятся за прибыльностью. Некоторые так её и не достигают. Другие сильно зависят от долга, регулярно выпускают новые акции для привлечения капитала или продолжают работать без устойчивого денежного потока. Лишь немногие в итоге становятся лидерами рынка, а многие терпят неудачу задолго до этого.\n\nКак инвестор, вы не обязаны предсказывать каждую будущую историю успеха.\n\nВаша цель — повысить шансы, что компании, которыми вы владеете, продержатся достаточно долго, чтобы ею стать.\n\nСейчас ваш портфель по-прежнему больше опирается на оптимизм, чем на финансовую силу.\n\nЭто не делает его плохим портфелем — но делает его более рискованным.';

  @override
  String get verdictSafetyMarkerTier2Section1Label => 'Как это улучшить?';

  @override
  String get verdictSafetyMarkerTier2Section1Body =>
      'Оценивая компанию, старайтесь меньше времени тратить на вопрос:\n\n«Насколько сильно может вырасти эта акция?»\n\nИ больше времени — на вопросы:\n\nКомпания стабильно прибыльна?\nВыручка растёт потому, что бизнес улучшается, а не просто из-за временного ажиотажа?\nМожет ли компания существовать без постоянного привлечения нового капитала?\nЕсть ли у руководства подтверждённая история достижения результатов?\n\nИногда самые сильные вложения поначалу не выглядят захватывающими.\n\nОни тихо наращивают прибыль, укрепляют баланс и годами вознаграждают терпеливых инвесторов.\n\nПолностью исключать спекулятивные компании из портфеля не нужно.\n\nПросто убедитесь, что они исключение, а не основа.\n\nПусть вес портфеля несут финансово здоровые бизнесы, а более рискованные идеи остаются тщательно контролируемыми возможностями.';

  @override
  String get verdictSafetyMarkerTier2Section2Label => 'И напоследок';

  @override
  String get verdictSafetyMarkerTier2Section2Body =>
      'Надежда может быть частью вложения.\n\nНо она никогда не должна быть всей инвестиционной стратегией.\n\nСамые сильные портфели строятся не на компаниях с самыми громкими обещаниями — они строятся на компаниях, которые последовательно эти обещания выполняют.';

  @override
  String get verdictSafetyMarkerTier3Title => 'Портфель с потенциалом';

  @override
  String get verdictSafetyMarkerTier3Intro =>
      'Ваш портфель показывает явный прогресс.\n\nБольшинство вложений опирается на компании с прочным бизнес-фундаментом, а меньшая часть по-прежнему несёт повышенную неопределённость. Такой баланс говорит о том, что вы начинаете смотреть дальше рыночного ажиотажа и внимательнее оценивать силу бизнесов, в которые инвестируете.\n\nЭто важный шаг.\n\nУспешное инвестирование — это не поиск компаний с самыми захватывающими историями.\n\nЭто поиск бизнесов, способных год за годом создавать ценность.\n\nУ сильных компаний часто схожие черты. Они генерируют стабильную выручку, поддерживают здоровую рентабельность, разумно управляют долгом и продолжают расти даже в сложных рыночных условиях.\n\nВаш портфель уже отражает многие из этих качеств.\n\nОднако в нём всё ещё есть компании, чьё будущее зависит больше от ожиданий, чем от доказанных финансовых результатов.\n\nЭто не делает их автоматически плохими вложениями.\n\nНекоторые спекулятивные компании со временем становятся завтрашними лидерами рынка.\n\nСложность в том, что заранее невозможно узнать, кто из них преуспеет, а кто нет.\n\nПоэтому опытные инвесторы обычно строят большую часть портфеля вокруг бизнесов, уже доказавших финансовую силу, ограничивая долю компаний, которые всё ещё пытаются себя проявить.';

  @override
  String get verdictSafetyMarkerTier3Section1Label => 'Как это улучшить?';

  @override
  String get verdictSafetyMarkerTier3Section1Body =>
      'По мере роста портфеля старайтесь сделать качество бизнеса одним из главных фильтров при выборе вложений.\n\nПрежде чем купить компанию, смотрите дальше котировки.\n\nСпросите себя:\n\nЭтот бизнес стабильно прибылен?\nГенерирует ли он здоровый денежный поток?\nДолг под контролем?\nДоказало ли руководство способность последовательно исполнять стратегию?\nХотел бы я по-прежнему владеть этой компанией, если бы её котировка не менялась следующие три года?\n\nОтветы на эти вопросы часто раскрывают намного больше, чем краткосрочный энтузиазм рынка.\n\nПомните: сильное вложение строится на сильном бизнесе, а не просто на популярной акции.';

  @override
  String get verdictSafetyMarkerTier3Section2Label => 'И напоследок';

  @override
  String get verdictSafetyMarkerTier3Section2Body =>
      'Отличной компании не обязательно быть захватывающей.\n\nЕй нужно быть устойчивой.\n\nРынок часто на время вознаграждает ажиотаж.\n\nОн вознаграждает сильные бизнесы намного дольше.\n\nЧем больше ваши решения определяются качеством бизнеса, а не рыночным ажиотажем, тем сильнее становится ваш портфель.';

  @override
  String get verdictSafetyMarkerTier4Title => 'Качество прежде всего';

  @override
  String get verdictSafetyMarkerTier4Intro =>
      'Ваш портфель отражает дисциплинированный подход к инвестированию.\n\nВыбранные вами компании, как правило, опираются на прочный финансовый фундамент, а не на краткосрочный рыночный ажиотаж. Вместо того чтобы гнаться за заголовками или модными трендами, вы сосредоточились на бизнесах, уже доказавших способность генерировать выручку, зарабатывать прибыль, разумно управлять долгом и создавать долгосрочную ценность.\n\nЭто одна из важнейших привычек, которую вырабатывают успешные инвесторы.\n\nРынок полон захватывающих историй.\n\nОдни обещают революционные технологии.\n\nДругие обещают изменить целые отрасли.\n\nНемногие в итоге это делают.\n\nМногие так и не оправдывают этих ожиданий.\n\nСильным бизнесам не нужны экстраординарные обещания, чтобы привлекать инвесторов. Они завоёвывают доверие последовательным исполнением, финансовой устойчивостью и годами подтверждённых результатов.\n\nВаш портфель отражает именно такой настрой.\n\nВместо того чтобы полагаться на надежду, вы построили большую часть портфеля вокруг компаний, уже показавших способность переживать экономические спады, адаптироваться к меняющимся рынкам и продолжать расти со временем.\n\nНи одна компания не свободна от риска полностью.\n\nДаже самые сильные бизнесы переживают трудные годы, разочаровывающую отчётность или неожиданные вызовы.\n\nОднако финансово здоровые компании обычно намного лучше подготовлены восстанавливаться после таких неудач, чем бизнесы, уже балансирующие на грани выживания.\n\nЭта разница особенно ценна в периоды рыночной неопределённости.';

  @override
  String get verdictSafetyMarkerTier4Section1Label =>
      'Как сделать это ещё лучше?';

  @override
  String get verdictSafetyMarkerTier4Section1Body =>
      'Продолжайте делать то же, что и сейчас, — но никогда не переставайте задавать вопросы.\n\nДаже выдающиеся компании заслуживают регулярного пересмотра.\n\nРынки меняются.\n\nОтрасли трансформируются.\n\nПоявляются новые конкуренты.\n\nПрежде чем добавить новое вложение, спросите себя:\n\nЭта компания всё ещё финансово сильна?\nУлучшился ли её бизнес за последние несколько лет?\nПродолжает ли она создавать ценность для акционеров?\nЧувствовал бы я себя комфортно, владея этим бизнесом во время серьёзного спада рынка?\n\nСильный портфель строится не поиском идеальных компаний.\n\nОн строится последовательным выбором бизнесов, которые продолжают заслуживать ваше доверие.';

  @override
  String get verdictSafetyMarkerTier4Section2Label => 'И напоследок';

  @override
  String get verdictSafetyMarkerTier4Section2Body =>
      'Великие инвесторы не ищут идеальные акции.\n\nОни ищут исключительные бизнесы.\n\nКотировки растут и падают каждый день.\n\nСильные бизнесы продолжают наращивать ценность ещё долго после того, как сегодняшние заголовки будут забыты.\n\nВкладываясь в качественные бизнесы, вы вкладываетесь в компании, уже научившиеся выживать, адаптироваться и расти.';

  @override
  String get verdictSafetyMarkerTier5Title =>
      'Инвестиции в бизнес, а не в истории';

  @override
  String get verdictSafetyMarkerTier5Intro =>
      'Вы вкладываетесь в бизнесы, а не в обещания.\n\nВаш портфель отражает мышление долгосрочного инвестора.\n\nВместо того чтобы гнаться за ажиотажем, рыночной шумихой или очередным модным трендом, вы последовательно выбирали компании с прочным финансовым фундаментом и доказанными бизнес-результатами.\n\nЭти бизнесы полагаются не только на смелые обещания или оптимистичные прогнозы.\n\nОни генерируют реальную выручку.\n\nОни приносят устойчивую прибыль.\n\nОни разумно управляют долгом.\n\nОни вознаграждают акционеров дисциплинированным распределением капитала.\n\nСамое важное — они доказали способность адаптироваться, конкурировать и расти в меняющихся рыночных условиях.\n\nЭто не гарантирует успех каждого вложения.\n\nНи одна компания не застрахована от экономических спадов, неожиданных трудностей или периодов слабых результатов.\n\nОднако бизнесы с прочными фундаментальными показателями обычно намного лучше подготовлены преодолевать такие препятствия, чем компании, всё ещё ищущие жизнеспособную бизнес-модель.\n\nЭто одно из главных различий между инвестированием и спекуляцией.\n\nСпекуляция спрашивает:\n\n«Чем эта компания могла бы стать?»\n\nИнвестирование спрашивает:\n\n«Что эта компания уже доказала, что умеет делать?»\n\nВаш портфель говорит о том, что вы чаще задаёте второй вопрос.\n\nИменно эта привычка помогла многим успешным инвесторам приумножать капитал десятилетиями — не предсказывая будущее, а владея бизнесами, способными создавать ценность год за годом.';

  @override
  String get verdictSafetyMarkerTier5Section1Label =>
      'Продолжайте мыслить как владелец бизнеса';

  @override
  String get verdictSafetyMarkerTier5Section1Body =>
      'Даже выдающиеся компании заслуживают регулярного пересмотра.\n\nРынки меняются.\n\nОтрасли эволюционируют.\n\nКонкурентные преимущества способны ослабевать со временем.\n\nПродолжайте смотреть дальше котировки.\n\nИзучайте финансовую отчётность.\n\nСледите за квартальными результатами.\n\nОбращайте внимание на уровень долга, прибыльность, денежный поток и решения руководства.\n\nСильнейшие инвесторы не покупают отличные компании и не забывают о них навсегда.\n\nОни продолжают следить, чтобы эти компании оставались отличными бизнесами.\n\nПомните: качественная компания сегодня должна продолжать заслуживать эту репутацию и завтра.';

  @override
  String get verdictSafetyMarkerTier5Section2Label => 'И напоследок';

  @override
  String get verdictSafetyMarkerTier5Section2Body =>
      'Акция — это больше, чем тикер.\n\nЗа каждой акцией стоит реальный бизнес, реальные сотрудники, реальные клиенты и реальные финансовые результаты.\n\nРынок может какое-то время вознаграждать захватывающие истории.\n\nНо в долгосрочной перспективе он последовательно вознаграждал бизнесы, создающие долговечную ценность.\n\nВеличайшее вложение — не поиск следующего громкого заголовка. Это владение компаниями, которые продолжают доказывать свою ценность ещё долго после того, как заголовки поблёкнут.';

  @override
  String get verdictSectorBalanceNoDataTitle => 'Пока нет данных по секторам';

  @override
  String get verdictSectorBalanceNoDataIntro =>
      'Этот тест завершился без единой открытой позиции — оценивать концентрацию по секторам пока не по чему.';

  @override
  String get verdictSectorBalanceTier1Title => 'Один сектор правит всем';

  @override
  String get verdictSectorBalanceTier1Intro =>
      'В вашем портфеле могут быть отличные компании — но все они стоят на одном и том же фундаменте.\n\nБольшая часть ваших вложений сосредоточена в одном секторе экономики, а значит, будущее портфеля сильно зависит от успеха одной отрасли.\n\nЭто называется риском секторной концентрации.\n\nСами компании могут быть финансово сильными.\n\nИх руководство может быть превосходным.\n\nИх продукты могут лидировать на рынке.\n\nНо если вся отрасль сталкивается с неожиданными трудностями, даже выдающиеся бизнесы часто падают вместе.\n\nИстория не раз это показывала.\n\nТехнологии, банковский сектор, недвижимость, энергетика, биотехнологии — каждый сектор переживал периоды быстрого роста, за которыми следовали годы разочаровывающих результатов.\n\nСильнейшие компании обычно выживают.\n\nИх котировки не всегда избегают общего спада.\n\nРынки не спрашивают, хороши ли ваши компании.\n\nОни часто спрашивают, хотят ли инвесторы вообще присутствия в этой отрасли.\n\nКогда доверие исчезает, целый сектор может упасть разом — даже если многие его бизнесы остаются фундаментально здоровыми.';

  @override
  String get verdictSectorBalanceTier1Section1Label => 'Как это улучшить?';

  @override
  String get verdictSectorBalanceTier1Section1Body =>
      'Попробуйте посмотреть за пределы любимой отрасли.\n\nВместо вопроса:\n\n«Какая компания в этом секторе лучшая?»\n\nЗадайте ещё и такой:\n\n«Какие важные части экономики я полностью игнорирую?»\n\nЗдравоохранение.\nФинансовые услуги.\nПромышленность.\nПотребительский сектор.\nЭнергетика.\nКоммунальные услуги.\nТелекоммуникации.\n\nКаждый сектор по-своему реагирует на меняющиеся экономические условия.\n\nВладение бизнесами из разных отраслей помогает убедиться, что успех портфеля не зависит от одной экономической истории.\n\nДиверсификация по секторам не устраняет риск.\n\nОна не даёт одной отрасли решать судьбу всего портфеля.';

  @override
  String get verdictSectorBalanceTier1Section2Label => 'И напоследок';

  @override
  String get verdictSectorBalanceTier1Section2Body =>
      'Отличная компания всё равно может оказаться частью рискованного портфеля.\n\nНе потому, что бизнес слаб, —\n\nа потому, что слишком многие ваши вложения зависят от одной и той же части экономики.\n\nНе вкладывайте всю уверенность в одну отрасль. Постройте портфель, способный двигаться вперёд, даже когда один сектор отстаёт.';

  @override
  String get verdictSectorBalanceTier2Title =>
      'Слишком много веры в одну отрасль';

  @override
  String get verdictSectorBalanceTier2Intro =>
      'Ваш портфель начинает диверсифицироваться, но один сектор всё ещё намного весомее остальных.\n\nХотя у вас есть компании из разных отраслей, значительная часть капитала по-прежнему сосредоточена в одной области экономики. Если этот сектор переживёт затяжной спад, весь портфель может пострадать намного сильнее, чем вы ожидаете.\n\nЭто не значит, что вы выбрали плохие компании.\n\nБолее того, многие из них могут быть выдающимися бизнесами.\n\nСложность в том, что даже отличные компании часто движутся в одном направлении, если принадлежат одной отрасли.\n\nСильная отчётность, запуски продуктов, процентные ставки, государственное регулирование, технологические изменения или сдвиги в настроениях инвесторов способны разом затронуть весь сектор.\n\nКогда это происходит, владение несколькими компаниями из одной отрасли не всегда даёт ту диверсификацию, на которую рассчитывают инвесторы.\n\nИногда это просто означает многократное принятие одного и того же риска.';

  @override
  String get verdictSectorBalanceTier2Section1Label => 'Как это улучшить?';

  @override
  String get verdictSectorBalanceTier2Section1Body =>
      'Вашему портфелю не нужна полная перестройка.\n\nЕму просто нужен лучший баланс.\n\nВ следующий раз, вкладывая деньги, подумайте о компании из сектора, который сейчас представлен в портфеле намного слабее.\n\nВместо того чтобы ещё больше усиливать крупнейшую позицию, укрепите одну из самых слабых.\n\nСо временем такие небольшие решения создадут портфель, более устойчивый к неожиданным изменениям рынка.\n\nЦель не в том, чтобы избегать любимой отрасли.\n\nЦель — не зависеть от неё.';

  @override
  String get verdictSectorBalanceTier2Section2Label => 'И напоследок';

  @override
  String get verdictSectorBalanceTier2Section2Body =>
      'Иметь любимый сектор — совершенно нормально.\n\nПросто не позволяйте ему стать всей вашей инвестиционной стратегией.\n\nСамые сильные портфели строятся не вокруг одной успешной отрасли. Они строятся вокруг экономики, которая никогда не перестаёт меняться.';

  @override
  String get verdictSectorBalanceTier3Title => 'Лучший баланс уже близко';

  @override
  String get verdictSectorBalanceTier3Intro =>
      'Ваш портфель движется в верном направлении.\n\nВы уже распределили вложения между несколькими секторами экономики — это важный шаг к снижению риска. Однако одна отрасль по-прежнему занимает заметно большую долю портфеля, чем остальные.\n\nЭто не серьёзная проблема — но это возможность стать лучше.\n\nРынки не движутся в идеальной гармонии.\n\nРазные секторы по-разному реагируют на экономические условия, процентные ставки, инфляцию, технологические изменения и потребительский спрос. Пока одна отрасль может испытывать трудности месяцами или даже годами, другая способна продолжать расти в тех же самых условиях.\n\nИменно поэтому баланс важен.\n\nПортфель не становится сильнее от нахождения одного идеального сектора.\n\nОн становится сильнее, когда сразу несколько секторов получают возможность вносить вклад в ваш долгосрочный успех.\n\nСейчас ваш портфель всё ещё немного смещён в сторону одной части экономики.\n\nК счастью, вы намного ближе к отличной диверсификации, чем к слабой.';

  @override
  String get verdictSectorBalanceTier3Section1Label => 'Как это улучшить?';

  @override
  String get verdictSectorBalanceTier3Section1Body =>
      'Продавать существующие вложения не нужно.\n\nВместо этого дайте будущим покупкам постепенно улучшить баланс.\n\nДобавляя новые компании, уделяйте чуть больше внимания секторам, которые сейчас занимают меньшую долю портфеля.\n\nСо временем распределение капитала естественным образом станет более сбалансированным без лишних сделок и налоговых последствий.\n\nНебольшие, но последовательные корректировки часто эффективнее резких изменений разом.';

  @override
  String get verdictSectorBalanceTier3Section2Label => 'И напоследок';

  @override
  String get verdictSectorBalanceTier3Section2Body =>
      'Диверсификация не в том, чтобы сделать каждый сектор одинакового размера.\n\nОна в том, чтобы ни одна отрасль не получила слишком большой контроль над вашим финансовым будущим.\n\nУ вашего портфеля уже есть прочный фундамент.\n\nНесколько продуманных вложений в недопредставленные секторы способны сделать его ещё сильнее, что бы ни принёс рынок дальше.';

  @override
  String get verdictSectorBalanceTier4Title =>
      'Сбалансирован по всей экономике';

  @override
  String get verdictSectorBalanceTier4Intro =>
      'Ваш портфель демонстрирует здоровый уровень секторной диверсификации.\n\nНи одна отрасль не доминирует среди ваших вложений, позволяя разным частям экономики вносить вклад в долгосрочный результат. Такой сбалансированный подход помогает снизить влияние любого отдельного сектора на весь портфель.\n\nЭто важное преимущество.\n\nРынки движутся циклами.\n\nТехнологии не будут лидировать вечно.\n\nЗдравоохранение не всегда будет опережать рынок.\n\nУ финансового сектора, промышленности, потребительских компаний, энергетики, коммунальных услуг и других секторов есть свои периоды силы и слабости.\n\nНикто не способен стабильно предсказывать, какая отрасль окажется лидером следующей.\n\nК счастью, вашему портфелю это и не нужно.\n\nРаспределив вложения по нескольким секторам, вы построили портфель, готовый к разным экономическим условиям, вместо того чтобы полагаться на один прогноз.\n\nИменно так и должна работать диверсификация.';

  @override
  String get verdictSectorBalanceTier4Section1Label =>
      'Как сделать это ещё лучше?';

  @override
  String get verdictSectorBalanceTier4Section1Body =>
      'Продолжайте поддерживать уже созданный баланс.\n\nПо мере роста портфеля не позволяйте одному быстрорастущему сектору постепенно занять доминирующее положение.\n\nПериодического беглого пересмотра распределения по секторам обычно достаточно, чтобы сохранить хороший баланс.\n\nТакже помните, что секторная диверсификация — лишь одна часть построения устойчивого портфеля.\n\nКачество бизнесов, которыми вы владеете, остаётся не менее важным, чем отрасли, к которым они принадлежат.\n\nСильные компании, распределённые по нескольким секторам, создают более сильный портфель, чем просто владение множеством разных отраслей.';

  @override
  String get verdictSectorBalanceTier4Section2Label => 'И напоследок';

  @override
  String get verdictSectorBalanceTier4Section2Body =>
      'Сбалансированный портфель не пытается угадать, какой сектор победит следующим.\n\nОн готовится к тому, что момент триумфа может настать у любого сектора.\n\nВы не можете контролировать, откуда придёт следующий лидер рынка, — но можете построить портфель, готовый к этому моменту.';

  @override
  String get verdictSectorBalanceTier5Title =>
      'Ваше будущее не зависит от одного сектора';

  @override
  String get verdictSectorBalanceTier5Intro =>
      'Ваш портфель отражает хорошо сбалансированную инвестиционную стратегию.\n\nНи один сектор не доминирует среди ваших вложений, а значит, ваш долгосрочный успех не привязан к результатам одной отрасли. Вместо этого вложения распределены по разным частям экономики, позволяя портфелю выигрывать от широкого круга бизнесов, продуктов и экономических циклов.\n\nЭто одна из самых надёжных форм управления риском, доступных долгосрочному инвестору.\n\nРазные отрасли процветают в разных условиях.\n\nТехнологии могут лидировать в периоды инноваций.\n\nЗдравоохранение часто остаётся устойчивым на неспокойных рынках.\n\nПромышленность может выигрывать от экономического роста.\n\nУ потребительских компаний, финансовых услуг, коммунального сектора и энергетики есть собственные возможности и трудности на разных этапах рыночного цикла.\n\nВместо того чтобы пытаться угадать завтрашнего лидера, вы построили портфель, готовый к самым разным исходам.\n\nИменно так и должно работать долгосрочное инвестирование.\n\nВаш портфель не зависит от того, окажетесь ли вы правы насчёт одной отрасли.\n\nОн опирается на силу экономики в целом.';

  @override
  String get verdictSectorBalanceTier5Section1Label =>
      'Продолжайте беречь баланс';

  @override
  String get verdictSectorBalanceTier5Section1Body =>
      'По мере роста портфеля продолжайте периодически отслеживать распределение по секторам.\n\nИногда быстрорастущий сектор может естественным образом стать намного крупнее остального портфеля, а вы этого даже не заметите.\n\nПоддержание баланса не требует частых сделок.\n\nЧасто достаточно просто направлять новые вложения в недопредставленные секторы, чтобы сохранить хорошую диверсификацию портфеля.\n\nПомните: диверсификация — это не разовое решение.\n\nЭто постоянная привычка.';

  @override
  String get verdictSectorBalanceTier5Section2Label => 'И напоследок';

  @override
  String get verdictSectorBalanceTier5Section2Body =>
      'Будущее редко вознаграждает только одну отрасль.\n\nИнновации смещаются.\n\nЭкономические циклы меняются.\n\nПоявляются новые лидеры, пока вчерашние замедляются.\n\nВам не нужно знать, какой сектор окажется лидером следующим.\n\nВы построили портфель, который не зависит от одного-единственного ответа.\n\nСамые сильные портфели не делают ставку на одну часть экономики. Они растут вместе с экономикой в целом.';

  @override
  String get verdictSectorDiversificationNoDataTitle =>
      'Ни одной открытой позиции';

  @override
  String get verdictSectorDiversificationNoDataIntro =>
      'Этот тест завершился без единой покупки — диверсифицировать пока нечего.';

  @override
  String get verdictSectorDiversificationTier1Title =>
      'Не все яйца в одной корзине';

  @override
  String get verdictSectorDiversificationTier1Intro =>
      'Ваш портфель почти полностью доверился одному-двум секторам экономики. Это понятное решение. Когда конкретная отрасль переживает бум, кажется, что вы нашли очевидного победителя. Естественно приходит мысль:\n\n«Зачем вкладываться куда-то ещё, если все главные возможности здесь?»\n\nПроблема в том, что рынок редко следует одному сценарию.\n\nСегодня инвесторы в восторге от искусственного интеллекта. До этого — от электромобилей. Ещё раньше — от интернет-компаний, биотехнологий, чистой энергетики и множества других отраслей, которые когда-то казались непобедимыми. Некоторые из них действительно изменили мир — но почти каждая пережила периоды, когда цены резко падали, а уверенность инвесторов быстро сменялась неопределённостью.\n\nДело не в том, какой сектор вы выбрали.\n\nДело в том, что будущее всего вашего портфеля теперь зависит от одной идеи.\n\nЕсли у этого сектора возникнут проблемы, почти все ваши вложения ощутят удар одновременно.\n\nПредставьте самолёт с одним-единственным двигателем. Пока всё работает, полёт проходит гладко. Но если этот двигатель откажет, полагаться будет уже не на что.\n\nХорошо построенный инвестиционный портфель работает иначе. Он больше похож на самолёт с несколькими независимыми системами. Если одна часть даёт сбой, остальные продолжают выполнять свою работу, помогая всему портфелю оставаться устойчивым.\n\nИменно поэтому опытные инвесторы распределяют деньги между разными секторами экономики. Технологии, здравоохранение, финансы, промышленность, потребительские товары, коммунальные услуги, энергетика — эти отрасли не движутся в идеальной гармонии. Когда у одного сектора трудный год, другой может продолжать расти или просто оставаться стабильным. Такой баланс помогает снизить влияние неожиданных событий.';

  @override
  String get verdictSectorDiversificationTier1Section1Label =>
      'Как это улучшить?';

  @override
  String get verdictSectorDiversificationTier1Section1Body =>
      'Не пытайтесь угадать единственный сектор-победитель следующего десятилетия. Даже профессиональные инвесторы редко угадывают это стабильно верно.\n\nВместо этого стройте портфель шаг за шагом.\n\nПродолжайте вкладываться в сектор, в который верите, — но постепенно добавляйте охват других частей экономики. Не обязательно покупать всё сразу. Каждое новое вложение — это возможность сделать портфель немного более сбалансированным и немного более устойчивым.\n\nПеред следующей покупкой задайте себе один простой вопрос:\n\n«Если мой любимый сектор перестанет расти на ближайшие три года, останется ли мой портфель в хорошей форме?»\n\nЕсли этот вопрос вызывает у вас дискомфорт, вероятно, пора расширить круг вложений.';

  @override
  String get verdictSectorDiversificationTier1Section2Label => 'И напоследок';

  @override
  String get verdictSectorDiversificationTier1Section2Body =>
      'Диверсификация редко бывает захватывающей.\n\nОна не попадает в заголовки. Она не обещает мгновенное богатство. По сути, она может казаться даже немного скучной.\n\nНо диверсификация создана не для дней, когда всё растёт.\n\nОна создана для дней, когда рынок напоминает всем, что ни один сектор — каким бы захватывающим он ни казался — не растёт вечно.\n\nУспешный инвестор строит портфель не вокруг одной надежды. Он строит его так, чтобы пережить множество разных вариантов будущего.';

  @override
  String get verdictSectorDiversificationTier2Title =>
      'Прочный фундамент, но есть куда расти';

  @override
  String get verdictSectorDiversificationTier2Intro =>
      'Ваш портфель уже движется в верном направлении.\n\nВместо того чтобы полагаться на одну отрасль, вы распределили вложения между несколькими секторами экономики. Это важный шаг, поскольку он снижает риск того, что одна разочаровывающая отрасль потянет за собой весь портфель.\n\nМногие инвесторы никогда не доходят до этого этапа.\n\nОднако ваш портфель всё ещё почти полностью опирается на отдельные компании.\n\nДаже самые сильные бизнесы могут столкнуться с неожиданными неудачами. Слабый квартальный отчёт, новая конкуренция, изменения в регулировании, судебный иск или просто смена настроений на рынке способны заставить отдельную акцию буксовать месяцами — а то и годами.\n\nИменно здесь широкий рыночный ETF способен незаметно стать одним из самых ценных вложений в вашем портфеле.\n\nВоспринимайте ETF как фундамент под вашим домом.\n\nВы, вероятно, не восхищаетесь фундаментом каждый день. Он не захватывающий. Он не попадает в заголовки. О нём никто не говорит за семейным ужином.\n\nНо когда погода портится, вы очень рады, что он есть.\n\nШирокий рыночный ETF одной покупкой распределяет ваши вложения между сотнями — а то и тысячами — компаний. Он не заменяет отдельные акции. Вместо этого он помогает их уравновесить. Пока одна компания разочаровывает, множество других продолжают незаметно делать своё дело.\n\nЭто создаёт портфель, который зачастую более стабилен, проще в управлении и меньше зависит от успеха горстки компаний.';

  @override
  String get verdictSectorDiversificationTier2Section1Label =>
      'Как это улучшить?';

  @override
  String get verdictSectorDiversificationTier2Section1Body =>
      'Вы уже сделали самое сложное, диверсифицировавшись по нескольким секторам.\n\nТеперь подумайте о добавлении хотя бы одного широкого рыночного ETF, чтобы укрепить общую структуру портфеля.\n\nЗаменять компании, в которые вы верите, не нужно.\n\nПросто позвольте ETF стать устойчивым ядром, вокруг которого будет расти остальная часть вложений.\n\nМногие опытные долгосрочные инвесторы строят портфели именно так:\n\nНадёжный ETF даёт широкий охват рынка.\nОтдельные компании добавляются вокруг него ради дополнительных возможностей роста.\n\nТакое сочетание даёт лучшее из обоих миров — стабильность рынка в целом и потенциал более высокой доходности от тщательно отобранных бизнесов.';

  @override
  String get verdictSectorDiversificationTier2Section2Label => 'И напоследок';

  @override
  String get verdictSectorDiversificationTier2Section2Body =>
      'Хорошо диверсифицированный портфель измеряется не только количеством секторов, которыми он владеет.\n\nОн измеряется ещё и тем, скольких рисков он избегает.\n\nОтдельные компании способны вас удивить. Целый рынок удивить намного труднее.';

  @override
  String get verdictSectorDiversificationTier3Title =>
      'Портфель, способный пережить бурю';

  @override
  String get verdictSectorDiversificationTier3Intro =>
      'Ваш портфель выглядит продуманно выстроенным, а не собранным наугад.\n\nВаши вложения распределены по нескольким секторам экономики, а значит, ваш долгосрочный успех не зависит от одной отрасли или одной большой идеи. Сегодня может лидировать технологический сектор, а завтра в центре внимания окажутся здравоохранение, промышленность, финансы или потребительские компании. Никто не способен стабильно предсказывать, какой сектор окажется лидером следующим, — но вы уже подготовились к разным вариантам.\n\nИменно для этого и существует диверсификация.\n\nКогда один сектор переживает трудный период, другие могут продолжать расти или просто оставаться стабильными. Такой баланс помогает снизить влияние неожиданных рыночных событий и делает портфель более устойчивым в периоды волатильности.\n\nСамое важное — вы устояли перед соблазном поставить всё на один тренд. Вместо того чтобы пытаться угадать одного будущего победителя, вы дали своим вложениям возможность расти сразу в нескольких частях экономики. Такой подход не всегда даёт самую высокую доходность каждый отдельный год, но значительно повышает шансы на стабильный долгосрочный результат.\n\nВеликие инвесторы думают не только о том, сколько можно заработать.\n\nОни также думают о том, как остаться вложенными на протяжении каждого рыночного цикла.';

  @override
  String get verdictSectorDiversificationTier3Section1Label =>
      'Как сделать это ещё лучше?';

  @override
  String get verdictSectorDiversificationTier3Section1Body =>
      'Даже сильный портфель можно улучшить.\n\nЕсли у вас уже есть широкий рыночный ETF, вы построили прочный фундамент. Если нет — подумайте о том, чтобы его добавить. Один диверсифицированный ETF способен стать устойчивым ядром портфеля, пока отобранные вами отдельные акции дают дополнительные возможности роста.\n\nЕсть ещё одна привычка, которую часто вырабатывают опытные инвесторы.\n\nВкладывать каждый доступный доллар сразу, как только он появляется, не обязательно.\n\nНебольшой денежный резерв — это не признак нерешительности, а признак подготовки.\n\nКогда рынок внезапно падает, этот резерв даёт вам свободу покупать качественные компании по более привлекательным ценам, вместо того чтобы наблюдать за упущенными возможностями.\n\nНаличные, лежащие в стороне, не всегда бездействуют.\n\nИногда это будущая возможность, ожидающая подходящего момента.';

  @override
  String get verdictSectorDiversificationTier3Section2Label => 'И напоследок';

  @override
  String get verdictSectorDiversificationTier3Section2Body =>
      'Диверсификация защищает вас от зависимости от одного сектора.\n\nШирокий рыночный ETF распределяет риск между сотнями компаний.\n\nНебольшой денежный резерв даёт вам гибкость действовать тогда, когда другими движет страх.\n\nПо отдельности эти привычки могут казаться простыми.\n\nВместе они создают портфель, построенный не только для роста, но и для того, чтобы выстоять.\n\nУспешные инвесторы готовятся не только к растущим рынкам. Они также готовятся к возможностям, которые появляются, когда рынки падают.';

  @override
  String get verdictSectorDiversificationTier4Title =>
      'Диверсификация сделана правильно';

  @override
  String get verdictSectorDiversificationTier4Intro =>
      'Вы построили портфель, отражающий терпение, баланс и долгосрочное мышление.\n\nВаши вложения распределены по нескольким секторам экономики, снижая зависимость от какой-либо одной отрасли или рыночного тренда. Вместо того чтобы пытаться угадать одного будущего победителя, вы подготовили портфель к множеству возможных исходов.\n\nИменно для этого и создана диверсификация.\n\nКогда технологии замедляются, здравоохранение может продолжать расти. Когда потребительские расходы слабеют, коммунальный сектор или защитные бизнесы способны обеспечить стабильность. Никто не знает, какой сектор будет лидировать в следующем году, но вашему портфелю не нужно полагаться на один-единственный прогноз.\n\nВы построили структуру, созданную скорее адаптироваться, чем угадывать.\n\nЭто одна из самых сильных привычек, которую может выработать долгосрочный инвестор.';

  @override
  String get verdictSectorDiversificationTier4Section1Label =>
      'Важное напоминание';

  @override
  String get verdictSectorDiversificationTier4Section1Body =>
      'Хорошая секторная диверсификация не означает автоматически, что каждое вложение удачно.\n\nПортфель может быть идеально диверсифицирован по отраслям и при этом содержать компании со слабыми бизнес-моделями, чрезмерным долгом, снижающейся выручкой или крайне спекулятивными стратегиями.\n\nДиверсификация защищает вас от концентрации денег в одной части экономики.\n\nОна не защищает вас от покупки некачественных бизнесов.\n\nЭто особенно важно при инвестировании в крайне спекулятивные компании.\n\nРанние биотехнологические фирмы, стартапы без выручки, мем-акции и бизнесы, которые больше полагаются на будущие обещания, чем на доказанные результаты, могут переживать экстремальные ценовые колебания. Некоторые способны стать невероятными историями успеха.\n\nМногие другие так и не достигают прибыльности.\n\nВладеть компаниями просто потому, что они принадлежат разным секторам, недостаточно.\n\nКаждое вложение должно заслуживать своё место в портфеле силой своего бизнеса, а не только ажиотажем вокруг своей истории.';

  @override
  String get verdictSectorDiversificationTier4Section2Label =>
      'Как сделать это ещё лучше?';

  @override
  String get verdictSectorDiversificationTier4Section2Body =>
      'Продолжайте пересматривать свои компании — не только распределение по секторам.\n\nЗадавайте себе такие вопросы:\n\nУ этой компании устойчивый бизнес?\nСтабильно ли она генерирует выручку и прибыль?\nПосилен ли её уровень долга?\nХотел бы я по-прежнему владеть этим бизнесом, если бы котировка не росла несколько лет подряд?\n\nЭти вопросы часто раскрывают намного больше, чем растущий график акции.\n\nПомните: диверсификация никогда не должна становиться оправданием для покупки компаний вслепую.\n\nПортфель, заполненный слабыми бизнесами, не становится сильным только потому, что они работают в разных отраслях.';

  @override
  String get verdictSectorDiversificationTier4Section3Label => 'И напоследок';

  @override
  String get verdictSectorDiversificationTier4Section3Body =>
      'Диверсификация защищает ваш портфель.\n\nКачество защищает ваши вложения.\n\nДисциплина защищает ваше будущее.\n\nКогда все три работают вместе, вы уже не просто покупаете акции.\n\nВы строите инвестиционный портфель, созданный расти, адаптироваться и выдерживать десятилетия.';

  @override
  String get verdictSectorDiversificationTier5Title =>
      'От портфеля до зоопарка';

  @override
  String get verdictSectorDiversificationTier5Intro =>
      'Диверсификация — один из важнейших принципов долгосрочного инвестирования.\n\nНо, как и многие хорошие идеи, её можно довести до крайности.\n\nТеперь ваш портфель содержит так много отдельных компаний, что уследить за всеми ними становится непростой задачей само по себе.\n\nВ какой-то момент диверсификация перестаёт снижать риск и начинает снижать вашу способность понимать, чем вы на самом деле владеете.\n\nВ конце концов, трудно одновременно следить за отчётностью, финансовыми результатами, запусками продуктов, сменами руководства и событиями в отрасли для десятков бизнесов сразу.\n\nВ итоге ваши вложения начинают управлять вами, а не наоборот.\n\nХорошо построенному портфелю не нужно владеть всем.\n\nЕму нужно владеть достаточным.';

  @override
  String get verdictSectorDiversificationTier5Section1Label =>
      'Больше компаний не всегда значит меньше риска';

  @override
  String get verdictSectorDiversificationTier5Section1Body =>
      'Многие начинающие инвесторы считают, что покупка большего числа акций автоматически делает портфель безопаснее.\n\nНа деле наступает момент, когда каждая дополнительная компания добавляет очень мало защиты, при этом значительно усложняя понимание и управление портфелем.\n\nПредставьте, что нужно заботиться о трёх питомцах.\n\nЭто вполне посильно.\n\nА теперь представьте заботу о тридцати.\n\nРано или поздно кому-то не хватит внимания.\n\nТо же самое происходит с вложениями.\n\nЕсли вы уже не помните, зачем купили компанию, — или не замечаете, когда её бизнес начинает ухудшаться, — возможно, ей больше не место в вашем портфеле.';

  @override
  String get verdictSectorDiversificationTier5Section2Label =>
      'Качество всегда важнее количества';

  @override
  String get verdictSectorDiversificationTier5Section2Body =>
      'Владеть тридцатью посредственными бизнесами редко лучше, чем владеть пятнадцатью выдающимися, которые вы по-настоящему понимаете.\n\nУ каждой компании в портфеле должна быть чёткая причина там находиться.\n\nЕсли единственный ответ звучит так...\n\n«Потому что я хотел больше диверсификации».\n\n...стоит задуматься, действительно ли эта позиция улучшает портфель — или просто усложняет его.\n\nПомните: диверсификация нужна для снижения лишнего риска.\n\nОна не про то, чтобы собрать как можно больше тикеров.';

  @override
  String get verdictSectorDiversificationTier5Section3Label =>
      'Как это улучшить?';

  @override
  String get verdictSectorDiversificationTier5Section3Body =>
      'Найдите время пересмотреть свои вложения.\n\nСпросите себя:\n\nЯ всё ещё понимаю бизнес этой компании?\nКупил бы я эту компанию снова сегодня?\nДобавляет ли это вложение портфелю что-то уникальное?\nИли это просто ещё одна компания, дублирующая несколько других, которыми я уже владею?\n\nЕсли две компании служат почти одной и той же цели, возможно, обе вам не нужны.\n\nБолее простой портфель обычно легче отслеживать, легче понимать и легче удерживать в трудные для рынка периоды.';

  @override
  String get verdictSectorDiversificationTier5Section4Label => 'И напоследок';

  @override
  String get verdictSectorDiversificationTier5Section4Body =>
      'Портфель — это не коллекция марок.\n\nВы не получаете дополнительные очки за владение наибольшим числом компаний.\n\nВы получаете их, владея бизнесами, которые понимаете и уверенно удерживаете как в хорошие, так и в плохие времена.\n\nЦель не в том, чтобы владеть всем. Цель — знать, зачем вы владеете каждым вложением.';

  @override
  String get verdictMarkerNotAvailable => 'Недоступно.';

  @override
  String verdictMarkerFeedbackComingSoon(String label) {
    return 'Подробный разбор по показателю «$label» скоро появится.';
  }

  @override
  String get verdictTitle => 'Вердикт';

  @override
  String get verdictNotAvailable =>
      'Вердикт недоступен — сначала завершите тест.';

  @override
  String get verdictSessionCompleteTitle => 'ТЕСТ ЗАВЕРШЁН';

  @override
  String get verdictContinueLearning => 'Продолжить обучение';

  @override
  String get verdictBackToHome => 'На главную';

  @override
  String get verdictGuardianVerdictLabel => 'ВЕРДИКТ GUARDIAN';

  @override
  String get verdictGuardianHeadline => 'ВЫ ПРОШЛИ ИСПЫТАНИЕ';

  @override
  String get verdictGuardianShortText =>
      'Ваша симуляция рынка завершена. Вы прошли через разные рыночные условия и увидели, как ваш портфель и решения на них реагировали. Пришло время узнать, что результаты говорят о вашем инвестиционном поведении.';

  @override
  String get verdictViewYourAnalysis => 'Смотреть анализ →';

  @override
  String get verdictHoldingsLabel => 'Активы';

  @override
  String get verdictFinalPnlLabel => 'Итоговый P&L';

  @override
  String get verdictStartingCashLabel => 'Начальные наличные';

  @override
  String get verdictDividendsLabel => 'Дивиденды';

  @override
  String get verdictTopUpCountLabel => 'Пополнений';

  @override
  String get verdictTopUpTotalLabel => 'Сумма пополнений';

  @override
  String get verdictCommissionLabel => 'Комиссия';

  @override
  String get stressTestVerdictNoDataTitle => 'Нет данных';

  @override
  String get stressTestVerdictNoDataDescription => 'Данные сессии не найдены.';

  @override
  String get stressTestVerdictPanicTitle =>
      'ПАНИКА — Инвестор, ведомый страхом';

  @override
  String get stressTestVerdictPanicDescription =>
      'Вы позволили страху диктовать свои действия, продавая активы в худший момент и фиксируя убытки. Данные показывают, что вы продавали на дне минимум дважды, пока рынок падал. Эмоциональная дисциплина — основа успешного инвестирования. Подумайте об использовании стоп-лоссов и о том, чтобы придерживаться заранее продуманной стратегии, а не реагировать на краткосрочный рыночный шум.';

  @override
  String get stressTestVerdictFomoTitle => 'FOMO — Охотник за импульсом';

  @override
  String get stressTestVerdictFomoDescription =>
      'Вы демонстрируете классическое поведение FOMO (страх упустить возможность), покупая активы у самых пиков цены. Такая гонка за зелёными свечами часто приводит к переплате за активы. Успешные инвесторы покупают, когда «на улицах кровь», а не когда царит эйфория. Попробуйте усреднение стоимости вместо покупки на все деньги на исторических максимумах.';

  @override
  String get stressTestVerdictActiveTraderTitle =>
      'АКТИВНЫЙ ТРЕЙДЕР — Риск высокой частоты';

  @override
  String stressTestVerdictActiveTraderDescription(int totalTrades) {
    return 'Вы совершили более $totalTrades сделок за эту симуляцию. Хотя активная торговля может быть прибыльной, она также влечёт значительные издержки — комиссии, проскальзывание и налоги. Что важнее, частая торговля нередко переходит границу между методичным инвестированием и спекуляцией на дофамине. Задумайтесь, есть ли у каждой сделки чёткое обоснование.';
  }

  @override
  String get stressTestVerdictPatientShieldTitle =>
      'ТЕРПЕЛИВЫЙ ЩИТ — Дисциплинированный инвестор';

  @override
  String get stressTestVerdictPatientShieldDescription =>
      'Вы продемонстрировали настоящую дисциплину: совершали мало точных сделок, держали позиции в волатильности и не поддавались панике. Такой терпеливый, долгосрочный подход — отличительная черта легендарных инвесторов.';

  @override
  String get stressTestVerdictAbsoluteShieldTitle =>
      'АБСОЛЮТНЫЙ ЩИТ — Мастер эмоций';

  @override
  String get stressTestVerdictAbsoluteShieldExtra =>
      'Исключительный результат: вы не просто пережили эффект «чёрного лебедя» — вы выкупили просадку и удержали позицию. Это самый редкий и самый прибыльный образ мышления в инвестировании. Вы заслужили значок АБСОЛЮТНЫЙ ЩИТ.';

  @override
  String get stressTestVerdictBalancedTitle =>
      'СБАЛАНСИРОВАННЫЙ — Развивающийся инвестор';

  @override
  String get stressTestVerdictBalancedDescription =>
      'Ваши торговые паттерны показывают смешанное поведение. Хотя вы избежали серьёзных эмоциональных ошибок, есть пространство для роста в процессе принятия решений. Сосредоточьтесь на выработке системного подхода к инвестированию, минимизирующего эмоциональные реакции.';

  @override
  String get tradesEngineTestNotActive => 'Тест не активен';

  @override
  String get tradesEnginePriceNotAvailable => 'Цена недоступна';

  @override
  String get tradesEngineSlotFrozen =>
      'Этот тест заморожен — продлите Premium, чтобы снова покупать и продавать здесь.';

  @override
  String get tradesEngineInvalidAmount => 'Некорректная сумма';

  @override
  String get tradesEngineInsufficientCash => 'Недостаточно наличных';

  @override
  String get tradesEngineInsufficientShares => 'Недостаточно акций';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get watchlistLimitFree =>
      'Бесплатный лимит: 30 компаний. Premium — до 50.';

  @override
  String watchlistLimitMax(int max) {
    return 'Достигнут лимит: $max компаний.';
  }

  @override
  String get companyDetailTitle => 'О КОМПАНИИ';

  @override
  String get companyDetailSponsoredTitle => 'Спонсорский контент';

  @override
  String get companyDetailWatchAdBody =>
      'Посмотрите короткую рекламу, чтобы продолжить просмотр информации о компании.';

  @override
  String get companyDetailWatchAdButton => 'Смотреть рекламу (3с)';

  @override
  String get companyDetailUpgradeNoAds => 'Перейти на Premium — без рекламы';

  @override
  String get companyDetailLoadError => 'Не удалось загрузить данные компании';

  @override
  String get companyDetailLoadErrorBody =>
      'API рыночных данных может быть временно недоступен. Попробуйте ещё раз.';

  @override
  String get companyDetailNoPortfolios =>
      'Портфелей пока нет. Сначала создайте один.';

  @override
  String get companyDetailSelectPortfolioTitle => 'Выбор портфеля';

  @override
  String companyDetailSelectPortfolioBodyBuy(String symbol) {
    return 'В какой портфель вы хотите купить $symbol?';
  }

  @override
  String companyDetailSelectPortfolioBodySell(String symbol) {
    return 'В какой портфель вы хотите продать $symbol?';
  }

  @override
  String get companyDetailChangeLabel => 'ИЗМЕНЕНИЕ';

  @override
  String companyDetailChangePeriodLabel(String period) {
    return 'ИЗМЕНЕНИЕ ($period)';
  }

  @override
  String get commonNotAvailable => 'Н/Д';

  @override
  String get companyDetailKeyMetricsTitle => 'КЛЮЧЕВЫЕ ПОКАЗАТЕЛИ';

  @override
  String get companyDetailMetricPe => 'P/E';

  @override
  String get companyDetailMetricDividendYield => 'Дивидендная доходность';

  @override
  String get companyDetailMetricNetMargin => 'Чистая маржа';

  @override
  String get companyDetailMetricOperatingMargin => 'Операционная маржа';

  @override
  String get companyDetailMetricGrossMargin => 'Валовая маржа';

  @override
  String get companyDetailMetricRoe => 'ROE';

  @override
  String get companyDetailPriceLabel => 'ЦЕНА';

  @override
  String get companyDetailFsScoreLabel => 'FS ОЦЕНКА';

  @override
  String get companyDetailPhasePreMarket => 'ПРЕДТОРГИ';

  @override
  String get companyDetailPhaseMarketOpen => 'РЫНОК ОТКРЫТ';

  @override
  String get companyDetailPhasePostMarket => 'ПОСТТОРГИ';

  @override
  String get companyDetailPhaseMarketClosed => 'РЫНОК ЗАКРЫТ';

  @override
  String get companyDetailPositionTitle => 'МОИ ИНВЕСТИЦИИ';

  @override
  String get companyDetailAssetValueLabel => 'Стоимость актива';

  @override
  String get companyDetailSharesLabel => 'Акции';

  @override
  String get companyDetailAvgCostLabel => 'Средняя цена';

  @override
  String get companyDetailLimitOrdersTitle => 'ЛИМИТНЫЕ ОРДЕРА';

  @override
  String companyDetailSymbolLimitOrdersTitle(String symbol) {
    return 'Лимитные ордера $symbol';
  }

  @override
  String companyDetailDividendTrapPenalty(int pts) {
    return 'Штраф за дивидендную ловушку: -$pts б.';
  }

  @override
  String companyDetailCatastrophicLossPenalty(int pts) {
    return 'Штраф за критический убыток: -$pts б. (чистая маржа ниже -100%)';
  }

  @override
  String get companyDetailLegalDisclaimerMethodology =>
      'Юридический дисклеймер и методология';

  @override
  String get companyDetailMarkerValuation => 'Оценка стоимости';

  @override
  String get companyDetailMarkerFinancialHealth => 'Финансовое здоровье';

  @override
  String get companyDetailMarkerGrowthPotential => 'Потенциал роста';

  @override
  String get companyDetailMarkerEfficiency => 'Эффективность';

  @override
  String get companyDetailMarkerHistoricalTrend => 'Исторический тренд';

  @override
  String get companyDetailMarkerShareholderReturns => 'Доход акционеров';

  @override
  String get companyDetailMarkerDescValuation => 'P/E относительно сектора';

  @override
  String get companyDetailMarkerDescFinancialHealth =>
      'Соотношение долг/капитал';

  @override
  String get companyDetailMarkerDescGrowth => 'Рост выручки и EPS за 5 лет';

  @override
  String get companyDetailMarkerDescEfficiency => 'Чистая маржа и ROE';

  @override
  String get companyDetailMarkerDescHistoricalTrend =>
      'CAGR цены акции за 5 лет';

  @override
  String get companyDetailMarkerDescShareholderReturns => 'Дивиденды и байбэки';

  @override
  String get companyDetailRatingExcellent => 'Отлично';

  @override
  String get companyDetailRatingGood => 'Хорошо';

  @override
  String get companyDetailRatingAverage => 'Средне';

  @override
  String get companyDetailRatingWeak => 'Слабо';

  @override
  String get companyDetailRatingPoor => 'Плохо';

  @override
  String get companyWidgetPriceHeader => 'Цена и заголовок';

  @override
  String get companyWidgetKeyMetrics => 'Ключевые показатели';

  @override
  String get companyWidgetFinancialScore => 'Финансовая оценка';

  @override
  String get companyWidgetPosition => 'Ваша позиция';

  @override
  String get companyWidgetLimitOrders => 'Лимитные ордера';

  @override
  String get companyWidgetEncyclopedia => 'История компании';

  @override
  String get companyEncyclopediaCardTitle => '📖 ИСТОРИЯ КОМПАНИИ';

  @override
  String get companyEncyclopediaBusinessRow => 'История бизнеса';

  @override
  String get companyEncyclopediaMarketRow => 'Биржевая история';

  @override
  String get companyEncyclopediaPresentDayRow => 'В наши дни';

  @override
  String get companyEncyclopediaNoData => 'Нет данных';

  @override
  String get companyEncyclopediaLoadError => 'Не удалось загрузить статью';

  @override
  String get companyEncyclopediaPaywallTitle => 'Разблокировать статью';

  @override
  String get companyEncyclopediaPaywallBody =>
      'Посмотрите пару коротких реклам, чтобы прочитать полную историю компании, либо оформите Premium и читайте без рекламы в любое время.';

  @override
  String get companyEncyclopediaGoPremiumButton => 'Оформить Premium';

  @override
  String get companyEncyclopediaDisclaimerTitle => 'Дисклеймер';

  @override
  String get companyEncyclopediaDisclaimerBody =>
      'Вся информация в этом разделе основана на публичных данных, раскрываемых самими компаниями, и носит исключительно образовательный характер. Она не является финансовой консультацией, инвестиционной рекомендацией или итоговой оценкой бизнеса. Прежде чем делать какие-либо выводы о компании, пользователю следует самостоятельно проверить приведённые сведения.';

  @override
  String companyDetailCashAvailable(String cash) {
    return '$cash доступно';
  }

  @override
  String get companyDetailAcademicDisclaimerTitle =>
      'Образовательный и академический дисклеймер';

  @override
  String get companyDetailAcademicDisclaimerBody =>
      'Представленная здесь методология, определения и аналитические принципы основаны на стандартной теории корпоративных финансов и моделях оценки, преподаваемых в ведущих бизнес-школах. Предоставлено исключительно в образовательных целях.';

  @override
  String get companyDetailAdTitle => 'Спонсорская реклама';

  @override
  String get companyDetailAdContinuing => 'Продолжение через мгновение…';

  @override
  String get companyDetailNoPriceDataAvailable => 'Нет данных о цене';

  @override
  String get companyDetailChartLoadError => 'Не удалось загрузить график';

  @override
  String get companyDetailChartNotEnoughData => 'Недостаточно данных';

  @override
  String get commonOk => 'ОК';

  @override
  String get orderEntryTabMarket => 'Рыночная';

  @override
  String get orderEntryTabLimit => 'Лимитная';

  @override
  String get orderEntryExtendedHoursTitle => 'Расширенные часы';

  @override
  String get orderEntryExtendedHoursSubtitle =>
      'Выкл.: торговля только пока открыт реальный рынок';

  @override
  String get orderEntrySimulatedDisclaimerTitle =>
      'Дисклеймер: симулированная торговля, не брокерская деятельность';

  @override
  String get orderEntrySimulatedDisclaimerBody =>
      'Это приложение не является зарегистрированным брокером-дилером, инвестиционным консультантом или финансовой организацией и не предоставляет услуги по исполнению ордеров на реальных финансовых рынках.\n\nВсе операции покупки и продажи выполняются исключительно на симулированном счёте с использованием виртуальной валюты (Paper Trading). Сделки, совершённые в этом приложении, предназначены исключительно для образовательных целей, не приводят к покупке или владению реальными ценными бумагами, не создают прав акционера и не имеют реальной финансовой или юридической силы.';

  @override
  String get orderEntryUnitUsd => 'USD';

  @override
  String get orderEntryUnitShares => 'Акции';

  @override
  String orderEntryApproxShares(String shares) {
    return '≈ $shares акций';
  }

  @override
  String get orderEntryLimitPriceTitle => 'ЛИМИТНАЯ ЦЕНА';

  @override
  String get orderEntryLimitPriceHintBuy =>
      'Выберите цену ниже текущей для ордера на покупку';

  @override
  String get orderEntryLimitPriceHintSell =>
      'Выберите цену выше текущей для ордера на продажу';

  @override
  String get orderEntryCostLabel => 'Стоимость:';

  @override
  String get orderEntryQtyLabel => 'Кол-во:';

  @override
  String orderEntrySharesAbbrev(String shares) {
    return '$shares шт.';
  }

  @override
  String get orderEntryPlaceOrder => 'Разместить ордер';

  @override
  String get orderEntryMarketClosedTitle => 'Рынок закрыт';

  @override
  String get orderEntryMarketClosedBody =>
      'Извините, рынок сейчас закрыт, поэтому рыночные ордера не могут быть исполнены прямо сейчас.\n\nВы всё ещё можете разместить лимитный ордер — он будет ждать и исполнится, когда рынок снова откроется. Либо включите расширенные часы, чтобы торговать круглосуточно.';

  @override
  String get orderEntryPlaceLimitInstead => 'Разместить лимитный ордер вместо';

  @override
  String get orderEntryEnterAmount => 'Введите сумму';

  @override
  String get orderEntryInvalidQuantity => 'Некорректное количество';

  @override
  String get orderEntryEnterValidLimitPrice =>
      'Введите корректную лимитную цену';

  @override
  String orderEntryNotEnoughCash(String cash) {
    return 'Недостаточно доступных средств — свободно $cash (часть зарезервирована под ожидающие ордера)';
  }

  @override
  String orderEntryNotEnoughShares(String shares) {
    return 'Недостаточно акций — у вас есть $shares';
  }

  @override
  String get orderEntryInfoMarket =>
      'Рыночные ордера исполняются по лучшей доступной цене. Исполнение гарантировано, но итоговая цена может отличаться от ожидаемой.';

  @override
  String get orderEntryInfoLimit =>
      'Лимитные ордера исполняются только по указанной цене или лучше. Частичное или полное исполнение не гарантировано.';

  @override
  String get orderEntryInfoStop =>
      'Стоп-ордера активируются при достижении стоп-цены, после чего исполняются как рыночный ордер.';

  @override
  String get orderEntryInfoStopLimit =>
      'Стоп-лимит ордера активируются при достижении стоп-цены, после чего исполняются как лимитный ордер.';

  @override
  String get stressTestOrderInfoMarket =>
      'Рыночные ордера исполняются по лучшей доступной симулированной цене. Исполнение гарантировано, но итоговая цена может отличаться от ожидаемой.';

  @override
  String get stressTestOrderInfoLimit =>
      'Лимитные ордера исполняются, только когда симулированная цена достигнет выбранной вами цены или лучше. Исполнение не гарантировано.';

  @override
  String get stressTestOrderCommissionNotice =>
      'За каждую покупку и продажу взимается брокерская комиссия 0.5%, как у реальных брокеров.';

  @override
  String stressTestOrderCommissionEstimate(String amount) {
    return 'Комиссия: ≈$amount';
  }

  @override
  String get orderEntryHoldingsLimitTitle => 'Достигнут лимит';

  @override
  String orderEntryHoldingsLimitBody(int max) {
    return 'Вы превысили допустимый лимит на покупку активов для этого портфеля ($max компаний).';
  }

  @override
  String get orderEntryHoldingsLimitPromoTitle =>
      'Достигнут лимит активов портфеля';

  @override
  String get orderEntryPriceLoadError => 'Не удалось загрузить текущую цену';

  @override
  String get companyDetailDisclaimerTitle =>
      'Образовательное назначение и юридический дисклеймер';

  @override
  String get companyDetailDisclaimerBody =>
      'Это приложение работает исключительно как образовательный симулятор, созданный, чтобы помочь пользователям научиться анализировать и понимать финансовые показатели бизнеса. Оценки и аналитика формируются на основе публичной финансовой отчётности компаний, а также академических моделей ведущих университетов и признанных учебников по финансовой грамотности.\n\nОтображаемые рыночные цены и показатели могут быть задержаны, оценочны или отличаться от реальных биржевых цен. Содержимое приложения не является предложением, рекомендацией или побуждением покупать либо продавать какие-либо финансовые активы. Все торговые решения принимаются исключительно и самостоятельно пользователем. Разработчики не оказывают финансовых услуг и не несут ответственности за какую-либо упущенную выгоду, финансовые потери или потерю реального капитала.\n\nПродолжая использовать это приложение, вы полностью подтверждаете и принимаете условия данного дисклеймера, включая освобождение разработчиков от какой-либо ответственности. Отсутствие ознакомления с данным дисклеймером не освобождает пользователя от соблюдения его условий и не даёт оснований для каких-либо претензий, споров или судебных исков.';

  @override
  String get metricInfoPeTitle => 'P/E';

  @override
  String get metricInfoPeSubtitle => 'Отношение цены к прибыли';

  @override
  String get metricInfoPeSection1Header => 'Что такое P/E?';

  @override
  String get metricInfoPeSection1Body =>
      'Отношение цены к прибыли (P/E) сравнивает цену акции компании с размером прибыли, которую она зарабатывает.\n\nПроще говоря: P/E показывает, сколько инвесторы готовы платить сегодня за каждый \$1 годовой прибыли компании. Это один из самых широко используемых показателей оценки на фондовом рынке.';

  @override
  String get metricInfoPeSection2Header => 'Как он рассчитывается?';

  @override
  String get metricInfoPeSection2Body =>
      'Формула\nP/E = Цена акции ÷ Прибыль на акцию (EPS)\n\nПример\nЦена акции = \$100\nПрибыль на акцию = \$5\nP/E = 100 ÷ 5 = 20\n\nЭто значит, что инвесторы сейчас платят \$20 за каждый \$1 годовой прибыли.';

  @override
  String get metricInfoPeSection3Header => 'О чём он говорит?';

  @override
  String get metricInfoPeSection3Body =>
      'P/E помогает ответить на один важный вопрос: «Дорого или дёшево стоит эта компания по отношению к своей прибыли?»\n\nВ целом:\n• Более низкий P/E = более низкая оценка\n• Более высокий P/E = более высокая оценка\n\nОднако низкий P/E не значит автоматически «хорошо», а высокий P/E не значит автоматически «плохо». Контекст всегда важен.';

  @override
  String get metricInfoPeSection4Header => 'Какой P/E считается хорошим?';

  @override
  String get metricInfoPeSection4Body =>
      'Идеального значения не существует, ведь каждая отрасль устроена по-своему.\n\nНиже 10 — часто считается очень дёшево. Возможные причины: пессимизм рынка, спад бизнеса, временные трудности или скрытая возможность. Требует тщательного изучения.\n\n10–20 — часто считается разумной оценкой для зрелых компаний. Характерно для стабильного бизнеса — товаров повседневного спроса, банков, промышленных компаний.\n\n20–30 — инвесторы ожидают роста будущей прибыли, сильных конкурентных позиций и надёжной бизнес-модели. Компания дорожает.\n\nВыше 30 — рынок ожидает значительного роста в будущем. Характерно для технологических компаний, быстрорастущего бизнеса и инновационных отраслей. Такие компании могут показывать отличные результаты — но и ожидания от них выше.';

  @override
  String get metricInfoPeSection5Header =>
      'Почему высокий P/E может быть совершенно нормальным?';

  @override
  String get metricInfoPeSection5Body =>
      'Представьте две компании.\n\nКомпания A — прибыль растёт на 2% в год, P/E = 12\nКомпания B — прибыль растёт на 35% в год, P/E = 40\n\nНа первый взгляд компания B кажется очень дорогой. Но если её прибыль продолжит быстро расти, сегодняшняя высокая оценка со временем может оказаться вполне разумной. Инвесторы платят не только за сегодняшнюю прибыль — но и за потенциал завтрашнего дня.';

  @override
  String get metricInfoPeSection6Header =>
      'Почему низкий P/E может быть опасен?';

  @override
  String get metricInfoPeSection6Body =>
      'Низкий P/E может говорить о том, что инвесторы ожидают проблем. Возможные причины: падение продаж, снижение прибыли, крупный долг, потеря доли рынка, судебные разбирательства или слабое управление.\n\nИногда рынок просто реагирует на риски, которые не сразу заметны. Это явление называют «ловушкой стоимости» (Value Trap) — акция кажется дешёвой, но продолжает показывать слабые результаты.';

  @override
  String get metricInfoPeSection7Header => 'Что если P/E отрицательный?';

  @override
  String get metricInfoPeSection7Body =>
      'Отрицательный P/E означает, что компания показала убыток вместо прибыли. Это не обязательно говорит о том, что у компании дела плохи.\n\nВозможные причины: крупные инвестиции в будущий рост, строительство новых заводов, выход на новые рынки, покупка другой компании, временный экономический спад или разовые бухгалтерские расходы.\n\nМногие успешные компании проходили через периоды отрицательной прибыли, прежде чем вернуться к прибыльности.';

  @override
  String get metricInfoPeSection8Header => 'Что такое «хайп»?';

  @override
  String get metricInfoPeSection8Body =>
      'Иногда инвесторы становятся чрезмерно оптимистичны в отношении компании. Цена акций растёт намного быстрее, чем реальная прибыль компании, из-за чего P/E становится очень высоким.\n\nЭто часто происходит, когда инвесторы ждут революционных технологий, роста искусственного интеллекта, прорывных продуктов или масштабного расширения в будущем. Высокий P/E, вызванный ажиотажем, часто называют рыночным хайпом.\n\nЕсли компания не оправдывает эти высокие ожидания, цена акций может резко упасть — даже если бизнес остаётся здоровым.';

  @override
  String get metricInfoPeSection9Header => 'Типичные ошибки новичков';

  @override
  String get metricInfoPeSection9Body =>
      '• Покупать акции только потому, что P/E низкий.\n• Избегать любых компаний с высоким P/E.\n• Сравнивать компании из совершенно разных отраслей.\n• Игнорировать рост прибыли.\n• Игнорировать уровень долга.\n• Принимать инвестиционные решения на основе одного-единственного показателя.';

  @override
  String get metricInfoPeSection10Header => 'У P/E есть ограничения';

  @override
  String get metricInfoPeSection10Body =>
      'P/E лучше всего работает для компаний со стабильной прибылью. Он менее полезен для стартапов, компаний с временными убытками, бизнеса с сильно цикличной прибылью или компаний, переживающих масштабную реструктуризацию.\n\nДля таких компаний инвесторы обычно опираются на дополнительные показатели оценки.';

  @override
  String get metricInfoPeSection11Header => 'Лучше всего использовать вместе с';

  @override
  String get metricInfoPeSection11Body =>
      'P/E никогда не стоит рассматривать в одиночку. Сочетайте его с: ростом выручки, чистой маржой, операционной маржой, ROE, уровнем долга, свободным денежным потоком и дивидендной доходностью.\n\nОдновременный взгляд на несколько показателей даёт намного более чёткую картину финансового здоровья компании.';

  @override
  String get metricInfoPeSection12Header => 'Аналогия из жизни';

  @override
  String get metricInfoPeSection12Body =>
      'Представьте два многоквартирных дома.\n\nДом A — цена: \$500,000, годовой доход от аренды: \$50,000\nДом B — цена: \$1,000,000, годовой доход от аренды: \$50,000\n\nДом A выглядит намного дешевле. Но если дом B находится в центре быстрорастущего города, где через несколько лет доход от аренды ожидается вдвое выше, более высокая цена может быть оправдана.\n\nС акциями всё работает похожим образом.';

  @override
  String get metricInfoPeSection13Header => 'Главный вывод';

  @override
  String get metricInfoPeSection13Body =>
      'P/E показывает, сколько инвесторы платят за каждый доллар прибыли компании. Это отличная отправная точка для оценки акции — но его никогда не стоит использовать как единственный фактор при принятии инвестиционного решения.';

  @override
  String get metricInfoDividendYieldTitle => 'Дивидендная доходность';

  @override
  String get metricInfoDividendYieldSubtitle =>
      'Годовой доход от дивидендов относительно цены акции';

  @override
  String get metricInfoDividendYieldSection1Header =>
      'Что такое дивидендная доходность?';

  @override
  String get metricInfoDividendYieldSection1Body =>
      'Дивидендная доходность показывает, сколько денег компания ежегодно выплачивает акционерам относительно текущей цены акции.\n\nПроще говоря: дивидендная доходность показывает, сколько годового дохода в виде дивидендов вы получаете на каждые \$100, вложенные в акцию. Это один из важнейших показателей для инвесторов, ориентированных на доход.';

  @override
  String get metricInfoDividendYieldSection2Header => 'Как она рассчитывается?';

  @override
  String get metricInfoDividendYieldSection2Body =>
      'Формула\nДивидендная доходность = Годовой дивиденд на акцию ÷ Цена акции × 100%\n\nПример\nГодовой дивиденд = \$2.40\nЦена акции = \$100\nДивидендная доходность = 2.4%\n\nЭто значит, что на каждые вложенные \$100 вы получаете примерно \$2.40 в год в виде дивидендов (до вычета налогов).';

  @override
  String get metricInfoDividendYieldSection3Header => 'О чём она говорит?';

  @override
  String get metricInfoDividendYieldSection3Body =>
      'Дивидендная доходность измеряет потенциал дохода от акции.\n\nВ целом:\n• Более высокая доходность = более высокий дивидендный доход\n• Более низкая доходность = более низкий дивидендный доход\n\nОднако более высокая дивидендная доходность не всегда лучше.';

  @override
  String get metricInfoDividendYieldSection4Header =>
      'Какая дивидендная доходность считается хорошей?';

  @override
  String get metricInfoDividendYieldSection4Body =>
      'Универсального «идеального» значения не существует.\n\n0% — компания не выплачивает дивиденды. Характерно для растущих компаний, стартапов и многих технологических компаний. Вместо выплат акционерам такой бизнес реинвестирует прибыль, чтобы расти быстрее.\n\n1%–2% — сравнительно небольшой дивиденд. Часто встречается у компаний, ориентированных на долгосрочный рост, но всё же вознаграждающих акционеров.\n\n2%–4% — как правило, считается здоровым и устойчивым диапазоном. Многие качественные компании попадают именно сюда.\n\n4%–6% — сравнительно высокий дивиденд. Может быть привлекательным, но инвесторам стоит проверить, сможет ли компания продолжать такие выплаты.\n\nВыше 6% — требует особого внимания. Иногда дивиденд действительно щедрый. А иногда цена акции резко упала, из-за чего доходность выглядит необычно высокой. Это скорее тревожный сигнал, чем выгодная сделка.';

  @override
  String get metricInfoDividendYieldSection5Header =>
      'Почему высокая дивидендная доходность не всегда хороша?';

  @override
  String get metricInfoDividendYieldSection5Body =>
      'Дивидендная доходность растёт как при увеличении дивидендов, так и при падении цены акции.\n\nРассмотрим пример.\n\nВчера — цена = \$100, дивиденд = \$4, доходность = 4%\nСегодня — цена упала до \$50, дивиденд остался \$4, доходность стала 8%\n\nДивиденд не стал лучше. Акция просто сильно подешевела. Возможно, инвесторы обеспокоены будущим компании.';

  @override
  String get metricInfoDividendYieldSection6Header =>
      'Может ли компания с 0% дивидендной доходности всё равно быть отличной?';

  @override
  String get metricInfoDividendYieldSection6Body =>
      'Безусловно. Многие успешные компании сознательно не платят дивиденды. Вместо этого они направляют прибыль на: разработку новых продуктов, международную экспансию, строительство новых заводов, покупку конкурентов или инвестиции в исследования и инновации.\n\nЕсли эти инвестиции приносят более высокую прибыль в будущем, акционеры могут выиграть за счёт роста цены акций, а не дивидендных выплат.';

  @override
  String get metricInfoDividendYieldSection7Header =>
      'Может ли дивидендная доходность снижаться?';

  @override
  String get metricInfoDividendYieldSection7Body =>
      'Да. Причины могут быть такими: цена акции растёт быстрее дивидендов, компания снижает дивиденд, или компания временно приостанавливает дивидендные выплаты.\n\nБолее низкая доходность не означает автоматически, что компания стала слабее.';

  @override
  String get metricInfoDividendYieldSection8Header =>
      'Может ли дивидендная доходность расти?';

  @override
  String get metricInfoDividendYieldSection8Body =>
      'Да. Возможные причины: компания повышает дивиденд, цена акции снижается, или происходит и то и другое одновременно.\n\nПоэтому инвесторам всегда стоит выяснять, почему изменилась доходность.';

  @override
  String get metricInfoDividendYieldSection9Header =>
      'Что такое сокращение дивидендов?';

  @override
  String get metricInfoDividendYieldSection9Body =>
      'Сокращение дивидендов происходит, когда компания уменьшает сумму выплат акционерам. Компании могут сокращать дивиденды, потому что им нужны деньги на: погашение долга, преодоление экономического спада, финансирование крупных инвестиций или защиту бизнеса в трудные периоды.\n\nСокращение дивидендов не всегда признак неудачи. Иногда это ответственное финансовое решение, которое укрепляет компанию в долгосрочной перспективе.';

  @override
  String get metricInfoDividendYieldSection10Header =>
      'Почему некоторые компании никогда не платят дивиденды?';

  @override
  String get metricInfoDividendYieldSection10Body =>
      'Многие растущие компании считают, что каждый заработанный доллар может принести ещё большую отдачу, если реинвестировать его в бизнес. Например: выход на новые рынки, наём новых сотрудников, разработка новых технологий или расширение производственных мощностей.\n\nВ таких случаях инвесторы рассчитывают на рост стоимости капитала, а не на дивидендный доход.';

  @override
  String get metricInfoDividendYieldSection11Header =>
      'Типичные ошибки новичков';

  @override
  String get metricInfoDividendYieldSection11Body =>
      '• Покупать акции с самой высокой дивидендной доходностью.\n• Считать, что дивиденды гарантированы навсегда.\n• Игнорировать прибыль и денежный поток компании.\n• Сравнивать дивидендную доходность компаний из совершенно разных отраслей.\n• Фокусироваться только на доходе, игнорируя качество бизнеса.';

  @override
  String get metricInfoDividendYieldSection12Header =>
      'Лучше всего использовать вместе с';

  @override
  String get metricInfoDividendYieldSection12Body =>
      'Дивидендная доходность становится намного информативнее в сочетании с: коэффициентом выплат (Dividend Payout Ratio), ростом прибыли, свободным денежным потоком, P/E, чистой маржой и уровнем долга.\n\nЭти показатели помогают понять, насколько устойчивы дивидендные выплаты.';

  @override
  String get metricInfoDividendYieldSection13Header => 'Аналогия из жизни';

  @override
  String get metricInfoDividendYieldSection13Body =>
      'Представьте, что вы покупаете квартиру для сдачи в аренду.\n\nКвартира A стоит \$200,000 и приносит \$6,000 в год арендной платы. Доходность от аренды = 3%\n\nКвартира B стоит \$200,000 и приносит \$12,000 в год. Доходность от аренды = 6%\n\nКвартира B выглядит намного привлекательнее. Но если дому требуется дорогой ремонт или жильцы съезжают, более высокая доходность может сопровождаться более высоким риском.\n\nИнвестирование в дивиденды работает очень похожим образом.';

  @override
  String get metricInfoDividendYieldSection14Header => 'Главный вывод';

  @override
  String get metricInfoDividendYieldSection14Body =>
      'Дивидендная доходность показывает годовой дивидендный доход относительно текущей цены акции. Более высокая доходность может выглядеть привлекательно, но качество и устойчивость этих дивидендов гораздо важнее самого процента.';

  @override
  String get metricInfoNetMarginTitle => 'Чистая маржа';

  @override
  String get metricInfoNetMarginSubtitle =>
      'Прибыль, остающаяся после всех расходов';

  @override
  String get metricInfoNetMarginSection1Header => 'Что такое чистая маржа?';

  @override
  String get metricInfoNetMarginSection1Body =>
      'Чистая маржа показывает, сколько прибыли остаётся у компании после оплаты всех расходов. К этим расходам относятся: себестоимость продукции, зарплаты сотрудников, аренда, налоги, проценты по долгу, операционные расходы и все прочие затраты бизнеса.\n\nПроще говоря: чистая маржа показывает, сколько денег компания реально оставляет себе с каждого доллара продаж. Это один из лучших показателей общей прибыльности компании.';

  @override
  String get metricInfoNetMarginSection2Header => 'Как она рассчитывается?';

  @override
  String get metricInfoNetMarginSection2Body =>
      'Формула\nЧистая маржа = Чистая прибыль ÷ Выручка × 100%\n\nПример\nВыручка = \$100 млн\nЧистая прибыль = \$20 млн\nЧистая маржа = 20%\n\nЭто значит, что компания оставляет себе \$20 прибыли с каждых \$100 продаж.';

  @override
  String get metricInfoNetMarginSection3Header => 'О чём она говорит?';

  @override
  String get metricInfoNetMarginSection3Body =>
      'Чистая маржа показывает, насколько эффективно компания превращает выручку в реальную прибыль.\n\nВ целом:\n• Более высокая маржа = более прибыльный бизнес\n• Более низкая маржа = менее прибыльный бизнес\n\nУ компаний с высокой чистой маржой обычно есть: эффективные операции, сильная ценовая власть, хороший контроль над издержками и здоровая бизнес-модель.';

  @override
  String get metricInfoNetMarginSection4Header =>
      'Какая чистая маржа считается хорошей?';

  @override
  String get metricInfoNetMarginSection4Body =>
      'Единого стандарта не существует, ведь отрасли очень сильно различаются.\n\nНиже 5% — обычно считается низкой маржой. Характерно для бизнеса с острой конкуренцией или тонкой маржой, например продуктовых магазинов, авиакомпаний, розничных сетей.\n\n5%–10% — здоровый уровень для многих традиционных отраслей.\n\n10%–20% — очень хорошая прибыльность. Многие успешные компании стабильно работают в этом диапазоне.\n\nВыше 20% — отличная прибыльность. Часто встречается у компаний с сильными брендами, софтверного бизнеса, товаров класса люкс или высокотехнологичных продуктов.\n\nВыше 30% — исключительный результат. Обычно говорит о выдающейся бизнес-модели или значительных конкурентных преимуществах компании.';

  @override
  String get metricInfoNetMarginSection5Header =>
      'Почему высокая чистая маржа важна?';

  @override
  String get metricInfoNetMarginSection5Body =>
      'Компания с высокой чистой маржой обладает большей гибкостью. Она может: инвестировать в рост, увеличивать дивиденды, выкупать собственные акции, переживать сложные экономические периоды или продолжать инвестировать во время рецессий.\n\nБолее высокая прибыльность часто означает более сильный и устойчивый бизнес.';

  @override
  String get metricInfoNetMarginSection6Header =>
      'Почему низкая чистая маржа не всегда плоха?';

  @override
  String get metricInfoNetMarginSection6Body =>
      'Некоторые отрасли по своей природе работают с низкой маржой. Например, супермаркет может иметь чистую маржу всего 2%, но продавать товаров на миллиарды долларов каждый год. Небольшая маржа при огромных продажах всё равно может давать значительную прибыль.\n\nПоэтому чистую маржу всегда нужно сравнивать с компаниями из той же отрасли.';

  @override
  String get metricInfoNetMarginSection7Header =>
      'Может ли чистая маржа быть отрицательной?';

  @override
  String get metricInfoNetMarginSection7Body =>
      'Да. Отрицательная чистая маржа означает, что за отчётный период компания понесла убыток. Однако это не означает автоматически, что бизнес терпит крах.\n\nВозможные причины: крупные инвестиции, экономическая рецессия, разовые судебные расходы, строительство завода, поглощения, временная реструктуризация или валютные убытки.\n\nМногие успешные компании переживали периоды отрицательной маржи, прежде чем вернуться к прибыльности.';

  @override
  String get metricInfoNetMarginSection8Header =>
      'Что приводит к росту чистой маржи?';

  @override
  String get metricInfoNetMarginSection8Body =>
      'Чистая маржа обычно растёт, когда компания: продаёт больше продукции, повышает цены, снижает издержки, повышает эффективность, платит меньше процентов по долгу или сокращает операционные расходы.\n\nСтабильно растущая маржа часто говорит об отличном управлении.';

  @override
  String get metricInfoNetMarginSection9Header =>
      'Что приводит к снижению чистой маржи?';

  @override
  String get metricInfoNetMarginSection9Body =>
      'Маржа прибыли может снижаться из-за: роста производственных затрат, повышения зарплат, инфляции, усиления конкуренции, падения продаж, роста процентных ставок или непредвиденных расходов.\n\nВременное снижение — это нормально. А вот долгосрочная нисходящая тенденция заслуживает более пристального внимания.';

  @override
  String get metricInfoNetMarginSection10Header =>
      'Почему важно сравнивать отрасли?';

  @override
  String get metricInfoNetMarginSection10Body =>
      'У разных отраслей совершенно разные бизнес-модели. Например, супермаркет с чистой маржой 2% вполне может быть отличным бизнесом, а вот софтверная компания с той же маржой в 2%, скорее всего, столкнулась бы с серьёзными проблемами прибыльности.\n\nВсегда сравнивайте компании с их прямыми конкурентами.';

  @override
  String get metricInfoNetMarginSection11Header => 'Типичные ошибки новичков';

  @override
  String get metricInfoNetMarginSection11Body =>
      '• Считать, что у всех компаний должна быть одинаковая чистая маржа.\n• Сравнивать технологические компании с розничными сетями.\n• Игнорировать долгосрочные тенденции.\n• Смотреть только на результаты одного года.\n• Игнорировать причины изменения маржи.';

  @override
  String get metricInfoNetMarginSection12Header =>
      'Лучше всего использовать вместе с';

  @override
  String get metricInfoNetMarginSection12Body =>
      'Чистая маржа становится ещё полезнее в сочетании с: валовой маржой, операционной маржой, ROE, ростом выручки, свободным денежным потоком, P/E и уровнем долга.\n\nВместе эти показатели дают гораздо более полную картину финансового здоровья компании.';

  @override
  String get metricInfoNetMarginSection13Header => 'Аналогия из жизни';

  @override
  String get metricInfoNetMarginSection13Body =>
      'Представьте два ресторана.\n\nРесторан A получает \$1,000,000 годовых продаж, но оставляет себе лишь \$20,000 прибыли. Чистая маржа = 2%\n\nРесторан B получает те же \$1,000,000, но оставляет себе \$200,000. Чистая маржа = 20%\n\nОба ресторана генерируют одинаковую выручку, но ресторан B работает намного эффективнее и прибыльнее. Именно это и помогает понять инвесторам чистая маржа.';

  @override
  String get metricInfoNetMarginSection14Header => 'Главный вывод';

  @override
  String get metricInfoNetMarginSection14Body =>
      'Чистая маржа показывает, сколько прибыли остаётся у компании после оплаты всех расходов. Более высокая маржа обычно говорит о более сильном, эффективном и финансово здоровом бизнесе, но сравнивать компании всегда следует в рамках одной отрасли.';

  @override
  String get metricInfoOperatingMarginTitle => 'Операционная маржа';

  @override
  String get metricInfoOperatingMarginSubtitle =>
      'Прибыль от основной деятельности до уплаты процентов и налогов';

  @override
  String get metricInfoOperatingMarginSection1Header =>
      'Что такое операционная маржа?';

  @override
  String get metricInfoOperatingMarginSection1Body =>
      'Операционная маржа показывает, сколько прибыли компания зарабатывает от основной деятельности до уплаты процентов по долгам и налогов. В отличие от чистой маржи, операционная маржа отражает только то, насколько эффективно ведётся сам бизнес.\n\nПроще говоря: операционная маржа показывает, сколько денег компания оставляет себе с каждого доллара продаж до финансовых расходов и налогов. Многие профессиональные инвесторы считают этот показатель одним из лучших индикаторов эффективности менеджмента.';

  @override
  String get metricInfoOperatingMarginSection2Header =>
      'Как она рассчитывается?';

  @override
  String get metricInfoOperatingMarginSection2Body =>
      'Формула\nОперационная маржа = Операционная прибыль ÷ Выручка × 100%\n\nПример\nВыручка = \$100 млн\nОперационная прибыль = \$25 млн\nОперационная маржа = 25%\n\nЭто значит, что после оплаты всех операционных расходов компания оставляет себе \$25 с каждых \$100 продаж — до уплаты процентов и налогов.';

  @override
  String get metricInfoOperatingMarginSection3Header => 'О чём она говорит?';

  @override
  String get metricInfoOperatingMarginSection3Body =>
      'Операционная маржа показывает, насколько прибыльным на самом деле является основной бизнес компании. Она отвечает на вопросы: контролирует ли менеджмент расходы? Эффективен ли бизнес? Способна ли компания получать хорошую прибыль от повседневной деятельности?\n\nВысокая операционная маржа обычно говорит о том, что компанией хорошо управляют.';

  @override
  String get metricInfoOperatingMarginSection4Header =>
      'Что такое операционная прибыль?';

  @override
  String get metricInfoOperatingMarginSection4Body =>
      'Операционная прибыль — это прибыль, которая остаётся после оплаты: себестоимости проданных товаров (COGS), зарплат сотрудников, аренды, маркетинга, исследований и разработок, административных расходов и прочих операционных затрат.\n\nВ неё не входят: процентные платежи, налог на прибыль, а также разовые чрезвычайные доходы или убытки.\n\nБлагодаря этому операционная маржа даёт более чистую картину результатов бизнеса.';

  @override
  String get metricInfoOperatingMarginSection5Header =>
      'Какая операционная маржа считается хорошей?';

  @override
  String get metricInfoOperatingMarginSection5Body =>
      'В разных отраслях действуют разные нормы.\n\nНиже 5% — обычно считается низким показателем. Часто встречается в бизнесах с острой конкуренцией.\n\n5–10% — нормальный уровень для многих традиционных компаний.\n\n10–20% — сильные операционные результаты. Многие успешные компании стабильно показывают маржу в этом диапазоне.\n\nВыше 20% — отлично. Часто указывает на сильную ценовую власть, эффективный менеджмент или конкурентные преимущества.\n\nВыше 30% — выдающийся результат. Обычно встречается у софтверных компаний, люксовых брендов или бизнесов с исключительно эффективными операциями.';

  @override
  String get metricInfoOperatingMarginSection6Header =>
      'Почему операционная маржа важна?';

  @override
  String get metricInfoOperatingMarginSection6Body =>
      'В отличие от чистой маржи, операционная маржа исключает факторы, которые менеджмент не полностью контролирует, — например, налоговые ставки, процентные расходы и структуру долга. Это позволяет инвесторам оценить качество реальной операционной деятельности компании.\n\nУ двух компаний может быть разная чистая маржа просто потому, что у одной из них больше долга. Операционная маржа помогает убрать это искажение.';

  @override
  String get metricInfoOperatingMarginSection7Header =>
      'Почему операционная маржа может быть низкой?';

  @override
  String get metricInfoOperatingMarginSection7Body =>
      'Более низкая операционная маржа не обязательно означает слабую компанию. Возможные причины: крупные инвестиции в рост, запуск новых продуктов, выход на новые рынки, увеличение расходов на маркетинг, рост затрат на персонал или временная инфляция.\n\nИногда такие инвестиции приводят к гораздо более высокой прибыли в будущем.';

  @override
  String get metricInfoOperatingMarginSection8Header =>
      'Может ли операционная маржа быть отрицательной?';

  @override
  String get metricInfoOperatingMarginSection8Body =>
      'Да. Отрицательная операционная маржа означает, что основной бизнес компании в данный момент убыточен ещё до уплаты процентов или налогов.\n\nВозможные причины: слабые продажи, высокие производственные затраты, плохой контроль расходов, крупная экспансия, экономический спад или временная реструктуризация.\n\nОдин убыточный квартал сам по себе не обязательно повод для тревоги. Однако стабильно отрицательная операционная маржа заслуживает внимательного изучения.';

  @override
  String get metricInfoOperatingMarginSection9Header =>
      'Почему инвесторы ценят стабильную операционную маржу?';

  @override
  String get metricInfoOperatingMarginSection9Body =>
      'Компания со стабильной или растущей операционной маржой часто демонстрирует: сильный менеджмент, устойчивую ценовую власть, хороший контроль расходов и долгосрочные конкурентные преимущества.\n\nДолгосрочная стабильность зачастую ценнее одного исключительно высокого результата.';

  @override
  String get metricInfoOperatingMarginSection10Header =>
      'Почему компании нужно сравнивать в рамках одной отрасли?';

  @override
  String get metricInfoOperatingMarginSection10Body =>
      'Операционная маржа сильно различается между отраслями. Например, супермаркет может работать с операционной маржой всего 4% и при этом оставаться отличным бизнесом, тогда как для софтверной компании маржа в 4% почти наверняка сигнализировала бы о серьёзных проблемах с прибыльностью.\n\nСравнение в рамках одной отрасли — обязательное условие анализа.';

  @override
  String get metricInfoOperatingMarginSection11Header =>
      'Типичные ошибки новичков';

  @override
  String get metricInfoOperatingMarginSection11Body =>
      '• Путать операционную маржу с чистой маржой.\n• Сравнивать компании из разных отраслей.\n• Игнорировать долгосрочные тренды.\n• Считать один необычно хороший год нормой.\n• Опираться только на один финансовый показатель.';

  @override
  String get metricInfoOperatingMarginSection12Header =>
      'Что стоит анализировать вместе с этим показателем';

  @override
  String get metricInfoOperatingMarginSection12Body =>
      'Операционная маржа даёт гораздо больше информации, если анализировать её вместе с: валовой маржой, чистой маржой, ростом выручки, ROE, свободным денежным потоком, уровнем долга и коэффициентом P/E.\n\nВместе эти показатели дают полную картину качества бизнеса.';

  @override
  String get metricInfoOperatingMarginSection13Header => 'Пример из жизни';

  @override
  String get metricInfoOperatingMarginSection13Body =>
      'Представьте две компании-перевозчика. Обе зарабатывают \$100 млн выручки.\n\nКомпания А тратит на операционную деятельность \$85 млн. Операционная маржа = 15%\n\nКомпания Б тратит всего \$70 млн. Операционная маржа = 30%\n\nЕщё до уплаты налогов и процентов видно, что компания Б ведёт бизнес намного эффективнее. Такая эффективность часто приводит к более сильным результатам в долгосрочной перспективе.';

  @override
  String get metricInfoOperatingMarginSection14Header => 'Главный вывод';

  @override
  String get metricInfoOperatingMarginSection14Body =>
      'Операционная маржа показывает, насколько прибылен основной бизнес компании до уплаты процентов и налогов. Более высокая операционная маржа, как правило, говорит о лучшей операционной эффективности, более строгом контроле расходов и более здоровой бизнес-модели.';

  @override
  String get metricInfoGrossMarginTitle => 'Валовая маржа';

  @override
  String get metricInfoGrossMarginSubtitle =>
      'Прибыль после прямых производственных затрат';

  @override
  String get metricInfoGrossMarginSection1Header => 'Что такое валовая маржа?';

  @override
  String get metricInfoGrossMarginSection1Body =>
      'Валовая маржа показывает, сколько денег компания оставляет себе после оплаты только прямых затрат на производство своих товаров или услуг. Эти прямые затраты называются себестоимостью проданных товаров (COGS).\n\nПроще говоря: валовая маржа показывает, насколько прибыльны продукты компании ещё до оплаты зарплат, маркетинга, аренды, налогов, процентов и прочих операционных расходов. Это один из первых индикаторов ценовой власти компании и эффективности производства.';

  @override
  String get metricInfoGrossMarginSection2Header => 'Как она рассчитывается?';

  @override
  String get metricInfoGrossMarginSection2Body =>
      'Формула\nВаловая маржа = (Выручка − Себестоимость проданных товаров) ÷ Выручка × 100%\n\nПример\nВыручка = \$100 млн\nСебестоимость проданных товаров = \$60 млн\nВаловая прибыль = \$40 млн\nВаловая маржа = 40%\n\nЭто значит, что компания оставляет себе \$40 с каждых \$100 продаж ещё до оплаты каких-либо операционных расходов.';

  @override
  String get metricInfoGrossMarginSection3Header =>
      'Что такое себестоимость проданных товаров (COGS)?';

  @override
  String get metricInfoGrossMarginSection3Body =>
      'COGS включает прямые затраты, необходимые для производства товара или оказания услуги. Примеры: сырьё, производственные затраты, труд рабочих на заводе, упаковка, доставка на склады, а также производственное оборудование, напрямую используемое при изготовлении продукции.\n\nВ COGS не входят: зарплаты офисных сотрудников, реклама, исследования и разработки, налоги, процентные платежи и административные расходы.';

  @override
  String get metricInfoGrossMarginSection4Header => 'О чём она говорит?';

  @override
  String get metricInfoGrossMarginSection4Body =>
      'Валовая маржа отвечает на один простой вопрос: «Насколько прибылен сам продукт?»\n\nВысокая валовая маржа обычно означает, что компания может производить свои товары относительно дёшево по сравнению с ценой продажи.';

  @override
  String get metricInfoGrossMarginSection5Header =>
      'Какая валовая маржа считается хорошей?';

  @override
  String get metricInfoGrossMarginSection5Body =>
      'Ответ зависит от отрасли.\n\nНиже 20% — обычно встречается в отраслях с острой ценовой конкуренцией, например у продуктовых магазинов, оптовых поставщиков продовольствия, дистрибьюторов топлива.\n\n20–40% — нормальный уровень для многих традиционных производителей.\n\n40–60% — высокая прибыльность. Часто встречается у компаний с ценными брендами или премиальными продуктами.\n\nВыше 60% — отлично. Часто встречается у софтверных компаний, люксовых брендов, фармацевтических компаний и технологических бизнесов.\n\nВыше 80% — исключительный результат. Обычно означает, что продукт стоит очень дёшево в производстве, а клиенты готовы платить за него премиальную цену.';

  @override
  String get metricInfoGrossMarginSection6Header =>
      'Почему высокая валовая маржа важна?';

  @override
  String get metricInfoGrossMarginSection6Body =>
      'У компании с высокой валовой маржой остаётся больше денег на: маркетинг, зарплаты сотрудников, исследования и разработки, расширение бизнеса, выплату долгов или дивиденды.\n\nВысокая валовая маржа даёт бизнесу больше гибкости в сложные экономические периоды.';

  @override
  String get metricInfoGrossMarginSection7Header =>
      'Почему низкая валовая маржа не всегда плоха?';

  @override
  String get metricInfoGrossMarginSection7Body =>
      'В некоторых отраслях низкая валовая маржа — это норма. Например, супермаркет может зарабатывать всего 15% валовой маржи, но благодаря тому, что он продаёт миллионы товаров каждый день, он всё равно способен получать значительную прибыль.\n\nВажна бизнес-модель. Всегда сравнивайте компании в рамках одной отрасли.';

  @override
  String get metricInfoGrossMarginSection8Header =>
      'Может ли валовая маржа снижаться?';

  @override
  String get metricInfoGrossMarginSection8Body =>
      'Да. Частые причины: рост цен на материалы, повышение зарплат, увеличение расходов на доставку, инфляция, скидки для клиентов, усиление конкуренции или сбои в цепочках поставок.\n\nСнижение валовой маржи часто сигнализирует о том, что производство дорожает или ослабевает ценовая власть компании.';

  @override
  String get metricInfoGrossMarginSection9Header =>
      'Может ли валовая маржа расти?';

  @override
  String get metricInfoGrossMarginSection9Body =>
      'Безусловно. Возможные причины: повышение цен на продукцию, снижение производственных затрат, более выгодные контракты с поставщиками, повышение эффективности производства, рост доли премиальных продуктов в продажах или эффект масштаба.\n\nРост валовой маржи часто говорит об укреплении бизнеса.';

  @override
  String get metricInfoGrossMarginSection10Header =>
      'Почему инвесторы следят за динамикой валовой маржи?';

  @override
  String get metricInfoGrossMarginSection10Body =>
      'Валовая маржа за один год рассказывает лишь часть истории. Гораздо важнее то, растёт маржа, остаётся стабильной или снижается.\n\nКомпания со стабильно растущей валовой маржой часто становится более конкурентоспособной и эффективной.';

  @override
  String get metricInfoGrossMarginSection11Header => 'Типичные ошибки новичков';

  @override
  String get metricInfoGrossMarginSection11Body =>
      '• Считать, что валовая маржа равна общей прибыли.\n• Сравнивать совершенно разные отрасли.\n• Игнорировать изменения показателя со временем.\n• Опираться только на результаты одного года.\n• Забывать, что операционные расходы всё ещё предстоит оплатить.';

  @override
  String get metricInfoGrossMarginSection12Header =>
      'Чем валовая маржа отличается от операционной и чистой маржи?';

  @override
  String get metricInfoGrossMarginSection12Body =>
      'Представьте прибыльность как три последовательных этапа.\n\nВаловая маржа — насколько прибылен сам продукт?\n\nОперационная маржа — насколько прибылен весь операционный бизнес?\n\nЧистая маржа — сколько прибыли остаётся после того, как оплачено абсолютно всё?\n\nВместе эти три показателя маржи рассказывают полную историю прибыльности компании.';

  @override
  String get metricInfoGrossMarginSection13Header =>
      'Что стоит анализировать вместе с этим показателем';

  @override
  String get metricInfoGrossMarginSection13Body =>
      'Валовая маржа становится гораздо информативнее в сочетании с: операционной маржой, чистой маржой, ростом выручки, ROE, свободным денежным потоком и коэффициентом P/E.\n\nВместе эти показатели помогают инвесторам понять, где компания зарабатывает прибыль — и куда она затем расходуется.';

  @override
  String get metricInfoGrossMarginSection14Header => 'Пример из жизни';

  @override
  String get metricInfoGrossMarginSection14Body =>
      'Представьте, что пекарня продаёт торт за \$100. Ингредиенты стоят \$35.\n\nВаловая прибыль = \$65\nВаловая маржа = 65%\n\nОднако пекарне ещё предстоит заплатить: зарплаты сотрудникам, аренду, электричество, рекламу и налоги. Только после оплаты всех этих расходов становится понятна истинная прибыль бизнеса.\n\nВаловая маржа просто показывает, насколько прибылен сам торт до всех этих дополнительных затрат.';

  @override
  String get metricInfoGrossMarginSection15Header => 'Главный вывод';

  @override
  String get metricInfoGrossMarginSection15Body =>
      'Валовая маржа показывает, сколько денег компания оставляет себе после оплаты прямых затрат на производство товаров или услуг. Более высокая валовая маржа, как правило, говорит о более сильной ценовой власти, более эффективном производстве и большей финансовой гибкости — но её всегда нужно сравнивать с компаниями из той же отрасли.';

  @override
  String get metricInfoRoeTitle => 'ROE';

  @override
  String get metricInfoRoeSubtitle => 'Рентабельность собственного капитала';

  @override
  String get metricInfoRoeSection1Header => 'Что такое ROE?';

  @override
  String get metricInfoRoeSection1Body =>
      'Рентабельность собственного капитала (ROE) показывает, насколько эффективно компания генерирует прибыль, используя деньги, вложенные акционерами.\n\nПроще говоря: ROE показывает, сколько прибыли компания зарабатывает на каждый \$1 собственного капитала. Это один из важнейших индикаторов эффективности менеджмента и качества бизнеса.';

  @override
  String get metricInfoRoeSection2Header => 'Как он рассчитывается?';

  @override
  String get metricInfoRoeSection2Body =>
      'Формула\nROE = Чистая прибыль ÷ Собственный капитал × 100%\n\nПример\nЧистая прибыль = \$20 млн\nСобственный капитал = \$100 млн\nROE = 20%\n\nЭто значит, что компания заработала 20 центов прибыли на каждый \$1, вложенный акционерами.';

  @override
  String get metricInfoRoeSection3Header => 'Что такое собственный капитал?';

  @override
  String get metricInfoRoeSection3Body =>
      'Собственный капитал — это стоимость, которая принадлежит владельцам компании после погашения всех долгов. Он рассчитывается так:\n\nАктивы − Обязательства = Собственный капитал\n\nМожно воспринимать его как чистую стоимость компании. Если бы бизнес продал все свои активы и погасил все долги, то, что осталось бы, принадлежало бы акционерам.';

  @override
  String get metricInfoRoeSection4Header => 'О чём говорит ROE?';

  @override
  String get metricInfoRoeSection4Body =>
      'ROE показывает, насколько эффективно менеджмент использует деньги акционеров. Более высокий ROE, как правило, означает, что компания генерирует больше прибыли без необходимости в крупных дополнительных вложениях.\n\nУ компаний со стабильно высоким ROE часто есть: сильная бизнес-модель, эффективный менеджмент, конкурентные преимущества и высокая прибыльность.';

  @override
  String get metricInfoRoeSection5Header => 'Какой ROE считается хорошим?';

  @override
  String get metricInfoRoeSection5Body =>
      'Ответ зависит от отрасли, но общие ориентиры такие:\n\nНиже 5% — обычно считается слабым результатом. Компания получает относительно немного прибыли на капитал акционеров.\n\n5–10% — приемлемо. Часто встречается у медленно растущих или высококонкурентных бизнесов.\n\n10–15% — хороший уровень. Многие устоявшиеся компании работают именно в этом диапазоне.\n\n15–20% — очень сильный результат. Часто указывает на качественный бизнес.\n\nВыше 20% — отлично. Компании, стабильно удерживающие ROE выше 20%, часто обладают устойчивыми конкурентными преимуществами.\n\nВыше 30% — исключительный результат, но требует более пристального изучения. Иногда очень высокий ROE отражает выдающийся бизнес. А иногда он попросту является следствием очень высокой долговой нагрузки.';

  @override
  String get metricInfoRoeSection6Header =>
      'Почему высокий ROE может вводить в заблуждение?';

  @override
  String get metricInfoRoeSection6Body =>
      'Компания может повышать ROE двумя совершенно разными способами.\n\nХорошая причина — она становится более прибыльной.\n\nРискованная причина — она занимает крупные суммы денег.\n\nПри росте долга собственный капитал сокращается относительно общих активов. Меньшая база капитала может сделать ROE значительно выше — даже если сам бизнес никак не улучшился.\n\nПоэтому ROE всегда нужно анализировать вместе с уровнем долга.';

  @override
  String get metricInfoRoeSection7Header =>
      'Может ли низкий ROE быть приемлемым?';

  @override
  String get metricInfoRoeSection7Body =>
      'Да. Молодые компании часто вкладывают крупные средства в: новые заводы, исследования, расширение или новые продукты. Такие инвестиции увеличивают собственный капитал ещё до того, как начинают приносить значительную прибыль.\n\nВ результате ROE может оставаться низким несколько лет, пока бизнес всё ещё растёт.';

  @override
  String get metricInfoRoeSection8Header => 'Может ли ROE быть отрицательным?';

  @override
  String get metricInfoRoeSection8Body =>
      'Да. Отрицательный ROE означает, что компания зафиксировала чистый убыток. Однако это не обязательно означает, что дела компании плохи.\n\nВозможные причины: временный спад, крупные инвестиции, разовые бухгалтерские убытки, поглощения, реструктуризация или чрезвычайные расходы.\n\nВажный вопрос — ожидается ли восстановление прибыльности.';

  @override
  String get metricInfoRoeSection9Header =>
      'Почему инвесторы ценят стабильный ROE?';

  @override
  String get metricInfoRoeSection9Body =>
      'Один отличный год почти ничего не значит. Компания, которая стабильно показывает ROE в районе 18–21% на протяжении многих лет, демонстрирует устойчивое управление и надёжную бизнес-модель.\n\nПостоянство зачастую ценнее отдельных всплесков.';

  @override
  String get metricInfoRoeSection10Header => 'Типичные ошибки новичков';

  @override
  String get metricInfoRoeSection10Body =>
      '• Смотреть на ROE только за один год.\n• Игнорировать долговую нагрузку.\n• Сравнивать не связанные между собой отрасли.\n• Считать, что любой высокий ROE — признак качества.\n• Игнорировать долгосрочные тренды.';

  @override
  String get metricInfoRoeSection11Header =>
      'Что стоит анализировать вместе с этим показателем';

  @override
  String get metricInfoRoeSection11Body =>
      'ROE даёт гораздо больше информации в сочетании с: соотношением долга к капиталу, чистой маржой, операционной маржой, валовой маржой, свободным денежным потоком, ростом выручки и коэффициентом P/E.\n\nЭти показатели помогают понять, устойчива ли высокая прибыльность.';

  @override
  String get metricInfoRoeSection12Header => 'Пример из жизни';

  @override
  String get metricInfoRoeSection12Body =>
      'Представьте двух владельцев бизнеса. Оба вложили в свои компании по \$100 000.\n\nВладелец А зарабатывает \$8 000 в год. ROE = 8%\n\nВладелец Б зарабатывает \$25 000. ROE = 25%\n\nВладелец Б использует ту же сумму вложенного капитала намного эффективнее. Именно это и измеряет ROE.';

  @override
  String get metricInfoRoeSection13Header =>
      'Почему долгосрочные инвесторы внимательно следят за ROE';

  @override
  String get metricInfoRoeSection13Body =>
      'Многие успешные долгосрочные инвесторы отдают предпочтение компаниям, которые годами стабильно показывают высокий ROE.\n\nПочему? Потому что стабильно высокий ROE может говорить о: сильном менеджменте, устойчивых конкурентных преимуществах, эффективном использовании капитала и способности бизнеса создавать долгосрочную ценность для акционеров.\n\nТем не менее высокий ROE всегда нужно проверять на разумность долговой нагрузки — см. ниже.';

  @override
  String get metricInfoRoeSection14Header => 'Главный вывод';

  @override
  String get metricInfoRoeSection14Body =>
      'ROE показывает, насколько эффективно компания превращает деньги акционеров в прибыль. Стабильно высокий ROE часто сигнализирует о качественном бизнесе, но инвесторам всегда стоит проверять, обеспечен ли этот результат реальной прибыльностью или чрезмерной долговой нагрузкой.';

  @override
  String get metricInfoValuationTitle => 'Оценка';

  @override
  String get metricInfoValuationSubtitle =>
      'Насколько справедливо рынок оценивает компанию';

  @override
  String get metricInfoValuationSection1Header => 'Что такое оценка?';

  @override
  String get metricInfoValuationSection1Body =>
      'Оценка показывает, насколько справедливо рынок оценивает компанию — исходя из её финансовых показателей и в сравнении с другими компаниями той же отрасли.\n\nПроще говоря: этот показатель помогает понять, не переплачивают ли инвесторы за акции компании — или, наоборот, не платят ли слишком мало.\n\nОднако дорогая акция не всегда является плохой инвестицией, а дешёвая — не всегда хорошей.';

  @override
  String get metricInfoValuationSection2Header => 'Почему оценка важна?';

  @override
  String get metricInfoValuationSection2Body =>
      'Покупая акции, инвестор приобретает не только текущий бизнес компании — он также покупает ожидания относительно её будущего.\n\nИногда эти ожидания становятся чрезмерно оптимистичными, и цена акций растёт намного быстрее, чем реальные результаты компании.\n\nВ других случаях рынок становится излишне пессимистичным, и качественные компании торгуются ниже того уровня, который многие инвесторы считают их справедливой стоимостью.\n\nОценка помогает инвесторам понять, выглядит ли текущая цена разумной.';

  @override
  String get metricInfoValuationSection3Header => 'Что означает высокий балл?';

  @override
  String get metricInfoValuationSection3Body =>
      'Высокий балл по оценке говорит о том, что текущая рыночная цена компании выглядит разумной относительно её финансовых показателей и в сравнении со схожими компаниями.\n\nЭто не гарантирует роста акций, но, как правило, указывает на более низкий риск переплаты.';

  @override
  String get metricInfoValuationSection4Header => 'Что означает низкий балл?';

  @override
  String get metricInfoValuationSection4Body =>
      'Низкий балл по оценке может говорить о том, что инвесторы платят за акции компании с премией.\n\nЭто повышает риск того, что будущие ожидания уже заложены в цену акций.\n\nЕсли компания не оправдает эти ожидания, акции могут упасть в цене — даже если сам бизнес останется здоровым.';

  @override
  String get metricInfoValuationSection5Header =>
      'Почему низкий балл не всегда плохо?';

  @override
  String get metricInfoValuationSection5Body =>
      'Некоторые компании годами торгуются с премией к средней оценке, потому что обладают:\n\n• сильными конкурентными преимуществами\n• быстрым ростом прибыли\n• лидирующими позициями на рынке\n• инновационными продуктами\n• высоким доверием инвесторов\n\nВ таких случаях более высокая оценка может быть полностью оправданной.';

  @override
  String get metricInfoValuationSection6Header =>
      'Почему высокий балл — не гарантия?';

  @override
  String get metricInfoValuationSection6Body =>
      'Даже если оценка компании выглядит привлекательной, это не гарантирует роста цены её акций.\n\nИногда рынок уже учитывает риски, которые ещё не полностью отражены в финансовой отчётности.\n\nПоэтому оценку всегда стоит рассматривать вместе с финансовой устойчивостью, прибыльностью и потенциалом роста компании.';

  @override
  String get metricInfoValuationSection7Header =>
      'На что стоит обратить внимание инвесторам?';

  @override
  String get metricInfoValuationSection7Body =>
      'Оценка помогает определить риск переплаты, но не измеряет общее качество бизнеса.\n\nКомпанию всегда стоит анализировать по нескольким финансовым показателям, а не полагаться только на оценку.';

  @override
  String get metricInfoValuationSection8Header => 'Главный вывод';

  @override
  String get metricInfoValuationSection8Body =>
      'Оценка помогает понять, насколько справедлива текущая рыночная цена компании относительно её финансовых показателей. Это ценный инструмент для выявления риска переплаты, но его никогда не стоит использовать как единственный фактор при оценке инвестиции.';

  @override
  String get metricInfoFinancialHealthTitle => 'Финансовое здоровье';

  @override
  String get metricInfoFinancialHealthSubtitle =>
      'Устойчивость и способность управлять долгом';

  @override
  String get metricInfoFinancialHealthSection1Header =>
      'Что такое финансовое здоровье?';

  @override
  String get metricInfoFinancialHealthSection1Body =>
      'Финансовое здоровье отражает общую финансовую устойчивость компании и её способность управлять долгом и долгосрочными обязательствами.\n\nПроще говоря: этот показатель помогает понять, стоит ли за компанией прочный финансовый фундамент или в будущем её могут ждать повышенные финансовые риски.\n\nФинансово здоровая компания, как правило, лучше подготовлена к экономическим спадам, способна инвестировать в будущий рост и легче адаптируется к изменениям рыночных условий.';

  @override
  String get metricInfoFinancialHealthSection2Header =>
      'Почему финансовое здоровье важно?';

  @override
  String get metricInfoFinancialHealthSection2Body =>
      'Любому бизнесу нужны деньги, чтобы работать и расти.\n\nОдни компании полагаются в основном на собственные средства, другие — сильно зависят от заёмных.\n\nДолг сам по себе не является чем-то плохим — он может помочь бизнесу расшириться, построить новые мощности или приобрести конкурентов. Однако чрезмерная долговая нагрузка способна стать серьёзным бременем, особенно в периоды замедления роста или высоких процентных ставок.\n\nФинансовое здоровье помогает инвесторам понять, насколько устойчивой может оказаться компания в разных экономических условиях.';

  @override
  String get metricInfoFinancialHealthSection3Header =>
      'Что означает высокий балл?';

  @override
  String get metricInfoFinancialHealthSection3Body =>
      'Высокий балл по финансовому здоровью говорит о том, что компания выглядит финансово стабильной и ответственно управляет своими обязательствами.\n\nКомпании с крепким финансовым здоровьем, как правило, лучше способны:\n\n• инвестировать в будущий рост\n• справляться с неожиданными трудностями\n• продолжать работу во время экономических спадов\n• сохранять финансовую гибкость\n\nНи одна компания не застрахована от рисков полностью, но более крепкое финансовое положение часто обеспечивает большую устойчивость в долгосрочной перспективе.';

  @override
  String get metricInfoFinancialHealthSection4Header =>
      'Что означает низкий балл?';

  @override
  String get metricInfoFinancialHealthSection4Body =>
      'Низкий балл по финансовому здоровью может говорить о том, что компания несёт повышенный финансовый риск.\n\nЭто может снизить её гибкость и сделать более уязвимой в сложные экономические периоды.\n\nКомпании со слабым финансовым здоровьем могут сталкиваться с такими трудностями, как:\n\n• более высокая стоимость заимствований\n• сниженная способность инвестировать\n• повышенное давление во время рецессий\n• повышенная чувствительность к росту процентных ставок\n\nНизкий балл не обязательно означает, что у компании проблемы, но он заслуживает более пристального внимания.';

  @override
  String get metricInfoFinancialHealthSection5Header =>
      'Почему низкий балл не всегда плохо?';

  @override
  String get metricInfoFinancialHealthSection5Body =>
      'Некоторые отрасли по своей природе связаны с более высоким уровнем долга.\n\nНапример:\n\n• коммунальные предприятия\n• телекоммуникации\n• недвижимость\n• инфраструктурные компании\n\nТакие компании часто генерируют стабильные денежные потоки, которые позволяют им безопасно управлять более высокой долговой нагрузкой.\n\nПоэтому финансовое здоровье всегда стоит рассматривать в контексте отрасли и бизнес-модели компании.';

  @override
  String get metricInfoFinancialHealthSection6Header =>
      'Почему высокий балл — не гарантия?';

  @override
  String get metricInfoFinancialHealthSection6Body =>
      'Даже финансово крепкие компании могут столкнуться с неожиданными трудностями.\n\nПотрясения на рынке, изменение потребительского спроса, неудачные управленческие решения или глобальные экономические события способны затронуть любой бизнес.\n\nФинансовое здоровье снижает риск, но не устраняет его полностью.';

  @override
  String get metricInfoFinancialHealthSection7Header =>
      'На что стоит обратить внимание инвесторам?';

  @override
  String get metricInfoFinancialHealthSection7Body =>
      'Финансовое здоровье отражает способность компании сохранять устойчивость с течением времени, но это лишь часть общей картины.\n\nКомпанию также стоит оценивать с точки зрения прибыльности, оценки стоимости, потенциала роста и операционной эффективности.\n\nРассмотрение всех этих факторов вместе даёт гораздо более сбалансированную картину.';

  @override
  String get metricInfoFinancialHealthSection8Header => 'Главный вывод';

  @override
  String get metricInfoFinancialHealthSection8Body =>
      'Финансовое здоровье отражает общую финансовую силу и устойчивость компании. Компании с более прочным финансовым фундаментом, как правило, лучше справляются с неопределённостью, способны поддерживать будущий рост и выдерживать экономические трудности, но ни один отдельный показатель не стоит рассматривать в изоляции.';

  @override
  String get metricInfoGrowthPotentialTitle => 'Потенциал роста';

  @override
  String get metricInfoGrowthPotentialSubtitle =>
      'Насколько стабильно рос бизнес';

  @override
  String get metricInfoGrowthPotentialSection1Header =>
      'Что такое потенциал роста?';

  @override
  String get metricInfoGrowthPotentialSection1Body =>
      'Потенциал роста отражает, насколько стабильно компания расширяла свой бизнес с течением времени, увеличивая выручку и прибыль.\n\nПроще говоря: этот показатель помогает понять, растёт ли компания, топчется на месте или постепенно теряет темп.\n\nУ растущих компаний, как правило, больше возможностей увеличить свою стоимость в долгосрочной перспективе, хотя рост никогда не гарантирован.';

  @override
  String get metricInfoGrowthPotentialSection2Header =>
      'Почему потенциал роста важен?';

  @override
  String get metricInfoGrowthPotentialSection2Body =>
      'Успешная компания должна быть не просто прибыльной сегодня — у неё также должна быть возможность расти в будущем.\n\nРост бизнеса может обеспечиваться за счёт:\n\n• увеличения продаж продукции\n• выхода на новые рынки\n• запуска новых услуг\n• увеличения доли рынка\n• повышения операционной эффективности\n\nСтабильный рост часто отражает сильный спрос, эффективное управление и здоровую бизнес-стратегию.';

  @override
  String get metricInfoGrowthPotentialSection3Header =>
      'Что означает высокий балл?';

  @override
  String get metricInfoGrowthPotentialSection3Body =>
      'Высокий балл по потенциалу роста говорит о том, что компания демонстрировала устойчивый и стабильный рост бизнеса с течением времени.\n\nКомпании с более высоким потенциалом роста, как правило, лучше способны:\n\n• увеличивать прибыль в будущем\n• расширять деятельность\n• укреплять конкурентные позиции\n• создавать долгосрочную ценность для акционеров\n\nСтабильный рост обычно рассматривается как позитивный признак качества бизнеса.';

  @override
  String get metricInfoGrowthPotentialSection4Header =>
      'Что означает низкий балл?';

  @override
  String get metricInfoGrowthPotentialSection4Body =>
      'Низкий балл по потенциалу роста может говорить о том, что расширение бизнеса замедлилось или стало нестабильным.\n\nВозможные причины:\n\n• снижение потребительского спроса\n• усиление конкуренции\n• насыщение рынка\n• экономические трудности\n• проблемы, специфичные для конкретной компании\n\nНизкий балл не обязательно означает, что бизнес слаб, но может указывать на меньше возможностей для роста в ближайшем будущем.';

  @override
  String get metricInfoGrowthPotentialSection5Header =>
      'Почему низкий балл не всегда плохо?';

  @override
  String get metricInfoGrowthPotentialSection5Body =>
      'Не каждой успешной компании нужно стремительно расти.\n\nМногие зрелые компании делают ставку на:\n\n• стабильную прибыль\n• надёжные дивиденды\n• сильный денежный поток\n• долгосрочную стабильность\n\nТакие компании способны обеспечивать привлекательную долгосрочную доходность даже без быстрого расширения.';

  @override
  String get metricInfoGrowthPotentialSection6Header =>
      'Почему высокий балл — не гарантия?';

  @override
  String get metricInfoGrowthPotentialSection6Body =>
      'Быстрый рост часто сопровождается завышенными ожиданиями.\n\nЕсли в будущем рост замедлится, инвесторы могут отреагировать негативно, даже если компания продолжает работать хорошо.\n\nПоддерживать рост также становится сложнее по мере того, как компания увеличивается и укрепляет позиции на рынке.\n\nПоэтому устойчивый рост, как правило, ценится выше, чем короткие периоды исключительных результатов.';

  @override
  String get metricInfoGrowthPotentialSection7Header =>
      'На что стоит обратить внимание инвесторам?';

  @override
  String get metricInfoGrowthPotentialSection7Body =>
      'Рост всегда стоит оценивать вместе с прибыльностью и финансовой устойчивостью.\n\nКомпания, которая быстро растёт и при этом стабильно получает здоровую прибыль, обычно находится в более сильном положении, чем та, что растёт быстро, но испытывает финансовые трудности.\n\nДолгосрочная стабильность обычно важнее краткосрочного ускорения.';

  @override
  String get metricInfoGrowthPotentialSection8Header => 'Главный вывод';

  @override
  String get metricInfoGrowthPotentialSection8Body =>
      'Потенциал роста показывает, насколько стабильно компания расширяла бизнес с течением времени. Устойчивый и стабильный рост способен создавать долгосрочные возможности, но его всегда стоит рассматривать вместе с прибыльностью, финансовым здоровьем и общим качеством бизнеса.';

  @override
  String get metricInfoEfficiencyTitle => 'Эффективность';

  @override
  String get metricInfoEfficiencySubtitle =>
      'Насколько эффективно выручка превращается в прибыль';

  @override
  String get metricInfoEfficiencySection1Header => 'Что такое прибыльность?';

  @override
  String get metricInfoEfficiencySection1Body =>
      'Прибыльность показывает, насколько эффективно компания превращает выручку в прибыль.\n\nПроще говоря: этот показатель помогает понять, эффективно ли компания зарабатывает деньги — или просто генерирует большие продажи при небольшой прибыли.\n\nПрибыльная компания, как правило, лучше подготовлена к тому, чтобы инвестировать в рост, вознаграждать акционеров и справляться со сложными экономическими условиями.';

  @override
  String get metricInfoEfficiencySection2Header => 'Почему прибыльность важна?';

  @override
  String get metricInfoEfficiencySection2Body =>
      'Одна лишь выручка не даёт полной картины.\n\nКомпания может генерировать продажи на миллиарды долларов, но оставлять себе в качестве прибыли лишь небольшую часть.\n\nДругая компания может иметь меньшую выручку, но работать намного эффективнее, обеспечивая более сильную и стабильную прибыль.\n\nПрибыльность помогает инвесторам понять качество бизнес-модели компании.';

  @override
  String get metricInfoEfficiencySection3Header => 'Что означает высокий балл?';

  @override
  String get metricInfoEfficiencySection3Body =>
      'Высокий балл по прибыльности говорит о том, что компания стабильно превращает существенную часть выручки в прибыль.\n\nКомпании с высокой прибыльностью, как правило, лучше способны:\n\n• инвестировать в будущий рост\n• расширять деятельность\n• выплачивать дивиденды\n• выкупать собственные акции\n• создавать финансовые резервы\n• выдерживать экономические спады\n\nСтабильно прибыльные компании часто демонстрируют эффективное управление и сильные конкурентные преимущества.';

  @override
  String get metricInfoEfficiencySection4Header => 'Что означает низкий балл?';

  @override
  String get metricInfoEfficiencySection4Body =>
      'Низкий балл по прибыльности может говорить о том, что компании сложно получать здоровую прибыль.\n\nВозможные причины:\n\n• рост операционных издержек\n• жёсткая конкуренция\n• слабая ценовая власть\n• снижение спроса\n• неэффективное управление затратами\n• временные трудности в бизнесе\n\nНизкая прибыльность может снижать способность компании расти или реагировать на неожиданное финансовое давление.';

  @override
  String get metricInfoEfficiencySection5Header =>
      'Почему низкий балл не всегда плохо?';

  @override
  String get metricInfoEfficiencySection5Body =>
      'Некоторые виды бизнеса по своей природе работают с низкой рентабельностью.\n\nНапример:\n\n• супермаркеты\n• авиакомпании\n• оптовые дистрибьюторы\n• крупные розничные сети\n\nТакие отрасли часто делают ставку на очень большие объёмы продаж, а не на высокую прибыль с каждой продажи.\n\nНизкий балл по прибыльности всегда стоит оценивать в контексте отрасли компании.';

  @override
  String get metricInfoEfficiencySection6Header =>
      'Почему высокий балл — не гарантия?';

  @override
  String get metricInfoEfficiencySection6Body =>
      'Высокая прибыльность сегодня не гарантирует высокую прибыльность завтра.\n\nИзменение рыночных условий, усиление конкуренции, рост издержек или замедление экономики — всё это способно снизить будущую прибыль.\n\nИнвесторам стоит искать компании, которые демонстрировали стабильную прибыльность на протяжении многих лет, а не полагаться на один удачный отчётный период.';

  @override
  String get metricInfoEfficiencySection7Header =>
      'На что стоит обратить внимание инвесторам?';

  @override
  String get metricInfoEfficiencySection7Body =>
      'Прибыльность — один из самых сильных индикаторов качества бизнеса, но её никогда не стоит рассматривать изолированно.\n\nПолноценная оценка должна также учитывать:\n\n• финансовое здоровье\n• потенциал роста\n• оценку стоимости\n• операционную эффективность\n\nРассмотрение этих факторов вместе даёт гораздо более чёткое понимание долгосрочных перспектив компании.';

  @override
  String get metricInfoEfficiencySection8Header => 'Главный вывод';

  @override
  String get metricInfoEfficiencySection8Body =>
      'Прибыльность показывает, насколько эффективно компания превращает выручку в прибыль. Компании с высокой и стабильной прибыльностью, как правило, лучше подготовлены к росту, инвестициям и преодолению экономических трудностей, но прибыльность всегда стоит оценивать вместе с другими аспектами финансовых показателей.';

  @override
  String get metricInfoHistoricalTrendTitle => 'Историческая динамика';

  @override
  String get metricInfoHistoricalTrendSubtitle =>
      'Как рынок вознаграждал компанию с течением времени';

  @override
  String get metricInfoHistoricalTrendSection1Header =>
      'Что такое доверие рынка?';

  @override
  String get metricInfoHistoricalTrendSection1Body =>
      'Доверие рынка отражает, как инвесторы сейчас воспринимают компанию — исходя из её общих результатов, устойчивости и перспектив на будущее.\n\nПроще говоря: этот показатель помогает понять, доверяет ли рынок будущему компании или становится более осторожным.\n\nДоверие инвесторов может сильно влиять на цену акций, особенно в краткосрочной и среднесрочной перспективе.';

  @override
  String get metricInfoHistoricalTrendSection2Header =>
      'Почему доверие рынка важно?';

  @override
  String get metricInfoHistoricalTrendSection2Body =>
      'Фондовым рынком движут не только факты, но и ожидания.\n\nКомпания может отчитаться об отличных финансовых результатах, но если инвесторы ожидали ещё большего, цена акций всё равно может упасть.\n\nАналогично, акции компании со средними результатами могут вырасти, если инвесторы верят, что её будущее улучшается.\n\nДоверие рынка помогает инвесторам понять, как рынок сейчас воспринимает бизнес компании.';

  @override
  String get metricInfoHistoricalTrendSection3Header =>
      'Что означает высокий балл?';

  @override
  String get metricInfoHistoricalTrendSection3Body =>
      'Высокий балл по доверию рынка говорит о том, что инвесторы в целом позитивно оценивают будущее компании.\n\nКомпании с высоким доверием рынка часто выигрывают от:\n\n• позитивных настроений инвесторов\n• стабильных долгосрочных ожиданий\n• сильной репутации\n• доверия к руководству\n• оптимизма относительно будущего роста\n\nБолее высокое доверие может облегчить компании привлечение капитала и долгосрочных инвесторов.';

  @override
  String get metricInfoHistoricalTrendSection4Header =>
      'Что означает низкий балл?';

  @override
  String get metricInfoHistoricalTrendSection4Body =>
      'Низкий балл по доверию рынка может говорить о том, что инвесторы становятся более осторожными.\n\nВозможные причины:\n\n• замедление роста бизнеса\n• слабые финансовые результаты\n• усиление конкуренции\n• неопределённость в отрасли\n• экономические опасения\n• трудности, специфичные для конкретной компании\n\nСнижение доверия не обязательно означает, что компания работает плохо, но часто сигнализирует о росте неопределённости.';

  @override
  String get metricInfoHistoricalTrendSection5Header =>
      'Почему низкий балл не всегда плохо?';

  @override
  String get metricInfoHistoricalTrendSection5Body =>
      'Настроения инвесторов могут меняться быстро.\n\nИногда рынок эмоционально реагирует на краткосрочные новости, временные неудачи или более широкие экономические условия.\n\nДаже сильные компании порой переживают периоды сниженного доверия, прежде чем восстановиться на фоне улучшения условий бизнеса.\n\nДля долгосрочных инвесторов временный пессимизм может даже создавать привлекательные возможности.';

  @override
  String get metricInfoHistoricalTrendSection6Header =>
      'Почему высокий балл — не гарантия?';

  @override
  String get metricInfoHistoricalTrendSection6Body =>
      'Высокое доверие инвесторов иногда может становиться избыточным.\n\nКогда ожидания становятся нереалистично оптимистичными, цена акций может расти намного быстрее, чем сам бизнес.\n\nЕсли будущие результаты не оправдают этих ожиданий, доверие инвесторов может быстро упасть, что приведёт к росту волатильности цены.\n\nДоверие всегда должно опираться на крепкие фундаментальные показатели бизнеса.';

  @override
  String get metricInfoHistoricalTrendSection7Header =>
      'На что стоит обратить внимание инвесторам?';

  @override
  String get metricInfoHistoricalTrendSection7Body =>
      'Доверие рынка отражает текущее отношение инвесторов к компании, но рыночные настроения могут меняться намного быстрее, чем сам бизнес.\n\nДля взвешенного инвестиционного решения доверие рынка всегда стоит рассматривать вместе с:\n\n• оценкой стоимости\n• финансовым здоровьем\n• потенциалом роста\n• прибыльностью\n• операционной эффективностью\n\nСильные компании строятся на прочных фундаментальных показателях, а не только на рыночном оптимизме.';

  @override
  String get metricInfoHistoricalTrendSection8Header => 'Главный вывод';

  @override
  String get metricInfoHistoricalTrendSection8Body =>
      'Доверие рынка отражает, как инвесторы сейчас оценивают будущее компании. Позитивные настроения способны поддерживать динамику акций, а снижение доверия может усиливать неопределённость. Однако настроения инвесторов всегда стоит оценивать вместе с реальной финансовой силой компании и долгосрочным качеством её бизнеса.';

  @override
  String get metricInfoCapitalReturnTitle => 'Доходность для акционеров';

  @override
  String get metricInfoCapitalReturnSubtitle =>
      'Дивиденды и обратный выкуп акций';

  @override
  String get metricInfoCapitalReturnSection1Header =>
      'Что такое доходность для акционеров?';

  @override
  String get metricInfoCapitalReturnSection1Body =>
      'Доходность для акционеров показывает, как компания вознаграждает своих акционеров, возвращая им стоимость через дивиденды и обратный выкуп акций.\n\nПроще говоря: этот показатель помогает понять, насколько эффективно компания делится своим финансовым успехом с инвесторами.\n\nНекоторые компании вознаграждают акционеров регулярными дивидендами, другие предпочитают выкупать собственные акции. Многие успешные компании сочетают оба подхода.';

  @override
  String get metricInfoCapitalReturnSection2Header =>
      'Почему доходность для акционеров важна?';

  @override
  String get metricInfoCapitalReturnSection2Body =>
      'Когда компания получает прибыль, руководству нужно решить, как распорядиться этими деньгами.\n\nОсновные варианты:\n\n• инвестировать в будущий рост\n• сократить долг\n• создать денежные резервы\n• выплатить дивиденды\n• выкупить собственные акции\n\nВозврат капитала акционерам может демонстрировать финансовую силу компании и уверенность в её будущем.';

  @override
  String get metricInfoCapitalReturnSection3Header =>
      'Что означает высокий балл?';

  @override
  String get metricInfoCapitalReturnSection3Body =>
      'Высокий балл по доходности для акционеров говорит о том, что компания придерживается последовательного и дружественного по отношению к акционерам подхода к возврату стоимости.\n\nЭто может включать:\n\n• надёжные дивидендные выплаты\n• устойчивый рост дивидендов\n• продуманные программы обратного выкупа акций\n• сбалансированную стратегию распределения капитала\n\nКомпании с сильной политикой возврата капитала акционерам часто ориентированы на создание долгосрочной ценности, а не на краткосрочные результаты.';

  @override
  String get metricInfoCapitalReturnSection4Header =>
      'Что означает низкий балл?';

  @override
  String get metricInfoCapitalReturnSection4Body =>
      'Низкий балл по доходности для акционеров не обязательно указывает на низкое качество бизнеса.\n\nВозможные причины:\n\n• реинвестирование прибыли в будущий рост\n• расширение деятельности\n• разработка новых продуктов\n• приобретение других компаний\n• укрепление баланса\n\nМногие успешные компании предпочитают реинвестировать прибыль, а не возвращать деньги напрямую акционерам.';

  @override
  String get metricInfoCapitalReturnSection5Header =>
      'Почему низкий балл не всегда плохо?';

  @override
  String get metricInfoCapitalReturnSection5Body =>
      'Быстрорастущие компании часто обеспечивают более высокую долгосрочную доходность, инвестируя в собственный бизнес, а не выплачивая дивиденды или выкупая акции.\n\nЕсли эти инвестиции приводят к росту будущей прибыли, акционеры могут выигрывать за счёт долгосрочного роста цены акций вместо немедленных денежных выплат.\n\nОриентированные на рост компании часто придерживаются такой стратегии в годы активного расширения.';

  @override
  String get metricInfoCapitalReturnSection6Header =>
      'Почему высокий балл — не гарантия?';

  @override
  String get metricInfoCapitalReturnSection6Body =>
      'Возврат денежных средств акционерам, как правило, является позитивным сигналом — но только если он финансово устойчив.\n\nНапример:\n\n• компания может выплачивать необычно высокие дивиденды, которые невозможно поддерживать в дальнейшем;\n• компания может выкупать акции, одновременно наращивая чрезмерный долг.\n\nВозврат капитала акционерам никогда не должен ослаблять долгосрочную финансовую устойчивость компании.\n\nЗдоровая доходность для акционеров должна опираться на сильную прибыль, денежный поток и прочное финансовое положение.';

  @override
  String get metricInfoCapitalReturnSection7Header =>
      'На что стоит обратить внимание инвесторам?';

  @override
  String get metricInfoCapitalReturnSection7Body =>
      'Доходность для акционеров стоит рассматривать как часть общей стратегии распределения капитала компании.\n\nКомпания, которая балансирует между:\n\n• инвестициями в бизнес\n• финансовой устойчивостью\n• устойчивыми дивидендами\n• ответственным обратным выкупом акций\n\nчаще всего создаёт больше долгосрочной ценности для своих акционеров.\n\nЕдиного «лучшего» подхода не существует. Правильная стратегия зависит от стадии роста компании, отрасли и долгосрочных целей.';

  @override
  String get metricInfoCapitalReturnSection8Header => 'Главный вывод';

  @override
  String get metricInfoCapitalReturnSection8Body =>
      'Доходность для акционеров показывает, как компания вознаграждает инвесторов через дивиденды и обратный выкуп акций. Высокая доходность для акционеров часто отражает дисциплинированное финансовое управление, но она всегда должна опираться на здоровую прибыль, устойчивый денежный поток и прочный финансовый фундамент.';

  @override
  String get metricInfoFsScoreLegalTitle => 'Юридическое уведомление';

  @override
  String get metricInfoFsScoreLegalSubtitle =>
      'Финансовые оценки и рыночные данные';

  @override
  String get metricInfoFsScoreLegalSection1Body =>
      'Финансовые оценочные показатели (включая FS Score), отображаемые в данном приложении, рассчитываются автоматически с помощью математических алгоритмов на основе общедоступных рыночных данных и корпоративной финансовой отчётности (в частности, отчётов 10-K, 10-Q, поданных в SEC).\n\nДанные показатели являются исключительно результатом аналитических расчётов, предназначенным для образовательных целей и симуляции рыночных исследований. Они не являются инвестиционной рекомендацией, финансовым советом, кредитным рейтингом или одобрением какой-либо ценной бумаги либо организации.\n\nНи приложение, ни его разработчики не гарантируют точность, полноту или своевременность используемых данных либо рассчитываемых показателей. Пользователь несёт полную ответственность за любые торговые или инвестиционные решения, принятые самостоятельно за пределами данного образовательного симулятора.';

  @override
  String get metricInfoPortfolioHealthTitle => 'Здоровье портфеля';

  @override
  String get metricInfoPortfolioHealthSubtitle =>
      'Комплексная оценка качества портфеля';

  @override
  String get metricInfoPortfolioHealthSection1Body =>
      '«Здоровье портфеля» — это комплексная оценка структуры вашего портфеля и качества инвестиций. Вместо того чтобы изучать множество отдельных показателей по отдельности, этот виджет объединяет несколько важных индикаторов в единую сводку, которая помогает понять, следует ли ваш портфель здоровым принципам инвестирования.\n\nСильный портфель определяется не только прибылью или убытком. Даже портфель, который сейчас приносит доход, может скрывать слабые места — например, слишком крупную долю денег, вложенную в одну компанию, или чрезмерную концентрацию инвестиций в одной отрасли. Эти риски могут быть незаметны на растущем рынке, но становятся гораздо заметнее, когда рыночная ситуация меняется.\n\nВиджет «Здоровье портфеля» анализирует различные аспекты вашего портфеля, включая диверсификацию, концентрацию, отраслевой баланс и общую устойчивость. Каждый индикатор вносит вклад в итоговую картину и помогает выявить области, которые могут нуждаться в улучшении.\n\nБолее высокая оценка обычно означает, что ваши инвестиции распределены более эффективно, что снижает лишний риск и делает портфель более устойчивым к неожиданным рыночным событиям. Более низкая оценка не обязательно означает, что ваш портфель плох, но может указывать на то, что некоторые корректировки способны улучшить его баланс и снизить подверженность рискам, которых можно было бы избежать.\n\nЭтот виджет призван помочь инвесторам сосредоточиться на постепенном формировании более здорового портфеля, а не на реакции на краткосрочные движения рынка.';

  @override
  String get metricInfoAssetAllocationPctTitle => 'Распределение активов, %';

  @override
  String get metricInfoAssetAllocationPctSubtitle =>
      'Как распределён ваш капитал';

  @override
  String get metricInfoAssetAllocationPctSection1Body =>
      '«Распределение активов» показывает, как именно ваш инвестиционный капитал распределён между отдельными компаниями, которыми вы владеете.\n\nКаждый отображаемый процент показывает долю вашего общего портфеля, вложенную в конкретную компанию. По мере изменения цен акций эти проценты также меняются автоматически. Компания, которая показывает очень хорошие результаты, может постепенно занять гораздо большую долю вашего портфеля, даже если вы ни разу не докупали её акции.\n\nОтслеживать распределение активов важно, потому что чрезмерная концентрация повышает риск. Если одна компания составляет значительную долю ваших инвестиций, успех или неудача этого отдельного бизнеса будет намного сильнее влиять на весь ваш портфель.\n\nСбалансированное распределение помогает снизить зависимость от какой-либо отдельной компании. Идеального распределения, подходящего каждому инвестору, не существует, но избегание чрезмерно крупных позиций помогает со временем создать более устойчивый инвестиционный портфель.\n\nЭтот виджет позволяет быстро определить ваши крупнейшие позиции, отслеживать, как развивается портфель, и решить, соответствует ли текущее распределение вашим инвестиционным целям.';

  @override
  String get metricInfoDiversificationIndicatorTitle =>
      'Индикатор диверсификации';

  @override
  String get metricInfoDiversificationIndicatorSubtitle =>
      'Отраслевой баланс ваших вложений';

  @override
  String get metricInfoDiversificationIndicatorSection1Body =>
      '«Индикатор диверсификации» измеряет, как ваши инвестиции распределены по разным секторам экономики.\n\nКаждая компания относится к определённой отрасли или сектору экономики — например, технологиям, здравоохранению, финансовым услугам, потребительским товарам, энергетике, промышленности, коммунальным услугам или недвижимости. Разные секторы часто ведут себя по-разному в зависимости от экономической ситуации, процентных ставок, потребительского спроса или глобальных событий.\n\nЕсли большая часть ваших денег вложена только в один сектор, ваш портфель становится более уязвимым к проблемам, затрагивающим эту отрасль. Например, спад технологических компаний может оказать серьёзное влияние, если ваш портфель состоит преимущественно из акций технологического сектора.\n\nПортфель, распределённый между несколькими секторами, может снизить этот вид риска, поскольку разные отрасли способны вести себя по-разному в один и тот же период. Пока один сектор переживает трудности, другой может оставаться стабильным или продолжать расти.\n\nЭтот виджет помогает понять, из каких секторов состоит ваш портфель, выявить области, которые могут быть перепредставлены, и обнаружить секторы, которых сейчас не хватает. Постепенное наращивание отраслевой диверсификации может улучшить общий баланс ваших инвестиций без необходимости владеть очень большим числом компаний.';

  @override
  String get metricInfoDiversificationProgressTitle =>
      'Прогресс диверсификации';

  @override
  String get metricInfoDiversificationProgressSubtitle =>
      'Постепенное расширение портфеля';

  @override
  String get metricInfoDiversificationProgressSection1Body =>
      '«Прогресс диверсификации» отслеживает рост вашего портфеля, измеряя количество разных компаний, которыми вы владеете.\n\nДля многих долгосрочных инвесторов диверсификация формируется постепенно, на протяжении месяцев или даже лет. Каждая новая инвестиция способна увеличить разнообразие компаний, представленных в портфеле, и снизить зависимость от какой-либо одной из них.\n\nВладение лишь несколькими компаниями означает, что каждая инвестиция сильнее влияет на результат всего портфеля. По мере роста числа позиций влияние слабых результатов одной компании обычно уменьшается, что создаёт более сбалансированную структуру инвестиций.\n\nОднако диверсификация — это не просто покупка как можно большего числа компаний. Портфель со множеством компаний из одной и той же отрасли всё равно может быть плохо диверсифицирован. Настоящая диверсификация сочетает в себе как количество компаний, так и разнообразие секторов, которые они представляют.\n\nЭтот виджет позволяет отслеживать ваш прогресс в формировании более широкого портфеля. Наблюдение за тем, как это число растёт со временем, может способствовать дисциплинированному инвестированию и напоминать, что диверсификация — это постепенный процесс, а не то, что достигается за один день.\n\nПо мере роста вашего портфеля этот виджет даёт простое визуальное представление о том, как далеко вы продвинулись на пути к долгосрочной диверсификации.';

  @override
  String get metricInfoPsychologyDisciplineTitle => 'Дисциплина';

  @override
  String get metricInfoPsychologyDisciplineSubtitle =>
      'Покупать по плану, а не на эмоциях';

  @override
  String get metricInfoPsychologyDisciplineSection1Header =>
      'Что такое инвестиционная дисциплина?';

  @override
  String get metricInfoPsychologyDisciplineSection1Body =>
      'Инвестиционная дисциплина — это способность принимать решения на основе стратегии, а не эмоций.\n\nРынок постоянно создаёт ситуации, которые проверяют инвесторов на прочность:\n\nКогда цены быстро растут — появляется азарт и страх упустить возможность.\n\nКогда рынок падает — появляется страх, и инвесторы часто колеблются или впадают в панику.\n\nМногие инвестиционные ошибки происходят не из-за нехватки знаний об инвестировании.\n\nОни происходят потому, что эмоции заставляют инвесторов менять решения в самый неподходящий момент.\n\nДисциплина помогает инвесторам придерживаться своей стратегии независимо от того, что происходит вокруг.';

  @override
  String get metricInfoPsychologyDisciplineSection2Header => 'Простой пример';

  @override
  String get metricInfoPsychologyDisciplineSection2Body =>
      'Представьте двух инвесторов.\n\nУ обоих одинаковая сумма денег и доступ к одной и той же информации.';

  @override
  String get metricInfoPsychologyDisciplineSection3Header => 'Инвестор А';

  @override
  String get metricInfoPsychologyDisciplineSection3Body =>
      'Рынок быстро растёт.\n\nВ новостях повсюду истории об одной популярной компании.\n\nВсе говорят о её будущем потенциале.\n\nИнвестор покупает, потому что боится упустить возможность.\n\nЧерез несколько месяцев ситуация на рынке меняется.\n\nЦена акции падает.\n\nИнвестор продаёт, потому что им овладевает страх.\n\nЕго решения управляются эмоциями.';

  @override
  String get metricInfoPsychologyDisciplineSection4Header => 'Инвестор Б';

  @override
  String get metricInfoPsychologyDisciplineSection4Body =>
      'Прежде чем купить, он задаёт себе важные вопросы:\n\nЗачем я покупаю эту компанию?\nИзменилась ли реальная стоимость бизнеса?\nСоответствует ли эта покупка моей инвестиционной стратегии?\n\nКогда рынок растёт, он не покупает просто потому, что все воодушевлены.\n\nКогда рынок падает, он ищет возможности.\n\nЕго решения основаны на процессе, а не на рыночных эмоциях.';

  @override
  String get metricInfoPsychologyDisciplineSection5Header =>
      'Что отслеживает этот виджет?';

  @override
  String get metricInfoPsychologyDisciplineSection5Body =>
      'Этот виджет анализирует историю ваших покупок и оценивает, насколько ваши действия соответствуют принципам дисциплинированного инвестирования.\n\nОн смотрит не только на результат ваших инвестиций.\n\nОн учитывает условия и обстановку, в которых принимались ваши решения.';

  @override
  String get metricInfoPsychologyDisciplineSection6Header =>
      'Покупки во время рыночного страха';

  @override
  String get metricInfoPsychologyDisciplineSection6Body =>
      'Покупки во время:\n\nпадения рынка;\nфинансовых кризисов;\nпериодов крайней неопределённости;\n\nмогут демонстрировать способность действовать тогда, когда многие инвесторы напуганы.';

  @override
  String get metricInfoPsychologyDisciplineSection7Header =>
      'Покупки во время рыночного ажиотажа';

  @override
  String get metricInfoPsychologyDisciplineSection7Body =>
      'Покупки во время:\n\nрыночного хайпа;\nстремительного роста цен;\nмассового внимания к определённой теме;\n\nмогут указывать на эмоциональное решение и желание не упустить возможность.';

  @override
  String get metricInfoPsychologyDisciplineSection8Header =>
      'Контроль риска при появлении возможностей';

  @override
  String get metricInfoPsychologyDisciplineSection8Body =>
      'Даже хорошая инвестиционная идея требует грамотной реализации.\n\nСильный инвестор не просто распознаёт возможности.\n\nОн также управляет размером позиций и сохраняет гибкость.\n\nНапример, покупка во время падения рынка при сохранении денежного резерва свидетельствует о более взвешенном и продуманном подходе.';

  @override
  String get metricInfoPsychologyDisciplineSection9Header =>
      'Чему учит этот виджет?';

  @override
  String get metricInfoPsychologyDisciplineSection9Body =>
      'Этот виджет учит одному из самых важных навыков долгосрочного инвестора:\n\nуправлять не только своим портфелем, но и собственным поведением.\n\nПотому что рынок нельзя контролировать.\n\nВы не можете контролировать:\n\nновости;\nэкономику;\nдвижение цен;\nэмоции других инвесторов.\n\nНо вы можете контролировать:\n\nсвои решения;\nсвою стратегию;\nсвою реакцию на события.';

  @override
  String get metricInfoPsychologyDisciplineSection10Header => 'Главная мысль';

  @override
  String get metricInfoPsychologyDisciplineSection10Body =>
      'Успешный инвестор — это не тот, кто никогда не ошибается.\n\nОшибаются все.\n\nУспешный инвестор — это тот, кто способен продолжать принимать рациональные решения даже тогда, когда рынок создаёт максимальное давление.\n\nВаша стратегия показывает, что вы покупаете.\n\nВаша дисциплина показывает, почему вы это покупаете.';

  @override
  String get metricInfoPsychologyPanicTitle => 'Паника';

  @override
  String get metricInfoPsychologyPanicSubtitle =>
      'Продавать спокойно, а не в страхе';

  @override
  String get metricInfoPsychologyPanicSection1Header =>
      'Что такое паника в инвестировании?';

  @override
  String get metricInfoPsychologyPanicSection1Body =>
      'Паника в инвестировании — это не просто чувство страха.\n\nСтрах — естественная реакция, когда речь идёт о деньгах.\n\nКаждый инвестор испытывает неуверенность, когда цены падают.\n\nПроблема начинается тогда, когда страх начинает управлять решениями.\n\nПадение цены акции само по себе не означает, что инвестиция плохая.\n\nИногда снижение цены означает:\n\nвесь рынок находится под давлением;\nинвесторы временно напуганы;\nхорошая компания дешевеет.\n\nНо в периоды стресса многие инвесторы принимают решения, основываясь на эмоциях, а не на анализе.\n\nОни продают, потому что ситуация вызывает дискомфорт.\n\nОни продают, потому что хотят прекратить боль.\n\nОни продают, потому что верят, что падение будет продолжаться вечно.\n\nЭто одна из самых распространённых ошибок в инвестировании.';

  @override
  String get metricInfoPsychologyPanicSection2Header => 'Простой пример';

  @override
  String get metricInfoPsychologyPanicSection2Body =>
      'Представьте, что инвестор покупает акции сильной компании.\n\nБизнес растёт.\n\nФинансовые показатели в порядке.\n\nДолгосрочная идея остаётся неизменной.\n\nНо затем рынок вступает в трудный период.\n\nЦена акции падает:\n\n-20%.\n\nЗатем:\n\n-35%.\n\nПовсюду появляются негативные заголовки.\n\nМногие инвесторы начинают бояться.';

  @override
  String get metricInfoPsychologyPanicSection3Header => 'Инвестор А';

  @override
  String get metricInfoPsychologyPanicSection3Body =>
      'Падающая цена вызывает стресс.\n\nОн думает:\n\n«Я больше не могу выносить этот убыток».\n\nОн продаёт почти в самой нижней точке.\n\nЧерез несколько месяцев рынок начинает восстанавливаться.\n\nПроблема была не только в падении цены.\n\nПроблема была в том, что решение принималось в момент, когда эмоции были сильнее всего.';

  @override
  String get metricInfoPsychologyPanicSection4Header => 'Инвестор Б';

  @override
  String get metricInfoPsychologyPanicSection4Body =>
      'Он пересматривает первоначальную инвестиционную идею.\n\nОн спрашивает себя:\n\nСтала ли компания слабее?\nИзменилась ли бизнес-модель?\nЯвляется ли это временной реакцией рынка?\n\nЕсли причина для инвестиции всё ещё актуальна, он сохраняет терпение.\n\nОн понимает, что волатильность — часть инвестирования.';

  @override
  String get metricInfoPsychologyPanicSection5Header =>
      'Что отслеживает этот виджет?';

  @override
  String get metricInfoPsychologyPanicSection5Body =>
      'Этот виджет анализирует ваше поведение при продаже и оценивает, как вы реагируете в сложных рыночных ситуациях.\n\nОн не считает каждую убыточную продажу ошибкой.\n\nПродажа с убытком иногда может быть правильным решением.\n\nУмный инвестор может продавать, потому что:\n\nфундаментальные показатели бизнеса изменились;\nпервоначальная инвестиционная идея больше не актуальна;\nпоявилась более выгодная возможность.\n\nВажный вопрос звучит так:\n\nПочему вы продали?';

  @override
  String get metricInfoPsychologyPanicSection6Header =>
      'Продажи во время страха';

  @override
  String get metricInfoPsychologyPanicSection6Body =>
      'Система смотрит на то, происходили ли продажи в периоды крайнего давления на рынок.\n\nПродажа вблизи крупных падений может указывать на эмоциональную реакцию, особенно если позже инвестиция восстанавливается в цене.';

  @override
  String get metricInfoPsychologyPanicSection7Header =>
      'Способность принимать волатильность';

  @override
  String get metricInfoPsychologyPanicSection7Body =>
      'Успешные инвесторы понимают, что колебания цены — это нормально.\n\nДаже сильные компании могут переживать временные спады.\n\nЭтот виджет помогает оценить, умеете ли вы отличать временный рыночный шум от реальных проблем с инвестицией.';

  @override
  String get metricInfoPsychologyPanicSection8Header =>
      'Как пережить экстремальные события на рынке';

  @override
  String get metricInfoPsychologyPanicSection8Body =>
      'Самое серьёзное испытание для инвестора часто наступает во время кризисов.\n\nОбвалы рынка порождают:\n\nнеопределённость;\nстрах;\nдавление, толкающее к действию.\n\nИнвесторы, способные пережить эти периоды без эмоциональных решений, демонстрируют один из самых ценных навыков в инвестировании:\n\nтерпение.';

  @override
  String get metricInfoPsychologyPanicSection9Header =>
      'Чему учит этот виджет?';

  @override
  String get metricInfoPsychologyPanicSection9Body =>
      'Этот виджет учит, что инвестирование — это не только выбор правильных активов.\n\nЭто ещё и контроль над своими реакциями, когда события развиваются не по плану.\n\nВы не можете контролировать:\n\nобвалы рынка;\nнегативные новости;\nвременные падения цен.\n\nНо вы можете контролировать:\n\nсвои решения;\nсвою подготовку;\nсвою реакцию на неопределённость.';

  @override
  String get metricInfoPsychologyPanicSection10Header => 'Главная мысль';

  @override
  String get metricInfoPsychologyPanicSection10Body =>
      'Великий инвестор — это не тот, кто никогда не испытывает страха.\n\nСтрах чувствуют все.\n\nРазница в том, что происходит дальше.\n\nОдни инвесторы позволяют страху принимать решения за них.\n\nДругие полагаются на терпение, анализ и чёткую стратегию.\n\nВаш портфель показывает, чем вы владеете.\n\nВаша Дисциплина показывает, как вы покупаете.\n\nВаш показатель Паники показывает, как вы себя ведёте, когда рынок испытывает вас на прочность.';

  @override
  String get metricInfoPsychologyPatienceTitle => 'Терпение';

  @override
  String get metricInfoPsychologyPatienceSubtitle =>
      'Умение дать позиции время';

  @override
  String get metricInfoPsychologyPatienceSection1Header =>
      'Что такое терпение инвестора?';

  @override
  String get metricInfoPsychologyPatienceSection1Body =>
      'Терпение инвестора — это способность сохранять фокус на долгосрочном плане, не принимая лишних решений из-за краткосрочных колебаний рынка.\n\nМногие инвесторы считают, что успешное инвестирование — это поиск идеального момента для покупки или продажи.\n\nНо на самом деле одно из главных преимуществ инвестора — это время.\n\nРынок постоянно создаёт ситуации, которые проверяют терпение на прочность:\n\nцены движутся вверх и вниз;\nпоявляются неожиданные новости;\nдругие инвесторы поддаются азарту или страху;\nдаже у хороших компаний порой случаются трудные периоды.\n\nВ такие моменты инвесторы часто чувствуют давление, вынуждающее их действовать.\n\nИм хочется что-то изменить.\n\nИм хочется исправить ситуацию.\n\nНо иногда лучшее решение — вообще не принимать решения.';

  @override
  String get metricInfoPsychologyPatienceSection2Header => 'Простой пример';

  @override
  String get metricInfoPsychologyPatienceSection2Body =>
      'Представьте двух инвесторов, купивших акции одной и той же сильной компании.\n\nБизнес продолжает расти.\n\nФинансовые показатели остаются стабильными.\n\nНо рынок вступает в трудный период, и цена акций падает.';

  @override
  String get metricInfoPsychologyPatienceSection3Header => 'Инвестор А';

  @override
  String get metricInfoPsychologyPatienceSection3Body =>
      'Падение цены вызывает у него стресс.\n\nОн думает:\n\n«Может, я ошибся. Нужно что-то сделать».\n\nОн продаёт, потому что ситуация кажется ему неприятной.\n\nПозже компания восстанавливается.\n\nПроблема была не во временном падении.\n\nПроблема была в том, что первоначальной инвестиционной идее не дали достаточно времени.';

  @override
  String get metricInfoPsychologyPatienceSection4Header => 'Инвестор Б';

  @override
  String get metricInfoPsychologyPatienceSection4Body =>
      'Он анализирует ситуацию.\n\nОн задаёт себе вопросы:\n\nБизнес стал слабее?\nИзменилась ли первоначальная причина для инвестиции?\nЭто проблема компании или просто страх рынка?\n\nЕсли инвестиционная идея по-прежнему актуальна, он сохраняет терпение.\n\nОн понимает, что краткосрочная волатильность — нормальная часть долгосрочного инвестирования.';

  @override
  String get metricInfoPsychologyPatienceSection5Header =>
      'Что отслеживает этот виджет?';

  @override
  String get metricInfoPsychologyPatienceSection5Body =>
      'Этот виджет анализирует ваше инвестиционное поведение и измеряет способность сохранять терпение в разных рыночных ситуациях.\n\nОн не просто измеряет, как долго вы держите позицию.\n\nДержать плохую компанию много лет — это не терпение.\n\nНастоящее терпение означает:\n\nдавать хорошим решениям достаточно времени, чтобы сработать, оставаясь при этом готовым отреагировать, когда факты действительно изменятся.';

  @override
  String get metricInfoPsychologyPatienceSection6Header =>
      'Способность избегать лишних действий';

  @override
  String get metricInfoPsychologyPatienceSection6Body =>
      'Рынок находится в постоянном движении.\n\nКаждое изменение цены способно вызвать эмоциональную реакцию.\n\nЭтот виджет оценивает, на чём основаны ваши решения:\n\nна новой информации;\nна изменении качества бизнеса;\nна чёткой инвестиционной причине;\nили просто на временном давлении рынка.';

  @override
  String get metricInfoPsychologyPatienceSection7Header =>
      'Способность сохранять спокойствие во время кризиса';

  @override
  String get metricInfoPsychologyPatienceSection7Body =>
      'Самое серьёзное испытание терпения возникает во время экстремальных событий.\n\nОбвалы рынка порождают:\n\nстрах;\nнеопределённость;\nдавление, вынуждающее продавать.\n\nИменно в такие моменты многие инвесторы совершают свои самые серьёзные ошибки, потому что сосредотачиваются только на текущей ситуации.\n\nТерпеливый инвестор понимает, что трудные периоды — неотъемлемая часть инвестирования.';

  @override
  String get metricInfoPsychologyPatienceSection8Header =>
      'Фиксация прибыли без жадности';

  @override
  String get metricInfoPsychologyPatienceSection8Body =>
      'Терпение — это не только про то, чтобы держать позицию.\n\nЭто ещё и умение вовремя остановиться.\n\nДисциплинированный инвестор способен принять успешный результат, не дожидаясь вечно идеального момента для выхода.\n\nРынки редко предоставляют идеальный тайминг.';

  @override
  String get metricInfoPsychologyPatienceSection9Header =>
      'Чему учит этот виджет?';

  @override
  String get metricInfoPsychologyPatienceSection9Body =>
      'Этот виджет учит одному из важнейших уроков инвестирования:\n\nвремя — одно из главных преимуществ, которые может иметь инвестор.\n\nВы не можете контролировать:\n\nежедневные колебания цен;\nэмоции рынка;\nэкономические события.\n\nНо вы можете контролировать:\n\nсвои реакции;\nсвой процесс принятия решений;\nсвою способность сохранять фокус.';

  @override
  String get metricInfoPsychologyPatienceSection10Header => 'Главная мысль';

  @override
  String get metricInfoPsychologyPatienceSection10Body =>
      'Терпение не означает игнорировать проблемы.\n\nОно не означает держать каждую инвестицию вечно.\n\nОно означает умение отличать временный рыночный шум от реальных перемен, требующих действий.\n\nЛучшие инвесторы — не те, кто принимает больше всего решений.\n\nЭто те, кто принимает правильные решения и даёт им достаточно времени, чтобы сработать.\n\nВаша оценка «Дисциплина» показывает, как вы входите в рынок.\n\nВаша оценка «Паника» показывает, как вы реагируете под давлением.\n\nВаша оценка «Терпение» показывает, способны ли вы превратить время в своё преимущество.';

  @override
  String get metricInfoPsychologyStrategyTitle => 'Стратегия';

  @override
  String get metricInfoPsychologyStrategySubtitle =>
      'Как построен ваш портфель';

  @override
  String get metricInfoPsychologyStrategySection1Header =>
      'Что такое инвестиционная стратегия?';

  @override
  String get metricInfoPsychologyStrategySection1Body =>
      'Инвестиционная стратегия — это не просто список компаний, которыми вы владеете.\n\nЭто система правил, которая направляет ваши решения.\n\nСильная стратегия отвечает на такие вопросы:\n\nЧто я покупаю?\nПочему я это покупаю?\nКак я управляю риском?\nЧто я буду делать во время падения рынка?\nКак я отреагирую, когда появятся новые возможности?';

  @override
  String get metricInfoPsychologyStrategySection2Header => 'Простой пример';

  @override
  String get metricInfoPsychologyStrategySection2Body =>
      'Два инвестора могут владеть одними и теми же акциями.\n\nНо их стратегии могут быть совершенно разными.';

  @override
  String get metricInfoPsychologyStrategySection3Header => 'Инвестор А';

  @override
  String get metricInfoPsychologyStrategySection3Body =>
      'Покупает компании, потому что их цены растут.\n\nСледит за каждым заголовком новостей.\n\nПокупает после резкого роста цены из страха упустить возможность.\n\nПродаёт во время падений рынка из-за паники.\n\nУ него есть инвестиции, но нет системы.';

  @override
  String get metricInfoPsychologyStrategySection4Header => 'Инвестор Б';

  @override
  String get metricInfoPsychologyStrategySection4Body =>
      'Покупает сильные компании.\n\nКонтролирует размер позиций.\n\nДержит денежный резерв.\n\nИспользует ETF для дополнительной диверсификации.\n\nИмеет план на разные рыночные ситуации.\n\nОн не просто владеет акциями.\n\nУ него есть стратегия.';

  @override
  String get metricInfoPsychologyStrategySection5Header =>
      'Что отслеживает этот виджет?';

  @override
  String get metricInfoPsychologyStrategySection5Body =>
      'Этот виджет анализирует, следует ли ваш подход к инвестированию принципам долгосрочного управления портфелем.\n\nОн оценивает:';

  @override
  String get metricInfoPsychologyStrategySection6Header =>
      'Качество ваших инвестиций';

  @override
  String get metricInfoPsychologyStrategySection6Body =>
      'Инвестируете ли вы в сильные компании с устойчивыми бизнес-моделями?\n\nИли берёте на себя чрезмерный риск в надежде на быструю прибыль?';

  @override
  String get metricInfoPsychologyStrategySection7Header =>
      'Баланс между ростом и защитой';

  @override
  String get metricInfoPsychologyStrategySection7Body =>
      'Портфель должен не только хорошо показывать себя на растущем рынке.\n\nОн должен уметь пережить и трудные периоды.';

  @override
  String get metricInfoPsychologyStrategySection8Header =>
      'Готовность к возможностям';

  @override
  String get metricInfoPsychologyStrategySection8Body =>
      'Инвесторы без плана часто принимают эмоциональные решения.\n\nИнвесторы со стратегией понимают:\n\nкогда ждать;\nкогда инвестировать;\nкогда пересматривать свои решения.';

  @override
  String get metricInfoPsychologyStrategySection9Header => 'Главная мысль';

  @override
  String get metricInfoPsychologyStrategySection9Body =>
      'Успешное инвестирование — это не поиск одной идеальной акции.\n\nЭто построение системы, которая помогает вам снова и снова принимать разумные решения.\n\nВы не можете контролировать рынок.\n\nНо вы можете контролировать свои действия.';

  @override
  String get metricInfoInvestorScoreTitle =>
      'Психология и стратегия: две оценки';

  @override
  String get metricInfoInvestorScoreSubtitle =>
      'Две стороны вашего инвестиционного поведения';

  @override
  String get metricInfoInvestorScoreSection1Header =>
      'Что показывают эти виджеты?';

  @override
  String get metricInfoInvestorScoreSection1Body =>
      'Ваше инвестиционное поведение оценивается двумя отдельными оценками, а не одним усреднённым числом.\n\nОни не измеряют:\n\nсколько денег вы заработали;\nнасколько быстро вырос ваш портфель;\nполучите ли вы прибыль в будущем.\n\nВместо этого каждая оценка отвечает на свой вопрос:\n\n«Оценка психологии» — насколько ваше поведение во время теста соответствует привычкам дисциплинированного инвестора?\n\n«Оценка стратегии» — насколько хорошо на самом деле построен ваш портфель, независимо от того, как вы себя вели, когда его строили?';

  @override
  String get metricInfoInvestorScoreSection2Header =>
      'Почему две оценки, а не одна?';

  @override
  String get metricInfoInvestorScoreSection2Body =>
      'Трейдер может вести себя безупречно — без паники, без погони за заголовками, с большим терпением — и при этом иметь плохо построенный портфель: всё в одной акции, без денежного резерва, без ETF. Возможна и обратная ситуация: хорошо диверсифицированный портфель, собранный за счёт импульсивных, эмоциональных сделок.\n\nЕсли объединить обе оценки в одно число, одна сторона может скрыть проблемы другой. Разделяя их, мы даём вам данные, на основе которых можно реально действовать.';

  @override
  String get metricInfoInvestorScoreSection3Header =>
      '🧠 ОЦЕНКА ПСИХОЛОГИИ — Дисциплина, Паника, Терпение';

  @override
  String get metricInfoInvestorScoreSection3Body =>
      'Как вы вели себя во время теста: следовали ли плану, как реагировали на падения рынка и давали ли своим решениям время сработать.';

  @override
  String get metricInfoInvestorScoreSection4Header =>
      '📊 ОЦЕНКА СТРАТЕГИИ — Концентрация, Доля ETF, Денежный буфер, Секторальный баланс, Диверсификация, Маркер безопасности';

  @override
  String get metricInfoInvestorScoreSection4Body =>
      'Как на самом деле построен ваш портфель прямо сейчас — независимо от решений, которые к этому привели.';

  @override
  String get metricInfoInvestorScoreSection5Header =>
      '🧩 Диверсификация — как построен ваш портфель';

  @override
  String get metricInfoInvestorScoreSection5Body =>
      'Этот показатель оценивает:\n\nкак распределены ваши инвестиции;\nнасколько сильно ваш портфель зависит от одной компании или идеи;\nнасколько хорошо ваш портфель защищён от единичной ошибки.\n\nСильный инвестор понимает:\n\nвладеть одной отличной компанией может быть хорошим решением.\n\nНо строить весь портфель вокруг одной идеи — значит создавать лишний риск.';

  @override
  String get metricInfoInvestorScoreSection6Header =>
      '🧩 Стратегия — как вы управляете портфелем';

  @override
  String get metricInfoInvestorScoreSection6Body =>
      'Этот показатель оценивает:\n\nбаланс активов;\nдолю ETF;\nденежные резервы;\nуправление риском.\n\nСильная стратегия помогает избежать ситуаций вроде:\n\n«Я купил всё, что мне понравилось, а теперь не знаю, что делать дальше».\n\nПортфель — это не только то, чем вы владеете.\n\nЭто ещё и то, насколько вы готовы к разным рыночным ситуациям.';

  @override
  String get metricInfoInvestorScoreSection7Header =>
      '🧩 Дисциплина — как вы принимаете инвестиционные решения';

  @override
  String get metricInfoInvestorScoreSection7Body =>
      'Этот показатель анализирует:\n\nпокупаете ли вы на страхе или на эйфории;\nследуете ли вы своей стратегии;\nоснованы ли ваши решения на логике или на эмоциях.\n\nОдна из самых распространённых ошибок инвесторов:\n\nпокупать тогда, когда все вокруг уже чувствуют уверенность.\n\nДисциплина помогает инвесторам искать возможности, а не просто следовать за толпой.';

  @override
  String get metricInfoInvestorScoreSection8Header =>
      '🧩 Паника — как вы реагируете на падения рынка';

  @override
  String get metricInfoInvestorScoreSection8Body =>
      'Этот показатель отражает:\n\nпродаёте ли вы под давлением;\nкак вы справляетесь со спадами рынка;\nумеете ли вы отличать временное падение от реальной проблемы.\n\nПадения рынка неизбежны.\n\nВажный вопрос — не:\n\n«Упадёт ли рынок?»\n\nВажный вопрос:\n\n«Как я отреагирую, когда это произойдёт?»';

  @override
  String get metricInfoInvestorScoreSection9Header =>
      '🧩 Терпение — умеете ли вы дать времени сработать';

  @override
  String get metricInfoInvestorScoreSection9Body =>
      'Этот показатель оценивает:\n\nвашу способность ждать;\nизбегаете ли вы лишних решений;\nсохраняете ли вы сосредоточенность в трудные периоды.\n\nИногда лучшее инвестиционное решение — не принимать решения.\n\nТерпение даёт хорошим идеям время раскрыться.';

  @override
  String get metricInfoInvestorScoreSection10Header =>
      'Как понимать свои оценки?';

  @override
  String get metricInfoInvestorScoreSection10Body =>
      'Обе оценки используют одни и те же 5 уровней независимо друг от друга — оценка психологии 75 и оценка стратегии 75 означают одно и то же для каждой из сторон вашего инвестирования, но они не обязаны совпадать между собой.\n\n🔴 0–20 — Начинающий инвестор\nВаш инвестиционный процесс пока сильно подвержен влиянию эмоций и краткосрочных реакций. Главная цель — не поиск идеальных инвестиций, а первый шаг: выработка крепких инвестиционных привычек.\n\n🟠 21–40 — Развивающийся инвестор\nВы понимаете многие базовые инвестиционные концепции, но рыночные ситуации всё ещё могут влиять на некоторые решения. Следующий шаг: выработать чёткие правила и научиться последовательно им следовать.\n\n🟡 41–60 — Сбалансированный инвестор\nВы заложили прочный фундамент. Вы понимаете важность стратегии и управления риском. Тем не менее некоторые рыночные ситуации всё ещё могут создавать давление.\n\n🟢 61–80 — Дисциплинированный инвестор\nВаше поведение демонстрирует крепкие инвестиционные привычки. Вы способны контролировать эмоции, оценивать риски и принимать более взвешенные решения.\n\n⭐ 81–100 — Мышление опытного инвестора\nВаши действия демонстрируют высокий уровень инвестиционной зрелости. Вы понимаете важность долгосрочного мышления, силу дисциплины и необходимость контроля риска. Однако высокая оценка не означает совершенства — рынок всегда может удивить инвестора. Главное преимущество — способность продолжать принимать рациональные решения в меняющихся условиях.';

  @override
  String get metricInfoInvestorScoreSection11Header =>
      'Главное назначение этого виджета';

  @override
  String get metricInfoInvestorScoreSection11Body =>
      'Эти оценки созданы не для того, чтобы сказать вам:\n\n«Вы хороший инвестор».\n\nили\n\n«Вы плохой инвестор».\n\nИх цель — показать:\n\n«Какие инвестиционные привычки вам помогают, а какие могут ограничивать ваш долгосрочный прогресс».\n\nКаждый инвестор может улучшить обе оценки.\n\nНе пытаясь предугадать каждое движение рынка.\n\nА совершенствуя собственный процесс принятия решений.';

  @override
  String get metricInfoInvestorScoreSection12Header => 'Заключительная мысль';

  @override
  String get metricInfoInvestorScoreSection12Body =>
      'Рынок нельзя контролировать.\n\nВы не можете контролировать:\n\nновости;\nцены;\nэкономические циклы.\n\nНо вы можете контролировать:\n\nсвою стратегию;\nсвои решения;\nсвою дисциплину.\n\nВаш портфель показывает, чем вы владеете.\n\nВаша оценка психологии показывает, как вы принимаете решения. Ваша оценка стратегии показывает, что вы строите. Вместе они показывают, каким инвестором вы становитесь.';

  @override
  String get metricInfoPsychologyDiversificationTitle => 'Диверсификация';

  @override
  String get metricInfoPsychologyDiversificationSubtitle =>
      'Распределение риска в портфеле';

  @override
  String get metricInfoPsychologyDiversificationSection1Header =>
      'Что такое диверсификация?';

  @override
  String get metricInfoPsychologyDiversificationSection1Body =>
      'Диверсификация — это способ снизить риск портфеля, распределив инвестиции между разными активами.\n\nПроще говоря:\n\nне кладите все яйца в одну корзину.\n\nЕсли эта корзина упадёт, вы потеряете всё.\n\nНо если у вас несколько корзин, проблема с одной из них не разрушит весь результат.\n\nВ инвестировании это означает:\n\nвладеть разными компаниями;\nинвестировать в разные отрасли;\nизбегать зависимости от одной-единственной акции.';

  @override
  String get metricInfoPsychologyDiversificationSection2Header =>
      'Простой пример';

  @override
  String get metricInfoPsychologyDiversificationSection2Body =>
      'Представьте, что у инвестора есть \$15,000.\n\nСценарий 1:\n\nОн вкладывает всё в одну компанию.\n\nЕсли у этой компании дела идут хорошо, результат может быть отличным.\n\nНо если у бизнеса возникают проблемы, страдает весь портфель целиком.\n\nОдин неудачный отчёт.\n\nОдна ошибка руководства.\n\nОдин неожиданный кризис.\n\nВесь удар приходится на одну-единственную инвестицию.\n\nСценарий 2:\n\nТе же \$15,000 распределены между разными компаниями:\n\nтехнологии;\nздравоохранение;\nтовары повседневного спроса;\nфинансовые услуги;\nпромышленные компании.\n\nТеперь проблемы в одной отрасли не обязательно вредят всему портфелю.\n\nНекоторые компании могут испытывать трудности, пока другие продолжают показывать хорошие результаты.';

  @override
  String get metricInfoPsychologyDiversificationSection3Header =>
      'Но диверсификация — это не просто покупка множества акций';

  @override
  String get metricInfoPsychologyDiversificationSection3Body =>
      'Многие начинающие инвесторы думают:\n\n«У меня 20 компаний, значит, мой портфель в безопасности».\n\nНо это не всегда так.\n\nМожно владеть 20 разными компаниями и при этом иметь сильно концентрированный портфель.\n\nНапример:\n\n20 компаний из сектора искусственного интеллекта.\n\nФормально вы владеете множеством бизнесов.\n\nНо если в отрасли ИИ произойдёт серьёзный спад, весь ваш портфель может упасть одновременно.\n\nНастоящая диверсификация — это не про количество.\n\nЭто про баланс.';

  @override
  String get metricInfoPsychologyDiversificationSection4Header =>
      'Что отслеживает этот виджет?';

  @override
  String get metricInfoPsychologyDiversificationSection4Body =>
      'Этот виджет анализирует, насколько хорошо распределён ваш портфель.\n\nОн учитывает несколько важных элементов:';

  @override
  String get metricInfoPsychologyDiversificationSection5Header =>
      'Количество компаний';

  @override
  String get metricInfoPsychologyDiversificationSection5Body =>
      'Слишком мало компаний делает портфель зависимым всего от нескольких решений.\n\nНо слишком много компаний может превратить портфель в набор случайных активов, за которыми становится сложно следить.';

  @override
  String get metricInfoPsychologyDiversificationSection6Header =>
      'Распределение по секторам';

  @override
  String get metricInfoPsychologyDiversificationSection6Body =>
      'Разные отрасли по-разному реагируют на экономические условия.\n\nКогда один сектор испытывает давление, другой может оставаться устойчивым.\n\nПоэтому важно спрашивать себя не только:\n\n«Сколькими компаниями я владею?»\n\nНо и:\n\n«К каким видам бизнеса и отраслям относятся эти компании?»';

  @override
  String get metricInfoPsychologyDiversificationSection7Header =>
      'Концентрация отдельных позиций';

  @override
  String get metricInfoPsychologyDiversificationSection7Body =>
      'Даже сильный портфель может стать рискованным, если одна компания занимает слишком большую долю вашего капитала.\n\nВаша любимая компания может быть отличным бизнесом.\n\nНо даже у отличных компаний бывают неожиданные трудности.';

  @override
  String get metricInfoPsychologyDiversificationSection8Header =>
      'Главная мысль';

  @override
  String get metricInfoPsychologyDiversificationSection8Body =>
      'Хорошая диверсификация не означает скупать всё подряд.\n\nОна означает создание портфеля, в котором одна ошибка, одна компания или одна отрасль не могут разрушить весь ваш инвестиционный путь.\n\nЦель диверсификации — не устранить весь риск.\n\nЭто невозможно.\n\nЦель — сделать риск управляемым.';

  @override
  String get metricInfoGuardianVerdictTitle => 'ВЕРДИКТ GUARDIAN';

  @override
  String get metricInfoGuardianVerdictSubtitle =>
      'Поздравляем — вы завершили симуляцию рынка своего портфеля.';

  @override
  String get metricInfoGuardianVerdictSection1Header =>
      'Симуляция рынка завершена';

  @override
  String get metricInfoGuardianVerdictSection1Body =>
      'В ходе симуляции вы прошли через разные рыночные периоды и сценарии, основанные на закономерностях, наблюдавшихся на протяжении реальной истории рынков. События, которые в реальном мире могут разворачиваться месяцами или даже годами, в симуляции были ускорены, чтобы вы могли ощутить их последствия за гораздо более короткое время.\n\nВы увидели, как ваш портфель может вести себя в самых разных условиях:\n\n📈 Рост рынка\n➖ Боковое движение и неопределённость\n📉 Падение рынка\n🔄 Восстановление после спада\n🚀 Рыночный ажиотаж\n🎲 Спекулятивные движения\n⚠️ Кризисные сценарии\n🦢 Редкие экстремальные события и сценарии «чёрного лебедя»\n\nУ каждой из этих рыночных фаз свои особенности.\n\nАжиотаж — это не просто рост цены.\n\nСпекуляция — это не то же самое, что долгосрочное инвестирование.\n\nПадение рынка не означает автоматически, что бизнес слабеет.\n\nА уверенный рост цены не означает автоматически, что актив стал более удачной инвестицией.\n\nВо время симуляции вы уже увидели эти закономерности в действии. Некоторые из них вы, возможно, распознали сразу. Другие могли пройти незамеченными. Именно поэтому одной симуляции может быть недостаточно.\n\nПопробуйте пройти разные симуляции рынка ещё раз. Измените портфель и понаблюдайте, как меняются ваши решения и поведение портфеля в разных рыночных условиях.\n\nСо временем вы сможете лучше распознавать разные рыночные фазы и понимать, почему одно и то же действие может иметь совершенно разный смысл в зависимости от ситуации.';

  @override
  String get metricInfoGuardianVerdictSection2Header =>
      'Важная вещь, которую стоит помнить';

  @override
  String get metricInfoGuardianVerdictSection2Body =>
      'Ни в реальном мире, ни в нашем симуляторе никто не может знать наверняка, куда рынок двинется завтра.\n\nНикто не может достоверно предсказать: когда закончится период роста; когда начнётся падение; насколько глубоким окажется спад; когда начнётся восстановление; какой сектор станет следующим лидером; какое неожиданное событие изменит настроение рынка.\n\nИменно поэтому цель этого теста — не научить вас предсказывать рынок. Его цель — научить вас кое-чему более полезному: понимать возможные рыночные сценарии и наблюдать за собственным поведением, когда они происходят.';

  @override
  String get metricInfoGuardianVerdictSection3Header =>
      'Тренируйтесь, а не предсказывайте';

  @override
  String get metricInfoGuardianVerdictSection3Body =>
      'Используйте симулятор как тренировочную площадку. Проходите разные сценарии. Наблюдайте за своими решениями. Следите за тем, что происходит с вашим портфелем при изменении рыночных условий.\n\nСамое главное — научитесь распознавать классические ошибки, которые инвесторы изучают уже десятилетиями: погоня за ажиотажем, FOMO, слабая диверсификация, чрезмерная концентрация, панические продажи, отсутствие денежного резерва, постоянные попытки поймать идеальный момент для входа и выхода, а также решения на основе эмоций.\n\nИ здесь важно провести границу: речь идёт об инвестировании, а не о трейдинге. Трейдер и долгосрочный инвестор могут смотреть на один и тот же рынок, но их цели, временные горизонты и подходы к риску могут сильно различаться. Наш симулятор создан не для того, чтобы научить вас постоянно покупать и продавать. Он создан, чтобы помочь вам понять долгосрочное инвестиционное поведение и выработать более качественные привычки принятия решений.';

  @override
  String get metricInfoGuardianVerdictSection4Header =>
      'А теперь посмотрим на ваши результаты';

  @override
  String get metricInfoGuardianVerdictSection4Body =>
      'Ниже вы найдёте подробный анализ ваших действий и вашего портфеля на протяжении всей симуляции. Каждый показатель основан на ваших реальных решениях и событиях, которые произошли во время теста.\n\nСистема анализирует: какие активы вы выбирали; насколько диверсифицированным был ваш портфель; когда вы покупали; когда вы продавали; как вы вели себя во время падений рынка; как часто вы меняли свои позиции; проявляли ли вы терпение; как вы управляли риском и денежным резервом; насколько ваше поведение соответствовало принципам дисциплинированного долгосрочного инвестирования.\n\nВаши действия обрабатываются с помощью объективного алгоритмического анализа, который формирует индивидуальные поведенческие показатели и общий профиль инвестора.\n\nРечь идёт не о том, чтобы просто сказать вам «Вы поступили правильно» или «Вы поступили неправильно». Вместо этого система показывает: что произошло, почему это важно и какой инвестиционный навык вам, возможно, стоит развить.\n\nПоэтому не стоит воспринимать свой результат как окончательный приговор. Это не предсказание ваших будущих финансовых результатов и не мерило вас как личности. Это лишь снимок вашего поведения в рамках конкретной симуляции.\n\nИ если результат вам не понравился — это на самом деле хорошо. Ведь здесь у вас есть возможность, которую гораздо труднее получить в реальной жизни: совершать ошибки в симуляторе, изучать свои решения, пробовать снова и постепенно учиться распознавать и избегать классических инвестиционных ошибок до того, как они станут проблемами в реальном мире.';

  @override
  String get marketClockWindowEarlyPreMarketShortHeadline => 'Ранний премаркет';

  @override
  String get marketClockWindowEarlyPreMarketShortDetail =>
      'Низкая ликвидность, рискованные спреды';

  @override
  String get marketClockWindowEarlyPreMarketFullTitle => 'Ранний премаркет';

  @override
  String get marketClockWindowEarlyPreMarketWhatHappens =>
      'Это самая ранняя стадия торгов. Биржа официально ещё не открылась, но электронные торги уже идут.\n\nВ это время на рынке в основном активны крупные инвестиционные фонды, институциональные трейдеры и компании, реагирующие на ночные новости.\n\nОбычных инвесторов совсем немного, поэтому рынок ощущается тихим и почти пустым.\n\nПредставьте, что вы зашли в супермаркет за час до официального открытия. Внутри лишь несколько человек, часть полок ещё не заполнена, а цены не всегда отражают то, какими они будут позже днём.\n\nИменно так выглядит рынок в период раннего премаркета.';

  @override
  String get marketClockWindowEarlyPreMarketWhyItMatters =>
      'Главная проблема этой сессии — низкая ликвидность.\n\nПокупателей и продавцов просто слишком мало.\n\nИз-за этого разница между ценой покупки и ценой продажи (спред) может оказаться неожиданно большой.\n\nНапример, акция вчера закрылась на уровне \$100, но следующий доступный продавец готов продать её только за \$102.\n\nЕсли вы разместите рыночный ордер, брокер может исполнить сделку по этой завышенной цене.\n\nВы можете потерять деньги ещё до начала торгового дня.';

  @override
  String get marketClockWindowEarlyPreMarketDangerForBeginner =>
      'После одной крупной сделки цена может резко подскочить, потому что заявок недостаточно, чтобы удержать её стабильной.\n\nЭто часто создаёт резкие движения на графике, которые исчезают, как только на рынок выходит больше трейдеров.\n\nМногие новички видят внезапный скачок и думают:\n\n«Акция взлетает! Нужно покупать прямо сейчас!»\n\nЧерез несколько минут ажиотаж спадает, и цена возвращается туда, откуда начала.';

  @override
  String get marketClockWindowEarlyPreMarketWhatToDo =>
      'Если вы инвестируете на долгий срок, лучшее решение — обычно подождать.\n\nЕсли вам всё же нужно купить или продать в эту сессию, всегда используйте лимитный ордер.\n\nЛимитный ордер позволяет задать максимальную цену, которую вы готовы заплатить, защищая вас от неожиданных скачков цены.';

  @override
  String get marketClockWindowEarlyPreMarketFomoShieldTip =>
      'Если кажется, что вы вот-вот упустите невероятную возможность — скорее всего, перед вами движение на низкой ликвидности.\n\nНе спешите.\n\nПосле открытия основной сессии цены обычно становятся куда стабильнее.';

  @override
  String get marketClockWindowPreMarketReportsShortHeadline =>
      'Премаркет и новости';

  @override
  String get marketClockWindowPreMarketReportsShortDetail =>
      'Высокий риск, публикация отчётностей';

  @override
  String get marketClockWindowPreMarketReportsFullTitle => 'Премаркет';

  @override
  String get marketClockWindowPreMarketReportsWhatHappens =>
      'Рынок постепенно просыпается.\n\nВсё больше инвесторов начинают заключать сделки, банки анализируют события ночи, а трейдеры готовятся к открытию торгов.\n\nИменно в это время многие компании публикуют квартальную отчётность, а правительство США часто выпускает важные экономические данные — по инфляции, занятости и ВВП.\n\nОдна новость может сдвинуть цену акции на 10–20% ещё до официального открытия рынка.';

  @override
  String get marketClockWindowPreMarketReportsWhyItMatters =>
      'Это период, когда рынок пытается ответить на один важный вопрос:\n\n«Сегодняшние новости хорошие или плохие?»\n\nТысячи инвесторов читают одну и ту же информацию, но приходят к совершенно разным выводам.\n\nОдни начинают покупать.\n\nДругие — продавать.\n\nТретьи решают зафиксировать прибыль.\n\nВ результате цена может несколько раз поменять направление всего за несколько минут.';

  @override
  String get marketClockWindowPreMarketReportsDangerForBeginner =>
      'Эта сессия управляется эмоциями.\n\nНовичок может увидеть, что акция выросла на 12% до открытия торгов, и подумать:\n\n«Если не куплю сейчас, упущу возможность».\n\nЧерез десять минут появляются новые детали...\n\nИ акция неожиданно падает.\n\nПодобные ситуации случаются гораздо чаще, чем ожидает большинство новичков.';

  @override
  String get marketClockWindowPreMarketReportsWhatToDo =>
      'Используйте это время, чтобы подготовиться, а не реагировать.\n\nПроверьте, какие компании отчитываются сегодня.\n\nПрочитайте новости.\n\nПересмотрите свой инвестиционный план.\n\nНо не пытайтесь предсказать, куда цены двинутся в ближайшие пять минут.';

  @override
  String get marketClockWindowPreMarketReportsFomoShieldTip =>
      'Успешным инвесторам не обязательно реагировать первыми.\n\nСпокойные, обдуманные решения почти всегда лучше, чем погоня за быстро движущимися ценами.';

  @override
  String get marketClockWindowOpeningBellShortHeadline => 'Открытие торгов';

  @override
  String get marketClockWindowOpeningBellShortDetail =>
      'Пик волатильности, хаос открытия';

  @override
  String get marketClockWindowOpeningBellFullTitle => 'Открытие торгов';

  @override
  String get marketClockWindowOpeningBellWhatHappens =>
      'Нью-Йоркская фондовая биржа официально открывается.\n\nМиллионы инвесторов по всему миру одновременно начинают торговать.\n\nИсполняются ордера, размещённые ночью и во время премаркета.\n\nБанки, пенсионные фонды, инвестиционные компании, торговые алгоритмы и частные инвесторы — все становятся активны одновременно.\n\nЗа первый час торгов из рук в руки переходят миллиарды долларов.';

  @override
  String get marketClockWindowOpeningBellWhyItMatters =>
      'Обычно это самый напряжённый час всего торгового дня.\n\nЦены могут быстро двигаться в обоих направлениях.\n\nПоначалу может показаться, что у рынка нет чёткого направления.\n\nНа самом деле он просто ищет справедливую цену, обработав все ночные новости.';

  @override
  String get marketClockWindowOpeningBellDangerForBeginner =>
      'Первые 15–30 минут часто называют самой волатильной частью дня.\n\nДаже если вы выбрали отличную компанию, её акция может ненадолго просесть, прежде чем продолжить рост.\n\nМногие новички паникуют, увидев эти ранние красные цифры, и продают качественные активы без всякой веской причины.';

  @override
  String get marketClockWindowOpeningBellWhatToDo =>
      'Если вы новичок в инвестировании, обычно нет необходимости торговать сразу после открытия.\n\nДостаточно подождать всего 20–30 минут, чтобы рынок успокоился.\n\nКак только первая волна эмоций схлынет, движения цен станет намного легче понять.';

  @override
  String get marketClockWindowOpeningBellFomoShieldTip =>
      'Рынок открыт весь день.\n\nХорошие возможности редко исчезают в первые минуты, а вот эмоциональные ошибки могут аукаться гораздо дольше.';

  @override
  String get marketClockWindowMorningSessionShortHeadline => 'Утренний тренд';

  @override
  String get marketClockWindowMorningSessionShortDetail =>
      'Лучшее время для спокойной торговли';

  @override
  String get marketClockWindowMorningSessionFullTitle => 'Утренняя сессия';

  @override
  String get marketClockWindowMorningSessionWhatHappens =>
      'Первый час торгов позади, и рынок наконец успокоился.\n\nОсновная часть эмоциональных покупок и продаж уже случилась. Крупные фонды приняли решения и теперь исполняют свои планы более размеренно.\n\nЕсли утром они решили покупать — скорее всего, продолжат покупать в течение сессии. Если решили продавать — будут делать это более контролируемо.\n\nДвижения цен становятся более плавными, а общее направление рынка легче различить.\n\nИменно в это время рынок перестаёт реагировать эмоционально и начинает вести себя более рационально.';

  @override
  String get marketClockWindowMorningSessionWhyItMatters =>
      'Многие опытные инвесторы считают это одним из лучших моментов для торговли.\n\nПокупателей и продавцов достаточно, а значит ордера исполняются быстро и по справедливым ценам.\n\nРазница между ценой покупки и продажи (спред) обычно небольшая, а неожиданные скачки цены становятся реже.\n\nЕсли рынок выбрал направление на день, именно в эту сессию его чаще всего проще всего разглядеть.';

  @override
  String get marketClockWindowMorningSessionDangerForBeginner =>
      'Это один из самых безопасных периодов торгового дня, но новички всё равно совершают одну и ту же ошибку.\n\nОни видят, что акция уже немного подросла, и думают:\n\n«Я упустил свой шанс».\n\nИли замечают небольшой откат и решают, что с компанией что-то не так.\n\nНа самом деле небольшие колебания цены — это совершенно нормально.\n\nАкции не обязательно стоять на месте, чтобы оставаться хорошей долгосрочной инвестицией.';

  @override
  String get marketClockWindowMorningSessionWhatToDo =>
      'Если вы инвестируете на долгий срок, это часто один из лучших моментов для запланированных сделок.\n\nРынок уже показал направление, ликвидность высокая, а цены обычно стабильнее, чем в первые минуты торгов.\n\nПридерживайтесь своего инвестиционного плана вместо того, чтобы реагировать на каждое небольшое движение.';

  @override
  String get marketClockWindowMorningSessionFomoShieldTip =>
      'Хорошее инвестирование редко требует идеального тайминга.\n\nЕсли вы провели исследование и понимаете, зачем покупаете компанию, спокойный рынок обычно ваш лучший союзник.';

  @override
  String get marketClockWindowLunchHourShortHeadline => 'Обеденный час';

  @override
  String get marketClockWindowLunchHourShortDetail =>
      'Затишье, низкая активность';

  @override
  String get marketClockWindowLunchHourFullTitle => 'Обеденный час';

  @override
  String get marketClockWindowLunchHourWhatHappens =>
      'Обычно это самая тихая часть торгового дня.\n\nМногие профессиональные трейдеры уходят на обед, управляющие портфелями отходят от рабочих мест, а европейские рынки начинают закрываться на день.\n\nИз-за меньшего числа участников объём торгов заметно снижается.\n\nЕсли утром рынок напоминал бурную реку, теперь он больше похож на спокойное озеро.';

  @override
  String get marketClockWindowLunchHourWhyItMatters =>
      'Когда торгует меньше людей, цены обычно двигаются гораздо медленнее.\n\nМногие акции в этот период движутся боком, без явного направления.\n\nЭто не признак того, что что-то не так.\n\nЭто просто естественная часть дневного ритма рынка.\n\nНе каждый час должен быть насыщенным событиями.';

  @override
  String get marketClockWindowLunchHourDangerForBeginner =>
      'Как ни странно, главный риск обеденного часа — скука.\n\nМногие новички открывают приложение, видят, что ничего интересного не происходит, и всё равно испытывают желание совершить сделку.\n\nОни покупают не потому, что нашли отличную инвестицию.\n\nОни покупают просто потому, что хотят что-то сделать.\n\nТакие эмоциональные «сделки от скуки» часто становятся дорогим уроком.';

  @override
  String get marketClockWindowLunchHourWhatToDo =>
      'Если вы следуете долгосрочному плану, вполне можно совершить запланированные покупки в эту сессию.\n\nЕсли вы просто наблюдаете за рынком, используйте более спокойные часы с толком.\n\nЧитайте отчёты компаний.\n\nИзучайте бизнесы, которые вас интересуют.\n\nИли просто сделайте перерыв сами.\n\nИногда лучшая сделка — та, которую вы так и не совершили.';

  @override
  String get marketClockWindowLunchHourFomoShieldTip =>
      'Чтобы стать успешным инвестором, вовсе не обязательно торговать каждый день.\n\nТерпение — один из самых ценных навыков, которые можно развить.';

  @override
  String get marketClockWindowMidAfternoonShortHeadline => 'Дневная сессия';

  @override
  String get marketClockWindowMidAfternoonShortDetail =>
      'Стабильная торговля, реакция на ФРС';

  @override
  String get marketClockWindowMidAfternoonFullTitle => 'Середина дня';

  @override
  String get marketClockWindowMidAfternoonWhatHappens =>
      'Рынок снова начинает оживать.\n\nТрейдеры возвращаются за рабочие места, торговая активность растёт, и цены снова становятся более подвижными.\n\nВ некоторые дни именно в это время Федеральная резервная система (ФРС) объявляет решения по процентной ставке или другие важные экономические новости.\n\nТакие заявления могут изменить настроение всего рынка за считаные минуты.\n\nВ более спокойные дни рынок просто продолжает тренд, заданный утром.';

  @override
  String get marketClockWindowMidAfternoonWhyItMatters =>
      'К этому моменту рынок уже впитал большую часть утренних новостей.\n\nЕсли выходят новые экономические данные, крупные инвесторы могут быстро скорректировать позиции.\n\nЭто способно вызвать новую волну сильных движений цены.\n\nПонимание того, что происходит в этот период, помогает не удивляться внезапной волатильности.';

  @override
  String get marketClockWindowMidAfternoonDangerForBeginner =>
      'В обычный торговый день эта сессия относительно спокойна.\n\nОднако в дни важных заявлений ФРС волатильность может резко возрасти.\n\nАкции, индексы и даже весь рынок могут поменять направление за считаные минуты.\n\nМногие новички видят эти резкие движения и заходят в рынок, не понимая, что их вызвало.\n\nК сожалению, цены часто разворачиваются так же быстро.';

  @override
  String get marketClockWindowMidAfternoonWhatToDo =>
      'Перед сделкой бросьте быстрый взгляд на экономический календарь.\n\nЕсли запланировано важное заявление ФРС или крупный экономический отчёт, подумайте о том, чтобы подождать, пока рынок на них отреагирует.\n\nВ обычные торговые дни это ещё один отличный период для спокойного и продуманного инвестирования.';

  @override
  String get marketClockWindowMidAfternoonFomoShieldTip =>
      'Опытные инвесторы знают: не обязательно реагировать на каждое рыночное событие.\n\nИногда защитить свои деньги — значит просто подождать, пока рынок снова прояснится.';

  @override
  String get marketClockWindowPowerHourShortHeadline => 'Час пик';

  @override
  String get marketClockWindowPowerHourShortDetail =>
      'Финальный рывок, большие объёмы';

  @override
  String get marketClockWindowPowerHourFullTitle => 'Час пик';

  @override
  String get marketClockWindowPowerHourWhatHappens =>
      'Торговый день подходит к концу.\n\nДля рынка это как последние минуты финального матча — все хотят завершить его сильно.\n\nДейтрейдеры начинают закрывать позиции, чтобы не держать риск ночью.\n\nКрупные фонды ребалансируют портфели перед закрытием торгов.\n\nТорговые алгоритмы исполняют тысячи оставшихся заявок.\n\nВ результате торговая активность стремительно растёт, и рынок становится куда более энергичным.';

  @override
  String get marketClockWindowPowerHourWhyItMatters =>
      'Час пик обычно второй по загруженности период всего торгового дня.\n\nОбъём торгов резко возрастает, а движения цены часто становятся сильнее и увереннее.\n\nАкции, весь день двигавшиеся боком, могут внезапно прорваться в одном направлении.\n\nМногие дневные максимумы и минимумы формируются именно в последний час перед закрытием.';

  @override
  String get marketClockWindowPowerHourDangerForBeginner =>
      'Высокая активность означает и более высокую волатильность.\n\nАкция, весь день выглядевшая стабильной, может внезапно подскочить или упасть на несколько процентов за минуты.\n\nМногие новички принимают эти резкие движения за начало крупного тренда.\n\nОни спешат купить, боясь упустить возможность...\n\nИли паникуют и продают, решив, что начался обвал.\n\nНа самом деле такие движения часто вызваны закрытием позиций трейдерами перед закрытием торгов — а не изменением долгосрочной ценности компании.';

  @override
  String get marketClockWindowPowerHourWhatToDo =>
      'Если вы следуете продуманному инвестиционному плану, это вполне разумное время для покупки или продажи.\n\nОднако никогда не принимайте решение просто потому, что цена вдруг начала двигаться быстрее.\n\nПрежде чем разместить заявку, задайте себе простой вопрос:\n\n«Я следую своему инвестиционному плану или реагирую на эмоции?»\n\nЕсли ответ — эмоции, обычно лучше подождать.';

  @override
  String get marketClockWindowPowerHourFomoShieldTip =>
      'Не каждое резкое движение цены — отличная возможность.\n\nИногда самый умный инвестор — просто тот, кто сохраняет спокойствие, пока остальные спешат.';

  @override
  String get marketClockWindowAfterHoursShortHeadline => 'После закрытия';

  @override
  String get marketClockWindowAfterHoursShortDetail =>
      'Рынок закрыт, вечерняя отчётность';

  @override
  String get marketClockWindowAfterHoursFullTitle => 'После закрытия';

  @override
  String get marketClockWindowAfterHoursWhatHappens =>
      'Основная торговая сессия официально завершилась.\n\nМногим кажется, что биржа закрыта.\n\nНа самом деле электронные торги продолжаются и после закрытия.\n\nИменно в это время многие крупнейшие компании мира публикуют квартальную отчётность.\n\nТакие компании, как Apple, Microsoft, Amazon, Alphabet, Meta и многие другие, часто публикуют результаты вскоре после закрытия торгов.\n\nИнвесторы сразу же начинают реагировать на новости.';

  @override
  String get marketClockWindowAfterHoursWhyItMatters =>
      'Один отчёт о прибыли способен полностью изменить то, как инвесторы оценивают компанию.\n\nЕсли результаты лучше ожиданий, акция может подскочить на 10–20%.\n\nЕсли компания разочаровала инвесторов, цена может так же быстро упасть.\n\nСложность в том, что после закрытия торгует гораздо меньше людей.\n\nПри низкой ликвидности даже относительно небольшие заявки могут заметно сдвигать цену.';

  @override
  String get marketClockWindowAfterHoursDangerForBeginner =>
      'Торговля после закрытия — один из самых рискованных периодов для новичков.\n\nПредставьте, что акция закрылась на уровне \$100.\n\nПосле отчёта следующий доступный продавец хочет \$112, а самый высокий покупатель предлагает лишь \$108.\n\nРазрыв между ценой покупки и продажи становится необычно широким.\n\nРазместив рыночный ордер, вы рискуете заплатить намного больше, чем ожидали.\n\nПервая реакция на отчётность также сильно продиктована эмоциями.\n\nМногие инвесторы читают заголовки, ещё не разобравшись в самом отчёте.\n\nПрежде чем цена стабилизируется, она может несколько раз резко качнуться.';

  @override
  String get marketClockWindowAfterHoursWhatToDo =>
      'Обычно спешить незачем.\n\nИспользуйте это время, чтобы прочитать отчёт, разобраться в том, что действительно произошло, и посмотреть, как результаты интерпретируют опытные инвесторы.\n\nОчень часто рынок находит куда более разумную цену уже после открытия основной сессии на следующий день.\n\nТерпение обычно вознаграждается.';

  @override
  String get marketClockWindowAfterHoursFomoShieldTip =>
      'Пропуск первых пяти минут после отчёта редко меняет ваш долгосрочный успех.\n\nСпокойное решение почти всегда ценнее быстрого.';

  @override
  String get marketClockWindowClosedShortHeadline => 'Биржа закрыта';

  @override
  String get marketClockWindowClosedShortDetail => 'Ночью торгов нет';

  @override
  String get marketClockWindowClosedFullTitle => 'Рынок закрыт';

  @override
  String get marketClockWindowClosedWhatHappens =>
      'Сейчас рынок полностью закрыт.\n\nОсновные торги завершены, новые сделки не исполняются.\n\nЗа кулисами биржи обрабатывают миллионы завершённых транзакций, обновляют записи и готовят системы к следующему торговому дню.\n\nДля инвесторов это самая тихая часть суток.\n\nЦены перестают двигаться.\n\nШум стихает.\n\nИ впервые за день не нужно принимать решения немедленно.';

  @override
  String get marketClockWindowClosedWhyItMatters =>
      'Это идеальное время, чтобы мыслить ясно.\n\nБез постоянного наблюдения за колебаниями цен гораздо проще сосредоточиться на действительно важном.\n\nМногие опытные инвесторы уделяют изучению компаний после закрытия рынка больше времени, чем самой торговле.\n\nЛучшие инвестиционные решения часто принимаются, когда рынок спокоен — а не когда он в движении.';

  @override
  String get marketClockWindowClosedDangerForBeginner =>
      'Главная ошибка новичков в период закрытого рынка — не торговля.\n\nЭто чрезмерные раздумья.\n\nМногие часами читают бесконечные заголовки, пытаясь точно угадать, что рынок сделает завтра.\n\nПравда проста:\n\nНикто не знает.\n\nХорошие новости не всегда толкают цены вверх.\n\nПлохие новости не всегда обрушивают акции.\n\nПопытки предугадать каждое движение обычно лишь создают ненужный стресс.';

  @override
  String get marketClockWindowClosedWhatToDo =>
      'Используйте это тихое время с пользой.\n\nПросмотрите свой портфель.\n\nПрочитайте отчётности и годовые отчёты компаний.\n\nУзнайте больше о бизнесах, которыми вы владеете — или которыми планируете владеть.\n\nПроверьте, соответствуют ли ваши инвестиции долгосрочным целям.\n\nИ наконец...\n\nОтдохните.\n\nРынок всегда будет там и завтра, а ясные решения гораздо проще принимать со свежей головой.';

  @override
  String get marketClockWindowClosedFomoShieldTip =>
      'Лучшие инвесторы — не те, кто весь день смотрит на графики.\n\nЭто те, кто по-настоящему понимает бизнесы, в которые инвестирует, и у кого хватает терпения придерживаться своего плана.';

  @override
  String get marketClockWindowWeekendClosedShortHeadline => 'Выходные';

  @override
  String get marketClockWindowWeekendClosedShortDetail =>
      'Рынки откроются в понедельник';

  @override
  String get marketClockWindowWeekendClosedFullTitle => 'Выходные';

  @override
  String get marketClockWindowWeekendClosedTimeRangeLabel =>
      'Суббота – воскресенье';

  @override
  String get marketClockWindowWeekendClosedWhatHappens =>
      'Фондовый рынок США закрыт на выходные.\n\nАкции не покупаются и не продаются, цены не меняются, а новые заявки не будут исполнены до открытия рынка.\n\nЭто обычная часть расписания рынка. Даже крупнейшим финансовым рынкам мира нужна пауза.';

  @override
  String get marketClockWindowWeekendClosedWhyItMatters =>
      'Пока рынок закрыт, мир не останавливается.\n\nКомпании продолжают вести бизнес.\n\nВыходят экономические новости.\n\nМогут происходить политические события.\n\nК утру понедельника вся эта информация уже отражена в ценах акций.\n\nИменно поэтому рынки иногда открываются заметно выше или ниже после выходных.';

  @override
  String get marketClockWindowWeekendClosedDangerForBeginner =>
      'Многие новички проводят все выходные, переживая о том, что рынок сделает в понедельник.\n\nОни постоянно читают заголовки и пытаются предугадать любой возможный исход.\n\nНа самом деле никто точно не знает, как откроется рынок.\n\nПопытки угадать каждое движение обычно создают лишь стресс — а не более удачные инвестиционные решения.';

  @override
  String get marketClockWindowWeekendClosedWhatToDo =>
      'Выходные — отличная возможность стать лучшим инвестором.\n\nПросмотрите свой портфель.\n\nПочитайте о компаниях, которыми владеете.\n\nУзнайте что-то новое об инвестировании.\n\nИли просто отдохните и насладитесь выходными.\n\nЯсная голова часто приводит к лучшим решениям, чем целый день перед графиками.';

  @override
  String get marketClockWindowWeekendClosedFomoShieldTip =>
      'Настоящие рынки сегодня могут быть закрыты, но обучение не берёт выходных.';

  @override
  String get marketClockWindowWeekendClosedStressTestPromoTitle =>
      'Пока рынок закрыт...';

  @override
  String get marketClockWindowWeekendClosedStressTestPromoBody =>
      'Симуляция рынка доступна всегда.\n\nТренируйтесь собирать портфели, реагировать на рыночные события и принимать инвестиционные решения без риска для реальных денег.\n\nСимулятор создан, чтобы помочь вам понять, как ведёт себя рынок, и выработать дисциплину ещё до инвестирования на реальном рынке.\n\nКаждая сделка в симуляции рынка полностью независима от реальных рыночных цен, так что вы можете экспериментировать, учиться на ошибках и уверенно совершенствоваться.';

  @override
  String get marketClockWindowMarketHolidayShortHeadline => 'Рыночный праздник';

  @override
  String get marketClockWindowMarketHolidayShortDetail =>
      'Биржа закрыта по случаю праздника';

  @override
  String get marketClockWindowMarketHolidayFullTitle => 'Рыночный праздник';

  @override
  String get marketClockWindowMarketHolidayTimeRangeLabel => 'Весь день';

  @override
  String get marketClockWindowMarketHolidayWhatHappens =>
      'Сегодня фондовый рынок США закрыт из-за официального биржевого праздника.\n\nОбычные торги не проводятся, а заявки будут ждать следующей торговой сессии.\n\nЭто происходит несколько раз в год во время крупных праздников в США.';

  @override
  String get marketClockWindowMarketHolidayWhyItMatters =>
      'Рыночный праздник — это не то же самое, что проблема на рынке.\n\nНичего необычного не происходит.\n\nТорговля просто приостанавливается согласно биржевому календарю.\n\nОднако новости всё равно могут выходить, пока рынок закрыт.\n\nКогда торги возобновятся, цены могут скорректироваться с учётом всего, что произошло за это время.';

  @override
  String get marketClockWindowMarketHolidayDangerForBeginner =>
      'Некоторые новички думают, что рынок «замер», потому что случилось что-то плохое.\n\nНа самом деле биржевые праздники планируются заранее.\n\nНет причин волноваться только из-за того, что торги приостановлены на день.';

  @override
  String get marketClockWindowMarketHolidayWhatToDo =>
      'Воспользуйтесь более спокойным днём.\n\nПочитайте отчёты компаний.\n\nПересмотрите свои инвестиционные цели.\n\nПриведите в порядок список наблюдения.\n\nИли уделите время развитию своих знаний об инвестировании.\n\nКаждый опытный инвестор когда-то начинал с обучения.';

  @override
  String get marketClockWindowMarketHolidayFomoShieldTip =>
      'Лучшие инвесторы совершенствуются не только тогда, когда рынок открыт.\n\nОни развиваются каждый день.';

  @override
  String get marketClockWindowMarketHolidayStressTestPromoTitle =>
      'Продолжайте тренироваться';

  @override
  String get marketClockWindowMarketHolidayStressTestPromoBody =>
      'Хотя реальный рынок закрыт, симуляция рынка остаётся полностью доступна.\n\nЭто идеальное место, чтобы потренироваться в покупках, продажах, управлении портфелем и эмоциональной дисциплине без риска для реальных денег.\n\nВы можете пробовать разные стратегии, безопасно ошибаться и лучше понимать, как рынок реагирует в разных ситуациях.\n\nКогда реальный рынок снова откроется, вы вернётесь с бóльшим опытом и увереннее.';

  @override
  String get marketClockWindowEarlyCloseSessionShortHeadline =>
      'День раннего закрытия';

  @override
  String get marketClockWindowEarlyCloseSessionShortDetail =>
      'Рынок закроется в 13:00 по ET';

  @override
  String get marketClockWindowEarlyCloseSessionFullTitle =>
      'День раннего закрытия';

  @override
  String get marketClockWindowEarlyCloseSessionWhatHappens =>
      'Сегодня биржа работает по сокращённому расписанию и закроется в 13:00 по времени Нью-Йорка вместо 16:00.';

  @override
  String get marketClockWindowEarlyCloseSessionWhyItMatters =>
      'Времени на исполнение заявок меньше — торговая активность и объёмы сжимаются в более короткое окно.';

  @override
  String get marketClockWindowEarlyCloseSessionDangerForBeginner =>
      'Легко забыть о раннем закрытии и разместить заявку, которая сегодня не исполнится.';

  @override
  String get marketClockWindowEarlyCloseSessionWhatToDo =>
      'Планируйте сделки заранее и не откладывайте важные заявки на вторую половину дня.';

  @override
  String get marketClockWindowEarlyCloseSessionStressTestPromoTitle =>
      'Сначала попробуйте без риска';

  @override
  String get marketClockWindowEarlyCloseSessionStressTestPromoBody =>
      'Сокращённая, более быстрая сессия может показаться непривычной. Потренируйтесь в симуляции рынка — без реальных денег на кону, но с реальными рыночными условиями для обучения.';

  @override
  String get marketClockRiskEarlyPreMarketWhyNow =>
      'Рынок только начал просыпаться. Покупателей и продавцов очень мало, поэтому даже небольшие сделки могут двигать цену сильнее обычного. Ликвидность низкая, спреды широкие, а цены могут не отражать истинную стоимость компании.';

  @override
  String get marketClockRiskEarlyPreMarketWhatToDo =>
      'Если у вас нет конкретной причины торговать, обычно лучше подождать. Используйте это тихое время, чтобы просмотреть список наблюдения, прочитать новости компаний и подготовить план на день. Если сделка всё же необходима, всегда рассматривайте лимитный ордер вместо рыночного.';

  @override
  String get marketClockRiskPreMarketReportsWhyNow =>
      'Торговая активность растёт по мере того, как на рынок выходит больше участников. Именно в это время многие компании публикуют отчётность, а также выходят важные экономические данные США. Цены часто быстро реагируют и могут продолжать меняться, пока инвесторы усваивают новости.';

  @override
  String get marketClockRiskPreMarketReportsWhatToDo =>
      'Сосредоточьтесь на понимании новостей, а не на немедленной реакции на них. Изучите отчётности, проверьте экономический календарь и посмотрите, как реагирует рынок, прежде чем принимать решение.';

  @override
  String get marketClockRiskOpeningBellWhyNow =>
      'Начинается основная торговая сессия, и одновременно исполняются миллионы ночных заявок. Объём торгов чрезвычайно высок, как и волатильность. Рынок ищет справедливую цену, обработав всю ночную информацию.';

  @override
  String get marketClockRiskOpeningBellWhatToDo =>
      'Для новичков терпение часто оказывается лучшей стратегией. Дайте рынку 20-30 минут на то, чтобы устояться, прежде чем совершать запланированные долгосрочные инвестиции. Избегайте решений, основанных на первых резких движениях цены.';

  @override
  String get marketClockRiskMorningSessionWhyNow =>
      'Ранняя волатильность спадает, ликвидность остаётся высокой, а движения цены становятся более стабильными. Это часто один из самых сбалансированных периодов торгового дня.';

  @override
  String get marketClockRiskMorningSessionWhatToDo =>
      'Если вы инвестируете на долгий срок, это, как правило, один из лучших моментов для запланированных покупок. Продолжайте опираться на фундаментальные показатели компании, а не на краткосрочные колебания цены.';

  @override
  String get marketClockRiskLunchHourWhyNow =>
      'Торговая активность снижается, поскольку многие профессиональные трейдеры уходят на обед. Движения цены становятся тише, и рынок часто движется боком.';

  @override
  String get marketClockRiskLunchHourWhatToDo =>
      'Это хорошее время, чтобы изучить компании, просмотреть финансовую отчётность или совершить запланированные долгосрочные инвестиции, не торопясь. Не торгуйте только потому, что рынок кажется тихим.';

  @override
  String get marketClockRiskMidAfternoonWhyNow =>
      'Активность снова растёт по мере возвращения трейдеров. В некоторые дни заявления ФРС или важные экономические отчёты могут заметно повысить волатильность.';

  @override
  String get marketClockRiskMidAfternoonWhatToDo =>
      'Перед сделкой проверьте, не запланированы ли крупные экономические события. В обычные дни это ещё один комфортный период для долгосрочного инвестирования. В дни заседаний ФРС подумайте о том, чтобы подождать реакции рынка.';

  @override
  String get marketClockRiskPowerHourWhyNow =>
      'Последний час торгов проходит особенно активно, пока дейтрейдеры закрывают позиции, а фонды ребалансируют портфели. Сильные движения цены — обычное дело.';

  @override
  String get marketClockRiskPowerHourWhatToDo =>
      'Избегайте погони за быстро движущимися ценами. Если вы совершаете запланированную инвестицию, придерживайтесь своей стратегии, а не реагируйте на позднедневной ажиотаж.';

  @override
  String get marketClockRiskAfterHoursWhyNow =>
      'Многие компании публикуют отчётность после закрытия рынка. При этом активных трейдеров становится меньше, что может привести к сильным колебаниям цены и более широким спредам.';

  @override
  String get marketClockRiskAfterHoursWhatToDo =>
      'Обычно лучше потратить это время на чтение отчётов и анализ новостей, чем на торговлю. Ожидание следующей основной сессии часто приводит к более спокойным и обдуманным решениям.';

  @override
  String get marketClockRiskEarlyCloseSessionWhyNow =>
      'Сегодня фондовый рынок США работает по сокращённому расписанию.\n\nМногие институциональные инвесторы, банки и профессиональные трейдеры заканчивают работу раньше обычного, поэтому активность рынка постепенно снижается в течение дня. Из-за меньшего числа участников одни акции могут торговаться менее активно, а другие — испытывать неожиданные движения цены из-за низкого объёма торгов.\n\nГлавный риск — обманчивое ощущение спокойствия. Хотя рынок может выглядеть тихим, при меньшем числе участников даже относительно небольшие сделки способны заметнее влиять на цены. Спреды между ценой покупки и продажи могут расширяться, а движения цены — становиться менее предсказуемыми.\n\nЕщё один важный фактор: многие инвесторы предпочитают сокращать или закрывать позиции перед длинными праздничными выходными, чтобы не держать риск, пока рынок закрыт. Это может создавать дополнительное давление продавцов, даже если никаких негативных новостей о компании нет.';

  @override
  String get marketClockRiskEarlyCloseSessionWhatToDo =>
      'Если вы инвестируете на долгий срок и решение уже принято, сокращённый торговый день сам по себе не повод отказываться от инвестиции.\n\nОднако если сделка не срочная, ожидание следующей полной торговой сессии часто обеспечивает лучшую ликвидность и более стабильные рыночные условия.\n\nИспользуйте дополнительное время, чтобы просмотреть список наблюдения, почитать отчёты компаний или потренироваться в симуляции рынка.\n\nРаннее закрытие рынка — не повод торопиться с решениями. Иногда самый разумный шаг — просто дождаться следующего полноценного торгового дня, когда рынок вернётся к обычным условиям.';

  @override
  String get marketClockRiskClosedWhyNow =>
      'Рынок закрыт, сделки не заключаются. Это идеальная возможность отвлечься от движений цены и сосредоточиться на обучении.';

  @override
  String get marketClockRiskClosedWhatToDo =>
      'Просмотрите свой портфель, почитайте отчёты компаний и подготовьте план на следующий торговый день. Также можно потренироваться в симуляции рынка, где каждая сделка симулируется и полностью независима от реального рынка.';

  @override
  String get marketClockRiskWeekendHolidayWhyNow =>
      'Фондовый рынок закрыт, но мир не останавливается. Новости, политика и объявления компаний продолжаются, даже если торгов нет.';

  @override
  String get marketClockRiskWeekendHolidayWhatToDo =>
      'Используйте возможность учиться без спешки. Изучайте новые компании, развивайте свои знания об инвестировании или тренируйтесь в симуляции рынка. Это безопасная среда, где можно укрепить уверенность, выработать дисциплину и проверить идеи без риска для реальных денег.';

  @override
  String get marketClockNewYorkTimeTitle => 'ВРЕМЯ НЬЮ-ЙОРКА';

  @override
  String get marketClockMacroPhasePreMarketLabel => 'ПРЕМАРКЕТ';

  @override
  String get marketClockMacroPhaseMarketOpenLabel => 'РЫНОК ОТКРЫТ';

  @override
  String get marketClockMacroPhaseAfterHoursLabel => 'ПОСЛЕ ЗАКРЫТИЯ';

  @override
  String get marketClockMacroPhaseMarketClosedLabel => 'РЫНОК ЗАКРЫТ';

  @override
  String marketClockCountdownEnds(String time) {
    return 'Конец: $time';
  }

  @override
  String marketClockCountdownStarts(String time) {
    return 'Начало: $time';
  }

  @override
  String marketClockDurationHoursMinutes(String hours, String minutes) {
    return '$hoursч $minutesм';
  }

  @override
  String marketClockDurationMinutes(String minutes) {
    return '$minutesм';
  }

  @override
  String get marketClockWidgetDisplayNameNyTime => 'Время Нью-Йорка';

  @override
  String get marketClockWidgetDisplayNameMarketPhase => 'Фаза рынка';

  @override
  String get marketClockWidgetDisplayNameTimingIndicator => 'Индикатор риска';

  @override
  String get portfolioBalanceWidgetDisplayNamePortfolioHealth =>
      'Здоровье портфеля';

  @override
  String get portfolioBalanceWidgetDisplayNameAssetAllocation =>
      'Распределение активов, %';

  @override
  String get portfolioBalanceWidgetDisplayNameDiversificationIndicator =>
      'Индикатор диверсификации';

  @override
  String get portfolioBalanceWidgetDisplayNameDiversificationProgress =>
      'Прогресс диверсификации';

  @override
  String get marketTimelineTitle => 'ЭПОХИ';

  @override
  String marketTimelineEpochCount(int current, int total) {
    return 'Эпоха $current из $total';
  }

  @override
  String marketTimelineEpochLabel(int number, String description) {
    return 'Эп. $number · $description';
  }

  @override
  String get marketTimelineDescBull => 'Широкий рост рынка';

  @override
  String get marketTimelineDescSideways => 'Спокойный, боковой тренд';

  @override
  String get marketTimelineDescBear => 'Постепенное снижение';

  @override
  String get marketTimelineDescVolatility => 'Резкие колебания без тренда';

  @override
  String get marketTimelineDescBlackSwan => 'Обвал по всем направлениям';

  @override
  String get marketTimelineDescCrash => 'Резкое падение в секторе';

  @override
  String get marketTimelineDescRecovery => 'Восстановление после кризиса';

  @override
  String get marketTimelineDescHype => 'Всплеск в целевом секторе';

  @override
  String get marketTimelineDescSpeculation => 'Разнонаправленная волатильность';

  @override
  String get psychologyAuditTimesOnce => 'один раз';

  @override
  String psychologyAuditTimesCount(int n) {
    return '$n раз';
  }

  @override
  String get psychologyAuditRightDiversifying =>
      'Отличная работа с диверсификацией! Вы покупали активы из разных секторов — это защищает ваш капитал.';

  @override
  String get psychologyAuditRightPatience =>
      'Отличное терпение. Вы не продаёте в панике на просадках и даёте прибыли спокойно расти.';

  @override
  String get psychologyAuditRightDiscipline =>
      'Хорошая дисциплина. Вы следуете своему плану и не гонитесь за каждым движением рынка.';

  @override
  String get psychologyAuditRightNerve =>
      'Крепкие нервы. Вы держитесь стабильно во время рыночной турбулентности вместо панических продаж.';

  @override
  String psychologyAuditRightSectorSpread(int count) {
    return 'Вы распределены по $count секторам. Хорошая диверсификация снижает риск, если пострадает одна отрасль.';
  }

  @override
  String psychologyAuditRightCashBuffer(int pct) {
    return 'Вы держите $pct% в кэше. Это даёт гибкость для покупок, когда появляются возможности.';
  }

  @override
  String get psychologyAuditMistakeFomoBuying =>
      'Вы покупаете во время рыночного хайпа/эйфории! Вы гонитесь за зелёными свечами из-за FOMO.';

  @override
  String get psychologyAuditMistakePanicSelling =>
      'Вы продаёте активы в убыток при малейшей просадке рынка.';

  @override
  String get psychologyAuditMistakeLackDiversification =>
      'Вашему портфелю не хватает диверсификации. Слишком большая доля в одном активе резко увеличивает риск.';

  @override
  String get psychologyAuditMistakeOvertrading =>
      'Вы торгуете слишком часто. Каждая сделка обходится вам — притормозите и дважды подумайте перед действием.';

  @override
  String psychologyAuditMistakeBoughtAtPeak(String times) {
    return 'Вы покупали на пике $times. Это классический FOMO — покупка, когда все вокруг в эйфории.';
  }

  @override
  String psychologyAuditMistakeSoldAtBottom(String times) {
    return 'Вы продавали на дне $times. Панические продажи фиксируют убытки, которые могли бы восстановиться.';
  }

  @override
  String get psychologyAuditRiskConcentration =>
      'Высокий риск концентрации! Если ваш крупнейший актив упадёт, весь портфель пойдёт вниз вместе с ним.';

  @override
  String get psychologyAuditRiskNoSafetyNet =>
      'Нет подушки безопасности! Вы вложили 100% средств. Если сейчас случится «чёрный лебедь», у вас не будет кэша, чтобы выкупить просадку.';

  @override
  String get psychologyAuditRiskSingleSector =>
      'Вы только в 1 секторе. Спад в одной отрасли может свести на нет всю вашу прибыль.';

  @override
  String psychologyAuditRiskOvertrading(String rate) {
    return 'Тревога по перегрузке сделками! Вы совершаете $rate сделок в день. Высокая частота = больше стресса и ошибок.';
  }

  @override
  String get psychologyAuditRiskRealizedLosses =>
      'Ваши зафиксированные убытки накапливаются. Рассмотрите меньшие размеры позиций, пока не найдёте свой ритм.';

  @override
  String get psychologyAuditFreshTitle =>
      'Ваша симуляция рынка только началась!';

  @override
  String get psychologyAuditFreshTip =>
      'Делайте первые шаги обдуманно: диверсифицируйтесь по 3+ секторам и держите немного кэша в резерве, чтобы улучшить показатель Стратегии.';

  @override
  String get psychologyAuditTitle => 'Аудит действий в реальном времени';

  @override
  String psychologyAuditSubtitle(int score) {
    return 'Психологический показатель: $score/100';
  }

  @override
  String get psychologyAuditSectionRights => '🟢 Что вы делаете правильно';

  @override
  String get psychologyAuditSectionMistakes => '🔴 В чём вы допускаете ошибки';

  @override
  String get psychologyAuditSectionRisks => '⚠️ Активные риски';

  @override
  String get psychologyAuditAllClearTip =>
      'Пока всё в порядке. Продолжайте наблюдать за рынком и принимать взвешенные решения — не торопитесь.';

  @override
  String get marketPhaseWidgetTitle => 'ФАЗА РЫНКА';

  @override
  String get marketPhaseWidgetDetailsTooltip => 'Подробнее';

  @override
  String get marketClockFomoShieldStatusTitle => 'ИНДИКАТОР РИСКА';

  @override
  String get marketClockRiskDetailWhyNowLabel => 'Почему сейчас?';

  @override
  String get marketClockRiskDetailWhatToDoLabel => 'Что вам делать?';

  @override
  String get marketClockScreenTitle => 'РЫНОЧНЫЕ ЧАСЫ';

  @override
  String get marketClockAddWidgetsButton => 'Добавить виджеты';

  @override
  String get marketClockRiskTierLowLabel => 'НИЗКИЙ РИСК';

  @override
  String get marketClockRiskTierModerateLabel => 'УМЕРЕННЫЙ РИСК';

  @override
  String get marketClockRiskTierHighLabel => 'ВЫСОКИЙ РИСК';

  @override
  String get marketClockRiskTierClosedLabel => 'РЫНОК ЗАКРЫТ';

  @override
  String get marketClockMetricLiquidity => 'Ликвидность';

  @override
  String get marketClockMetricVolatility => 'Волатильность';

  @override
  String get marketClockMetricNewsRisk => 'Новостной риск';

  @override
  String get marketClockMetricFomoShield => 'F.O.M.O. Shield';

  @override
  String get marketClockRiskScoreLabel => 'ОЦЕНКА РИСКА';

  @override
  String get marketClockWidgetSettingsTitle => 'Настройки виджетов';

  @override
  String get marketClockWidgetSettingsReset => 'Сбросить';

  @override
  String get marketPeriodDetailFallbackTitle => 'ПЕРИОД';

  @override
  String get marketPeriodDetailWhatsHappeningLabel => 'Что происходит?';

  @override
  String get marketPeriodDetailWhyDoesItMatterLabel => 'Почему это важно?';

  @override
  String get marketPeriodDetailWhatCanGoWrongLabel => 'Что может пойти не так?';

  @override
  String get marketPeriodDetailWhatShouldBeginnersDoLabel =>
      'Что делать новичкам?';

  @override
  String get marketPeriodDetailOpenStressTestButton =>
      'Открыть симуляцию рынка';

  @override
  String get marketPeriodDetailFomoShieldTipLabel => 'СОВЕТ FOMO SHIELD';

  @override
  String get marketPhasesScreenTitle => 'ФАЗЫ РЫНКА';

  @override
  String get marketPhasesScreenNowBadge => 'СЕЙЧАС';

  @override
  String get marketPhasesScreenMoreLink => 'Ещё';

  @override
  String get assetsScreenTitle => 'Активы';

  @override
  String get assetsScreenNoAssets => 'Нет активов';

  @override
  String get assetsScreenTotalValueLabel => 'ОБЩАЯ СТОИМОСТЬ';

  @override
  String get assetsScreenStartCashLabel => 'СТАРТОВЫЙ КЭШ';

  @override
  String get assetsScreenSortValue => 'Стоимость';

  @override
  String get assetsScreenSortMarketPrice => 'Рыночная цена';

  @override
  String get assetsScreenDevPhaseLabel => 'ФАЗА';

  @override
  String get assetsScreenDevTempLabel => 'ТЕМП';

  @override
  String get assetsScreenDevFatigueLabel => 'УСТАЛОСТЬ';

  @override
  String get assetsScreenDevSeedLabel => 'СИД';

  @override
  String get assetsScreenDevTickLabel => 'ТИК';

  @override
  String assetsScreenDevNewsLabel(String symbol) {
    return 'НОВОСТИ $symbol';
  }

  @override
  String assetsScreenDevHypeLabel(String sector) {
    return 'ХАЙП $sector';
  }

  @override
  String assetsScreenDevTimeLeftHm(int hours, int minutes) {
    return '$hours ч $minutes мин осталось';
  }

  @override
  String assetsScreenDevTimeLeftM(int minutes) {
    return '$minutes мин осталось';
  }

  @override
  String get assetsScreenDevTimeEnding => 'завершается';

  @override
  String get stockDetailAppBarTitle => 'КАРТОЧКА КОМПАНИИ';

  @override
  String whyTodayScreenAppBarTitle(String symbol) {
    return 'ДИАГНОСТИКА $symbol';
  }

  @override
  String get whyTodayScreenTodaysChangeTitle => 'ИЗМЕНЕНИЕ ЗА СЕГОДНЯ';

  @override
  String get whyTodayScreenDollarsLabel => 'ДОЛЛАРЫ';

  @override
  String get whyTodayScreenPercentLabel => 'ПРОЦЕНТ';

  @override
  String get whyTodayScreenThisTickTitle => 'ЭТОТ ТИК — РАЗБИВКА ФАКТОРОВ';

  @override
  String get whyTodayScreenWholePeriodTitle =>
      'ВЕСЬ ПЕРИОД — РАЗБИВКА ФАКТОРОВ';

  @override
  String whyTodayScreenWholePeriodSubtitle(int tickCount) {
    return 'С учётом веса движения цены каждого тика — $tickCount тиков с момента первой покупки.';
  }

  @override
  String whyTodayScreenWholePeriodSubtitleRecentOnly(int tickCount) {
    return 'С учётом веса движения цены каждого тика — $tickCount тиков с момента первой покупки (только недавние — кэш ещё не накоплен).';
  }

  @override
  String get whyTodayScreenRawDriftTitle =>
      'СЫРЫЕ ЗНАЧЕНИЯ ДРЕЙФА (ПОСЛЕДНИЙ ТИК)';

  @override
  String get whyTodayScreenRawDriftSubtitle =>
      'Ненормализовано — до масштабирования 5 факторов выше в сумму 100%.';

  @override
  String get whyTodayScreenFactorMarketTrends => 'Рыночные тренды';

  @override
  String get whyTodayScreenFactorSector => 'Сектор';

  @override
  String get whyTodayScreenFactorNews => 'Новости';

  @override
  String get whyTodayScreenFactorSectorHype => 'Хайп сектора';

  @override
  String get whyTodayScreenFactorNoise => 'Шум';

  @override
  String get whyTodayScreenRawMarketDrift => 'Рыночный дрейф';

  @override
  String get whyTodayScreenRawSectorDrift => 'Секторный дрейф';

  @override
  String get whyTodayScreenRawHype => 'Хайп';

  @override
  String get whyTodayScreenNewsAndHypeTitle => 'НОВОСТИ И ХАЙП СЕКТОРА';

  @override
  String get whyTodayScreenMarketPhaseTitle => 'ФАЗА РЫНКА / ЭПОХИ';

  @override
  String whyTodayScreenNewsLiveLabel(String headline) {
    return 'Новость — В ЭФИРЕ: $headline';
  }

  @override
  String whyTodayScreenTargetDetail(String percent) {
    return 'цель $percent%';
  }

  @override
  String get whyTodayScreenSectorHypeLiveLabel => 'Хайп сектора — В ЭФИРЕ';

  @override
  String whyTodayScreenSectorTargetDetail(String percent) {
    return 'цель сектора $percent%';
  }

  @override
  String whyTodayScreenRemainingHm(int hours, int minutes) {
    return '≈$hours ч $minutes мин осталось';
  }

  @override
  String whyTodayScreenRemainingM(int minutes) {
    return '≈$minutes мин осталось';
  }

  @override
  String get whyTodayScreenWrappingUp => 'завершается';

  @override
  String whyTodayScreenNewsHistoryTitle(int count) {
    return 'ИСТОРИЯ НОВОСТЕЙ ($count)';
  }

  @override
  String get whyTodayScreenNoNewsEpisodes => 'Пока нет новостных эпизодов.';

  @override
  String whyTodayScreenSectorHypeHistoryTitle(int count) {
    return 'ИСТОРИЯ ХАЙПА СЕКТОРА ($count)';
  }

  @override
  String get whyTodayScreenNoHypeEpisodes => 'Пока нет эпизодов хайпа сектора.';

  @override
  String whyTodayScreenEpochSingle(int num) {
    return 'Эпоха $num';
  }

  @override
  String whyTodayScreenEpochRange(int start, int end) {
    return 'Эпоха $start–$end';
  }

  @override
  String whyTodayScreenEpochScenario(int num, String scenario) {
    return 'Эпоха $num — $scenario';
  }

  @override
  String get whyTodayScreenActiveLabel => 'активна';

  @override
  String get whyTodayScreenTicksTitle => 'Тики';

  @override
  String whyTodayScreenFactorMoved(String factor, int percent) {
    return '$factor изменил на $percent%';
  }

  @override
  String get whyTodayScreenEmptyStateMessage =>
      'Пока нет данных по тикам для этой позиции.';

  @override
  String get stockLimitOrdersTitle => 'ЛИМИТНЫЕ ОРДЕРА';

  @override
  String stockLimitOrdersSeeAll(int count) {
    return 'Показать все ордера ($count)';
  }

  @override
  String stockLimitOrdersSheetTitle(String symbol) {
    return 'Лимитные ордера $symbol';
  }

  @override
  String get stockPositionCardTitle => 'ВАША ПОЗИЦИЯ';

  @override
  String get stockPositionCardAssetValueLabel => 'Стоимость актива';

  @override
  String get stockPositionCardSharesLabel => 'Акции';

  @override
  String get stockPositionCardUnrealizedPnlLabel => 'Нереализ. P&L';

  @override
  String get stockPositionCardAvgCostLabel => 'Средняя цена';

  @override
  String get stockSparklineChartTitle => 'ГРАФИК ЦЕНЫ';

  @override
  String get whyTodayCardTitle => 'ПОЧЕМУ СЕГОДНЯ';

  @override
  String get whyTodayCardButtonLabel => 'Почему сегодня?';

  @override
  String get whyTodayCardTodaysChangeLabel => 'ИЗМЕНЕНИЕ ЗА СЕГОДНЯ';

  @override
  String get whyTodayCardPercentChangeLabel => 'ИЗМЕНЕНИЕ В %';

  @override
  String get whyTodayCardFactorMarketTrends => 'Рыночные тренды';

  @override
  String get whyTodayCardFactorSector => 'Сектор';

  @override
  String get whyTodayCardFactorNews => 'Новости';

  @override
  String get whyTodayCardFactorSectorHype => 'Хайп сектора';

  @override
  String get whyTodayCardFactorNoise => 'Шум';

  @override
  String get whyTodayCardHintNoData =>
      'Пока недостаточно данных по этой позиции — загляните после следующего тика цены, чтобы понять, что может её двигать.';

  @override
  String get whyTodayCardHintMarketBull =>
      'Широкая сила рынка может поддерживать эту позицию вместе с общим трендом сегодня.';

  @override
  String get whyTodayCardHintMarketSideways =>
      'Рынок в целом сейчас движется в боковике, что может удерживать эту позицию относительно ровной.';

  @override
  String get whyTodayCardHintMarketBear =>
      'Более широкое снижение рынка может давить на эту позицию вместе с остальным рынком.';

  @override
  String get whyTodayCardHintMarketVolatility =>
      'Резкие, разнонаправленные движения рынка могут быть причиной сегодняшних колебаний.';

  @override
  String get whyTodayCardHintMarketRecovery =>
      'Рынок может стабилизироваться после недавнего шока — это может объяснять сегодняшнее движение.';

  @override
  String get whyTodayCardHintMarketBlackSwan =>
      'Необычный резкий шок по всему рынку может двигать цену сегодня — стоит внимательно следить.';

  @override
  String get whyTodayCardHintMarketCrash =>
      'Резкая распродажа по всему рынку может сильно давить на эту позицию прямо сейчас.';

  @override
  String get whyTodayCardHintSector =>
      'Это движение может быть связано с тем, как торгуется сектор этой позиции относительно остального рынка.';

  @override
  String get whyTodayCardHintNews =>
      'За сегодняшним движением может стоять новость по компании — например, отчёт о прибыли.';

  @override
  String get whyTodayCardHintHype =>
      'Более широкая волна внимания ко всему сектору этой позиции может двигать цену сегодня.';

  @override
  String get whyTodayCardHintNoise =>
      'Сегодняшнее движение выглядит как обычные повседневные колебания цены без одного явного драйвера.';

  @override
  String stressTestOrderRowBuyLine(String quantity) {
    return 'Купить $quantity акций';
  }

  @override
  String stressTestOrderRowSellLine(String quantity) {
    return 'Продать $quantity акций';
  }

  @override
  String stressTestOrderRowLimitPriceLine(String price) {
    return 'Лимитная цена $price';
  }

  @override
  String get monetizationModalTitle => 'Достигнут лимит поиска';

  @override
  String get monetizationModalDescription =>
      'Вы использовали все бесплатные поиски. Оформите Premium для безлимитного поиска или посмотрите рекламу, чтобы получить ещё 15.';

  @override
  String get monetizationModalUpgradeButton => 'Оформить Premium';

  @override
  String get monetizationModalWatchAdButton =>
      'Посмотреть рекламу (+15 поисков)';

  @override
  String get monetizationModalCounterResetAdmin =>
      '🔧 Счётчик сброшен до 15 (админ)';

  @override
  String get monetizationModalResetCounterAdmin => 'Сбросить счётчик (админ)';

  @override
  String get monetizationModalSponsoredAd => 'Спонсорская реклама';

  @override
  String get monetizationModalRewardText =>
      'Ваша награда: +15 бесплатных поисков';

  @override
  String monetizationModalSecondsRemaining(int seconds) {
    return 'Осталось $seconds с';
  }

  @override
  String get monetizationModalSkip => 'Пропустить';

  @override
  String get monetizationModalComingSoon => '🏗️ Подписка Premium — скоро!';

  @override
  String get monetizationModalRewardEarned => '✓ Получено ещё 15 поисков!';

  @override
  String get premiumPromoOverlayBarrierLabel => 'Промо-заставка Premium';

  @override
  String get premiumPromoOverlayDefaultTitle => 'Функция Premium';

  @override
  String get premiumPromoOverlayBadge => 'PREMIUM';

  @override
  String get premiumPromoOverlaySubtitle =>
      'Оформите подписку, чтобы открыть это и многое другое';

  @override
  String get premiumPromoOverlayFeatureAdFree => 'Полностью без рекламы';

  @override
  String premiumPromoOverlaySecondsShort(int seconds) {
    return '$seconds с';
  }

  @override
  String premiumPromoOverlayClosingIn(int seconds) {
    return 'Закроется через $seconds с…';
  }

  @override
  String get premiumPromoOverlayClose => 'Закрыть';

  @override
  String get disclaimerScreenTitle => 'Дисклеймер';

  @override
  String get disclaimerScreenAccessRestricted => 'Доступ ограничен';

  @override
  String get disclaimerScreenAppWillClose => 'Приложение сейчас закроется';

  @override
  String get disclaimerScreenCloseAppButton => 'Закрыть приложение';

  @override
  String get disclaimerScreenImportantNoticeTitle => 'Важное уведомление';

  @override
  String get disclaimerScreenImportantNoticeBody =>
      'F.O.M.O. Shield — образовательный инструмент, созданный, чтобы помочь инвесторам понять поведение рынка и собственные модели принятия решений. Приложение не предоставляет финансовые консультации, инвестиционные рекомендации или какие-либо консультационные услуги.';

  @override
  String get disclaimerScreenFsScoresTitle => 'Независимость FS Score';

  @override
  String get disclaimerScreenFsScoresBody =>
      'FS Score и все связанные аналитические материалы — результат собственного анализа F.O.M.O. Shield на основе математических моделей и общедоступных данных. Мы не получаем вознаграждение от компаний за включение в рейтинги или изменение оценок. FS Score не являются рекомендацией покупать, продавать или держать какую-либо ценную бумагу.';

  @override
  String get disclaimerScreenDataSourcesTitle => 'Источники данных';

  @override
  String get disclaimerScreenDataSourcesBody =>
      'Рыночные данные предоставляются через API Finnhub и Wikipedia. Мы стремимся к точности, но не можем гарантировать полноту, точность или актуальность всех данных. Прошлые результаты не гарантируют будущих. Сценарии симуляции рынка основаны на математических моделях и исторических закономерностях.';

  @override
  String get disclaimerScreenPrivacyTitle => 'Конфиденциальность';

  @override
  String get disclaimerScreenPrivacyBody =>
      'Мы собираем минимум данных, необходимых для работы приложения: ваш email (для создания аккаунта) и данные, которые вы создаёте внутри приложения (портфели, список отслеживания, симуляции). Мы не продаём ваши данные третьим лицам.';

  @override
  String get disclaimerScreenTermsUpdatesTitle => 'Обновления условий';

  @override
  String get disclaimerScreenTermsUpdatesBody =>
      'Мы оставляем за собой право обновлять этот дисклеймер, Условия использования и Политику конфиденциальности. В случае изменений приложение уведомит вас и потребует повторного принятия обновлённых условий для продолжения работы.';

  @override
  String get disclaimerScreenAcceptPrefix =>
      'Я подтверждаю, что мне есть 18 лет, и полностью принимаю этот дисклеймер, ';

  @override
  String get disclaimerScreenTermsOfServiceLink => 'Условия использования';

  @override
  String get disclaimerScreenAcceptAndThe => ', а также ';

  @override
  String get disclaimerScreenPrivacyPolicyLink => 'Политику конфиденциальности';

  @override
  String get disclaimerScreenAcceptButton => 'Принимаю';

  @override
  String get disclaimerScreenLinkFailed =>
      'Не удалось открыть ссылку. Проверьте подключение к интернету.';

  @override
  String get accountRestoreScreenRestoreFailed =>
      'Не удалось восстановить аккаунт. Попробуйте ещё раз.';

  @override
  String get accountRestoreScreenTitle => 'Аккаунт назначен к удалению';

  @override
  String accountRestoreScreenDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'У вас осталось $count дня, чтобы восстановить аккаунт',
      many: 'У вас осталось $count дней, чтобы восстановить аккаунт',
      few: 'У вас осталось $count дня, чтобы восстановить аккаунт',
      one: 'У вас остался $count день, чтобы восстановить аккаунт',
    );
    return '$_temp0';
  }

  @override
  String accountRestoreScreenDeletionWarningSuffix(String date) {
    return ' — после $date он будет удалён навсегда, без возможности восстановления';
  }

  @override
  String get accountRestoreScreenAboutToErase =>
      'Этот аккаунт будет удалён навсегда, без возможности восстановления.';

  @override
  String get accountRestoreScreenRestoreButton => 'Восстановить аккаунт';

  @override
  String get forgotPasswordScreenEnterEmail => 'Пожалуйста, введите ваш email';

  @override
  String forgotPasswordScreenWaitSeconds(int seconds) {
    return 'Подождите $seconds сек. перед повторным запросом.';
  }

  @override
  String get forgotPasswordScreenTitle => 'Сброс пароля';

  @override
  String get forgotPasswordScreenSubtitle =>
      'Введите email, и мы отправим вам ссылку\nдля сброса пароля.';

  @override
  String get forgotPasswordScreenCheckEmail => 'Проверьте почту';

  @override
  String get forgotPasswordScreenSentMessage =>
      'Если этот email зарегистрирован в системе, мы отправили на него ссылку для сброса пароля.';

  @override
  String get forgotPasswordScreenDevModeNote =>
      'Режим разработки: ссылка для сброса выводится в консоль отладки.';

  @override
  String get forgotPasswordScreenSendButton => 'Отправить ссылку';

  @override
  String get forgotPasswordScreenBackToSignIn => 'Назад ко входу';

  @override
  String get authGoogleNoIdToken => 'Google не вернул ID-токен.';

  @override
  String get watchlistFullScreenEmptyTitle => 'Пока нет компаний';

  @override
  String get watchlistFullScreenEmptySubtitle =>
      'Нажмите +, чтобы найти и добавить компании';

  @override
  String get watchlistFullScreenSearchButton => 'Найти компании';

  @override
  String orderRowTilePriceLabel(String orderType, String price) {
    return '$orderType: цена $price';
  }

  @override
  String get orderCancelDialogTitle => 'Отменить ордер?';

  @override
  String get orderCancelDialogBody =>
      'Вы уверены, что хотите отменить этот ордер?';

  @override
  String get orderCancelDialogNo => 'Нет';

  @override
  String get orderCancelDialogYes => 'Да';

  @override
  String orderAmountSectionApproxUsd(String amount) {
    return '≈ $amount';
  }

  @override
  String orderAmountSectionAvailable(String cash) {
    return 'Доступно средств: $cash';
  }

  @override
  String get orderEntryNotifYouBought => 'Вы купили';

  @override
  String get orderEntryNotifYouSold => 'Вы продали';

  @override
  String orderEntryNotifFilledDetail(
    String quantity,
    String companyName,
    String price,
  ) {
    return '$quantity акций $companyName по цене $price';
  }

  @override
  String get orderEntryNotifBuyWord => 'Покупка';

  @override
  String get orderEntryNotifSellWord => 'Продажа';

  @override
  String orderEntryNotifOrderPlacedTitle(String orderType, String buyOrSell) {
    return '$buyOrSell ($orderType): ордер выставлен';
  }

  @override
  String orderEntryNotifPendingDetailBase(String quantity, String companyName) {
    return '$quantity акций $companyName';
  }

  @override
  String orderEntryNotifAtPrice(String price) {
    return ' по цене $price';
  }

  @override
  String get orderEntryNotifPendingSuffix => ' — в ожидании';

  @override
  String get verdictDisclaimerTitle => 'Дисклеймер';

  @override
  String get verdictDisclaimerBody =>
      'Обратите внимание: результаты симуляции рынка, оценки, выводы и текстовые комментарии, которые предоставляет это приложение, предназначены исключительно для образовательных и информационных целей.\n\nВсе вердикты формируются автоматически на основе анализа ваших решений в смоделированных рыночных сценариях, вдохновлённых историческими рыночными событиями и общепринятыми принципами долгосрочного инвестирования. Несмотря на все усилия сделать симуляции максимально реалистичными, они не могут учесть абсолютно все факторы, влияющие на реальные финансовые рынки.\n\nПрошлые рыночные события и историческая доходность не гарантируют, что похожие условия или результаты повторятся в будущем. Поведение реального рынка может существенно отличаться от сценариев, представленных в этом приложении. Любое сходство между симуляциями и реальными рыночными событиями следует рассматривать исключительно как образовательный пример, а не как прогноз.\n\nЭто приложение не предоставляет инвестиционных, финансовых, юридических или налоговых консультаций и не должно расцениваться как рекомендация покупать, продавать или держать какую-либо ценную бумагу, актив или финансовый инструмент.\n\nВсе инвестиционные решения пользователь принимает самостоятельно и несёт за них полную ответственность. Разработчики этого приложения не несут ответственности за какие-либо финансовые потери, упущенную выгоду, результаты инвестирования, а также за любой прямой, косвенный, случайный или последующий ущерб, возникший в результате использования приложения, его содержимого или решений, принятых на основе предоставленной информации.\n\nОсновная цель этого приложения — помочь пользователям лучше разобраться в основах инвестирования, диверсификации портфеля, управлении рисками, принципах долгосрочного инвестирования и психологических аспектах принятия инвестиционных решений. Весь контент предоставляется исключительно в образовательных целях и не может служить заменой профессиональной финансовой консультации или руководством для принятия реальных инвестиционных решений.';

  @override
  String get portfolioBalanceScreenTitle => 'БАЛАНС ПОРТФЕЛЯ';

  @override
  String get portfolioBalanceScreenDisclaimerTitle =>
      'Образовательный дисклеймер';

  @override
  String get portfolioBalanceScreenDisclaimerBody =>
      'Это приложение создано, чтобы помочь пользователям разобраться в инвестировании и управлении портфелем. Все оценки, показатели, симуляции и образовательные материалы предоставляются исключительно в информационных целях и не должны расцениваться как финансовая консультация или инвестиционная рекомендация.\n\nПриложение не указывает вам, что покупать, продавать или держать. Его задача — объяснять инвестиционные понятия, визуализировать характеристики портфеля и поддерживать обучение с помощью образовательных инструментов.\n\nИнвестирование связано с риском, и стоимость инвестиций может как расти, так и падать. Прошлые результаты и результаты симуляций не гарантируют будущей доходности. Всегда проводите собственное исследование и при необходимости обращайтесь за консультацией к лицензированному финансовому специалисту, прежде чем принимать инвестиционные решения.\n\nИспользуя это приложение, вы подтверждаете, что все инвестиционные решения остаются исключительно на вашей ответственности.';

  @override
  String get portfolioBalanceScreenAssetAllocationTitle =>
      'РАСПРЕДЕЛЕНИЕ АКТИВОВ, %';

  @override
  String get portfolioBalanceScreenDiversificationIndicatorTitle =>
      'ИНДИКАТОР ДИВЕРСИФИКАЦИИ';

  @override
  String get portfolioHealthWidgetTitle => 'ЗДОРОВЬЕ ПОРТФЕЛЯ';

  @override
  String get portfolioHealthWidgetDiversification => 'Диверсификация';

  @override
  String get portfolioHealthWidgetConcentration => 'Концентрация';

  @override
  String get portfolioHealthWidgetSectorBalance => 'Секторальный баланс';

  @override
  String get portfolioHealthWidgetStability => 'Стабильность';

  @override
  String get verdictStrategyCardTitle => 'СТРАТЕГИЯ';

  @override
  String get verdictStrategyCardConcentration => 'Концентрация';

  @override
  String get verdictStrategyCardEtfExposure => 'Доля ETF';

  @override
  String get verdictStrategyCardCashBuffer => 'Денежный буфер';

  @override
  String get verdictDiversificationCardTitle => 'ДИВЕРСИФИКАЦИЯ';

  @override
  String get verdictDiversificationCardSectorDiversification =>
      'Диверсификация по секторам';

  @override
  String get verdictDiversificationCardSafetyMarker => 'Маркер безопасности';

  @override
  String get verdictDiversificationCardSectorBalance => 'Секторальный баланс';

  @override
  String get psychologyStrategyWidgetTitle => 'СТРАТЕГИЯ';

  @override
  String get psychologyStrategyWidgetConcentration => 'Концентрация';

  @override
  String get psychologyStrategyWidgetEtfExposure => 'Доля ETF';

  @override
  String get psychologyStrategyWidgetCashBuffer => 'Денежный буфер';

  @override
  String get psychologyDiversificationWidgetTitle => 'ДИВЕРСИФИКАЦИЯ';

  @override
  String get psychologyDiversificationWidgetSectorBalance =>
      'Секторальный баланс';

  @override
  String get psychologyDiversificationWidgetSectorDiversification =>
      'Диверсификация по секторам';

  @override
  String get psychologyDiversificationWidgetSafetyMarker =>
      'Маркер безопасности';

  @override
  String get psychologyPatienceWidgetTitle => 'ТЕРПЕНИЕ';

  @override
  String get psychologyPatienceWidgetLabel => 'Терпение';

  @override
  String get psychologyPanicWidgetTitle => 'ПАНИКА';

  @override
  String get psychologyPanicWidgetLabel => 'Паника';

  @override
  String get psychologyDisciplineWidgetTitle => 'ДИСЦИПЛИНА';

  @override
  String get psychologyDisciplineWidgetLabel => 'Дисциплина';

  @override
  String get psychologyMeterScreenStrategyScore => 'ОЦЕНКА СТРАТЕГИИ';

  @override
  String get psychologyMeterScreenPsychologyScore => 'ОЦЕНКА ПСИХОЛОГИИ';

  @override
  String get psychologyMeterScreenSessionStats => 'СТАТИСТИКА СЕССИИ';

  @override
  String get verdictMarkerRowGood => 'Хорошо';

  @override
  String get verdictMarkerRowFair => 'Средне';

  @override
  String get verdictMarkerRowNeedsWork => 'Требует внимания';

  @override
  String get stressTestTradeHistoryScreenSessionNotFound => 'Сессия не найдена';

  @override
  String get stressTestTradeHistoryScreenNoTradesYet => 'Сделок пока нет';

  @override
  String get assetCountWidgetTitle => 'ПРОГРЕСС ДИВЕРСИФИКАЦИИ';

  @override
  String get assetCountWidgetAssetsLabel => 'АКТИВЫ';

  @override
  String get verdictMarkerDetailDiscipline => 'Дисциплина';

  @override
  String get verdictMarkerDetailPanic => 'Паника';

  @override
  String get verdictMarkerDetailPatience => 'Терпение';

  @override
  String get verdictMarkerDetailSectorDiversification =>
      'Диверсификация по секторам';

  @override
  String get verdictMarkerDetailSafetyMarker => 'Маркер безопасности';

  @override
  String get verdictMarkerDetailSectorBalance => 'Секторальный баланс';

  @override
  String get verdictMarkerDetailConcentration => 'Концентрация';

  @override
  String get verdictMarkerDetailEtfExposure => 'Доля ETF';

  @override
  String get verdictMarkerDetailCashBuffer => 'Денежный буфер';

  @override
  String get verdictMarkerDetailFallbackTitle => 'Вердикт';

  @override
  String get verdictScreenStrategyScoreLabel => 'ОЦЕНКА СТРАТЕГИИ';

  @override
  String get verdictScreenPsychologyScoreLabel => 'ОЦЕНКА ПСИХОЛОГИИ';

  @override
  String get verdictScreenDisciplineTitle => 'ДИСЦИПЛИНА';

  @override
  String get verdictScreenDisciplineLabel => 'Дисциплина';

  @override
  String get verdictScreenPanicTitle => 'ПАНИКА';

  @override
  String get verdictScreenPanicLabel => 'Паника';

  @override
  String get verdictScreenPatienceTitle => 'ТЕРПЕНИЕ';

  @override
  String get verdictScreenPatienceLabel => 'Терпение';

  @override
  String get notificationsScreenTitle => 'УВЕДОМЛЕНИЯ';

  @override
  String get notificationsScreenMarkAllRead => 'Отметить все как прочитанные';

  @override
  String get notificationsScreenEmptyState => 'Пока нет уведомлений.';

  @override
  String get notificationsRelativeTimeJustNow => 'сейчас';

  @override
  String notificationsRelativeTimeMinutesAgo(int count) {
    return '$count мин назад';
  }

  @override
  String notificationsRelativeTimeHoursAgo(int count) {
    return '$count ч назад';
  }

  @override
  String notificationsRelativeTimeDaysAgo(int count) {
    return '$count дн назад';
  }

  @override
  String get newsScenario0Headline => 'Прибыль превысила ожидания';

  @override
  String get newsScenario0Description =>
      'Компания отчиталась о квартальной выручке и прибыли выше прогнозов аналитиков.';

  @override
  String get newsScenario1Headline => 'Повышен годовой прогноз';

  @override
  String get newsScenario1Description =>
      'Руководство повысило прогноз по выручке и прибыли на текущий финансовый год.';

  @override
  String get newsScenario2Headline => 'Подписан крупный контракт';

  @override
  String get newsScenario2Description =>
      'Компания объявила о многолетнем соглашении с крупным корпоративным клиентом.';

  @override
  String get newsScenario3Headline => 'Объявлен байбэк акций';

  @override
  String get newsScenario3Description =>
      'Совет директоров одобрил масштабную программу обратного выкупа собственных акций.';

  @override
  String get newsScenario4Headline => 'Повышены дивиденды';

  @override
  String get newsScenario4Description =>
      'Компания повысила квартальные дивиденды и подтвердила стабильную дивидендную политику.';

  @override
  String get newsScenario5Headline => 'Сделка успешно закрыта';

  @override
  String get newsScenario5Description =>
      'Получены все необходимые согласования, и приобретение другой компании официально завершено.';

  @override
  String get newsScenario6Headline => 'Одобрен новый продукт';

  @override
  String get newsScenario6Description =>
      'Регулятор одобрил запуск нового продукта, открыв компании дополнительный источник дохода.';

  @override
  String get newsScenario7Headline => 'Программа сокращения расходов';

  @override
  String get newsScenario7Description =>
      'Компания объявила программу оптимизации, которая должна значительно снизить операционные расходы.';

  @override
  String get newsScenario8Headline => 'Погашение долга';

  @override
  String get newsScenario8Description =>
      'Компания досрочно погасила часть долговой нагрузки и улучшила баланс.';

  @override
  String get newsScenario9Headline => 'Расширение бизнеса';

  @override
  String get newsScenario9Description =>
      'Руководство объявило о выходе на новый международный рынок с запуском локальных операций.';

  @override
  String get newsScenario10Headline => 'Рост клиентской базы';

  @override
  String get newsScenario10Description =>
      'Число активных клиентов компании достигло рекордного значения.';

  @override
  String get newsScenario11Headline => 'Стратегическое партнёрство';

  @override
  String get newsScenario11Description =>
      'Компания подписала долгосрочное соглашение о сотрудничестве с лидером отрасли.';

  @override
  String get newsScenario12Headline => 'Прибыль не оправдала ожиданий';

  @override
  String get newsScenario12Description =>
      'Компания отчиталась о результатах ниже прогнозов аналитиков по прибыли и выручке.';

  @override
  String get newsScenario13Headline => 'Снижен прогноз';

  @override
  String get newsScenario13Description =>
      'Руководство понизило финансовый прогноз на оставшуюся часть года.';

  @override
  String get newsScenario14Headline => 'Сделка сорвалась';

  @override
  String get newsScenario14Description =>
      'Запланированное приобретение другой компании было отменено после долгих переговоров.';

  @override
  String get newsScenario15Headline => 'Отзыв продукции';

  @override
  String get newsScenario15Description =>
      'Компания начала масштабный отзыв продукции из-за производственного брака.';

  @override
  String get newsScenario16Headline => 'Кибератака';

  @override
  String get newsScenario16Description =>
      'Компания подтвердила кибератаку, затронувшую часть внутренних систем.';

  @override
  String get newsScenario17Headline => 'Уход генерального директора';

  @override
  String get newsScenario17Description =>
      'Генеральный директор неожиданно объявил об уходе с поста.';

  @override
  String get newsScenario18Headline => 'Подан иск';

  @override
  String get newsScenario18Description =>
      'Против компании подан крупный коллективный иск, связанный с её основным бизнесом.';

  @override
  String get newsScenario19Headline => 'Проблемы с поставками';

  @override
  String get newsScenario19Description =>
      'Компания предупредила о сбоях в цепочке поставок и возможных задержках производства.';

  @override
  String get newsScenario20Headline => 'Рост долговой нагрузки';

  @override
  String get newsScenario20Description =>
      'Компания отчиталась о значительном росте долга по итогам последнего отчётного периода.';

  @override
  String get newsScenario21Headline => 'Расследование регулятора';

  @override
  String get newsScenario21Description =>
      'Регулятор начал официальное расследование деятельности компании.';

  @override
  String get newsScenario22Headline => 'Потерян ключевой клиент';

  @override
  String get newsScenario22Description =>
      'Один из крупнейших клиентов компании отказался продлевать долгосрочный контракт.';

  @override
  String get newsScenario23Headline => 'Остановка производства';

  @override
  String get newsScenario23Description =>
      'Работа одного из основных производственных предприятий компании была временно приостановлена из-за технических проблем.';

  @override
  String get newsScenario24Headline => 'Объявлены сокращения';

  @override
  String get newsScenario24Description =>
      'Компания объявила о масштабной реструктуризации с сокращением персонала.';

  @override
  String notificationsPriceSwingTitleUp(String name, String percent) {
    return 'Акции $name выросли на $percent%';
  }

  @override
  String notificationsPriceSwingTitleDown(String name, String percent) {
    return 'Акции $name упали на $percent%';
  }

  @override
  String notificationsPriceSwingDetail(
    String duration,
    String symbol,
    String percent,
    int minutes,
  ) {
    return 'В вашем тесте «$duration»: $symbol изменился на $percent% за последние ~$minutes мин.';
  }

  @override
  String get notificationsStressTestCompletedTitle =>
      'Симуляция рынка завершена';

  @override
  String notificationsStressTestCompletedDetail(
    String duration,
    String percent,
  ) {
    return 'Тест «$duration» завершён — $percent% — нажмите, чтобы посмотреть вердикт.';
  }
}
