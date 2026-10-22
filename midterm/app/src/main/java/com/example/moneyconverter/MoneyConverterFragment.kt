package com.example.moneyconverter

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.AdapterView
import android.widget.ArrayAdapter
import androidx.fragment.app.Fragment
import com.example.moneyconverter.databinding.FragmentMoneyConverterBinding

// Ханш хөрвүүлэгч -2: сонгосон валютыг төгрөг рүү хөрвүүлнэ
class MoneyConverterFragment : Fragment() {

    private var _binding: FragmentMoneyConverterBinding? = null
    private val binding get() = _binding!!
    private var selected = CurrencyList.items[0]

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentMoneyConverterBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        selected = CurrencyList.find(arguments?.getString(ARG_CODE)) ?: CurrencyList.items[0]
        binding.fromFlag.text = selected.flag

        val codes = CurrencyList.items.map { it.code }
        binding.currencySpinner.adapter =
            ArrayAdapter(requireContext(), R.layout.item_currency_spinner, codes)
        binding.currencySpinner.setSelection(CurrencyList.items.indexOf(selected))
        binding.currencySpinner.onItemSelectedListener =
            object : AdapterView.OnItemSelectedListener {
                override fun onItemSelected(
                    parent: AdapterView<*>?, view: View?, position: Int, id: Long
                ) {
                    if (CurrencyList.items[position] != selected) {
                        selected = CurrencyList.items[position]
                        binding.fromFlag.text = selected.flag
                        binding.resultText.text = ""
                    }
                }

                override fun onNothingSelected(parent: AdapterView<*>?) {}
            }

        binding.convertButton.setOnClickListener { convert() }
    }

    private fun convert() {
        val text = binding.amountInput.text.toString().trim().replace(',', '.')
        val amount = text.toDoubleOrNull()
        if (amount == null || amount < 0 || !amount.isFinite()) {
            binding.amountInput.error = getString(R.string.invalid_amount)
            binding.resultText.text = ""
            return
        }
        val mnt = CurrencyList.toMnt(amount, selected)
        binding.resultText.text = CurrencyList.format(mnt)
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }

    companion object {
        const val ARG_CODE = "currencyCode"
    }
}
