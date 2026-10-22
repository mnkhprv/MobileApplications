package com.example.lab1.midterm

import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.Locale

data class Currency(val code: String, val name: String, val flag: String, val rate: Double)

object CurrencyList {
    // 1 нэгж валют хэдэн төгрөг болохыг харуулна (Монголбанкны ханшаас авсан тогтмол утга)
    val items = listOf(
        Currency("EUR", "Евро", "🇪🇺", 3726.0),
        Currency("GBP", "Английн фунт", "🇬🇧", 4280.0),
        Currency("RUB", "Оросын рубль", "🇷🇺", 42.5),
        Currency("CNY", "Хятадын юань", "🇨🇳", 480.0),
        Currency("JPY", "Японы иен", "🇯🇵", 22.9),
        Currency("KRW", "БНСУ-ын вон", "🇰🇷", 2.48),
        Currency("AUD", "Австрали доллар", "🇦🇺", 2230.0),
        Currency("CHF", "Швейцарь франк", "🇨🇭", 4290.0),
        Currency("CAD", "Канад доллар", "🇨🇦", 2450.0),
        Currency("SGD", "Сингапур доллар", "🇸🇬", 2650.0),
        Currency("SEK", "Швед крон", "🇸🇪", 330.0),
        Currency("TRY", "Туркийн Лир", "🇹🇷", 85.0),
        Currency("HKD", "Гонконг доллар", "🇭🇰", 440.0)
    )

    fun find(code: String?): Currency? = items.firstOrNull { it.code == code }

    fun toMnt(amount: Double, currency: Currency): Double = amount * currency.rate

    fun format(value: Double): String =
        DecimalFormat("#,##0.##", DecimalFormatSymbols(Locale.US)).format(value)
}
