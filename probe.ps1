# SureHCS - Trinh ket noi chan doan may cham cong (portable, khong cai dat)
# Chay 1 dong tren may trong LAN khach:
#   iex "& { $(irm https://raw.githubusercontent.com/<acc>/<repo>/<sha>/probe.ps1) } -Bundle '<chuoi>'"
#
# Co che: tai cloudflared ban da PIN (kiem SHA256), dung chuoi -Bundle (do ben SureHCS cap)
# de mo ket noi an toan tu may nay toi trung tam SureHCS. KHONG cai service, KHONG tao user,
# KHONG sua cau hinh may. Dong cua so / Ctrl+C = tat ket noi. Moi file tam tu xoa khi thoat.
# -Bundle chi chua thong tin ket noi cua dung khach hang nay, khong co trong ma nguon cong khai.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$Bundle
)
$ErrorActionPreference = 'Stop'

function Write-Step($m) { Write-Host "[SureHCS] $m" -ForegroundColor Cyan }

$b = $null
try { $b = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Bundle)) | ConvertFrom-Json }
catch { throw "Chuoi -Bundle khong hop le. Hay copy lai day du chuoi do SureHCS cap." }

foreach ($k in 'cfver', 'cfsha', 'creds', 'config') {
    if (-not $b.$k) { throw "Bundle thieu truong '$k'." }
}

$work = Join-Path $env:TEMP ("hcsmcc_" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $work | Out-Null
try {
    $exe = Join-Path $work 'cloudflared.exe'
    $url = "https://github.com/cloudflare/cloudflared/releases/download/$($b.cfver)/cloudflared-windows-amd64.exe"
    Write-Step "Tai trinh ket noi ($($b.cfver))..."
    $old = $ProgressPreference; $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $url -OutFile $exe -UseBasicParsing
    $ProgressPreference = $old

    $sha = (Get-FileHash -Path $exe -Algorithm SHA256).Hash.ToLower()
    if ($sha -ne $b.cfsha.ToLower()) {
        throw "SHA256 khong khop (muon $($b.cfsha), nhan $sha). Dung lai de an toan."
    }
    Write-Step "Da xac thuc chu ky (SHA256 khop)."

    $creds = Join-Path $work 'creds.json'
    [IO.File]::WriteAllText($creds, [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b.creds)))

    $cfgText = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b.config))
    $cfgText = $cfgText.Replace('__CREDS__', ($creds -replace '\\', '/'))
    $cfg = Join-Path $work 'config.yml'
    [IO.File]::WriteAllText($cfg, $cfgText)

    Write-Host ''
    Write-Host '========================================================' -ForegroundColor Green
    Write-Host '  DA KET NOI. De cua so nay MO trong khi SureHCS lam viec.' -ForegroundColor Green
    Write-Host '  Xong viec: dong cua so hoac bam Ctrl+C -> tat ngay.' -ForegroundColor Green
    Write-Host '========================================================' -ForegroundColor Green
    Write-Host ''
    & $exe tunnel --no-autoupdate --loglevel info --config $cfg run
}
finally {
    Write-Step "Don dep file tam..."
    Remove-Item -Path $work -Recurse -Force -ErrorAction SilentlyContinue
    Write-Step "Da tat ket noi va xoa file tam. Khong con gi tren may."
}
