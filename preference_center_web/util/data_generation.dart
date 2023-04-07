import 'dart:convert';
import 'dart:io';
import 'dart:math';

final Random random = Random();
const types = [
  'journal',
  'news',
  'service',
  'audience',
  'curated_journal',
  'interest'
];

List<String> categories = List.generate(
    3,
    (i) =>
        words[random.nextInt(words.length)] +
        ' ' +
        words[random.nextInt(words.length)]);

String randomCategory() {
  return categories[random.nextInt(categories.length)];
}

List<String> codes = [];

Map<String, dynamic> createPrefrence() {
  String? name;
  String? logo;
  String? text;
  List<String>? images;
  List<String>? categories;
  String code = String.fromCharCodes(List.generate(6, (i) {
    List<int> charCodePossibilities = [
      random.nextInt(27) + 65,
      random.nextInt(27) + 97,
      random.nextInt(10) + 48
    ];
    return charCodePossibilities[random.nextInt(3)];
  }));
  String type = types[random.nextInt(types.length)];
  switch (type) {
    case 'journal':
      logo = 'https://source.unsplash.com/random';
      name = randomPhrase(random.nextInt(4) + 3);
      images = List.generate(4, (i) => 'https://source.unsplash.com/random/$i');
      categories =
          List.generate(random.nextInt(2) + 1, (i) => randomCategory());
      break;
    case 'audience':
      name = randomPhrase(random.nextInt(3) + 2);
      categories =
          List.generate(random.nextInt(2) + 1, (i) => randomCategory());
      break;
    case 'interest':
      name = randomPhrase(random.nextInt(4) + 3);
      logo = 'https://source.unsplash.com/random';
      images = List.generate(4, (i) => 'https://source.unsplash.com/random/$i');
      categories =
          List.generate(random.nextInt(2) + 1, (i) => randomCategory());
      break;
    default:
      name = randomPhrase(random.nextInt(4) + 3);
      break;
  }

  codes.add(code);

  return {
    'code': code,
    'name': name,
    'type': type,
    'logo': logo,
    'images': images,
    'categories': categories,
    'text': text,
  };
}

Map<String, dynamic> createRecommendationEntry(String code) {
  return {
    'code': code,
    'recommendations':
        List.generate(random.nextInt(codes.length), (i) => codes[i]).join(',')
  };
}

List<String> words = File(
        'https-::gist.githubusercontent.com:deekayen:4148741:raw:98d35708fa344717d8eee15d11987de6c8e26d7d:1-1000.txt')
    .readAsStringSync()
    .split('\n');

String randomPhrase(int length) {
  var previous = "";
  List<String> indices = List.generate(length, (i) {
    var idx = Random.secure().nextInt(words.length - 1);
    // dont allow too many short words
    while (previous.length < 3 && words[idx].length < 3) {
      idx = Random.secure().nextInt(words.length - 1);
    }
    // or too many long words
    while (previous.length > 7 && words[idx].length > 7) {
      idx = Random.secure().nextInt(words.length - 1);
    }
    previous = words[idx];
    // capitalize the first word and other long words
    if (i == 1 || previous.length > 5) {
      previous =
          previous[0].toUpperCase() + previous.substring(1, previous.length);
    }
    return previous;
  });

  return indices.join(' ');
}

main(List<String> args) {
  print(jsonEncode(List.generate(10, (i) => createPrefrence())));
  print('   ');
  print('   ');
  print('   ');
  print('   ');
  print(jsonEncode(
      List.generate(10, (i) => createRecommendationEntry(codes[i]))));
}
