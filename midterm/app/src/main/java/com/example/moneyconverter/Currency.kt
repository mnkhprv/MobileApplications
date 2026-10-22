package com.example.moneyconverter

import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.Locale

data class Currency(val code: String, val name: String, val flag: String, val rate: Double)

object CurrencyList {
    // Монголбанкны албан ханш (1 нэгж валют = ? төгрөг), mongolbank.mn
    const val RATE_DATE = "2026-10-21"

    val items = listOf(
        Currency("EUR", "Евро", "🇪🇺", 4038.06),
        Currency("GBP", "Английн фунт", "🇬🇧", 4816.28),
        Currency("RUB", "Оросын рубль", "🇷🇺", 43.77),
        Currency("CNY", "Хятадын юань", "🇨🇳", 538.60),
        Currency("JPY", "Японы иен", "🇯🇵", 22.75),
        Currency("KRW", "БНСУ-ын вон", "🇰🇷", 2.72),
        Currency("AUD", "Австрали доллар", "🇦🇺", 2527.47),
        Currency("CHF", "Швейцарь франк", "🇨🇭", 4361.66),
        Currency("CAD", "Канад доллар", "🇨🇦", 2559.46),
        Currency("SGD", "Сингапур доллар", "🇸🇬", 2815.37),
        Currency("SEK", "Швед крон", "🇸🇪", 363.10),
        Currency("TRY", "Туркийн Лир", "🇹🇷", 72.52),
        Currency("HKD", "Гонконг доллар", "🇭🇰", 458.41)
    )

    fun find(code: String?): Currency? = items.firstOrNull { it.code == code }

    fun toMnt(amount: Double, currency: Currency): Double = amount * currency.rate

    fun format(value: Double): String =
        DecimalFormat("#,##0.##", DecimalFormatSymbols(Locale.US)).format(value)
}
