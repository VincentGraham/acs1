import 'package:flutter/material.dart';
import 'package:preference_center_web/routes/preferences_grid_router_delegate.dart';
import 'package:preference_center_web/state/list_filters.dart';
import 'package:preference_center_web/state/actions.dart';
import 'package:preference_center_web/state/view_models.dart';
import 'package:preference_center_web/widgets/basic.dart';
import 'package:provider/provider.dart';

import '../basic/dropdown.dart';
import '../basic/expandable_tile.dart';

class PreferenceListTile extends StatelessWidget {
  final double height;
  final double expandedHeightFactor;

  /// spacing between items
  final double spacing;

  final void Function(String?, PageAction) onClick;

  const PreferenceListTile({
    Key? key,
    this.height = 60,
    this.spacing = 24.0,
    this.expandedHeightFactor = 2.0,
    required this.onClick,
  }) : super(key: key);

  Widget _preferenceInformation() {
    return Selector<PreferenceViewModel, PreferenceViewModel>(
      selector: (_, preference) => preference,
      // only rebuild the entire row if the underlying preference changes
      // does not update if only a recommend relationship changes
      shouldRebuild: (p1, p2) => p1.rawPreference != p2.rawPreference,
      builder: (context, state, child) {
        final List<Widget> tiles = [
          ListTileItem(
            width: 80,
            child: Text('${state.type}', maxLines: 1),
          ),
          ListTileItem(
            width: 40,
            alignment: Alignment.center,
            child: CircleAvatar(
              foregroundImage:
                  state.hasLogo ? NetworkImage(state.logo, scale: 0.2) : null,
            ),
          ),
          ListTileItem(width: 120, child: Text('${state.code}', maxLines: 1)),
          ListTileItem(width: 300, child: Text('${state.name}', maxLines: 1)),
          ListTileItem(
            width: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  icon: Icon(Icons.edit),
                  label: Text("Edit"),
                  onPressed: () => (Router.of(context).routerDelegate
                          as PreferencesGridRouterDelegate)
                      .goToPage(action: PageAction.edit, code: state.code),
                ),
              ],
            ),
          ),

          // if preference is null or it is not recommended/recommending then do not
          // display the buttons
          // rebuilts the buttons when recommendation status changes
          Visibility(
            visible: (state.isRecommended || state.isRecommending),
            child: ListTileItem(
              width: 240,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Selector<PreferenceViewModel, bool>(
                  selector: (_, state) => state.isRecommending,
                  builder: (context, isRecommending, child) {
                    return ElevatedButton(
                      onPressed: () => Provider.of<PreferenceCenterModel>(
                              context,
                              listen: false)
                          .toggleCurrentIsRecommendation(recommendedBy: state),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          CircleBorder(),
                        ),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.all(8.0),
                        ),
                      ),
                      child: isRecommending
                          ? Icon(Icons.check,
                              color: Colors.green.shade800, size: 24)
                          : Container(width: 24, height: 24),
                    );
                  },
                ),
              ),
            ),
          ),

          Visibility(
            visible: (state.isRecommending || state.isRecommended),
            child: ListTileItem(
              width: 240,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Selector<PreferenceViewModel, bool>(
                  selector: (_, state) => state.isRecommended,
                  builder: (context, isRecommended, child) {
                    return ElevatedButton(
                      onPressed: () => Provider.of<PreferenceCenterModel>(
                              context,
                              listen: false)
                          .toggleIsRecommendationOfCurrent(
                              recommendation: state),
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          CircleBorder(),
                        ),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.all(8.0)),
                      ),
                      child: isRecommended
                          ? Icon(
                              Icons.check,
                              color: Colors.green.shade800,
                              size: 24,
                            )
                          : Container(width: 24, height: 24),
                    );
                  },
                ),
              ),
            ),
          ),
        ];

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...List.generate(
              tiles.length * 2 - 1,
              (i) {
                // add spacing between tiles
                if (i % 2 == 1) {
                  return SizedBox(width: spacing);
                } else {
                  return tiles[((i) / 2).round()];
                }
              },
            )
          ],
        );
      },
    );
  }

  Widget _preferenceDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black87,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.all(Radius.circular(2))),
            padding: const EdgeInsets.all(4),
            child: Selector<PreferenceViewModel, List<String>>(
              selector: (_, state) => state.categories
                  .map((e) => e.name ?? e.code ?? "Unknown Category")
                  .toList(),
              builder: (_, categories, __) => Text("${categories.join(', ')}"),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableTile(
      key: PageStorageKey(
        Provider.of<PreferenceViewModel>(context, listen: false).rawPreference,
      ),
      height: height,
      maxHeight: height * expandedHeightFactor,
      child: _preferenceInformation(),
      expandedChild: Container(
        color: Colors.deepOrange,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: _preferenceDetails(),
      ),
    );
  }
}

class PreferenceListHeader extends StatelessWidget {
  final double height;
  final double heightFactor;

  /// used to filter results
  final List<String> typeOptions;
  final List<String> recommendationOptions;
  final List<String> errorOptions;

  const PreferenceListHeader({
    Key? key,
    this.height = 64,
    this.heightFactor = 1.0,
    this.typeOptions = const [],
    this.recommendationOptions = const [],
    this.errorOptions = const [],
  }) : super(key: key);

  final List<Widget> columns = const [
    ListTileItem(
        width: 80,
        child: Text(
          "Type",
          maxLines: 1,
        )),
    SizedBox(width: 20),
    ListTileItem(
        width: 40,
        child: Text(
          "Logo",
          maxLines: 1,
        )),
    SizedBox(width: 20),
    ListTileItem(
        width: 120,
        child: Text(
          "Code",
          maxLines: 1,
        )),
    SizedBox(width: 20),
    ListTileItem(
        width: 300,
        child: Text(
          "Name",
          maxLines: 1,
        )),
    SizedBox(width: 20),
    ListTileItem(
      width: 300,
      child: Text(
        "Actions",
        maxLines: 1,
      ),
    ),
  ];

  Widget _buildNonResizable(context, state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey),
          ),
        ),
        child: SizedBox(
          height: height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Text(
                      "All Preferences",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Spacer(),
                    errorFilterDropDown(state),
                  ],
                ),
              ),
              Flexible(child: Row(children: columns)),
            ],
          ),
        ),
      ),
    );
  }

  Widget recommendationDropDown(context, state) {
    return DropDown(
      borderRadius: BorderRadius.circular(90),
      height: 64,
      width: 240,
      options: recommendationOptions,
      onChange: (index) {
        switch (recommendationOptions[index]) {
          case "Both":
            (Router.of(context).routerDelegate as PreferencesGridRouterDelegate)
                .goToPage(code: state.preference.code, action: PageAction.edit);
            break;
          case "Recommendations":
            (Router.of(context).routerDelegate as PreferencesGridRouterDelegate)
                .goToPage(
                    code: state.preference.code,
                    action: PageAction.getRecommendations);
            break;
          case "Recommended By":
            (Router.of(context).routerDelegate as PreferencesGridRouterDelegate)
                .goToPage(
                    code: state.preference.code,
                    action: PageAction.getRecommendedBy);
            break;
          default:
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ExpandableTileState> key = GlobalKey();
    return Consumer<PreferenceCenterModel>(
      builder: (context, state, child) {
        if (state.isHomePage) return _buildNonResizable(context, state);
        return ExpandableTile(
          key: key,
          height: height,
          maxHeight: height * heightFactor,
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    state.title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(width: 20),
                  ListTileItem(
                    width: 240,
                    child: recommendationDropDown(context, state),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.white)),
                    // probably dont do it this way
                    onPressed: () {
                      key.currentState?.toggleSize();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Add Recommendation"),
                    ),
                  ),
                  Spacer(),
                  errorFilterDropDown(state),
                ],
              ),
              Flexible(
                child: Row(
                  children: [
                    ...columns,
                    ...[
                      const SizedBox(width: 20),
                      ListTileItem(
                        width: 240,
                        child: Text(
                          "Recommends ${state.preference.shortName}",
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 20),
                      ListTileItem(
                        width: 240,
                        child: Text(
                          "${state.preference.shortName} Recommends",
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ],
                ),
              ),
            ],
          ),
          expandedChild: Container(
            width: 300,
            child: Autocomplete<PreferenceViewModel>(
              optionsBuilder: (TextEditingValue value) {
                if (value.text.length > 2) {
                  final text = value.text.toLowerCase();
                  return state.allPreferences.where((preference) =>
                      (preference.rawPreference != null) &&
                          (preference.code.toLowerCase().contains(text)) ||
                      (preference.name.toLowerCase().contains(text)) ||
                      (preference.type.toLowerCase().contains(text)) ||
                      (preference.rawPreference!
                          .toJson()
                          .toString()
                          .toLowerCase()
                          .contains(text)));
                } else {
                  return const [];
                }
              },
              displayStringForOption: (option) => option.code,
              optionsViewBuilder: (context, onSelect, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    child: SizedBox(
                      height: 200,
                      width: 650,
                      child: ListView.builder(
                        itemBuilder: (context, i) {
                          final option = options.elementAt(i);
                          return InkWell(
                            onTap: () {
                              onSelect(option);
                            },
                            child: Container(
                              height: 45,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0.1),
                              ),
                              child: Text(option.info),
                            ),
                          );
                        },
                        itemCount: options.length,
                      ),
                    ),
                  ),
                );
              },
              fieldViewBuilder: (context, controller, node, onSubmit) {
                return TextFormField(
                  focusNode: node,
                  controller: controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (value) {
                    state.addRecommendationOfCurrent(recommendationCode: value);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget errorFilterDropDown(PreferenceCenterModel state) {
    return ListTileItem(
      width: 120,
      child: DropDown(
        title: "Error Filter",
        options: errorOptions,
        iconColor: Colors.white,
        onChange: (index) {
          var filter;
          switch (errorOptions[index]) {
            case 'All Errors':
              filter = ErrorFilter.all;
              break;
            case 'Value':
              filter = ErrorFilter.missingValue;
              break;
            case 'Data':
              filter = ErrorFilter.missingData;
              break;
            case 'Text':
              filter = ErrorFilter.textFormat;
              break;
            case 'Only':
              filter = ErrorFilter.onlyErrors;
              break;
            default:
              filter = ErrorFilter.noErrors;
              break;
          }
          state.errorFilter = filter;
        },
        borderRadius: BorderRadius.circular(90),
        height: 64,
        width: 120,
      ),
    );
  }
}

class LogoWithDefault extends StatelessWidget {
  const LogoWithDefault({Key? key, this.preference}) : super(key: key);
  final PreferenceViewModel? preference;

  @override
  Widget build(BuildContext context) {
    if (preference == null || !(preference!.hasLogo))
      return Image.network(
          'https://source.unsplash.com/random/${preference?.code ?? key}');
    return Image.network(preference!.logo);
  }
}
