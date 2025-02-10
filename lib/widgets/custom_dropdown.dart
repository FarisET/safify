import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String? text; // Change type to String
  final String? hintText;
  final List<DropdownMenuItem<T>> items;
  final Function(T?)? onChanged;
  final String? errorText;
  final bool isEnabled;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.errorText,
    this.isEnabled = true,
    required this.text, // Now a String
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText != null
                  ? Colors.red
                  : Theme.of(context).highlightColor,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<T>(
              value: value,
              hint: Text(
                hintText ?? 'Select an option',
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
              items: items,
              onChanged: isEnabled ? onChanged : null,
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontWeight: FontWeight.bold,
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).secondaryHeaderColor,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                errorText: errorText,
                errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              isExpanded: true,
              dropdownColor: Theme.of(context).cardColor,
              menuMaxHeight: MediaQuery.of(context).size.height * 0.4,
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
              focusColor: Theme.of(context).focusColor,
              selectedItemBuilder: (BuildContext context) {
                return items.map<Widget>((DropdownMenuItem<T> item) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      text ??
                          item.value
                              .toString(), // Use `text` instead of `value`
                      style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
        const SizedBox(height: 10), // Ensures dropdown opens below field
      ],
    );
  }
}
