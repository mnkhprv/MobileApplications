package com.example.moneyconverter

import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.Locale

data class Currency(val code: String, val name: String, val flag: Int, val rate: Double)

object CurrencyList {
    // Монголбанкны албан ханш (1 нэгж валют = ? төгрөг), mongolbank.mn
    const val RATE_DATE = "2026-10-21"

    val items = listOf(
        Currency("EUR", "Евро", R.drawable.flag_eu, 4038.06),
        Currency("GBP", "Английн фунт", R.drawable.flag_gb, 4816.28),
        Currency("RUB", "Оросын рубль", R.drawable.flag_ru, 43.77),
        Currency("CNY", "Хятадын юань", R.drawable.flag_cn, 538.60),
        Currency("JPY", "Японы иен", R.drawable.flag_jp, 22.75),
        Currency("KRW", "БНСУ-ын вон", R.drawable.flag_kr, 2.72),
        Currency("AUD", "Австрали доллар", R.drawable.flag_au, 2527.47),
        Currency("CHF", "Швейцарь франк", R.drawable.flag_ch, 4361.66),
        Currency("CAD", "Канад доллар", R.drawable.flag_ca, 2559.46),
        Currency("SGD", "Сингапур доллар", R.drawable.flag_sg, 2815.37),
        Currency("SEK", "Швед крон", R.drawable.flag_se, 363.10),
        Currency("TRY", "Туркийн Лир", R.drawable.flag_tr, 72.52),
        Currency("HKD", "Гонконг доллар", R.drawable.flag_hk, 458.41)
    )

    fun find(code: String?): Currency? = items.firstOrNull { it.code == code }

    fun toMnt(amount: Double, currency: Currency): Double = amount * currency.rate

    fun format(value: Double): String =
        DecimalFormat("#,##0.##", DecimalFormatSymbols(Locale.US)).format(value)
}
