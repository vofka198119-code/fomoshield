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
  String get navStressTest => 'Стресс-тест';

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
      'У вас будет 14 дней, чтобы восстановить аккаунт после этого. Если вы не восстановите его за это время, аккаунт и все данные — портфели, список наблюдения, история стресс-тестов — будут удалены безвозвратно, без возможности восстановления.';

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
  String get premiumBenefitPortfolios => 'До 3 портфелей';

  @override
  String get premiumBenefitCapital => 'Стартовый капитал \$50 000';

  @override
  String get premiumBenefitStressTests => 'До 5 стресс-тестов';

  @override
  String get premiumBenefitAdFree => 'Без рекламы';

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
  String get stressTestWidgetTitle => 'МОЙ СТРЕСС-ТЕСТ';

  @override
  String get stressTestActiveTests => 'Активные тесты';

  @override
  String get stressTestMyResults => 'МОИ РЕЗУЛЬТАТЫ';

  @override
  String stressTestMoreCompleted(int count) {
    return '+ещё $count завершено';
  }

  @override
  String get stressTestNoActiveTests => 'Нет активных тестов';

  @override
  String get stressTestStartNewTest => 'Начните новый тест с нижней панели';

  @override
  String get stressTestGoPremium => 'ПРЕМИУМ';

  @override
  String get stressTestPremiumLowercase => 'премиум';

  @override
  String stressTestActiveLabel(String duration) {
    return 'Активен — $duration';
  }

  @override
  String get stressTestHubTitle => 'СТРЕСС-ТЕСТ';

  @override
  String get stressTestCompletedTestsSheetTitle => 'Завершённые тесты';

  @override
  String get stressTestActiveTestsTitle => 'АКТИВНЫЕ ТЕСТЫ';

  @override
  String get stressTestCompletedTestsTitle => 'ЗАВЕРШЁННЫЕ ТЕСТЫ';

  @override
  String get stressTestNoCompletedTestsYet => 'Завершённых тестов пока нет';

  @override
  String get stressTestNoTestsYet => 'Стресс-тестов пока нет';

  @override
  String get stressTestNoTestsHint =>
      'Нажмите кнопку выше, чтобы начать первый тест';

  @override
  String get stressTestNewTest => 'Новый стресс-тест';

  @override
  String stressTestActiveCountFree(int active, int max) {
    return '$active/$max активно · Premium = до 5 одновременно';
  }

  @override
  String get stressTestEmotionalResilience =>
      'Проверьте свою устойчивость к эмоциям';

  @override
  String get stressTestLimitReachedTitle => 'Достигнут лимит стресс-тестов';

  @override
  String get stressTestMaxSessionsReached => 'Достигнут лимит активных тестов';

  @override
  String stressTestArchiveSummary(String amount, int holdings, int trades) {
    return 'Итог: $amount · $holdings активов · $trades сделок';
  }

  @override
  String get stressTestSessionNotFound => 'Сессия не найдена';

  @override
  String get stressTestSetupTitle => 'Настройка стресс-теста';

  @override
  String get stressTestDurationSectionTitle => 'ДЛИТЕЛЬНОСТЬ ТЕСТА';

  @override
  String get stressTestStartButton => 'НАЧАТЬ СТРЕСС-ТЕСТ';

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
      'Эта длительность теста доступна только подписчикам Premium. Перейдите на Premium, чтобы открыть неограниченные возможности.';

  @override
  String get stressTestUpgradeToPremium => 'Перейти на Premium';

  @override
  String get stressTestNotNow => 'Не сейчас';

  @override
  String get stressTestCustomDurationTitle => 'Своя длительность теста';

  @override
  String get stressTestCustomDurationWarning =>
      'После запуска тест со своей длительностью нельзя прервать или остановить досрочно. Симуляция будет выполняться весь выбранный ниже период.';

  @override
  String stressTestDaysCount(int days) {
    return '$days дн.';
  }

  @override
  String get stressTestMinDays => 'Мин.: 5 дней';

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
  String get stressTestIAgreeStart => 'Согласен — начать тест';

  @override
  String get stressTestDisclaimerIntro =>
      'Этот стресс-тест использует специализированный алгоритмический движок, который симулирует экстремальные рыночные сценарии, включая затяжные медвежьи тренды, системные кризисы и полные обвалы финансовых рынков.';

  @override
  String get stressTestDisclaimerAck =>
      'Перед началом симуляции, пожалуйста, прочитайте и подтвердите следующее:';

  @override
  String get stressTestBulletScenarios =>
      'Симулированные сценарии — обвалы, кризисы и рыночные движения, генерируемые движком, являются гипотетическими математическими моделями. Они предназначены для проверки устойчивости портфеля в стрессовых условиях и не являются прогнозом реального поведения рынка.';

  @override
  String get stressTestBulletNotAdvice =>
      'Это не финансовая консультация — итоговый вердикт, аналитика и любые выводы, сделанные по результатам этого теста, предназначены только для информационных и образовательных целей. Они не являются персональной инвестиционной консультацией, рекомендацией покупать или продавать активы, а также любой формой финансового предложения.';

  @override
  String get stressTestBulletObjective =>
      'Объективная математическая оценка — итоговый вердикт и баллы формируются автоматически. Наш движок построен на признанных научных методах (включая симуляцию Монте-Карло, анализ хвостовых рисков и современные модели стресс-тестирования портфеля). Алгоритм полностью независим: он исключает человеческую предвзятость, эмоции и коммерческие интересы третьих сторон. Тем не менее важно помнить, что любая математическая модель имеет свои ограничения и не может предсказать абсолютно каждый реальный рыночный сценарий.';

  @override
  String get stressTestBulletLiability =>
      'Ограничение ответственности — положительный результат теста (то есть успешное «выживание» вашего портфеля при симулированном обвале рынка) не гарантирует аналогичного результата в реальных условиях. Платформа и её разработчики не несут ответственности за ваши инвестиционные решения, а также за любые прямые или косвенные убытки, включая, помимо прочего, потерю капитала на реальных рынках.';

  @override
  String get stressTestBulletPastPerformance =>
      'Прошлые результаты в этом симуляторе не гарантируют, не прогнозируют и не отражают реальные рыночные результаты. Любая торговая деятельность в реальной жизни сопряжена с существенным риском и осуществляется исключительно по вашему собственному усмотрению и под вашу ответственность.';

  @override
  String get stressTestEndOfDisclaimer => '▸ Конец дисклеймера';

  @override
  String get stressTestUnlimitedTesting => 'Неограниченное тестирование';

  @override
  String get stressTestInfiniteUpsellBody =>
      'Стресс-тест с бесконечной длительностью доступен исключительно подписчикам Premium. Перейдите на Premium, чтобы получить:';

  @override
  String get stressTestUpsellUnlimitedDuration =>
      'Неограниченную длительность теста';

  @override
  String get stressTestUpsellFullCrashScenarios =>
      'Полные сценарии обвала рынка';

  @override
  String get stressTestUpsellAdvancedAnalytics =>
      'Расширенную аналитику портфеля';

  @override
  String get stressTestAccessTitle => 'Доступ к стресс-тесту';

  @override
  String get stressTestPortfolioTitle => 'ПОРТФЕЛЬ СТРЕСС-ТЕСТА';

  @override
  String get stressTestNotStartedYet => 'Тест ещё не начат';

  @override
  String get stressTestGoBackToSetup =>
      'Вернитесь к настройке и запустите тест';

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
  String get stressTestTestComplete => 'Тест завершён';

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
  String get stressTestFinishTestButton => 'ЗАВЕРШИТЬ ТЕСТ';

  @override
  String get stressTestFinishTest => 'Завершить тест';

  @override
  String get stressTestFinishTestConfirm =>
      'Завершить тест сейчас и получить вердикт? Это действие нельзя отменить.';

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
  String get stressTestInvestmentDisclaimerTitle =>
      'ИНВЕСТИЦИОННЫЙ ДИСКЛЕЙМЕР\nИ ОГРАНИЧЕНИЕ ОТВЕТСТВЕННОСТИ';

  @override
  String get stressTestInvestmentDisclaimerBody =>
      'Этот вердикт формируется автоматически математической моделью исключительно на основе вашего смоделированного исторического поведения в этой закрытой тестовой среде. Он предоставляется только в образовательных и иллюстративных целях и НЕ является персональной инвестиционной, юридической или финансовой консультацией. Прошлые результаты в этом симуляторе не гарантируют, не прогнозируют и не отражают реальные рыночные результаты. Итоговые финансовые решения, покупка активов или торговая деятельность в реальной жизни сопряжены с существенным риском и осуществляются исключительно по вашему собственному усмотрению и под вашу ответственность. Создатели F.O.M.O. Shield не несут ответственности за финансовые убытки, понесённые при реальной торговле.';

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
  String get portfolioDeleteMenu => 'Удалить портфель';

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
  String get portfolioDeleteDialogTitle => 'Удалить портфель?';

  @override
  String get portfolioDeleteDialogBody =>
      'Все активы и история будут потеряны.';

  @override
  String get portfolioCannotDeleteLast =>
      'Нельзя удалить последний портфель. Сначала создайте новый.';

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
      'Результаты этого стресс-теста являются исключительно результатом компьютерной симуляции и предоставлены только в образовательных и учебных целях. Они основаны на заданных моделью сценариях и исторических рыночных событиях и не отражают, не предсказывают и не гарантируют результаты какого-либо портфеля в реальных рыночных условиях.\n\nРеальное поведение рынка, отдельных компаний и финансовых активов может существенно отличаться от результатов симуляции. Прошлые рыночные события и результаты не гарантируют аналогичных результатов в будущем.\n\nЛюбые оценки, рейтинги, вердикты или иные показатели, представленные в тесте, не являются инвестиционной, финансовой или иной профессиональной консультацией, а также не являются рекомендацией, предложением или побуждением покупать либо продавать какой-либо финансовый актив или основанием для принятия инвестиционных решений.\n\nЛюбое решение, принятое с использованием или с учётом информации, предоставленной приложением, принимается исключительно по усмотрению и на риск пользователя. Мы не гарантируем прибыль и не несём ответственности за какие-либо финансовые потери, убытки или упущенную выгоду, возникшие в результате использования симуляции или её результатов.\n\nЦель стресс-теста — помочь пользователям изучить рыночные сценарии, принципы инвестирования и собственное поведение в смоделированной среде, а не предсказать будущее.';

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
}
