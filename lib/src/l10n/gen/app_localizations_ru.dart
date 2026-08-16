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
}
