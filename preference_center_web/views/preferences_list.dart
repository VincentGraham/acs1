import 'package:flutter/material.dart';
import 'package:preference_center_web/api/preferences.dart';
import 'package:preference_center_web/api/recommendations.dart';
import 'package:preference_center_web/config/theme.dart';
import 'package:preference_center_web/models.dart';
import 'package:preference_center_web/routes/router.dart';
import 'package:preference_center_web/state/actions.dart';
import 'package:preference_center_web/state/view_models.dart';
import 'package:preference_center_web/widgets.dart';
import 'package:preference_center_web/widgets/preference_widgets.dart';
import 'package:provider/provider.dart';

enum SortableFields { name, code, type }

/// ideally this should only be created once and items will be updated by changing state
class StatefulPreferencesList extends StatefulWidget {
  final double itemHeight;
  final Preference? preference;
  final List<Preference> items;
  final void Function(String?, PageAction) onTapped;
  final VoidCallback? addRecommendationCallback;

  const StatefulPreferencesList({
    Key? key,
    this.itemHeight = 80,
    required this.items,
    required this.onTapped,
    this.preference,
    this.addRecommendationCallback,
  }) : super(key: key);

  @override
  _StatefulPreferencesListState createState() =>
      _StatefulPreferencesListState();
}

class _StatefulPreferencesListState extends State<StatefulPreferencesList> {
  /// the total items that are recommended by the preference
  late List<PreferenceViewModel> items = const [];

  /// the visible items to display after filtering / searching
  late List<PreferenceViewModel> filteredItems;
  static const typeOptions = [
    "All",
    "Journal",
    "Interest",
    "Audience",
    "Service",
    "News",
    "Other",
    "None",
  ];

  static const recommendationOptions = [
    "All",
    "Both",
    "Recommendations",
    "Recommended By",
  ];

  static const errorOptions = [
    "Clear",
    "Value",
    "Data",
    "Text",
    "Only",
    "No Errors",
  ];

  static final bucket = new PageStorageBucket();
  late final ScrollController controller;
  String? filterType;
  String? searchTerm;

  late String title = '';

  @override
  void initState() {
    super.initState();

    // use keepScrollOffset=0 to fix some pagestoragekey issue?
    controller =
        ScrollController(initialScrollOffset: 0, keepScrollOffset: false);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool containsString(PreferenceViewModel preference, String? search) {
    if (search == null) return true;
    return preference.name.contains(search) || preference.code.contains(search);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // padding: const EdgeInsets.all(32.0),
      padding: EdgeInsets.only(bottom: 60),
      child: Container(
        child: Selector<PreferenceCenterModel, bool>(
          selector: (_, state) => state.isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) {
              return Align(
                alignment: Alignment.center,
                child: Container(
                  width: 800,
                  height: 400,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        backgroundColor: Colors.teal,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 20),
                      Text("Loading Preferences . . .")
                    ],
                  ),
                ),
              );
            } else {
              return SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 60,
                      child: Container(color: Colors.white),
                    ),

                    // appbar actions go in the transparent area
                    const PreferenceCenterAppBar(),

                    // the full width white box behind the actual content
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        SizedBox(
                          height: 120,
                          child: Container(color: Colors.white),
                        ),
                        FractionallySizedBox(
                          widthFactor: 0.8,
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: 90),
                            // child: MyListHeader(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black45,
                                      blurRadius: 5,
                                      offset: Offset(-2.0, 2.0),
                                    )
                                  ],
                                ),
                                child: PreferenceListHeader(
                                  height: 120,
                                  heightFactor: 2,
                                  typeOptions: typeOptions,
                                  errorOptions: errorOptions,
                                  recommendationOptions: recommendationOptions,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Expanded(
                      flex: 9,
                      child: FractionallySizedBox(
                        alignment: Alignment.center,
                        widthFactor: 0.8,
                        heightFactor: 1,
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black45,
                                blurRadius: 5.0,
                                offset: Offset(-2.0, 4.0),
                              ),
                            ],
                          ),
                          // child: CustomScrollView(
                          //   controller: new ScrollController(
                          //     keepScrollOffset: false,
                          //   ),
                          //   slivers: [
                          child: PageStorage(
                            bucket: bucket,
                            child: Selector<PreferenceCenterModel,
                                List<PreferenceViewModel>>(
                              selector: (_, state) => state.filteredResults,
                              builder: (_, results, child) => Container(
                                child: ListView.builder(
                                  itemBuilder: (context, i) {
                                    return ChangeNotifierProvider<
                                        PreferenceViewModel>.value(
                                      value: results[i],
                                      child: PreferenceListTile(
                                        key: ValueKey<PreferenceViewModel>(
                                            results[i]),
                                        height: widget.itemHeight,
                                        expandedHeightFactor: 3.5,
                                        onClick: widget.onTapped,
                                      ),
                                    );
                                  },
                                  itemCount: results.length,
                                ),
                              ),
                              // builder: (context, results, _) => SliverList(
                              //   delegate: SliverChildBuilderDelegate(
                              //     (context, i) {
                              //       return PreferenceListTile(
                              //         key: ValueKey<PreferenceViewModel>(
                              //             results[i]),
                              //         height: widget.itemHeight,
                              //         expandedHeightFactor: 3.5,
                              //         preference: results[i],
                              //         onClick: widget.onTapped,
                              //       );
                              //     },
                              //     findChildIndexCallback: (Key key) {
                              //       final ValueKey<PreferenceViewModel>
                              //           valueKey = key as ValueKey<
                              //               PreferenceViewModel>;
                              //       final PreferenceViewModel value =
                              //           valueKey.value;
                              //       return results.indexOf(value);
                              //     },
                              //     childCount: results.length,
                              // ),
                              // ),
                            ),
                          ),
                          //   ],
                          // ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

/// the transparent area between the white bars
/// contains various actions
class PreferenceCenterAppBar extends StatelessWidget {
  const PreferenceCenterAppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        height: 90,
        width: MediaQuery.of(context).size.width,
        child: FractionallySizedBox(
          widthFactor: 0.8,
          child: Container(
            color: Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                    clipBehavior: Clip.hardEdge,
                    icon: Image.network(
                      'https://pubs.acs.org/pb-assets/images/preference-center/controls.svg',
                      height: 24,
                    ),
                    onPressed: () => Router.navigate(context, () {
                          (Router.of(context).routerDelegate
                                  as PreferencesGridRouterDelegate)
                              .goToPage(
                                  code: null,
                                  action: PageAction.getRecommendations);
                        }),
                    label: Row(
                      children: [
                        Text(' EMAIL',
                            style: Theme.of(context).textTheme.headline1),
                        Text(' PREFERENCE CENTER',
                            style: Theme.of(context)
                                .textTheme
                                .headline1!
                                .copyWith(fontWeight: FontWeight.w400)),
                      ],
                    ),
                    style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 8)))),
                Spacer(),
                TextButton.icon(
                  clipBehavior: Clip.hardEdge,
                  label: Icon(
                    Icons.home,
                    size: 22,
                    color: Colors.white,
                  ),
                  icon: SizedBox.shrink(),
                  onPressed: () {},
                  style: appBarButtonStyle,
                ),
                TextButton.icon(
                  clipBehavior: Clip.hardEdge,
                  label: Icon(
                    Icons.recommend,
                    size: 22,
                    color: Colors.white,
                  ),
                  icon: SizedBox.shrink(),
                  onPressed: () => uploadRecommendations(
                      Provider.of<PreferenceCenterModel>(context,
                          listen: false)),
                  style: appBarButtonStyle,
                ),
                TextButton.icon(
                  clipBehavior: Clip.hardEdge,
                  label: Icon(
                    Icons.room_preferences,
                    size: 22,
                    color: Colors.white,
                  ),
                  icon: SizedBox.shrink(),
                  onPressed: () => uploadPreferences(
                      Provider.of<PreferenceCenterModel>(context,
                          listen: false)),
                  style: appBarButtonStyle,
                ),
                Tooltip(
                  padding: const EdgeInsets.all(2.0),
                  message: "Export Files",
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                  child: TextButton.icon(
                    clipBehavior: Clip.hardEdge,
                    label: Icon(
                      Icons.download,
                      size: 22,
                      color: Colors.white,
                    ),
                    icon: SizedBox.shrink(),
                    onPressed: () => exportRecommendations(
                        Provider.of<PreferenceCenterModel>(context,
                                listen: false)
                            .recommendations),
                    style: appBarButtonStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
