import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.onClear,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 8.0,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: widget.controller,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: const BorderSide(
                  color: Colors.deepPurple,
                  width: 1.0,
                ),
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Icon(Icons.search, color: Colors.grey, size: 24),
              ),
              suffixIcon: widget.onClear != null &&
                      widget.controller.text.isNotEmpty
                  ? IconButton(
                      icon:
                          const Icon(Icons.clear, color: Colors.grey, size: 24),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onClear?.call();
                      },
                      tooltip: 'Clear Search',
                    )
                  : null,
            ),
            onChanged: widget.onChanged,
            onTap: () {
              setState(() {
                _isFocused = true;
              });
            },
            onEditingComplete: () {
              setState(() {
                _isFocused = false;
              });
            },
          ),
        ),
      ),
    );
  }
}
