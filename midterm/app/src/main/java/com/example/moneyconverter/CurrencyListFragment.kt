package com.example.moneyconverter

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.os.bundleOf
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.example.moneyconverter.databinding.FragmentCurrencyListBinding
import com.example.moneyconverter.databinding.ItemCurrencyBinding

// Ханш хөрвүүлэгч -1: валютын жагсаалт
class CurrencyListFragment : Fragment() {

    private var _binding: FragmentCurrencyListBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentCurrencyListBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        for (currency in CurrencyList.items) {
            val row = ItemCurrencyBinding.inflate(layoutInflater, binding.currencyRows, false)
            row.currencyFlag.setImageResource(currency.flag)
            row.currencyName.text = currency.name
            row.currencyCode.text = currency.code
            row.root.setOnClickListener {
                findNavController().navigate(
                    R.id.action_currencyListFragment_to_moneyConverterFragment,
                    bundleOf(MoneyConverterFragment.ARG_CODE to currency.code)
                )
            }
            binding.currencyRows.addView(row.root)
        }
    }

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }
}
