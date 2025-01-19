import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';

class CustomSearchField<T> extends StatelessWidget {
  final String hint;
  final List<SearchFieldListItem<T>> suggestions;
  final void Function(SearchFieldListItem<T>) onSuggestionTap;

  const CustomSearchField({
    Key? key,
    required this.hint,
    required this.suggestions,
    required this.onSuggestionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchField<T>(
      suggestions: suggestions,
      onSuggestionTap: onSuggestionTap,
      hint: hint,
    );
  }
}
