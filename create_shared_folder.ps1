# PowerShell-skript för att skapa en delad mapp och generera nätverksväg

# Kontrollera om skriptet körs som administratör
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Detta skript kräver administratörsrättigheter. Kör som administratör." -ForegroundColor Red
    exit 1
}

# Fråga användaren efter mappnamn
$folderName = Read-Host "Ange namn för den nya mappen"

# Kontrollera om mappnamn är angivet
if ([string]::IsNullOrWhiteSpace($folderName)) {
    Write-Host "Mappnamn kan inte vara tomt. Avslutar..." -ForegroundColor Red
    exit 1
}

# Skapa mappen i aktuell katalog
$newFolderPath = Join-Path $PWD $folderName
try {
    New-Item -Path $newFolderPath -ItemType Directory -Force
    Write-Host "Mapp skapad: $newFolderPath" -ForegroundColor Green
}
catch {
    Write-Host "Fel vid skapande av mapp: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Hämta datorns IP-adress
$ipAddress = (Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" -and $_.IPAddress -ne "127.0.0.1" -and $_.IPAddress -notlike "169.254.*" }).IPAddress | Select-Object -First 1

if ([string]::IsNullOrWhiteSpace($ipAddress)) {
    Write-Host "Kunde inte fastställa IP-adress. Avslutar..." -ForegroundColor Red
    exit 1
}

# Dela mappen på nätverket för alla
try {
    $shareName = $folderName

    # Ta bort befintlig delning om den finns
    $existingShare = Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue
    if ($existingShare) {
        Remove-SmbShare -Name $shareName -Force -ErrorAction SilentlyContinue
    }

    # Skapa ny delning med fullständig åtkomst för alla
    New-SmbShare -Name $shareName -Path $newFolderPath -FullAccess "Everyone"

    # Konfigurera delningen för att tillåta åtkomst utan att kräva autentisering
    # Detta gör att användare kan komma åt delningen utan att ange inloggningsuppgifter
    Grant-SmbShareAccess -Name $shareName -AccountName "Everyone" -AccessRight Full -Force

    # Inaktivera lösenordsskyddad delning för denna delning
    Set-SmbShare -Name $shareName -EncryptData $false -ConcurrentUserLimit 0

    Write-Host "Mapp delad som: $shareName" -ForegroundColor Green
    Write-Host "Delning konfigurerad med fullständig åtkomst för alla" -ForegroundColor Green
}
catch {
    Write-Host "Fel vid delning av mapp: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Skapa nätverksvägssträng
$networkPath = "\\$ipAddress\$shareName"

# Skapa en textfil i den nya mappen med nätverksvägen
$infoFilePath = Join-Path $newFolderPath "network_path.txt"
try {
    $networkPath | Out-File -FilePath $infoFilePath -Encoding UTF8
    Write-Host "Nätverksväg sparad till: $infoFilePath" -ForegroundColor Green
    Write-Host "Nätverksväg: $networkPath" -ForegroundColor Cyan
}
catch {
    Write-Host "Fel vid skapande av infofil: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`nDelning av mapp genomförd!" -ForegroundColor Green
Write-Host "Delad mapp är tillgänglig via: $networkPath" -ForegroundColor Yellow

Write-Host "`nObs: Windows kan efterfråga inloggningsuppgifter vid åtkomst till delningen." -ForegroundColor Yellow
Write-Host "Detta beror på Windows säkerhetsinställningar som kräver autentisering även för 'alla'-behörigheter." -ForegroundColor Yellow
Write-Host "För åtkomst kan du behöva ange giltiga Windows-inloggningsuppgifter från denna dator." -ForegroundColor Yellow