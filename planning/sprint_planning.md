# Sprint Planning - Stock Monitor Enhancements

> **Düzeltme (2026-10-21 kontrolü):** Bu dosya Sprint 1'i "✅ Complete" gösteriyordu; denetimle (2026-10-17) ve kontrolle (2026-10-21) doğrulanan gerçek durum aşağıda. İşaretler kod üzerinden teyitlidir.
>
> **Güncelleme (2026-11-06, 2. tur):** Kalem 1, 3 ve 4 kapatıldı — `contents/js/DataFetcher.js` + `Formatter.js` ayrıştırıldı, `showPortfolioMode` artık `SingleStockView` üzerinden P/L satırı basıyor, `extractChart()` tek kaynak. Sprint 1 durumu: **4 tamam / 1 kısmi** (CSV export hâlâ yalnız portföy listesi).

## Sprint 1: Core Performance & Portfolio Basics

**Goal**: Implement local data persistence and the foundation for portfolio tracking.
**Status**: ⚠️ Kısmi — 5 kalemin 4'ü tamam, 1'i kısmi (2026-11-06)

### Tasks:

1.  ✅ **Refactor Networking**: `contents/js/DataFetcher.js` (2026-11-06) — `fetchChart()` + `extractChart()`; `main.qml` yalnız orkestrasyon yapıyor (335 satır).
2.  ✅ **Portfolio Data Structure**: JSON şeması var — `ticker`, `shares`, `averageCost`, `addedDate` (`configPortfolio.qml` + `config/main.xml` → `portfolioData`).
3.  ✅ **Basic Portfolio UI**: `showPortfolioMode` artık `SingleStockView`'da P/L satırı olarak okunuyor (2026-11-06); config sekmesi "Portfolio" adıyla aktif.
4.  ✅ **Profit/Loss Calculation**: `(regularMarketPrice - averageCost) * shares` + yüzde; `updatePortfolioProfit()` her fetch'te ve config değişiminde çalışıyor (2026-11-06).
5.  ⚠️ **CSV Export Engine**: Yalnızca portföy listesi CSV'si dışa aktarılıyor (`configPortfolio.qml`); ana model/geçmiş verisi için export yok.

---

## Sprint 2: Proactive Monitoring & News

**Goal**: Add interactivity with alerts and real-time news.

### Tasks:

1.  **Alert Engine**: Add threshold check logic to the refresh cycle.
2.  **Notification Integration**: Trigger KDE Plasma system notifications on price breaches.
3.  **Alert Management UI**: A view to list, edit, and delete active price alerts.
4.  **News Feed Integration**: Fetch and display the latest ticker-related news in a "News" tab/view.
5.  **Multi-Exchange Search Helper**: Improve the "Add Ticker" UI to search for suffixes like `.IS`, `.L`, `.PA`.

---

## Sprint 3: Polish & UX

**Goal**: Finalize UI details and cross-platform compatibility.

### Tasks:

1.  **Icon/Badge Polish**: Enhance the compact view badges for portfolio status (e.g., green tint if overall portfolio is up).
2.  **Performance Optimization**: Cache news data to avoid excessive API calls.
3.  **Beta Testing & Bug Fixes**: Focus on Plasma 6 specific edge cases.
4.  **Final Documentation Update**: Update README.md with new feature instructions.
