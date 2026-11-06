import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import "../js/DataFetcher.js" as DataFetcher
import "../js/Formatter.js" as Formatter

PlasmoidItem {
    id: root

    // --- CONFIGURATION ---
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    // Detect where we are (Panel vs Desktop) to switch views
    preferredRepresentation: (Plasmoid.formFactor === PlasmaCore.Types.Horizontal || Plasmoid.formFactor === PlasmaCore.Types.Vertical)
    ? Plasmoid.CompactRepresentation
    : Plasmoid.FullRepresentation

    property int formFactor: Plasmoid.formFactor

    property string singleTicker: Plasmoid.configuration.ticker
    property bool isMultiMode: Plasmoid.configuration.isMultiMode
    property bool showTwoList: Plasmoid.configuration.showTwoList
    property string panelTicker: ""
    property string manualPanelTickerOverride: ""
    property string multiTickers: Plasmoid.configuration.multiTickers
    property bool sortAlphabetically: Plasmoid.configuration.sortAlphabetically
    property bool swapNameAndTicker: Plasmoid.configuration.swapNameAndTicker
    property string chartRange: Plasmoid.configuration.chartRange

    // Time Limits Config
    property bool limitHours: Plasmoid.configuration.limitHours
    property bool skipWeekendRefresh: Plasmoid.configuration.skipWeekendRefresh
    property int startHour: Plasmoid.configuration.startHour
    property int startMinute: Plasmoid.configuration.startMinute
    property int endHour: Plasmoid.configuration.endHour
    property int endMinute: Plasmoid.configuration.endMinute

    // Internal Properties for Single View
    property string singleCompanyName: "Loading..."
    property string currentPrice: "---"
    property double currentRawPrice: 0.0
    property string priceChange: "+0.00"
    property string percentChange: "+0.00%"
    property var chartDataPoints: []
    property double previousClose: 0.0
    property bool isPositive: true
    property string currencySym: ""

    // Portfolio Tracking (holdings come from configPortfolio.qml)
    property bool showPortfolioMode: Plasmoid.configuration.showPortfolioMode
    property string portfolioData: Plasmoid.configuration.portfolioData
    property var portfolioHolding: null
    property string portfolioProfit: ""
    property string portfolioProfitPct: ""
    property bool portfolioProfitPositive: true

    property bool isLightTheme: Plasmoid.configuration.isLightTheme
    property color positiveColor: Plasmoid.configuration.positiveColor
    property color negativeColor: Plasmoid.configuration.negativeColor
    property color tickerColor: Qt.colorEqual(Plasmoid.configuration.tickerColor, "#ffffff") && isLightTheme ? "#000000" : Plasmoid.configuration.tickerColor
    property int tickerOpacity: Plasmoid.configuration.tickerOpacity
    property color priceColor: Qt.colorEqual(Plasmoid.configuration.priceColor, "#ffffff") && isLightTheme ? "#000000" : Plasmoid.configuration.priceColor
    property int priceOpacity: Plasmoid.configuration.priceOpacity
    property int bgOpacity: Plasmoid.configuration.bgOpacity
    property bool hideChangePercentage: Plasmoid.configuration.hideChangePercentage
    property bool hideTimestamps: Plasmoid.configuration.hideTimestamps
    property bool formatPrices: Plasmoid.configuration.formatPrices
    property bool hideDecimals: Plasmoid.configuration.hideDecimals
    property string lastUpdated: ""
    property string nextUpdate: ""
    property color bgColor: isLightTheme ? "#ffffff" : "#1a1a1a"
    property color chartBaseColor: isLightTheme ? "#e0e0e0" : "#333333"
    property color secondaryTextColor: isLightTheme ? "#555555" : "#888888"

    ListModel { id: stockModel }

    function getCurrencySymbol(code) {
        return Formatter.getCurrencySymbol(code);
    }

    function formatNumber(amount, isChange) {
        return Formatter.formatNumber(amount, isChange, root.formatPrices, root.hideDecimals);
    }

    function refreshData() {
        if (root.isMultiMode) {
            fetchMultiStocks();
        }
        else {
            fetchSingleStock(root.singleTicker);
        }
    }

    // --- CHECK: IS MARKET OPEN? ---
    function checkTimeAndRefresh() {
        // 1. Always check weekend first (optional, but saves battery)
        var d = new Date();
        var day = d.getDay();
        // 0=Sun, 6=Sat. Crypto (BTC) runs 24/7, so you might want to skip this check for crypto.
        if (root.skipWeekendRefresh && (day === 0 || day === 6)) {
            return;
        }

        // 2. Check Time Window if enabled
        if (root.limitHours) {
            var currentTimeVal = d.getHours() * 60 + d.getMinutes();
            var startTimeVal = root.startHour * 60 + root.startMinute;
            var endTimeVal = root.endHour * 60 + root.endMinute;

            // If we are BEFORE start OR AFTER end, stop.
            if (currentTimeVal < startTimeVal || currentTimeVal >= endTimeVal) {
                return; // Do not fetch
            }
        }

        // 3. If passed, refresh
        refreshData();
    }

    function fetchSingleStock(symbol) {
        DataFetcher.fetchChart(symbol, root.chartRange, function(json) {
            processSingleData(json);
        });
    }

    function fetchMultiStocks() {
        var tickers = root.multiTickers.split(",");
        var targetTickers = [];
        tickers.forEach(function(t) {
            var clean = t.trim();
            if (clean !== "") targetTickers.push(clean);
        });

        if (root.sortAlphabetically) {
            targetTickers.sort(function(a, b) {
                return a.localeCompare(b);
            });
        }

        var defaultPanelTicker = targetTickers.length > 0 ? targetTickers[0] : "";
        root.panelTicker = root.manualPanelTickerOverride !== "" && targetTickers.indexOf(root.manualPanelTickerOverride) !== -1 ? root.manualPanelTickerOverride : defaultPanelTicker;
        root.singleTicker = root.panelTicker;

        // Initialize placeholders to maintain display order before async completion
        if (stockModel.count !== targetTickers.length) {
            stockModel.clear();
            targetTickers.forEach(function(cleanSymbol) {
                stockModel.append({
                    "ticker": cleanSymbol,
                    "name": "Loading...",
                    "price": "---",
                    "change": "",
                    "pct": "",
                    "isPos": true,
                    "chartPoints": [],
                    "prevClose": 0.0
                });
            });
        }

        targetTickers.forEach(function(cleanSymbol) {
            DataFetcher.fetchChart(cleanSymbol, root.chartRange, function(json) {
                processListRow(cleanSymbol, json);
            });
        });
    }

    function updateTimestamps() {
        var now = new Date();
        root.lastUpdated = now.toLocaleTimeString(Qt.locale(), "HH:mm");
        var next = new Date(now.getTime() + (Plasmoid.configuration.refreshInterval * 60000));
        root.nextUpdate = next.toLocaleTimeString(Qt.locale(), "HH:mm");
    }

    function processSingleData(json, fallbackSymbol) {
        try {
            var chart = DataFetcher.extractChart(json, root.chartRange);
            var meta = chart.meta;

            root.singleCompanyName = meta.shortName || meta.longName || (fallbackSymbol || root.singleTicker);
            root.currencySym = getCurrencySymbol(meta.currency);
            root.currentRawPrice = meta.regularMarketPrice;
            root.currentPrice = root.currencySym + formatNumber(meta.regularMarketPrice, false);
            root.chartDataPoints = chart.cleanData;
            root.previousClose = chart.prevClose;

            var change = meta.regularMarketPrice - root.previousClose;
            root.isPositive = change >= 0;
            root.priceChange = formatNumber(change, true);
            root.percentChange = formatNumber((change / root.previousClose) * 100, true) + "%";

            updateTimestamps();
            updatePortfolioProfit();
        } catch (e) { console.log("Error parsing single: " + e); }
    }

    function processListRow(symbol, json) {
        if (root.isMultiMode && symbol === root.panelTicker) {
            processSingleData(json, symbol);
        }
        try {
            var chart = DataFetcher.extractChart(json, root.chartRange);
            var meta = chart.meta;

            var current = meta.regularMarketPrice;
            var curSym = getCurrencySymbol(meta.currency);
            var change = current - chart.prevClose;
            var pct = chart.prevClose > 0 ? (change / chart.prevClose) * 100 : 0;

            var itemData = {
                "ticker": symbol,
                "name": meta.shortName || meta.longName || symbol,
                "price": curSym + formatNumber(current, false),
                "change": formatNumber(change, true),
                "pct": formatNumber(pct, true) + "%",
                "isPos": change >= 0,
                "chartPoints": chart.cleanData,
                "prevClose": chart.prevClose
            };

            var found = false;
            for (var k = 0; k < stockModel.count; k++) {
                if (stockModel.get(k).ticker === symbol) {
                    stockModel.set(k, itemData);
                    found = true;
                    break;
                }
            }
            if (!found) stockModel.append(itemData);

            updateTimestamps();
        } catch (e) { console.log("Error parsing multi: " + e); }
    }

    function findPortfolioHolding() {
        if (!root.showPortfolioMode || !root.portfolioData) return null;
        try {
            var holdings = JSON.parse(root.portfolioData);
            if (!holdings || holdings.length === undefined) return null;
            var symbol = String(root.singleTicker || "").toUpperCase();
            for (var i = 0; i < holdings.length; i++) {
                if (String(holdings[i].ticker || "").toUpperCase() === symbol) return holdings[i];
            }
        } catch (e) {
            console.log("Error parsing portfolio: " + e);
        }
        return null;
    }

    function updatePortfolioProfit() {
        var holding = findPortfolioHolding();
        var shares = holding ? Number(holding.shares) || 0 : 0;
        var averageCost = holding ? Number(holding.averageCost) || 0 : 0;

        if (!holding || shares <= 0 || root.currentRawPrice <= 0) {
            root.portfolioHolding = null;
            root.portfolioProfit = "";
            root.portfolioProfitPct = "";
            return;
        }

        var profit = (root.currentRawPrice - averageCost) * shares;
        var profitPct = averageCost > 0 ? ((root.currentRawPrice - averageCost) / averageCost) * 100 : 0;
        var sign = profit > 0 ? "+" : "";

        root.portfolioHolding = { "shares": shares, "averageCost": averageCost, "value": root.currentRawPrice * shares };
        root.portfolioProfitPositive = profit >= 0;
        root.portfolioProfit = sign + root.currencySym + formatNumber(profit, false);
        root.portfolioProfitPct = averageCost > 0 ? sign + formatNumber(profitPct, false) + "%" : "";
    }

    onSingleTickerChanged: {
        root.portfolioProfit = "";
        refreshData();
    }
    onIsMultiModeChanged: {
        stockModel.clear();
        if (!isMultiMode) {
            root.singleTicker = Qt.binding(function() { return Plasmoid.configuration.ticker; });
            root.singleCompanyName = "Loading...";
            root.currentPrice = "---";
            root.priceChange = "";
            root.percentChange = "";
            root.chartDataPoints = [];
        }
        refreshData();
    }
    onMultiTickersChanged: { stockModel.clear(); refreshData(); }
    onSortAlphabeticallyChanged: { stockModel.clear(); refreshData(); }
    onFormatPricesChanged: refreshData()
    onHideDecimalsChanged: refreshData()
    onChartRangeChanged: { stockModel.clear(); refreshData(); }
    onPortfolioDataChanged: updatePortfolioProfit()
    onShowPortfolioModeChanged: updatePortfolioProfit()

    Timer {
        interval: Plasmoid.configuration.refreshInterval * 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.checkTimeAndRefresh()
    }

    // --- PANEL VIEW (Compact Representation) ---
    compactRepresentation: PanelView {
        rootItem: root
    }

    // --- DESKTOP VIEW (Full Representation) ---
    fullRepresentation: Item {
        Layout.minimumWidth: root.showTwoList ? 380 : 190 // Leave room for both columns in multi mode
        Layout.minimumHeight: 170

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            SingleStockView {
                visible: !root.isMultiMode || root.showTwoList
                Layout.fillWidth: true
                Layout.fillHeight: true
                rootItem: root
            }
            MultiStockView {
                visible: root.isMultiMode
                Layout.fillWidth: true
                Layout.fillHeight: true
                rootItem: root
                listModel: stockModel
            }
        }
    }
}
