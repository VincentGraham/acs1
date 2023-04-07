import 'package:flutter/material.dart';
import 'package:preference_center_web/models/preference.dart';

class HorizontalListTile extends StatelessWidget {
  final double width = 80;
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class HorizontalList extends StatefulWidget {
  const HorizontalList({
    Key? key,
    this.itemWidth = 240,
    this.padding = EdgeInsets.zero,
    required this.items,
  }) : super(key: key);

  final double itemWidth;
  final EdgeInsets padding;
  final List<Preference> items;

  @override
  _HorizontalListState createState() => _HorizontalListState();
}

class _HorizontalListState extends State<HorizontalList> {
  late List<Preference> items;
  String? filterType;
  String? searchTerm;
  @override
  void initState() {
    super.initState();
    items = widget.items;
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool containsString(Preference preference, String? search) {
    if (search == null) return true;
    return (preference.name?.contains(search) ?? false) ||
        (preference.code?.contains(search) ?? false);
  }

  bool isType(Preference preference, String? type) {
    if (type == null) return true;
    return preference.type == type;
  }

  // type = null for no filter and search = null to clear search
  // always overwrites the filter or search term (no double filters)
  // but can stack a filter and a search on top of eachother
  void filter({String? type, String? search}) {
    setState(() {
      // reset the items to the full list
      if (type != null || search != null) {
        // reset the type filter and apply search
        items = widget.items;
        // search != null will search the items
        // search == null will check against the previous term.
        // null searches do not alter the items list
        if (type == null) {
          // a null [type] will undo the filter and only apply a search
          items.retainWhere(
              (preference) => containsString(preference, search ?? searchTerm));
        }

        // similar to search, will apply the given type filter
        // a null [search] will undo the search and only apply a filter
        if (search == null) {
          items.retainWhere(
              (preference) => isType(preference, type ?? filterType));
        }
      }
      filterType = type;
      searchTerm = search;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: ListView.builder(
        controller: ScrollController(keepScrollOffset: false),
        itemBuilder: (context, i) {
          return Container(
            width: widget.itemWidth,
            color: Colors.lightBlueAccent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("${items[i].name ?? 'No name'}"),
                Text("${items[i].code ?? 'No code'}"),
              ],
            ),
          );
        },
        itemCount: items.length,
      ),
    );
  }
}
