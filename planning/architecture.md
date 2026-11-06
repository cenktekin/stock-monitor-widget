# Architectural Design Document - Stock Monitor Widget

## 1. Overview

This document outlines the architectural changes required to support new features including Portfolio Tracking, Price Alerts, Financial News, and Multi-exchange support in the KDE Plasma Stock Monitor Widget.

## 2. Current Architecture

- **Language**: QML, JavaScript
- **Host**: KDE Plasma 6 (Plasmoid)
- **Data Source**: Yahoo Finance API (via `XMLHttpRequest`)
- **State Management**: `ListModel` and Plasmoid Properties
- **Storage**: `Plasmoid.configuration` (KConfig)

## 3. Proposed Enhancements

### 3.1. Persistence Layer (Portfoio & Alerts)

Currently, all data is either fetched or stored in simple configuration keys.

- **Challenge**: Portfolio data (shares, cost) and Alerts (thresholds) require more structured storage than simple strings.
- **Solution**:
  - Use a JSON-based local file for complex data structures (e.g., `~/.local/share/stockmonitor/users_data.json`).
  - Or leverage `Plasmoid.configuration` by serializing objects to JSON strings if the data size is small.

### 3.2. Notification System (Price Alerts)

- **Mechanism**: Use `org.kde.plasma.core.DataSource` with "notifications" specialized service or `KNotification` if available via QML.
- **Background Logic**: The existing `Timer` in `main.qml` will be enhanced to check current prices against alert thresholds every refresh cycle.

### 3.3. Portfolio Component

- **Data Model**: Extend the current `stockModel` to include:
  - `sharesHeld`: Number of shares owned.
  - `averageCost`: The average price paid.
  - `totalGainLoss`: Calculated as `(currentPrice - averageCost) * sharesHeld`.
- **UI**: Add a "Portfolio View" toggle in the Full Representation.

### 3.4. News Component

- **Fetcher**: A new JavaScript helper to fetch RSS/JSON news feeds from Yahoo Finance or similar.
- **UI**: A scrollable list within the expanded widget view.

### 3.5. Multi-Exchange Support

- **Strategy**: Yahoo Finance already supports many global exchanges via suffixes (e.g., `.IS` for BIST, `.DE` for Frankfurt).
- **Enhancement**: Improve the configuration UI to provide a helper/search for different exchanges instead of just raw ticker input.

## 4. Component Structure

```
contents/
├── ui/
│   ├── main.qml            (Entry point, view orchestration)
│   ├── PortfolioView.qml   (New: Portfolio specific UI)
│   ├── AlertView.qml       (New: Alert management UI)
│   ├── NewsView.qml        (New: News listing UI)
│   └── config/
│       └── configGeneral.qml (Updated: More granular settings)
└── js/
    ├── DataFetcher.js      (New: Refactored logic from main.qml)
    └── StorageHelper.js    (New: CSV export and local storage logic)
```
