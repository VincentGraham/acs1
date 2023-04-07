import 'package:flutter/foundation.dart' hide Category;
import 'package:preference_center_web/models/category.dart';

enum SchemaErrorType { textFormat, missingValue, noCode, newType, missingData }

class SchemaError {
  final SchemaErrorType type;
  final String? field;

  /// extra whitespace or other format errors
  SchemaError.textFormat(this.field) : type = SchemaErrorType.textFormat;

  /// [field] is found in other preferences with the same [type] but
  /// is null for this one
  SchemaError.missingValue(this.field) : type = SchemaErrorType.missingValue;

  /// preferences without a code un-referencable so should error
  SchemaError.noCode()
      : field = 'code',
        type = SchemaErrorType.noCode;

  /// an error if a preference is only found in recommendations.json but
  /// no information is in all_preferences.json
  SchemaError.missingData()
      : field = null,
        type = SchemaErrorType.missingData;
}

/// specify which fields each type should have.
/// it is unlikely that this will be a separate file
/// must define the types manually
class PreferenceModelSchema {
  // list of types and a list of fields that they can have
  Map<String, Set<String>> types = {};

  static PreferenceModelSchema? _schema;

  /// if preferences are already parsed in [Preferences.fromJson] then it
  /// might be best to check the fields there
  /// to avoid looping through the file again
  PreferenceModelSchema.fromJson(List<Map<String, dynamic>> jsonList) {
    // check all entries for their keys and type
    if (this.types.isEmpty) {
      for (var json in jsonList) {
        // new type found
        if (!this.types.containsKey(json['type'])) {
          this.types[json['type']] = Set();
        }
        // check the keys of that type to make sure none are missing
        for (var key in json.keys) {
          this.types[json['type']]!.add(key);
        }
      }
    }
  }

  static PreferenceModelSchema getSchema(List<Map<String, dynamic>> json) {
    if (_schema == null) {
      _schema = PreferenceModelSchema.fromJson(json);
    }
    return _schema!;
  }

  /// [validate] returns null if no error is found
  List<SchemaError> validate(Preference preference) {
    List<SchemaError> errors = [];
    // if (!types.containsKey(preference.type)) errors.add(SchemaError.newType());

    final json = preference.toJson();

    // every preference should have a code even if it does not have a type
    String? code = json['code'] ?? preference.code;
    if (code == null || code.isEmpty) {
      errors.add(SchemaError.missingValue('code'));
    } else if (!identical(code, code.trim())) {
      errors.add(SchemaError.textFormat('code'));
    }

    // check for unknown types / no types provided by the all_preferences file
    if (preference.type == null) {
      errors.add(SchemaError.missingValue('type'));
    }

    /// do not do anymore parsing if the preference isnt known
    if (preference.isUnknown) {
      errors.add(SchemaError.missingData());
      return errors;
    }

    // check the other fields of the preference
    for (var field in types[preference.type] ?? <String>[]) {
      // null value in a required field
      if (json[field] == null) errors.add(SchemaError.missingValue(field));

      // for the String fields, check that there are not leading / trailing
      // spaces - is there a better way to do this??

      if (field != 'images' && field != 'categories') {
        String? value = json[field];
        if (value == null ||
            !identical(value.trim(), value) ||
            value.trim().isEmpty ||
            value.isEmpty) {
          errors.add(SchemaError.textFormat(field));
        }
      }

      // validate List<String> fields
      if (preference.hasImages)
        for (var image in preference.images!) {
          if (image.trim() != image)
            errors.add(SchemaError.textFormat('images'));
        }
    }
    return errors.toList();
  }

  /// compute the errors for every preference in [toValidate]
  Map<Preference, List<SchemaError>> validateAll(List<Preference> toValidate) {
    // initialize to no errors
    var errors = Map<Preference, List<SchemaError>>.fromIterable(toValidate,
        key: (e) => e, value: (_) => []);
    for (Preference preference in toValidate) {
      errors[preference] = validate(preference);
    }
    return errors;
  }
}

/// a preference model with nullable fields
/// internal preference type agnostic
class Preference {
  // every preference has these three fields
  final String? code;
  final String? type;
  final String? name;

  // only some preferences have these
  final List<String>? categories;

  /// null unless categories.json has been loaded
  late final List<Category>? resolvedCategories;
  final String? logo;
  final List<String>? images;
  final String? text;

  // tracking which ones do
  bool hasName = false;
  bool hasType = false;
  bool hasCategories = false;
  bool hasLogo = false;
  bool hasImages = false;
  bool hasText = false;

  ///  should it be written back to the output file
  /// defaults to [true] when the preferences is read from json
  bool? shouldWrite = true;

  /// if the preference has no data
  bool isUnknown = false;

  Preference({
    this.code,
    this.type,
    this.name,
    this.categories,
    this.logo,
    this.images,
    this.text,
    this.shouldWrite,
    this.resolvedCategories,
  }) {
    hasName = name != null;
    hasType = type != null;
    hasLogo = logo != null;
    hasCategories = categories != null;
    hasImages = images != null;
    hasText = text != null;
  }

  /// merge properties provided with this preference's fields
  /// ignores named parameters if [preferenceData] is passed
  Preference copyWith({
    String? code,
    String? name,
    String? type,
    List<String>? categories,
    List<String>? images,
    String? logo,
    String? text,
    Preference? preferenceData,
    bool? shouldWrite,
  }) {
    if (preferenceData == null) {
      return Preference(
          code: code ?? this.code,
          type: type ?? this.type,
          name: name ?? this.name,
          categories: categories ?? this.categories,
          logo: logo ?? this.logo,
          images: images ?? this.images,
          text: text ?? this.text,
          shouldWrite: shouldWrite ?? this.shouldWrite);
    } else {
      return copyWith(
        code: preferenceData.code,
        name: preferenceData.name,
        type: preferenceData.type,
        categories: preferenceData.categories,
        logo: preferenceData.logo,
        images: preferenceData.images,
        text: preferenceData.text,
        shouldWrite: preferenceData.shouldWrite,
        preferenceData: null,
      );
    }
  }

// an empty preference that can be written to a file
  factory Preference.empty() => Preference(
      code: null,
      type: null,
      name: null,
      categories: null,
      logo: null,
      images: null,
      text: null,
      shouldWrite: true);

// creates an unknown preference that will not be written to the output file
  Preference.unknown(String code)
      : code = code,
        categories = null,
        images = null,
        resolvedCategories = null,
        logo = null,
        name = null,
        text = null,
        type = null,
        isUnknown = true,
        shouldWrite = false;

  factory Preference.fromJson(
    Map<String, dynamic> json, {
    Categories? categories,
  }) {
    final List<String>? categoriesFromString = json['category']?.split(',');
    final List<Category>? resolvedCategories = categoriesFromString?.map((e) {
      if (e == '')
        return Category.unknown(e);
      else
        return categories?[e] ?? Category.empty();
    }).toList();

    return Preference(
      code: json['code'],
      name: json['name'],
      type: json['type'],
      categories: categoriesFromString,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      logo: json['logo'],
      text: json['text'],
      shouldWrite: true,
      resolvedCategories: resolvedCategories,
    );
  }

// default to shouldWrite = true
  Map<String, dynamic> toJson() => shouldWrite ?? true
      ? {
          if (code != null) 'code': code,
          if (type != null) 'type': type,
          if (name != null) 'name': name,
          if (categories != null) 'category': categories!.join(','),
          if (logo != null) 'logo': logo,
          if (images != null) 'images': images,
          if (text != null) 'text': text,
        }
      : {};

  @override
  int get hashCode =>
      code.hashCode ^
      name.hashCode ^
      type.hashCode ^
      categories.hashCode ^
      images.hashCode ^
      logo.hashCode ^
      text.hashCode ^
      shouldWrite.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! Preference) return false;
    return code == other.code &&
        name == other.name &&
        type == other.type &&
        listEquals(categories, other.categories) &&
        listEquals(images, other.images) &&
        text == other.text &&
        logo == other.logo &&
        shouldWrite == other.shouldWrite;
  }
}

/// data logic class that stores the preference file information
class Preferences {
  /// the lookup table if only a code is known
  late Map<String, Preference> preferences = Map();
  PreferenceModelSchema? schema;
  Map<Preference, List<SchemaError>> errors = {};

  factory Preferences.fromJson(
    List<Map<String, dynamic>>? jsonList, {
    Categories? categories,
    bool makeSchema = false,
  }) {
    Map<String, Preference> preferences = {};
    PreferenceModelSchema? schema;

    if (jsonList == null) return Preferences.empty();

    if (makeSchema) schema = PreferenceModelSchema.getSchema(jsonList);

    for (final json in jsonList) {
      // do not overwrite existing data for new codes
      // if we want to support json merging then
      // remove this and use 'preferences[code] = Preference'
      preferences.putIfAbsent(json['code'],
          () => Preference.fromJson(json, categories: categories));
    }

    return Preferences._internal(preferences: preferences, schema: schema);
  }

  /// creates a table of all [Preferences] found and computes any errors
  /// which exist when first loaded
  Preferences._internal({this.schema, required this.preferences}) {
    // pre-compute the schema
    if (schema != null) {
      errors = schema!.validateAll(preferences.values.toList());
    }
  }

  /// creates an empty map of [Preference]s
  Preferences.empty() {
    preferences = {};
  }

  /// create the all_preferences.json file
  List<Map<String, dynamic>> toJson() {
    final prefs = preferences.values.toList();
    final json = List<Map<String, dynamic>>.generate(prefs.length, (int i) {
      if ((prefs[i].shouldWrite ?? false) && prefs[i].code != '')
        return prefs[i].toJson();
      else
        return <String, dynamic>{};
    })
      ..removeWhere((element) => element.isEmpty);
    return json;
  }

  /// return the preference or null if it is not found
  Preference? getNullable(String? code) => preferences[code];

  /// return an empty preference if not found
  Preference get(String code) => preferences[code] ?? Preference.unknown(code);

  /// reutrns a list of all the preference codes
  List<String> get codes => preferences.keys.toList();

  /// returns a list of all the stored preferences
  List<Preference> get all => preferences.values.toList();

  /// update some values of the preference or insert a new preference
  /// only pass one of preference or map. preference will take precedence
  /// must provide the entire list of images. does not combine lists
  void set({
    String? code,
    Map<String, dynamic>? json,
    Preference? preference,
    bool overwrite = true,
  }) {
    if (code == null && json == null && preference == null)
      throw ArgumentError.notNull();
    String resolvedCode = code ?? preference?.code ?? json!['code'];
    if (preference != null) {
      if (preferences.containsKey(resolvedCode)) {
        preferences[resolvedCode] = overwrite
            ? preference
            : preference.copyWith(preferenceData: preference);
      } else {
        preferences[resolvedCode] = preference;
      }
    } else if (json != null) {
      if (preferences.containsKey(resolvedCode) && !overwrite) {
        preferences[resolvedCode] = preferences[resolvedCode]!
            .copyWith(preferenceData: Preference.fromJson(json));
      } else {
        preferences[resolvedCode] = Preference.fromJson(json);
      }
    }
    validate(preferences[resolvedCode]!, force: true);
  }

  /// remove a single preference by code or a list
  /// like one returned from a .where method
  /// will  th{ preferences in all parameters
  void remove({
    String? code,
    List<String>? codes,
    List<Preference>? preferences,
  }) {
    if (code != null) {
      this.preferences.remove(code);
    }
    if (codes != null) {
      this.preferences.removeWhere((key, value) => codes.contains(key));
    }
    if (preferences != null) {
      this.preferences.removeWhere((key, value) => preferences.contains(value));
    }
  }

  /// returns a list of preferences of a certain type (type can be null)
  List<Preference> withType(String? type) {
    return this
        .preferences
        .values
        .where((preference) => preference.type == type)
        .toList();
  }

  /// find entries containing the same value
  /// [getAttribute] should resolve to a specific field
  /// such as [preference.code]
  List<Preference> getDuplicates(dynamic Function(Preference) getAttribute) {
    final Set<dynamic> attributes = preferences.values
        .map((preference) => getAttribute(preference))
        .toSet();

    final preferenceModels = preferences.values.toList(growable: false);
    preferenceModels.retainWhere(
        (preference) => attributes.contains(getAttribute(preference)));
    return preferenceModels;
  }

  /// returns all preferences with null in [field]
  /// this means the field will not be written to json
  /// it will not find fields which are empty such as 'images' : [],
  /// only supply one of the two. list take precedence over single field
  List<Preference> getNullValuedPreferences(
      {dynamic Function(Preference)? field,
      List<dynamic> Function(Preference)? fields}) {
    if (fields != null) {
      // include the preference if any of the fields are null
      return preferences.values.where((preference) {
        List<dynamic> _fields = fields(preference);
        _fields.removeWhere((f) => f != null);
        return _fields.isEmpty;
      }).toList();
    } else if (field != null) {
      return preferences.values
          .where((preference) => field(preference) == null)
          .toList();
    }
    // return empty list if no function given
    return [];
  }

  /// will be empty if [schema] is null (no errors are found)
  List<SchemaError> validate(Preference preference, {force = false}) {
    if (force && schema != null) {
      var result = schema!.validate(preference);
      errors[preference] = result;
      return result;
    }
    // check the errors pre-computed map first
    if (errors.containsKey(preference)) {
      return errors[preference]!;
      // check based on the schema and store it in the existing map
    } else if (schema != null) {
      var result = schema!.validate(preference);
      errors[preference] = result;
      return result;
    } else {
      // no schema was found, report no errors
      return [];
    }
  }

  /// pass through where method
  List<Preference> where(bool Function(Preference) test) {
    return preferences.values.where(test).toList();
  }

  bool contains(
      {String? code,
      String? name,
      String? type,
      String? logo,
      String? images}) {
    return false;
  }
}
