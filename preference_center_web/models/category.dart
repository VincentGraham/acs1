import 'dart:collection';

/// categories don't have any other information
/// references a category by its code
// typedef Category = Map<String?, String?>;

class Category {
  String? code;
  String? name;

  /// if this should be written to the output file
  bool shouldWrite;

  Category._internal({this.code, this.name, this.shouldWrite = false});

  /// default to writing any categories that are input as [json] back to
  /// the output file
  Category.fromJson(Map<String, dynamic> json)
      : code = json['code'],
        name = json['name'],
        shouldWrite = true;

  factory Category(String? code, String? name) =>
      Category._internal(code: code, name: name, shouldWrite: true);

  /// will return a valid map even if [shouldWrite] is false
  Map<String, dynamic> toJson() => {'code': code ?? '', 'name': name ?? ''};

  operator ==(Object other) {
    if (other is! Category) return false;
    return code == other.code && name == other.name;
  }

  factory Category.empty() => Category._internal();

  /// no name is given
  factory Category.unknown(String code) => Category._internal(code: code);

  @override
  int get hashCode => code.hashCode ^ name.hashCode;

  @override
  String toString() => "$name";
}

/// stores all the categories in the json file
class Categories {
  late HashSet<Category> _categories;

  Categories._internal(this._categories);

  Categories.empty() : _categories = HashSet();

  factory Categories.fromJson(List<Map<String, dynamic>>? json) {
    // if no json is given then categories is empty
    if (json == null) return Categories._internal(HashSet());

    // only allow one category per code
    HashSet<Category> categories = HashSet(
      equals: (c1, c2) => c1.code == c2.code,
      hashCode: (c1) => c1.code.hashCode,
    );
    for (var entry in json) {
      categories.add(Category.fromJson(entry));
    }
    return Categories._internal(categories);
  }

  List<String?> get all => _categories.map((e) => e.code).toList();

  /// write back into json format
  List<Map<String, dynamic>> toJson() =>
      _categories.map((e) => e.toJson()).toList();

  /// add or replace the name and code of a category
  void operator []=(String? code, String? name) {
    _categories.remove(code);
    _categories.add(Category(code, name));
  }

  /// name of the first category which matches the code
  Category? operator [](String? code) =>
      _categories.where((e) => e.code == code).first;
}
