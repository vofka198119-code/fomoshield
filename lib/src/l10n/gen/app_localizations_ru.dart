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
      'Ваш стресс-тест завершён. Вы прошли через разные рыночные условия и увидели, как ваш портфель и решения на них реагировали. Пришло время узнать, что результаты говорят о вашем инвестиционном поведении.';

  @override
  String get verdictViewYourAnalysis => 'Смотреть анализ →';

  @override
  String get verdictHoldingsLabel => 'Активы';

  @override
  String get verdictFinalPnlLabel => 'Итоговый P&L';

  @override
  String get verdictStartingCashLabel => 'Начальные наличные';

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
