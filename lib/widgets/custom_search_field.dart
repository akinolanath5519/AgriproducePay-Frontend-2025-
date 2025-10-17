import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

/// A reusable search field for selecting items with autocomplete suggestions.
/// Works for Commodity, Supplier, Customer, or any generic type.
class CustomSearchField<T> extends StatelessWidget {
  final TextEditingController controller;
  final List<T> suggestions;
  final String hint;
  final String Function(T) displayText;
  final void Function(T) onSelected;
  final String? Function(String?)? validator;
  final bool enabled;
  final IconData icon;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const CustomSearchField({
    super.key,
    required this.controller,
    required this.suggestions,
    required this.hint,
    required this.displayText,
    required this.onSelected,
    this.validator,
    this.enabled = true,
    this.icon = Icons.arrow_drop_down,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: AbsorbPointer(
        absorbing: !enabled,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Stack(
            children: [
              SearchField<T>(
                controller: controller,
                suggestions: suggestions
                    .map((item) => SearchFieldListItem<T>(
                          displayText(item),
                          item: item,
                        ))
                    .toList(),
                hint: hint,
                searchInputDecoration: SearchInputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                validator: validator,
                onSuggestionTap: (suggestion) {
                  onSelected(suggestion.item as T);
                  FocusScope.of(context).unfocus();
                },
              ),
              Positioned(
                right: 10,
                top: 12,
                child: Icon(icon, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
