# towebp i toavif – instrukcja instalacji

Stan na 17.10.2026

## Czym są towebp i toavif

To dwa narzędzia w terminalu, które hurtowo zamieniają obrazy JPG/JPEG i PNG na nowoczesne, lżejsze formaty: **towebp** na WebP, **toavif** na AVIF. Instaluje się je dwiema komendami przez Homebrew, a całość zajmuje około 5 minut.

- Konwertują wiele plików naraz: domyślnie tyle równolegle, ile procesor ma rdzeni.
- Nie psują plików: wynik powstaje najpierw jako plik tymczasowy, a istniejący `.webp`/`.avif` nigdy nie jest nadpisywany.
- Oryginały zostają, chyba że sam dodasz opcję `--delete`.
- Mogą działać w tle (cron) i automatycznie konwertować nowe obrazy, np. w folderze Pobrane.

Kod źródłowy: [mnich/towebp](https://github.com/mnich/towebp), [mnich/toavif](https://github.com/mnich/toavif). Aktualna wersja obu narzędzi: 1.1.0.

## Wymagania

Potrzebujesz tylko macOS i Homebrew. Narzędzia sprawdziłem na macOS z procesorem Apple Silicon. Na Macu z Intelem i na Linuksie z Homebrew powinny działać tak samo, ale tego nie testowałem.

1. Otwórz aplikację **Terminal** (Spotlight: ⌘ Spacja, wpisz „Terminal”).
2. Sprawdź, czy masz Homebrew:

   ```bash
   brew --version
   ```

   Jeśli widzisz numer wersji, przejdź do kolejnej sekcji.
3. Jeśli pojawi się `command not found: brew`, zainstaluj Homebrew oficjalnym skryptem ze strony [brew.sh](https://brew.sh):

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
4. Na końcu instalator wypisze sekcję **Next steps** z dwiema komendami dodającymi `brew` do `PATH`. Wykonaj je, zamknij Terminal i otwórz go ponownie, a potem jeszcze raz sprawdź `brew --version`.

Pozostałe zależności (`cwebp` z pakietu `webp`, `avifenc` z pakietu `libavif`) Homebrew zainstaluje sam razem z narzędziami.

## Instalacja

Narzędzia instaluje się z własnego repozytorium Homebrew (tzw. tapu) `mnich/tools`. Możesz zainstalować oba albo tylko jedno.

1. Dodaj tap (jednorazowo):

   ```bash
   brew tap mnich/tools
   ```
2. Zainstaluj narzędzia:

   ```bash
   brew install towebp toavif
   ```

   Tylko jedno: `brew install towebp` albo `brew install toavif`.
3. Sprawdź, czy działają:

   ```bash
   towebp --version
   toavif --version
   ```

   Powinno się pojawić `towebp 1.1.0` i `toavif 1.1.0`.

## Użycie ręczne

Zawsze podawaj folder (`-d`). Bez niego narzędzie przetworzy cały folder `~/Downloads` razem ze wszystkimi podfolderami, a to mogą być dziesiątki tysięcy obrazów.

```bash
towebp -d <folder> [opcje]
toavif -d <folder> [opcje]
```

| Opcja | Co robi | Domyślnie |
| --- | --- | --- |
| `-d`, `--dir <folder>` | Folder z obrazami | `~/Downloads` |
| `-q`, `--quality <0-100>` | Jakość wyniku | towebp: 80, toavif: 60 |
| `-s`, `--speed <0-10>` | Tylko toavif: szybkość kodowania, 0 = najwolniej i najmniejszy plik | 6 |
| `-t`, `--threads <n>` | Ile plików konwertować jednocześnie | liczba rdzeni |
| `--max-depth <n>` | Jak głęboko wchodzić w podfoldery; `1` = tylko wskazany folder | bez limitu |
| `--newer-than <plik>` | Tylko obrazy dodane po ostatniej zmianie wskazanego pliku | wyłączone |
| `--min-age <minuty>` | Pomija pliki zmienione w ostatnich N minutach (np. jeszcze pobierane) | 0 |
| `--delete` | Usuwa oryginał po udanej konwersji | wyłączone |
| `-h`, `--help` / `-v`, `--version` | Pomoc / wersja | |

Przykłady:

```bash
# Zdjęcia z jednego folderu, bez podfolderów, oryginały zostają
towebp -d ~/Desktop/zdjecia --max-depth 1

# Wyższa jakość AVIF, wolniejsze i dokładniejsze kodowanie
toavif -d ~/Desktop/zdjecia -q 70 -s 4

# Konwersja z usunięciem oryginałów
towebp -d ~/Desktop/zdjecia --delete
```

Obraz jest pomijany, jeśli obok leży już plik o tej samej nazwie z rozszerzeniem `.webp`/`.avif`. Ponowne uruchomienie przetwarza więc tylko nowe pliki. Gdy w folderze są np. `foto.jpg` i `foto.png`, konwertowany jest tylko jeden z nich, a drugi zostaje nietknięty.

## Automatyczna konwersja w folderze Pobrane

Cron uruchamia narzędzie co minutę, więc każdy nowy obraz w Pobranych (na dysku to `~/Downloads`) dostaje swoją wersję `.webp`/`.avif` po 1–2 minutach. Ta konfiguracja jest bezpieczna dla folderu, w którym już leżą tysiące plików:

- `--max-depth 1`: obsługuje tylko pliki leżące bezpośrednio w Pobranych, bez podfolderów;
- `--newer-than`: obsługuje tylko pliki dodane po włączeniu automatu, starych nie rusza;
- `--min-age 1`: czeka, aż plik przez minutę się nie zmienia, więc nie złapie pobierania w toku.

1. Utwórz pliki-znaczniki. Wyznaczają granicę: konwertowane będą tylko obrazy dodane później.

   ```bash
   touch ~/.towebp-since ~/.toavif-since
   ```
2. Dodaj wpisy do crona. Ta komenda dopisuje je do istniejących i sama wstawia właściwe ścieżki. Jeśli używasz tylko jednego narzędzia, usuń linię drugiego.

   ```bash
   ( crontab -l 2>/dev/null
     echo "* * * * * $(brew --prefix)/bin/towebp -d $HOME/Downloads --max-depth 1 --newer-than $HOME/.towebp-since --min-age 1 > /tmp/towebp_cron.log 2>&1"
     echo "* * * * * $(brew --prefix)/bin/toavif -d $HOME/Downloads --max-depth 1 --newer-than $HOME/.toavif-since --min-age 1 > /tmp/toavif_cron.log 2>&1"
   ) | crontab -
   ```
3. Daj cronowi dostęp do Pobranych. Bez tego macOS go blokuje, a w logu pojawia się `Operation not permitted`.
   1. Otwórz **Ustawienia systemowe → Prywatność i ochrona → Pełny dostęp do dysku**.
   2. Kliknij **+** i potwierdź hasłem lub Touch ID.
   3. Naciśnij **⌘⇧G**, wpisz `/usr/sbin/cron`, naciśnij Enter i wybierz **Otwórz**.
   4. Upewnij się, że przełącznik przy `cron` jest włączony.
4. Sprawdź działanie: wrzuć do Pobranych dowolny obraz PNG lub JPG i po 2 minutach zajrzyj do logów.

   ```bash
   cat /tmp/towebp_cron.log /tmp/toavif_cron.log
   ```

   Powinny być w nich linie `Converted: ...`, a obok obrazu pliki `.webp` i `.avif`.

Nie zmieniaj plików-znaczników (np. ponownym `touch`). To przesunie granicę, a obrazy dodane wcześniej, jeszcze nieprzerobione, zostaną pominięte.

Nie dodawaj `--delete` przy używaniu obu narzędzi naraz. Które pierwsze skończy, usunie oryginał, zanim drugie zdąży go przerobić. Z jednym narzędziem `--delete` jest bezpieczne.

**Wyłączenie automatu** (usuwa tylko wpisy tych dwóch narzędzi):

```bash
crontab -l | grep -v -E 'towebp|toavif' | crontab -
```

## Aktualizacja i odinstalowanie

Nowe wersje przychodzą przez Homebrew. Wpisy w cronie działają dalej po aktualizacji i niczego nie trzeba w nich zmieniać.

```bash
brew update
brew upgrade towebp toavif
```

Pełne odinstalowanie:

1. Wyłącz automat komendą z poprzedniej sekcji.
2. Usuń narzędzia, tap i pliki-znaczniki:

   ```bash
   brew uninstall towebp toavif
   brew untap mnich/tools
   rm -f ~/.towebp-since ~/.toavif-since
   ```

Pakiety `webp` i `libavif` zostaną. Usuniesz je przez `brew uninstall webp libavif`, jeśli nie używa ich nic innego.

## Najczęstsze problemy

| Objaw | Przyczyna | Rozwiązanie |
| --- | --- | --- |
| W logu crona: `Operation not permitted` | macOS nie dał cronowi dostępu do Pobranych | Nadaj `/usr/sbin/cron` pełny dostęp do dysku (krok 3 automatu) |
| `Bad CPU type in executable` przy każdym pliku | W `/usr/local/bin` został stary `cwebp`/`avifenc` z Homebrew dla Intela, przeniesiony z poprzedniego Maca | Sprawdź `which -a cwebp avifenc`; pierwsza na liście powinna być ścieżka `/opt/homebrew/bin`. Stare kopie usuń albo poproś mnie o pomoc |
| `command not found: towebp` | Homebrew nie jest w `PATH` albo instalacja się nie udała | Wykonaj kroki **Next steps** z instalatora Homebrew, otwórz nowy Terminal, powtórz `brew install` |
| `Another towebp instance is already running` | Poprzednie uruchomienie jeszcze trwa | Nic nie rób: to zabezpieczenie przed równoległymi uruchomieniami. Następne się wykona |
| Automat nie konwertuje pliku z podfolderu | Celowo: `--max-depth 1` obsługuje tylko pliki bezpośrednio w Pobranych | Przenieś plik do Pobranych albo przerób go ręcznie z `-d` |
| Obraz został pominięty | Obok leży już `.webp`/`.avif` o tej samej nazwie (też z innego obrazu, np. `foto.png` obok `foto.jpg`) | Zmień nazwę obrazu albo usuń stary plik wynikowy |

Narzędzie zwraca kod wyjścia 1, gdy jakakolwiek konwersja się nie uda. Pliki, których nie udało się przerobić, są oznaczone w logu jako `Conversion failed`. Z pytaniami i błędami pisz do mnie albo zgłoś issue w repozytorium [towebp](https://github.com/mnich/towebp/issues) lub [toavif](https://github.com/mnich/toavif/issues).
