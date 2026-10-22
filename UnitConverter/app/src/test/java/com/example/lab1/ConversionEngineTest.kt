package com.example.lab1

import com.example.lab1.converter.ConversionEngine
import com.example.lab1.converter.MeasurementCatalog
import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

class ConversionEngineTest {

    @Test
    fun everyCategoryHasRequiredUnits() {
        MeasurementCatalog.categories.forEach { category ->
            val expectedMinimum = if (category.id == "temperature") 3 else 6
            assertTrue(
                "${category.title} has fewer than $expectedMinimum units",
                category.units.size >= expectedMinimum
            )
        }
    }

    @Test
    fun everyUnitRoundTripsThroughCategoryBaseUnit() {
        MeasurementCatalog.categories.forEach { category ->
            category.units.forEach { unit ->
                val original = 17.25
                val converted = ConversionEngine.convert(
                    category.id,
                    unit.id,
                    category.defaultToUnitId,
                    original
                )
                val restored = ConversionEngine.convert(
                    category.id,
                    category.defaultToUnitId,
                    unit.id,
                    converted
                )
                assertEquals("${category.id}/${unit.id}", original, restored, 0.000001)
            }
        }
    }

    @Test
    fun convertsLengthThroughBaseUnit() {
        val result = ConversionEngine.convert("length", "mile", "kilometre", 1.0)
        assertEquals(1.609344, result, 0.0000001)
    }

    @Test
    fun convertsTemperatureWithOffset() {
        val fahrenheit = ConversionEngine.convert("temperature", "celsius", "fahrenheit", -40.0)
        val kelvin = ConversionEngine.convert("temperature", "celsius", "kelvin", 0.0)
        assertEquals(-40.0, fahrenheit, 0.0000001)
        assertEquals(273.15, kelvin, 0.0000001)
    }

    @Test
    fun representativeConversionFromEachLinearCategoryIsCorrect() {
        assertEquals(10_000.0, ConversionEngine.convert("area", "hectare", "square_metre", 1.0), 0.0)
        assertEquals(1_000.0, ConversionEngine.convert("volume", "litre", "millilitre", 1.0), 0.0)
        assertEquals(1_000.0, ConversionEngine.convert("mass", "kilogram", "gram", 1.0), 0.0)
        assertEquals(3_600.0, ConversionEngine.convert("time", "hour", "second", 1.0), 0.0)
        assertEquals(10.0, ConversionEngine.convert("speed", "kilometre_hour", "metre_second", 36.0), 0.000001)
        assertEquals(1_000.0, ConversionEngine.convert("density", "gram_cubic_centimetre", "kilogram_cubic_metre", 1.0), 0.0)
        assertEquals(3_600_000.0, ConversionEngine.convert("energy", "kilowatt_hour", "joule", 1.0), 0.0)
        assertEquals(Math.PI, ConversionEngine.convert("angle", "degree", "radian", 180.0), 0.0000001)
        assertEquals(9.80665, ConversionEngine.convert("weight", "kilogram_force", "newton", 1.0), 0.000001)
    }

    @Test
    fun convertsFuelEconomyWithoutPairwiseFormula() {
        val milesPerGallon = ConversionEngine.convert(
            "fuel",
            "litre_100_kilometre",
            "mile_gallon_us",
            8.0
        )
        assertEquals(29.4018, milesPerGallon, 0.0001)
    }

    @Test
    fun sameUnitReturnsOriginalValue() {
        val result = ConversionEngine.convert("energy", "joule", "joule", 123.456)
        assertEquals(123.456, result, 0.0)
    }

    @Test
    fun rejectsNegativeValuesOutsideTemperature() {
        assertThrows(IllegalArgumentException::class.java) {
            ConversionEngine.convert("mass", "kilogram", "gram", -1.0)
        }
    }

    @Test
    fun formatsWithAtMostSixDecimalPlaces() {
        assertEquals("0.333333", ConversionEngine.format(1.0 / 3.0))
        assertEquals("12.5", ConversionEngine.format(12.500000))
        assertEquals("1.25E-7", ConversionEngine.format(0.000000125))
    }
}
