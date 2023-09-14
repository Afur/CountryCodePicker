import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';

import 'package:country_code_picker/src/country_code.dart';
import 'package:country_code_picker/src/country_codes.dart';
import 'package:country_code_picker/src/selection_dialog.dart';

export 'src/country_code.dart';
export 'src/country_codes.dart';
export 'src/country_localizations.dart';
export 'src/selection_dialog.dart';

class CountryCodePicker extends StatefulWidget {
  final String initialSelection;
  final ValueChanged<CountryCode> onChanged;
  final ValueChanged<CountryCode?>? onInit;
  final List<String> favorites;
  final bool enabled;
  final double flagWidth;

  const CountryCodePicker({
    required this.initialSelection,
    required this.onChanged,
    required this.flagWidth,
    super.key,
    this.onInit,
    this.favorites = const [],
    this.enabled = true,
  });

  @override
  State<StatefulWidget> createState() => CountryCodePickerState();
}

class CountryCodePickerState extends State<CountryCodePicker> {
  late CountryCode selectedItem;
  late List<CountryCode> elements;
  late final List<CountryCode> favoriteElements;

  CountryCodePickerState();

  @override
  void initState() {
    super.initState();

    elements = countryCodes.map((json) => CountryCode.fromJson(json)).toList();

    selectedItem = elements.firstWhere(
      (item) =>
          (item.code.toUpperCase() == widget.initialSelection.toUpperCase()) ||
          (item.dialCode == widget.initialSelection) ||
          (item.name.toUpperCase() == widget.initialSelection.toUpperCase()),
      orElse: () => elements[0],
    );

    favoriteElements = elements
        .where(
          (item) =>
              widget.favorites.firstWhereOrNull(
                (criteria) =>
                    item.code.toUpperCase() == criteria.toUpperCase() ||
                    item.dialCode == criteria ||
                    item.name.toUpperCase() == criteria.toUpperCase(),
              ) !=
              null,
        )
        .toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    elements = elements.map((element) => element.localize(context)).toList();
    _onInit(selectedItem);
  }

  @override
  void didUpdateWidget(CountryCodePicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialSelection != widget.initialSelection) {
      selectedItem = elements.firstWhere(
        (criteria) =>
            (criteria.code.toUpperCase() == widget.initialSelection.toUpperCase()) ||
            (criteria.dialCode == widget.initialSelection) ||
            (criteria.name.toUpperCase() == widget.initialSelection.toUpperCase()),
        orElse: () => elements[0],
      );

      _onInit(selectedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: showCountryCodePickerDialog,
      child: Row(
        children: [
          const SizedBox(width: 12),
          Image.asset(
            selectedItem.flagUri,
            package: 'country_code_picker',
            width: 28,
          ),
          const SizedBox(width: 4),
          Text(
            selectedItem.dialCode,
            style: const TextStyle(
              color: Color(0xFF090A0A),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF090A0A),
            size: 24,
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Future<void> showCountryCodePickerDialog() async {
    final countryCode = await showDialog<CountryCode>(
      context: context,
      builder: (context) => Center(
        child: Dialog(
          child: SelectionDialog(
            elements,
            favoriteElements,
            widget.flagWidth,
          ),
        ),
      ),
    );

    if (countryCode != null) {
      setState(() {
        selectedItem = countryCode;
      });

      widget.onChanged(countryCode);
    }
  }

  void _onInit(CountryCode? countryCode) {
    widget.onInit?.call(countryCode);
  }
}
