# NEXT_ACTIONS — stock-monitor-widget-main

> **Amaç:** Dönüş çapası (resume anchor). Yeni bir oturumda
> `D:\projects\stock-monitor-widget-main\NEXT_ACTIONS.md oku ve uygula`
> cümlesiyle kaldığın yerden devam edersin.

## Durum (2026-11-06 — 2. tur kapandı)
- **Denetim:** 2026-10-17 · 50/100 (ilk kayıt)
- **1. kontrol:** 2026-10-21 → T1, T2, T6, T9 kapandı
- **2. tur:** 2026-11-06 → **T3, T4, T5, T7, T8 kapandı** + `configSearch.qml` injection düzeltmesi
- **Kalan:** F1, F2, F3 (fonksiyonel backlog) → yeni task, vade 2026-11-20

## Referanslar
- Ledger: `MASTER_PROJECT_LEDGER.md` → `### stock-monitor-widget-main`
- Joplin not: Teknik Notlar (id: `363820acd03941259d15aca1d4aa5893`)
- Kapanan task: `6ad3e0458f08baf7cbc4cadb` (21.10.2026)
- Kapanan task: `6ad8aa9d8f086e43496918f9` (06.11.2026 — 2. tur)
- Blast radius: `stock-monitor-ff` (aynı widget'ın tarayıcı portu — aynı ölü Portfolio deseni hâlâ orada)

## 2026-11-06'DA KAPANANLAR
| # | Kalem | Nasıl |
|---|-------|-------|
| T8 | Kirli ağaç | `planning/` + `NEXT_ACTIONS.md` commit edildi (proje hafızası). 3 Joplin export'u `.gitignore` → `*stock-monitor-widget-main - *.md` (kaynak doğruluk: Joplin) |
| T3 | Portfolio Mode kararı | **Seçenek A** uygulandı: `showPortfolioMode` + `portfolioData` `main.qml`'de okunuyor, `updatePortfolioProfit()` → `(regularMarketPrice - averageCost) * shares` + yüzde. `SingleStockView`'da "P/L" satırı, pozitif/negatif renk mevcut desenle. Config sekmesi adı "Portfolio Tracking(WIP)" → "Portfolio" |
| T4 | `processSingleData` ↔ `processListRow` kopyası | `extractChart(json, chartRange)` → `{cleanData, prevClose, meta}` tek kaynak. `chartPreviousClose > regularMarketPreviousClose > previousClose` önceliği **aynen korundu** (3. tekrar eden fix) |
| T5 | `main.qml` bölme | 524 → **335 satır**. Yeni: `contents/js/DataFetcher.js` (XHR + parse), `contents/js/Formatter.js` (formatNumber, getCurrencySymbol), `contents/ui/PanelView.qml` (compact representation) |
| T7 | QML doğrulama kapısı | `.github/workflows/ci.yml`: (1) `qmllint` — tüm `contents/**/*.qml`; (2) `kpackagetool6 --install` — `ubuntu:26.04` konteynerinde (24.04'te paket yok). `continue-on-error` yok |
| EK | `configSearch.qml` rich-text injection | `"<b>" + model.name` kaldırıldı → `textFormat: Text.PlainText` |

**Doğrulama:** `qmllint` yerelde (PySide6 6.9) → 0 error, yalnız `unqualified access` uyarıları (mevcut kod stili). `node --check` iki JS dosyasında temiz.

## AÇIK — FONKSİYONEL BACKLOG (yeni task: vade 2026-11-20)
| # | Kalem | Efor | Not |
|---|-------|------|-----|
| F1 | Offline cache | M | Son başarılı JSON + `lastUpdated` → `Plasmoid.configuration`; ağ hatasında eski fiyatı soluk göster + "stale" etiketi. `DataFetcher.fetchChart()`'ın hata yolu **şu an sessiz** — bu kalem onu da kapatır |
| F2 | Fiyat alarmı + KDE bildirimi | M | `architecture.md` §3.2; timer döngüsünde eşik kontrolü, `KNotification` veya Plasma `DataSource` |
| F3 | Watchlist JSON export/import | S | Portföy CSV deseni `configPortfolio.qml:escapeCsvField` ile aynı yaklaşım |
| F4 | `stock-monitor-ff` replikasyonu | M | T3 kararı + `configSearch.qml` PlainText düzeltmesi tarayıcı portuna taşınmalı (ayrı repo, ayrı task) |

## ERTELENEN
- F5 Teknik indikatör (RSI) — L efor.
- `main.qml` tamamen modülerleştirme — T5 sonrası 335 satır, gerek yok.

## REDDEDİLEN
- Alternatif API (Alpha Vantage / Finnhub) — kapsam + key bağımlılığı.
- Haber entegrasyonu — L efor + yeni dış bağımlılık.
- Çoklu borsa arama helper'ı — Yahoo `.IS/.L/.PA` suffix destekliyor.
- Mobil / PWA / marketplace gimmick'leri.

## DOĞRULAMA KOMUTLARI
```
cd D:\projects\stock-monitor-widget-main
git status -sb                 → main...origin/main (temiz)
git log --oneline -3
Select-String -Path contents\ui\*.qml -Pattern "console.log"   → 3 hata logu (single, multi, portfolio)
(Get-Content contents\ui\main.qml).Count                       → 335 (<400)
node --check contents\js\Formatter.js; node --check contents\js\DataFetcher.js
qmllint contents\**\*.qml        → Linux/CI (Windows'ta PySide6: pyside6-qmllint.exe)
kpackagetool6 --type Plasma/Applet --install .   → yalnız CI (ubuntu:26.04)
```
