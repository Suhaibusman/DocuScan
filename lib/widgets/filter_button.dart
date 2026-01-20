import 'package:flutter/material.dart';
import '../models/document_model.dart';
import '../constants/colors.dart';

class FilterButton extends StatelessWidget {
  final FilterType filterType;
  final bool isSelected;
  final VoidCallback onPressed;

  const FilterButton({
    Key? key,
    required this.filterType,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        child: Text(
          _getFilterName(filterType),
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  String _getFilterName(FilterType type) {
    switch (type) {
      case FilterType.none:
        return 'Original';
      case FilterType.grayscale:
        return 'Grayscale';
      case FilterType.blackWhite:
        return 'B&W';
      case FilterType.enhanced:
        return 'Enhanced';
    }
  }
}
