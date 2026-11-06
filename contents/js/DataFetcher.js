function getApiParams(chartRange) {
    // Yahoo Finance requires specific intervals for specific ranges
    // to return valid data and look good.
    switch (chartRange) {
        case "1D":  return "range=2d&interval=2m"; // Use 2d to get reliable previous close for indices
        case "5D":  return "range=5d&interval=15m";
        case "1M":  return "range=1mo&interval=60m"; // '1mo' is Yahoo syntax
        case "6M":  return "range=6mo&interval=1d";
        case "YTD": return "range=ytd&interval=1d";
        case "1Y":  return "range=1y&interval=1d";
        case "5Y":  return "range=5y&interval=1wk";
        case "Max": return "range=max&interval=1mo";
        default:    return "range=1d&interval=2m";
    }
}

function buildChartUrl(symbol, chartRange) {
    return "https://query1.finance.yahoo.com/v8/finance/chart/" + symbol + "?" + getApiParams(chartRange);
}

function fetchChart(symbol, chartRange, onSuccess) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
            onSuccess(JSON.parse(xhr.responseText));
        }
    }
    xhr.open("GET", buildChartUrl(symbol, chartRange));
    xhr.send();
}

function extractChart(json, chartRange) {
    var result = json.chart.result[0];
    var meta = result.meta;
    var quotes = result.indicators.quote[0].close;
    var timestamps = result.timestamp;

    var cleanData = [];
    var startTime = (meta.currentTradingPeriod && meta.currentTradingPeriod.regular) ? meta.currentTradingPeriod.regular.start : 0;

    for (var i = 0; i < quotes.length; i++) {
        if (quotes[i] !== null) {
            if (chartRange === "1D" && startTime > 0) {
                if (timestamps[i] >= startTime) {
                    cleanData.push(quotes[i]);
                }
            } else {
                cleanData.push(quotes[i]);
            }
        }
    }

    if (chartRange === "1D" && cleanData.length === 0 && timestamps && timestamps.length > 0) {
        var dayStartIndex = 0;
        for (var j = timestamps.length - 1; j > 0; j--) {
            if (timestamps[j] - timestamps[j - 1] > 4 * 3600) {
                dayStartIndex = j;
                break;
            }
        }
        for (var k = dayStartIndex; k < quotes.length; k++) {
            if (quotes[k] !== null) {
                cleanData.push(quotes[k]);
            }
        }
    }

    var prevClose;
    if (chartRange === "1D") {
        // Priority order matters: 1D previous close fixes must not regress
        prevClose = meta.chartPreviousClose || meta.regularMarketPreviousClose || meta.previousClose;
    } else {
        prevClose = meta.chartPreviousClose;
        if (!prevClose || prevClose === 0) {
            prevClose = cleanData.length > 0 ? cleanData[0] : meta.regularMarketPreviousClose;
        }
    }

    return { cleanData: cleanData, prevClose: prevClose, meta: meta };
}
