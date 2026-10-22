package com.example.lab1.converter

import java.math.RoundingMode
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.Locale
import kotlin.math.PI
import kotlin.math.abs

data class MeasurementCategory(
    val id: String,
    val title: String,
    val units: List<UnitDefinition>,
    val defaultFromUnitId: String,
    val defaultToUnitId: String,
    val allowsNegative: Boolean = false
)

data class UnitDefinition(
    val id: String,
    val name: String,
    val symbol: String,
    val scaleToBase: Double = 1.0,
    val offsetToBase: Double = 0.0,
    val reciprocalConstant: Double? = null
) {
    val displayName: String get() = "$name ($symbol)"

    fun toBase(value: Double): Double = reciprocalConstant?.let { constant ->
        require(value != 0.0) { ConversionEngine.ERROR_UNDEFINED_ZERO }
        constant / value
    } ?: (value * scaleToBase + offsetToBase)

    fun fromBase(baseValue: Double): Double = reciprocalConstant?.let { constant ->
        require(baseValue != 0.0) { ConversionEngine.ERROR_UNDEFINED_ZERO }
        constant / baseValue
    } ?: ((baseValue - offsetToBase) / scaleToBase)
}

object MeasurementCatalog {
    val categories: List<MeasurementCategory> = listOf(
        MeasurementCategory(
            id = "length",
            title = "Length",
            units = listOf(
                unit("millimetre", "Millimetre", "mm", 0.001),
                unit("centimetre", "Centimetre", "cm", 0.01),
                unit("metre", "Metre", "m", 1.0),
                unit("kilometre", "Kilometre", "km", 1_000.0),
                unit("inch", "Inch", "in", 0.0254),
                unit("foot", "Foot", "ft", 0.3048),
                unit("yard", "Yard", "yd", 0.9144),
                unit("mile", "Mile", "mi", 1_609.344)
            ),
            defaultFromUnitId = "metre",
            defaultToUnitId = "kilometre"
        ),
        MeasurementCategory(
            id = "area",
            title = "Area",
            units = listOf(
                unit("square_millimetre", "Square millimetre", "mm²", 0.000001),
                unit("square_centimetre", "Square centimetre", "cm²", 0.0001),
                unit("square_metre", "Square metre", "m²", 1.0),
                unit("square_kilometre", "Square kilometre", "km²", 1_000_000.0),
                unit("hectare", "Hectare", "ha", 10_000.0),
                unit("acre", "Acre", "ac", 4_046.8564224),
                unit("square_foot", "Square foot", "ft²", 0.09290304)
            ),
            defaultFromUnitId = "square_metre",
            defaultToUnitId = "hectare"
        ),
        MeasurementCategory(
            id = "volume",
            title = "Volume",
            units = listOf(
                unit("millilitre", "Millilitre", "mL", 0.001),
                unit("centilitre", "Centilitre", "cL", 0.01),
                unit("litre", "Litre", "L", 1.0),
                unit("cubic_metre", "Cubic metre", "m³", 1_000.0),
                unit("teaspoon_us", "US teaspoon", "tsp", 0.0049289216),
                unit("tablespoon_us", "US tablespoon", "tbsp", 0.0147867648),
                unit("cup_us", "US cup", "cup", 0.2365882365),
                unit("gallon_us", "US gallon", "gal", 3.785411784)
            ),
            defaultFromUnitId = "litre",
            defaultToUnitId = "millilitre"
        ),
        MeasurementCategory(
            id = "mass",
            title = "Mass",
            units = listOf(
                unit("milligram", "Milligram", "mg", 0.000001),
                unit("gram", "Gram", "g", 0.001),
                unit("kilogram", "Kilogram", "kg", 1.0),
                unit("tonne", "Tonne", "t", 1_000.0),
                unit("ounce", "Ounce", "oz", 0.028349523125),
                unit("pound", "Pound", "lb", 0.45359237),
                unit("stone", "Stone", "st", 6.35029318)
            ),
            defaultFromUnitId = "kilogram",
            defaultToUnitId = "pound"
        ),
        MeasurementCategory(
            id = "time",
            title = "Time",
            units = listOf(
                unit("millisecond", "Millisecond", "ms", 0.001),
                unit("second", "Second", "s", 1.0),
                unit("minute", "Minute", "min", 60.0),
                unit("hour", "Hour", "h", 3_600.0),
                unit("day", "Day", "day", 86_400.0),
                unit("week", "Week", "week", 604_800.0),
                unit("year", "Year", "yr", 31_557_600.0)
            ),
            defaultFromUnitId = "minute",
            defaultToUnitId = "hour"
        ),
        MeasurementCategory(
            id = "speed",
            title = "Speed",
            units = listOf(
                unit("metre_second", "Metre per second", "m/s", 1.0),
                unit("kilometre_hour", "Kilometre per hour", "km/h", 1.0 / 3.6),
                unit("mile_hour", "Mile per hour", "mph", 0.44704),
                unit("knot", "Knot", "kn", 0.5144444444),
                unit("foot_second", "Foot per second", "ft/s", 0.3048),
                unit("centimetre_second", "Centimetre per second", "cm/s", 0.01),
                unit("mach", "Mach", "Ma", 343.0)
            ),
            defaultFromUnitId = "kilometre_hour",
            defaultToUnitId = "metre_second"
        ),
        MeasurementCategory(
            id = "temperature",
            title = "Temperature",
            units = listOf(
                unit("celsius", "Celsius", "°C", 1.0),
                unit("fahrenheit", "Fahrenheit", "°F", 5.0 / 9.0, -160.0 / 9.0),
                unit("kelvin", "Kelvin", "K", 1.0, -273.15)
            ),
            defaultFromUnitId = "celsius",
            defaultToUnitId = "fahrenheit",
            allowsNegative = true
        ),
        MeasurementCategory(
            id = "density",
            title = "Density",
            units = listOf(
                unit("kilogram_cubic_metre", "Kilogram per cubic metre", "kg/m³", 1.0),
                unit("gram_cubic_centimetre", "Gram per cubic centimetre", "g/cm³", 1_000.0),
                unit("gram_millilitre", "Gram per millilitre", "g/mL", 1_000.0),
                unit("kilogram_litre", "Kilogram per litre", "kg/L", 1_000.0),
                unit("pound_cubic_foot", "Pound per cubic foot", "lb/ft³", 16.01846337),
                unit("pound_cubic_inch", "Pound per cubic inch", "lb/in³", 27_679.90471),
                unit("ounce_cubic_inch", "Ounce per cubic inch", "oz/in³", 1_729.994044)
            ),
            defaultFromUnitId = "kilogram_cubic_metre",
            defaultToUnitId = "gram_cubic_centimetre"
        ),
        MeasurementCategory(
            id = "energy",
            title = "Energy",
            units = listOf(
                unit("joule", "Joule", "J", 1.0),
                unit("kilojoule", "Kilojoule", "kJ", 1_000.0),
                unit("megajoule", "Megajoule", "MJ", 1_000_000.0),
                unit("calorie", "Calorie", "cal", 4.184),
                unit("kilocalorie", "Kilocalorie", "kcal", 4_184.0),
                unit("watt_hour", "Watt-hour", "Wh", 3_600.0),
                unit("kilowatt_hour", "Kilowatt-hour", "kWh", 3_600_000.0),
                unit("btu", "British thermal unit", "BTU", 1_055.05585262)
            ),
            defaultFromUnitId = "joule",
            defaultToUnitId = "kilojoule"
        ),
        MeasurementCategory(
            id = "angle",
            title = "Angle",
            units = listOf(
                unit("degree", "Degree", "°", PI / 180.0),
                unit("radian", "Radian", "rad", 1.0),
                unit("gradian", "Gradian", "gon", PI / 200.0),
                unit("arcminute", "Arcminute", "′", PI / 10_800.0),
                unit("arcsecond", "Arcsecond", "″", PI / 648_000.0),
                unit("turn", "Turn", "turn", 2.0 * PI)
            ),
            defaultFromUnitId = "degree",
            defaultToUnitId = "radian"
        ),
        MeasurementCategory(
            id = "weight",
            title = "Weight",
            units = listOf(
                unit("millinewton", "Millinewton", "mN", 0.001),
                unit("newton", "Newton", "N", 1.0),
                unit("kilonewton", "Kilonewton", "kN", 1_000.0),
                unit("dyne", "Dyne", "dyn", 0.00001),
                unit("pound_force", "Pound-force", "lbf", 4.4482216153),
                unit("kilogram_force", "Kilogram-force", "kgf", 9.80665),
                unit("ounce_force", "Ounce-force", "ozf", 0.27801385095)
            ),
            defaultFromUnitId = "newton",
            defaultToUnitId = "kilogram_force"
        ),
        MeasurementCategory(
            id = "fuel",
            title = "Fuel",
            units = listOf(
                unit("kilometre_litre", "Kilometre per litre", "km/L", 1.0),
                reciprocalUnit("litre_100_kilometre", "Litres per 100 kilometres", "L/100 km", 100.0),
                unit("mile_gallon_us", "Miles per US gallon", "mpg US", 0.425143707),
                unit("mile_gallon_uk", "Miles per UK gallon", "mpg UK", 0.35400619),
                reciprocalUnit("litre_kilometre", "Litres per kilometre", "L/km", 1.0),
                reciprocalUnit("us_gallon_100_mile", "US gallons per 100 miles", "gal/100 mi", 42.5143707),
                reciprocalUnit("uk_gallon_100_mile", "UK gallons per 100 miles", "gal/100 mi UK", 35.400619)
            ),
            defaultFromUnitId = "litre_100_kilometre",
            defaultToUnitId = "mile_gallon_us"
        )
    )

    fun findCategory(id: String?): MeasurementCategory? = categories.firstOrNull { it.id == id }

    private fun unit(
        id: String,
        name: String,
        symbol: String,
        scale: Double,
        offset: Double = 0.0
    ) = UnitDefinition(id, name, symbol, scale, offset)

    private fun reciprocalUnit(
        id: String,
        name: String,
        symbol: String,
        constant: Double
    ) = UnitDefinition(id, name, symbol, reciprocalConstant = constant)
}

object ConversionEngine {
    const val ERROR_NEGATIVE_VALUE = "negative_value"
    const val ERROR_UNDEFINED_ZERO = "undefined_zero"

    fun convert(
        categoryId: String,
        fromUnitId: String,
        toUnitId: String,
        value: Double
    ): Double {
        require(value.isFinite()) { "Value must be finite" }
        val category = requireNotNull(MeasurementCatalog.findCategory(categoryId)) {
            "Unknown category: $categoryId"
        }
        require(category.allowsNegative || value >= 0.0) { ERROR_NEGATIVE_VALUE }
        val from = requireNotNull(category.units.firstOrNull { it.id == fromUnitId }) {
            "Unknown source unit: $fromUnitId"
        }
        val to = requireNotNull(category.units.firstOrNull { it.id == toUnitId }) {
            "Unknown target unit: $toUnitId"
        }
        if (from == to) return value

        val result = to.fromBase(from.toBase(value))
        require(result.isFinite()) { ERROR_UNDEFINED_ZERO }
        return result
    }

    fun format(value: Double): String {
        val magnitude = abs(value)
        val pattern = if (magnitude != 0.0 && (magnitude < 0.000001 || magnitude >= 1_000_000_000_000.0)) {
            "0.######E0"
        } else {
            "0.######"
        }
        return DecimalFormat(pattern, DecimalFormatSymbols(Locale.US)).apply {
            roundingMode = RoundingMode.HALF_UP
        }.format(value)
    }
}
