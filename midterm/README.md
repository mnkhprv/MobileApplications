# Midterm – Ханш хөрвүүлэгч (Money Converter)

Figma загвар: https://www.figma.com/design/e6YlWUDlftAnUzvBhluKg2/Money-Converter

Ханш хөрвүүлэгчийг өмнөх Unit Converter апп дотор **fragment** ашиглан нэмсэн.
Unit Converter хэвээрээ ажиллана. Ангиллын дэлгэцийн зүүн дээд буланд байгаа **$**
товчийг дарахад ханш хөрвүүлэгч нээгдэнэ.

## Дэлгэцүүд

1. **Ханш хөрвүүлэгч -1** (`CurrencyListFragment`) – "Монгол банкны валютын ханш"
   гарчигтай 13 валютын жагсаалт (туг, нэр, код). Мөр дээр дарахад 2-р дэлгэц нээгдэнэ.
2. **Ханш хөрвүүлэгч -2** (`MoneyConverterFragment`) – сонгосон валютын туг, валют
   сонгох Spinner, дүн оруулах талбар, "Хөрвүүлэх" товч, төгрөгөөр гарсан үр дүн.

Хөрвүүлэх томьёо: `MNT = дүн × ханш`

Жишээ: 153.0 EUR × 3726 = 570,078 MNT

## Файлууд

- `app/src/main/java/com/example/lab1/midterm/Currency.kt` – валютын жагсаалт, ханш, тооцоо
- `app/src/main/java/com/example/lab1/midterm/CurrencyListFragment.kt`
- `app/src/main/java/com/example/lab1/midterm/MoneyConverterFragment.kt`
- `app/src/main/res/layout/fragment_currency_list.xml`, `item_currency.xml`
- `app/src/main/res/layout/fragment_money_converter.xml`, `item_currency_spinner.xml`
- `app/src/main/res/navigation/nav_graph.xml` – 2 шинэ fragment нэмсэн

## Тайлбар

- Ханшийг Монголбанкны ханшаас авч тогтмол утгаар кодонд бичсэн (интернэт шаардлагагүй).
- Хоосон, буруу дүн оруулахад "Зөв дүн оруулна уу" гэсэн алдаа гарна.
- Тугуудыг emoji ашиглан харуулсан.
