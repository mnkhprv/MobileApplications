# Midterm – Ханш хөрвүүлэгч (Money Converter)

Figma загвар: https://www.figma.com/design/e6YlWUDlftAnUzvBhluKg2/Money-Converter

Unit Converter-оос тусдаа Android апп. Нэг `MainActivity` дотор 2 **fragment**-ийг
Navigation Component ашиглан сольж харуулна.

## Дэлгэцүүд

1. **Ханш хөрвүүлэгч -1** (`CurrencyListFragment`) – "Монгол банкны валютын ханш"
   гарчигтай 13 валютын жагсаалт (туг, нэр, код). Мөр дээр дарахад 2-р дэлгэц нээгдэнэ.
2. **Ханш хөрвүүлэгч -2** (`MoneyConverterFragment`) – сонгосон валютын туг, валют
   сонгох Spinner, дүн оруулах талбар, "Хөрвүүлэх" товч, төгрөгөөр гарсан үр дүн.

Хөрвүүлэх томьёо: `MNT = дүн × ханш`

Жишээ: 153.0 EUR × 4,038.06 = 617,823.18 MNT

## Ханш

Монголбанкны албан ханш (mongolbank.mn, 2026-10-21-ний хаалтын ханш):

| Валют | Ханш (₮) | Валют | Ханш (₮) |
|-------|---------:|-------|---------:|
| EUR | 4,038.06 | CHF | 4,361.66 |
| GBP | 4,816.28 | CAD | 2,559.46 |
| RUB | 43.77 | SGD | 2,815.37 |
| CNY | 538.60 | SEK | 363.10 |
| JPY | 22.75 | TRY | 72.52 |
| KRW | 2.72 | HKD | 458.41 |
| AUD | 2,527.47 | | |

Ханшийг `Currency.kt` файлд тогтмол утгаар бичсэн. Шинэчлэх бол тэр файлд тоог солино.

## Файлууд

- `app/src/main/java/com/example/moneyconverter/MainActivity.kt` – NavHostFragment агуулна
- `Currency.kt` – валютын жагсаалт, ханш, тооцоо
- `CurrencyListFragment.kt`, `MoneyConverterFragment.kt` – 2 дэлгэц
- `res/navigation/nav_graph.xml` – дэлгэц хоорондын шилжилт

Тугуудын зургийг flagcdn.com сайтаас авсан (`res/drawable-nodpi`).

Хоосон, буруу дүн оруулахад "Зөв дүн оруулна уу" гэсэн алдаа гарна.
