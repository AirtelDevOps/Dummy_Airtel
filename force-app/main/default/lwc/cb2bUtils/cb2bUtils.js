import * as _ from 'vlocity_cmt/lodash';
import { formatCurrency } from "vlocity_cmt/utility";
import { LOCALE, CURRENCY } from "vlocity_cmt/salesforceUtils";

let currencyCode = CURRENCY;
let locale = LOCALE;

function formatCurrencyESM(price, options) {
    if (options) {
        return formatCurrency(price, options);
    } else {
        return formatCurrency(price, {money: currencyCode, anlocale: locale});
    }
}

function setCurrencyCode(val) {
    currencyCode = val;
}

function setLocale(val) {
    locale = val;
}

export {
    formatCurrencyESM,
    setCurrencyCode,
    setLocale
}