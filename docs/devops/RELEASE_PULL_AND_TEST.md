# ScanCo — Pulling releases & testing builds locally

> Как скачивать релизные билды из GitHub Actions / Releases и тестировать их
> на Windows (PowerShell + WSL2), Android (эмулятор/устройство) и macOS.

---

## 1. GitHub CLI — установка и вход

```powershell
winget install GitHub.cli
gh auth login        # GitHub.com → SSH (использовать существующий ключ) → web browser
gh auth status       # проверить: Logged in as <you>
```

> Токен НЕ передавать в чат/скрипты — `gh` хранит его сам.

---

## 2. Найти нужный запуск (run)

```powershell
# Последние запуски пайплайна (workflow release.yml)
gh run list -R vofka198119-code/fomoshield --workflow release.yml --limit 5

# Статус конкретного run и его джобы
gh run view <run-id> -R vofka198119-code/fomoshield
gh api repos/vofka198119-code/fomoshield/actions/runs/<run-id>/jobs --jq '.jobs[] | .name+" | "+.status+" | "+(.conclusion//"n/a")'

# Артефакты run (это то, что потом попадает в релиз)
gh api repos/vofka198119-code/fomoshield/actions/runs/<run-id>/artifacts --jq '.artifacts[] | .name+" | "+(.size_in_bytes|tostring)+" | "+(.id|tostring)'
```

**Готовые релизы** (финальные бинарники, без токена) — в **публичном** зеркале:
`https://github.com/vofka198119-code/fomoshield-releases/releases`
(тег вида `v1.0.0-{label}.<run>`, см. схему ниже). В приватном
`vofka198119-code/fomoshield` тоже есть Release, но качать оттуда без токена
нельзя. Артефакты доступны уже **во время** run — до того, как джоба Release
закончила работу.

---

### 2.2 Как называются релизы (схема тегов)

Префикс `dev` в `v1.0.0-dev.35` — **не хардкод**. Джоба `bump-version` выводит
пре-релизный тег из имени ветки:

| Ветка (push)          | Тег                         | label  |
|-----------------------|-----------------------------|--------|
| `main` / `master`     | `v1.0.0-main.35`            | `main` |
| `dev` / `develop`     | `v1.0.0-dev.35`             | `dev`  |
| любая другая (sanitized) | `v1.0.0-feature-auto-update.35` | `feature-auto-update` |
| тег `v*` (stable)     | `v1.0.1` (как в pubspec)     | `stable` |

- Один и тот же workflow работает на любой ветке — не нужно править пайплайн
  для нового окружения.
- **Приоритет** (кто «важнее», семантически): `stable` > `main` > `dev` > другая
  ветка > числовой label. Updater **label-aware** (`--dart-define=APP_LABEL`):
  `main`-сборка считается новее `dev`-сборки даже с меньшим run-номером, а
  `dev` никогда не перекроет `main`.
- Стабильный тег `v*` никогда не авто-бампается и имеет наивысший приоритет.

---

### 2.1 Чтение логов запусков — только через GitHub CLI

GitHub не отдаёт логи по прямой ссылке без авторизации — читать логи раннера
можно **только через GitHub CLI** (или REST API с токеном). Стрим-вывод прямо в
терминал:

```powershell
gh run view <run-id> -R vofka198119-code/fomoshield --log
```

**Скачивать логи в `.github/.logs/` НЕ обязательно.** Это просто локальный кэш
для удобного офлайн-анализа (grep по большому логу, сравнение запусков). Если
работаешь только через `gh` — достаточно стрима выше. Если нужен локальный
файл (например, чтобы искать `##[error]`/`##[warning]` по всему запуску):

```powershell
gh run view <run-id> -R vofka198119-code/fomoshield --log > .github/.logs/run-<id>.log
```

Формат лога: строки `тab-разделены` — `<job> <step> <message>`.

---

## 3. Скачивание executables → `.bin/{actionId}/{platform}/`

**Правило папок:** всегда кладём **исполняемые файлы** (не архивы) в
`.bin/<run-id>/<platform>/`. `<run-id>` — это action id запуска GitHub Actions.

**Важно:** при каждом новом pull сначала **удаляй старые** `.bin/<run-id>/*`:

```powershell
# 1) Почистить прошлый pull (оставить только последний)
Get-ChildItem .bin -Directory | Where-Object Name -match '^\d+$' | Remove-Item -Recurse -Force
```

**Способ А (основной, без токена) — из ПУБЛИЧНОГО релизного репозитория:**
`gh release download` сохраняет файлы **как есть** (никакой самовольной распаковки):

```powershell
$TAG = v1.0.0-dev.<run>   # тег из публичного релиза
$RID = <run-id>           # id запуска (для имени папки .bin)

gh release download $TAG -R vofka198119-code/fomoshield-releases -p "ScanCo.apk"     -D .bin/$RID/android
gh release download $TAG -R vofka198119-code/fomoshield-releases -p "ScanCo.zip"     -D .bin/$RID/windows
gh release download $TAG -R vofka198119-code/fomoshield-releases -p "ScanCo.tar.gz" -D .bin/$RID/linux
gh release download $TAG -R vofka198119-code/fomoshield-releases -p "ScanCo.dmg"     -D .bin/$RID/macos
gh release download $TAG -R vofka198119-code/fomoshield-releases -p "ScanCo.ipa"     -D .bin/$RID/iphone
```

**Способ Б (альтернатива, пока идёт run) — артефакты из приватного CI:**

```powershell
gh run download <run-id> -R vofka198119-code/fomoshield -n linux  -D .bin/<run-id>/linux
gh run download <run-id> -R vofka198119-code/fomoshield -n android -D .bin/<run-id>/android
gh run download <run-id> -R vofka198119-code/fomoshield -n iphone  -D .bin/<run-id>/iphone
```

> **Грабли `gh run download`:** он **распаковывает** содержимое артефакта.
> Для `windows` (артефакт = `ScanCo.zip`) это «распаковка внутри распаковки» и
> битый результат — поэтому Windows из артефактов качают напрямую по API
> (`/actions/artifacts/{id}/zip` + Expand-Archive). Способ А этих граблей лишён.

### 3.1 Извлекаем executables и выбрасываем архивы

| Платформа | Артефакт | Что оставляем в `.bin/<run-id>/<platform>/` |
|---|---|---|
| Linux | `ScanCo.tar.gz` | `tar -xzf ScanCo.tar.gz -C .bin/<run-id>/linux` → `./scanco`, `./data`, `./lib`; удалить `.tar.gz` |
| Windows | `ScanCo.zip` | уже распакован шагом 3 → `scanco.exe`, `data\`, `*.dll`; удалить `.zip` |
| Android | `ScanCo.apk` | сам `.apk` (это и есть исполняемый пакет) |
| iPhone | `ScanCo.ipa` | сам `.ipa` (подписанный бандл) |
| macOS | `ScanCo.dmg` | сам `.dmg` (образ диска) |

---

## 4. Тестирование на Windows (PowerShell)

```powershell
# Запуск exe
Start-Process -FilePath "C:\fomoshield\.bin\<run-id>\windows\scanco.exe" `
  -WorkingDirectory "C:\fomoshield\.bin\<run-id>\windows"

# Проверка, что приложение живое (окно открыто), затем закрыть
Get-Process scanco | Stop-Process -Force

# Лог приложения (FileLogger пишет рядом с exe)
Get-Content "C:\fomoshield\.bin\<run-id>\windows\logs\app.log" -Tail 30
```

Окно должно открыться и не падать. Если приложение «пустое/белое» — смотреть `logs\app.log`.

---

## 5. Тестирование Linux (WSL2) — на Windows

WSL2 обязателен: Linux ELF не запускается нативно в Windows. Дистрибутив Ubuntu
уже установлен (`wsl -l -v`).

```powershell
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/fomoshield/.bin/<run-id>/linux && ./scanco'
```

**Зависимости Ubuntu** (поставить один раз):

```bash
sudo apt-get update
sudo apt-get install -y libgtk-3-0 liblzma5 libsecret-1-0 libjsoncpp25 \
  libgles2 libegl1 libgl1 libgl1-mesa-dri libglx-mesa0   # OpenGL/EGL стек
```

> Без `libsecret-1-0` → `libsecret-1.so.0 => not found` (нужен flutter_secure_storage).
> Без Mesa/GLES (`libGLESv2.so.2`) → краш при старте: `egl: failed to create dri2 screen`.
> GUI выводится через WSLg (Windows 11) автоматически; рендер — программный (llvmpipe).

**Headless-прогон** (проверка, что стартует, 12 сек):

```bash
timeout 12 ./scanco 2>&1 | head -40   # app живёт и логирует → exit не мгновенный
```

---

## 6. Тестирование APK на Windows — Android Studio Emulator

APK **не запускается напрямую в Windows** — нужен Android-рантайм. Основной
вариант — **эмулятор Android Studio (AVD)**. BlueStacks больше не используется.

### 6.1 Первичная настройка (один раз)

1. **Скачать Android Studio**: https://developer.android.com/studio (официальная
   страница). Установщик включает IDE + Android SDK + эмулятор + AVD Manager.
2. **Запустить Android Studio** → «More Actions» → **SDK Manager** →
   установить последний **Android SDK Platform** и **Android SDK Build-Tools**.
3. **Device Manager** (иконка справа) → **Create device** → выбрать образ
   (например, Pixel + Android 14/15) → Finish.
4. **Запустить эмулятор**: Device Manager → ▶ (play) на созданном AVD.
   Окно эмулятора откроется как обычное приложение Windows.

`adb` теперь доступен из `platform-tools` внутри SDK:
`C:\Users\<you>\AppData\Local\Android\Sdk\platform-tools\adb.exe` — добавить
`...\platform-tools` в PATH или использовать полный путь.

### 6.2 Установка и запуск APK

```powershell
# adb из Android SDK platform-tools
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"

# Эмулятор регистрируется как локальное устройство (emulator-5554)
& $adb devices             # emulator-5554  device

# Установить APK (applicationId = com.scanco.scanco)
& $adb -s emulator-5554 install -r C:\fomoshield\.bin\<run-id>\android\ScanCo.apk

# Запустить приложение
& $adb -s emulator-5554 shell monkey -p com.scanco.scanco -c android.intent.category.LAUNCHER 1

# Скриншот, чтобы увидеть UI
& $adb -s emulator-5554 exec-out screencap -p > C:\fomoshield\emu_screenshot.png

# Логи приложения (flutter / UpdateService / ошибки)
& $adb -s emulator-5554 logcat -d -s flutter | Select-String -Pattern 'UpdateService|Error'
```

> Проверено: эмулятор Android Studio установил и запустил `com.scanco.scanco`
> (сборка из `.bin/<run-id>/android/ScanCo.apk`) — UI рендерится, `.env` грузится,
> авто-обновление можно гонять прямо в эмуляторе.

Альтернатива: физическое устройство по USB — та же команда `adb install -r ...`
(тогда `adb` из `platform-tools`, включить USB-отладку на телефоне).

---

## 7. Тестирование IPA на Windows

**.ipa нельзя установить на Windows** — iOS-приложения собираются и ставятся
только через экосистему Apple:

- Прямая установка (Ad Hoc) требует **macOS + Xcode** + подписанный профиль.
- Самый простой путь: загрузить IPA в **App Store Connect → TestFlight**
  (нужен аккаунт разработчика, $99/год) и тестировать через TestFlight на iPhone/iPad.
- На Windows можно только **посмотреть содержимое** IPA (это zip):
  ```powershell
  Expand-Archive C:\fomoshield\.bin\<run-id>\iphone\ScanCo.ipa C:\tmp\ipa
  ```

---

## 8. Тестирование на macOS

Бандл собирается как **`scanco.app`** (project-name `scanco`; отображаемое имя —
ScanCo). Сборка **без подписи (unsigned)** — Gatekeeper будет предупреждать.

**Установка из DMG:**
```bash
hdiutil attach ScanCo.dmg                          # смонтировать
cp -R /Volumes/ScanCo/scanco.app /Applications/    # скопировать в Applications
hdiutil detach /Volumes/ScanCo                     # размонтировать
```

**Запуск:**
```bash
open /Applications/scanco.app                      # как двойной клик
# Или напрямую бинарник (виден stdout/FileLogger в терминале):
/Applications/scanco.app/Contents/MacOS/scanco
```

**Gatekeeper (unsigned):** разово снять quarantine, либо `ПКМ → Open → Open`:
```bash
xattr -dr com.apple.quarantine /Applications/scanco.app
```

**Проверка, что живое / закрыть (по аналогии с Windows):**
```bash
pgrep -x scanco        # PID если запущено
pkill -x scanco        # закрыть
```

**Лог FileLogger** — пишется рядом с бинарником, т.е. внутри бандла:
```bash
tail -30 "/Applications/scanco.app/Contents/MacOS/logs/app.log"
```

---

## 9. Проверка авто-обновления

- Приложение читает релизы из **публичного** репозитория
  `vofka198119-code/fomoshield-releases` (зеркало бинарников) — **без токена**.
  Приватный репозиторий исходников не используется и не раскрывается.
- На Android обновление работает в приложении: примерно через **5 сек** после
  запуска (и по кнопке **⟳** на Профиле) приложение проверяет GitHub Releases,
  показывает «New Version Available» → скачивает APK в приложении (с прогрессом)
  → отдаёт **системному установщику Android** (нужно подтверждение пользователя).
- APK должен быть **подписан тем же ключом**, что установленная сборка (иначе
  signature mismatch). Android 8+ может один раз спросить «Install unknown apps».
- Версия на Профиле: **`v1.0.0 (24) ⟳`** — version (build); build = CI run number
  (из `--dart-define=APP_BUILD`), не статичный номер из pubspec.
- Updater **build-aware**: не предлагает `dev.N`, если установлена та же N.
- Updater **label-aware** (`--dart-define=APP_LABEL`): уважает приоритет веток
  `main > dev > other`, т.е. не «понижает» установку (см. §2.2).
- На iOS/desktop приложение установить не может — открывает страницу релиза GitHub.

### Публичный репозиторий релизов (настроено ✅)

- Публичное зеркало: `vofka198119-code/fomoshield-releases` — джоба `publish`
  (единственный релизный шаг) после сборки заливает `ScanCo.*` с тем же тегом;
  приложение качает их анонимно.
- README-коммит и секрет `RELEASE_PUBLISH_TOKEN` (fine-grained PAT, Contents: write
  на публичный репо) уже настроены. Пошаговая настройка (если нужно повторить):
  `docs/devops/vofka_secret_setup.md`.
- Если название репозитория изменится — поправить `_repo` в
  `lib/src/core/services/update_service.dart` и строку `repository:` в джобе
  `publish`.

---

## 10. Известные проблемы (на момент проверки run #25)

- **Desktop GoogleSignIn:** `GoogleSignIn.initialize()` в `_SplashScreenState.initState`
  (`lib/src/features/splash/splash_screen.dart`) бросает `UnimplementedError` на
  Windows/Linux/macOS. Не крашит приложение (ловится zone guard), но Sign-In на
  desktop не работает — планируется фикс: пропускать GoogleSignIn на non-mobile.

---

## Полезные gh-команды

```powershell
gh run list -R vofka198119-code/fomoshield --workflow release.yml --limit 5
gh run view <run-id> -R vofka198119-code/fomoshield --log            # стрим логов (только gh)
gh run view <run-id> -R vofka198119-code/fomoshield --log > .github/.logs/run-<id>.log   # ОПЦИОНАЛЬНО: локальный кэш для grep
gh release view -R vofka198119-code/fomoshield-releases                              # assets публичного релиза
gh release download <tag> -R vofka198119-code/fomoshield-releases -p "ScanCo.*" -D .bin/<run-id>  # без токена
```
