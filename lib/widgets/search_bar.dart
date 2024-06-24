import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearchChanged;
  final Function(String?) onFilterChanged;
  final List<String> filterOptions;

  const CustomSearchBar({
    required this.controller,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.filterOptions,
    Key? key,
  }) : super(key: key);

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  String? selectedFilter;

  void _showFilterDialog() async {
    String? result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter by Department'),
          content: DropdownButtonFormField<String>(
            value: selectedFilter,
            items: widget.filterOptions.map((String department) {
              return DropdownMenuItem<String>(
                value: department,
                child: Text(department),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedFilter = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, selectedFilter);
              },
              child: Text('Apply'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: Text('Clear'),
            ),
          ],
        );
      },
    );

    widget.onFilterChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: 'Search Action Team',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: widget.onSearchChanged,
          ),
        ),
        IconButton(
          icon: Icon(Icons.filter_list),
          tooltip: 'Filter',
          onPressed: _showFilterDialog,
        ),
      ],
    );
  }
}
