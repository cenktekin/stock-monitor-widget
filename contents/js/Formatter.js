function getCurrencySymbol(code) {
    // Return empty string if code is missing or literal "null"
    if (!code || code === "null") return "";

    var symbols = {
        "USD": "$", "EUR": "\u20ac", "GBP": "\u00a3", "INR": "\u20b9", "JPY": "\u00a5",
        "CNY": "\u00a5", "KRW": "\u20a9", "RUB": "\u20bd", "TRY": "\u20ba"
    };
    return symbols[code] || code + " ";
}

function formatNumber(amount, isChange, formatPrices, hideDecimals) {
    var num = parseFloat(amount);
    if (isNaN(num)) return amount;

    var isPositive = num >= 0;
    var absNum = Math.abs(num);

    var hideDecs = hideDecimals && !isChange;
    var formatted = hideDecs ? Math.round(absNum).toString() : absNum.toFixed(2);

    if (formatPrices) {
        var parts = formatted.split(".");
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        formatted = parts.join(".");
    }

    var sign = "";
    if (isChange && isPositive && num > 0) sign = "+";
    else if (!isPositive) sign = "-";

    return sign + formatted;
}
