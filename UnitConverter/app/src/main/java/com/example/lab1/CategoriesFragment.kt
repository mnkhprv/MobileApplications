package com.example.lab1

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.GridLayout
import android.widget.Toast
import androidx.core.os.bundleOf
import androidx.core.view.isVisible
import androidx.core.widget.doAfterTextChanged
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.example.lab1.converter.MeasurementCatalog
import com.example.lab1.databinding.FragmentCategoriesBinding
import com.example.lab1.databinding.ItemCategoryBinding
import java.util.Locale

class CategoriesFragment : Fragment() {

    private var _binding: FragmentCategoriesBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentCategoriesBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        renderCategories("")
        binding.searchInput.doAfterTextChanged { renderCategories(it?.toString().orEmpty()) }
        binding.historyButton.setOnClickListener {
            Toast.makeText(requireContext(), R.string.history_empty, Toast.LENGTH_SHORT).show()
        }
    }

    private fun renderCategories(query: String) {
        val normalizedQuery = query.trim().lowercase(Locale.ROOT)
        val categories = MeasurementCatalog.categories.filter {
            it.title.lowercase(Locale.ROOT).contains(normalizedQuery)
        }

        binding.categoryGrid.removeAllViews()
        categories.forEach { category ->
            val item = ItemCategoryBinding.inflate(layoutInflater, binding.categoryGrid, false)
            item.categoryName.text = category.title
            item.categoryIcon.setImageResource(iconFor(category.id))
            item.categoryCard.contentDescription = getString(
                R.string.open_category_description,
                category.title
            )
            item.categoryCard.setOnClickListener {
                findNavController().navigate(
                    R.id.action_categoriesFragment_to_converterFragment,
                    bundleOf(ConverterFragment.ARG_CATEGORY_ID to category.id)
                )
            }
            item.categoryCard.layoutParams = GridLayout.LayoutParams().apply {
                width = 0
                height = dpToPx(136)
                columnSpec = GridLayout.spec(GridLayout.UNDEFINED, 1f)
                setMargins(dpToPx(6), dpToPx(6), dpToPx(6), dpToPx(6))
            }
            binding.categoryGrid.addView(item.root)
        }
        binding.emptyState.isVisible = categories.isEmpty()
    }

    private fun iconFor(categoryId: String): Int = when (categoryId) {
        "length" -> R.drawable.ic_category_length
        "area" -> R.drawable.ic_category_area
        "volume" -> R.drawable.ic_category_volume
        "mass" -> R.drawable.ic_category_mass
        "time" -> R.drawable.ic_category_time
        "speed" -> R.drawable.ic_category_speed
        "temperature" -> R.drawable.ic_category_temperature
        "density" -> R.drawable.ic_category_density
        "energy" -> R.drawable.ic_category_energy
        "angle" -> R.drawable.ic_category_angle
        "weight" -> R.drawable.ic_category_weight
        "fuel" -> R.drawable.ic_category_fuel
        else -> R.drawable.ic_swap
    }

    private fun dpToPx(dp: Int): Int =
        (dp * resources.displayMetrics.density).toInt()

    override fun onDestroyView() {
        _binding = null
        super.onDestroyView()
    }
}
