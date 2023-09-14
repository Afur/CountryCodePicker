import 'package:flutter/material.dart';

import 'package:country_code_picker/src/country_code.dart';
import 'package:country_code_picker/src/country_localizations.dart';

class SelectionDialog extends StatefulWidget {
  final List<CountryCode> elements;
  final double flagWidth;
  final List<CountryCode> favoriteElements;

  const SelectionDialog(
    this.elements,
    this.favoriteElements,
    this.flagWidth,
  );

  @override
  State<StatefulWidget> createState() => _SelectionDialogState();
}

class _SelectionDialogState extends State<SelectionDialog> {
  /// this is useful for filtering purpose
  late List<CountryCode> _filteredElements;

  @override
  void initState() {
    super.initState();
    _filteredElements = widget.elements;
  }

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.hardEdge,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search)),
                onChanged: _onQueryChanged,
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  if (widget.favoriteElements.isEmpty)
                    const DecoratedBox(decoration: BoxDecoration())
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...widget.favoriteElements.map(
                          (f) => SimpleDialogOption(
                            child: _buildOption(f),
                            onPressed: () {
                              _selectItem(f);
                            },
                          ),
                        ),
                        const Divider(),
                      ],
                    ),
                  if (_filteredElements.isEmpty)
                    _buildEmptySearchWidget(context)
                  else
                    ..._filteredElements.map(
                      (e) => SimpleDialogOption(
                        child: _buildOption(e),
                        onPressed: () {
                          _selectItem(e);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildOption(CountryCode e) {
    return SizedBox(
      width: 400,
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Image.asset(
                e.flagUri,
                package: 'country_code_picker',
                width: widget.flagWidth,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              e.toLongString(),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchWidget(BuildContext context) {
    return Center(
      child: Text(CountryLocalizations.of(context)?.translate('no_country') ?? 'No country found'),
    );
  }

  void _onQueryChanged(String query) {
    final upper = query.toUpperCase();
    setState(() {
      _filteredElements = widget.elements
          .where((e) => e.code.contains(upper) || e.dialCode.contains(upper) || e.name.toUpperCase().contains(upper))
          .toList();
    });
  }

  void _selectItem(CountryCode e) {
    Navigator.pop(context, e);
  }
}
