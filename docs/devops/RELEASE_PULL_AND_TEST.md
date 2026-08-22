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

**Готовые релизы** смотри в `https://github.com/vofka198119-code/fomoshield/releases`
(тег вида `v1.0.0-dev.<run>`). Но артефакты доступны уже **во время** run —
до того, как джоба Release закончила работу.

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

# 2) Скачать нужные артефакты
gh run download <run-id> -R vofka198119-code/fomoshield -n linux  -D .bin/<run-id>/linux
gh run download <run-id> -R vofka198119-code/fomoshield -n android -D .bin/<run-id>/android
gh run download <run-id> -R vofka198119-code/fomoshield -n iphone  -D .bin/<run-id>/iphone
```

> **Грабли `gh run download`:** он **распаковывает** содержимое артефакта.
> Для `windows` (артефакт = `ScanCo.zip`) это приводит к «распаковке внутри
> распаковки» и битому результату. Поэтому **Windows качаем напрямую по API**:

```powershell
# 3) Windows — напрямую через API (сохраняет ScanCo.zip целым)
$id = <artifact_id артефакта "windows">        # из списка артефактов, шаг 2
$t = gh auth token
New-Item -ItemType Directory -Force -Path .bin/<run-id>/windows | Out-Null
curl.exe -sL -H "Authorization: Bearer $t" -o .bin/<run-id>/windows/container.zip `
  "https://api.github.com/repos/vofka198119-code/fomoshield/actions/artifacts/$id/zip"
Expand-Archive .bin/<run-id>/windows/container.zip -DestinationPath .bin/<run-id>/windows -Force
Remove-Item .bin/<run-id>/windows/container.zip
```

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

## 6. Тестирование APK на Windows

APK **не запускается напрямую в Windows** — нужен Android-рантайм. Самый быстрый
вариант — **BlueStacks** (уже установлен) с adb:

```powershell
# adb от BlueStacks (в PATH его нет)
$adb = "C:\Program Files\BlueStacks_nxt\HD-Adb.exe"

# Подключиться к BlueStacks (порт по умолчанию) и проверить устройства
& $adb connect 127.0.0.1:5555
& $adb devices            # 127.0.0.1:5555  device  (+ возможно emulator-5554)

# Установить APK (applicationId = com.scanco.scanco)
& $adb -s 127.0.0.1:5555 install -r C:\fomoshield\.bin\<run-id>\android\ScanCo.apk

# Запустить приложение
& $adb -s 127.0.0.1:5555 shell monkey -p com.scanco.scanco -c android.intent.category.LAUNCHER 1

# Скриншот, чтобы увидеть UI
& $adb -s 127.0.0.1:5555 exec-out screencap -p > C:\fomoshield\bs_screenshot.png

# Логи приложения (flutter / UpdateService / ошибки)
& $adb -s 127.0.0.1:5555 logcat -d -s flutter | Select-String -Pattern 'UpdateService|Error'
```

Альтернативы: эмулятор **Android Studio** (AVD) или физическое устройство по USB —
та же команда `adb install -r ...` (тогда `adb` из `platform-tools`, добавить в PATH).

> Проверено: BlueStacks + HD-Adb установили и запустили `com.scanco.scanco`
> (сборка из `.bin/<run-id>/android/ScanCo.apk`) — UI рендерится, `.env` грузится,
> авто-обновление можно гонять прямо в BlueStacks.

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
- На iOS/desktop приложение установить не может — открывает страницу релиза GitHub.

### Настройка публичного репозитория релизов (один раз)

1. Создать **публичный** репозиторий `vofka198119-code/fomoshield-releases`
   (если название другое — поправить `_repo` в `lib/src/core/services/update_service.dart`
   и строку `repository:` в джобе `publish-public`).
2. Сделать минимум один коммит (README) — нужен HEAD дефолтной ветки.
3. В **приватном** репо: Settings → Secrets and variables → Actions → New secret
   **`RELEASE_PUBLISH_TOKEN`** = fine-grained PAT (Access: только публичный
   релизный репо, Permissions: **Contents: write**). Токен живёт только в CI —
   в приложение не попадает.
4. Пайплайн: джоба `publish-public` после сборки заливает `ScanCo.*` в публичный
   репозиторий с тем же тегом; приложение скачивает их анонимно.

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
gh release view -R vofka198119-code/fomoshield                                        # assets релиза
gh release download <tag> -R vofka198119-code/fomoshield -D .bin/<tag>                 # сразу из релиза
```
