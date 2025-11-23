# Skapa Delad Mapp

Ett PowerShell-skript som skapar en ny mapp, delar den på nätverket och skapar en textfil med nätverksadressen.

## Funktioner

- Frågar användaren efter ett mappnamn
- Skapar en ny mapp i nuvarande katalog
- Delar mappen på nätverket med "alla" behörighet
- Skapar en textfil i den nya mappen med nätverksadressen (använder IP-adress istället för datornamn)
- Visar instruktioner på svenska

## Krav

- Windows-operativsystem
- Administratorsrättigheter (för att kunna dela mappar)

## Användning

1. Öppna PowerShell som administratör
2. Navigera till katalogen där skriptet finns
3. Kör kommandot:
   ```powershell
   irm "https://raw.githubusercontent.com/Olsson-Tim/Windows-folder-share/refs/heads/main/create_shared_folder.ps1" | iex
   ```
4. Följ anvisningarna och ange ett namn för den nya mappen

## Resultat

- En ny mapp skapas i aktuell katalog med det namn du angav
- Mappen delas på nätverket med namnet du valde
- En textfil med namnet `network_path.txt` skapas i den nya mappen
- Den innehåller nätverksadressen till den delade mappen med IP-adress
- Exempel på nätverksadress: `\\192.168.1.100\MinMapp`

## Obs!

- Windows kan fortfarande fråga efter inloggningsuppgifter när du ansluter till den delade mappen
- Detta beror på Windows säkerhetsinställningar som kräver autentisering även för "alla"-behörigheter
- För att komma åt den delade mappen kan du behöva ange giltiga Windows-inloggningsuppgifter från den aktuella datorn

## Felsökning

Om du får felmeddelanden:

- Försäkra dig om att du kör PowerShell som administratör
- Kontrollera att nätverket är korrekt konfigurerat
- Se till att Windows-brandväggen inte blockerar fil- och skrivar-delning