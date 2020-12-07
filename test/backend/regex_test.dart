import 'package:flutter_test/flutter_test.dart';

import 'package:auto_call/services/regex.dart';

///
/// The purpose of these tests is to verify behavior of Regex string patterns
///
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MagicRegex correct isname()', () {
    // Correct Tests
    expect(MagicRegex.isName("Brandon"), true);
    expect(MagicRegex.isName("brandon"), true);
    expect(MagicRegex.isName("Brandon Kunkel"), true);
    expect(MagicRegex.isName("Brandon Michael Kunkel"), true);
    expect(MagicRegex.isName("Brandon Michael-Kunkel Jr."), true);

    // Look for edge cases
    expect(MagicRegex.isName(" Brandon " ), true);
    expect(MagicRegex.isName(" brandon " ), true);
    expect(MagicRegex.isName(" Brandon Kunkel " ), true);
    expect(MagicRegex.isName(" Brandon-Kunkel " ), true);
    expect(MagicRegex.isName(" Brandon-Kunkel Jr. " ), true);
  });

  test('MagicRegex incorrect isname()', () {
    // Not Correct tests
    expect(MagicRegex.isName("1"), false);
  });

  test('MagicRegex correct isnumber()', () {
    // Correct Tests
    expect(MagicRegex.isNumber("4406675647"), true);
    expect(MagicRegex.isNumber("14406675647"), true);
    expect(MagicRegex.isNumber("440-667-5647"), true);
    expect(MagicRegex.isNumber("1-440-667-5647"), true);
    expect(MagicRegex.isNumber("1(440)667-5647"), true);

    // Look for edge cases
    expect(MagicRegex.isNumber(" 4406675647 "), true);
    expect(MagicRegex.isNumber(" 14406675647 "), true);
    expect(MagicRegex.isNumber(" 440-667-5647 "), true);
    expect(MagicRegex.isNumber(" 1-440-667-5647 "), true);
    expect(MagicRegex.isNumber(" 1(440)667-5647 "), true);
  });

  test('MagicRegex incorrect isnumber()', () {
    // Not Correct Tests
    expect(MagicRegex.isNumber("brandon"), false);
    expect(MagicRegex.isNumber(""), false);
    expect(MagicRegex.isNumber("ebay@gmail.com"), false);
  });

  test('MagicRegex isemail()', () {
    // Correct tests
    expect(MagicRegex.isEmail("a@b.com"), true);
    expect(MagicRegex.isEmail("stuff.stuff@yeah.com"), true);
    expect(MagicRegex.isEmail("brandon+food@yum.com"), true);
    expect(MagicRegex.isEmail("brandon-food@yum.com"), true);

    // Weird combinations
    expect(MagicRegex.isEmail("brandon-food+yeah@yum.com"), true);
    expect(MagicRegex.isEmail("brandon_food+more@yum.com"), true);

    // Spaces in front/end
    expect(MagicRegex.isEmail(" a@b.com "), true);
    expect(MagicRegex.isEmail(" stuff.stuff@yeah.com "), true);
    expect(MagicRegex.isEmail(" brandon+food@yum.com "), true);
  });
}
