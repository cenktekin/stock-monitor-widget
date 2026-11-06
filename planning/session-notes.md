# Session Notes — Yahoo `previousClose` Fix (24 Haziran 2026)

## Problem
XU100.IS (BIST 100) endeksi widget'da hatalı değişim yüzdesi gösteriyordu.
- Gösterdiği: **-2.33%** (14386 - 14729 = -343)
- Olması gereken: **-1.13%** (14376 - 14539 = -163)

## Kök Neden
Yahoo Finance v8 chart API'i `range=2d&interval=2m` ile çağırınca `previousClose` alanı 2 işlem günü öncesinin kapanışını döndürüyor. `chartPreviousClose` ise dünün kapanışını veriyor. Widget yanlış alanı kullanıyordu.

## Yapılan Değişiklik
**Dosya:** `contents/ui/main.qml`

- **Satır 240:** `regularMarketPreviousClose || previousClose || chartPreviousClose`
  → `chartPreviousClose || regularMarketPreviousClose || previousClose`

- **Satır 305:** Aynı değişiklik `processListRow()` içinde.

## CRITICAL: Bu 3. Tekrar Eden Fix
| Tarih | PR | Ne Oldu |
|-------|----|---------|
| 3 Şub 2026 | #4 | `range=1d` → `range=2d`, `chartPreviousClose` kullanıldı |
| 14 Şub 2026 | #5 | Yahoo değiştirdi, fallback tersine çevrildi |
| 24 Haz 2026 | #16 | Yahoo yine değiştirdi, fallback tekrar `chartPreviousClose`'a |

**Yahoo'nun API'i belgelenmemiş, `previousClose`/`chartPreviousClose` anlamı periyodik değişiyor.**

## PR
https://github.com/vpsone/stock-monitor-widget/pull/16

## Gelecek İçin Daha Sağlam Çözüm
Meta alanlarına güvenmek yerine 2 günlük mum verisinden hesaplamak:

```js
var closes = result.indicators.quote[0].close.filter(c => c !== null);
var prevClose = closes.length >= 2 ? closes[closes.length - 2] : meta.chartPreviousClose;
```
