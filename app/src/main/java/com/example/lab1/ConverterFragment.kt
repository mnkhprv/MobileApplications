package com.example.lab1

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import androidx.core.widget.doAfterTextChanged
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.example.lab1.converter.ConversionEngine
import com.example.lab1.converter.MeasurementCatalog
import com.example.lab1.converter.MeasurementCategory
import com.example.lab1.databinding.FragmentConverterBinding

class ConverterFragment : Fragment() {

    private var _binding: FragmentConverterBinding? = null
    private val binding get() = _binding!!
    private lateinit var category: MeasurementCategory
    private var fromIndex = 0
    private var toIndex = 0
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentConverterBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        val categoryId = arguments?.getString(ARG_CATEGORY_ID)
        category = MeasurementCatalog.findCategory(categoryId)
            ?: MeasurementCatalog.categories.first()
        val savedFromUnitId = savedInstanceState?.getString(STATE_FROM_UNIT_ID)
            ?: category.defaultFromUnitId
        val savedToUnitId = savedInstanceState?.getString(STATE_TO_UNIT_ID)
            ?: category.defaultToUnitId
        fromIndex = category.units.indexOfFirst { it.id == savedFromUnitId }
            .coerceAtLeast(0)
        toIndex = category.units.indexOfFirst { it.id == savedToUnitId }
            .coerceAtLeast(0)

        binding.categoryTitle.text = category.title
        binding.backButton.setOnClickListener { findNavController().popBackStack() }
        configureDropdowns()

        binding.valueInput.doAfterTextChanged { updateConversion() }
        binding.swapButton.setOnClickListener {
            val previousFrom = fromIndex
            fromIndex = toIndex
            toIndex = previousFrom
            binding.fromDropdown.setText(category.units[fromIndex].displayName, false)
            binding.toDropdown.setText(category.units[toIndex].displayName, false)
            updateConversion()
        }
    }

    private fun configureDropdowns() {
        val unitNames = category.units.map { it.displayName }
        val adapter = ArrayAdapter(requireContext(), R.layout.item_dropdown_unit, unitNames)
        binding.fromDropdown.setAdapter(adapter)
        binding.toDropdown.setAdapter(adapter)
        binding.fromDropdown.setText(unitNames[fromIndex], false)
        binding.toDropdown.setText(unitNames[toIndex], false)

        binding.fromDropdown.setOnItemClickListener { _, _, position, _ ->
            fromIndex = position
            updateConversion()
        }
        binding.toDropdown.setOnItemClickListener { _, _, position, _ ->
            toIndex = position
            updateConversion()
        }
    }

    private fun updateConversion() {
        val rawInput = binding.valueInput.text?.toString()?.trim().orEmpty()
        binding.valueInputLayout.error = null

        if (rawInput.isEmpty() || rawInput == "-" || rawInput == "." || rawInput == ",") {
            binding.resultInput.setText("")
            return
        }

        if (!VALID_NUMBER.matches(rawInput)) {
            showInputError(getString(R.string.invalid_number))
            return
        }

        val value = rawInput.replace(',', '.').toDoubleOrNull()
        if (value == null || !value.isFinite()) {
            showInputError(getString(R.string.invalid_number))
            return
        }

        runCatching {
            ConversionEngine.convert(
                categoryId = category.id,
                fromUnitId = category.units[fromIndex].id,
                toUnitId = category.units[toIndex].id,
                value = value
            )
        }.onSuccess { result ->
            binding.resultInput.setText(ConversionEngine.format(result))
        }.onFailure { error ->
            val message = when (error.message) {
                ConversionEngine.ERROR_NEGATIVE_VALUE -> getString(R.string.negative_value_error)
                ConversionEngine.ERROR_UNDEFINED_ZERO -> getString(R.string.zero_undefined_error)
                else -> getString(R.string.invalid_number)
            }
            showInputError(message)
        }
    }

    private fun showInputError(message: String) {
        binding.resultInput.setText("")
        binding.valueInputLayout.error = message
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        outState.putString(STATE_FROM_UNIT_ID, category.units[fromIndex].id)
        outState.putString(STATE_TO_UNIT_ID, category.units[toIndex].id)
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }

    companion object {
        const val ARG_CATEGORY_ID = "categoryId"
        private const val STATE_FROM_UNIT_ID = "fromUnitId"
        private const val STATE_TO_UNIT_ID = "toUnitId"
        private val VALID_NUMBER = Regex("^-?(?:\\d+(?:[.,]\\d*)?|[.,]\\d+)$")
    }
}
