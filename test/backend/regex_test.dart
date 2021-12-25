import 'package:flutter_test/flutter_test.dart';

import 'package:auto_call/classes/regex.dart';

///
/// The purpose of these tests is to verify behavior of Regex string patterns
///
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MagicRegex isname()', () {
    test('Upper case name', () => expect(MagicRegex.isName("Brandon"), true));
    test('Lower case name', () => expect(MagicRegex.isName("brandon"), true));
    test('First and last name', () => expect(MagicRegex.isName("Brandon Kunkel"), true));
    test('Full name with middle name', () => expect(MagicRegex.isName("Brandon Michael Kunkel"), true));
    test('Full name with middle initial', () => expect(MagicRegex.isName("Brandon M Kunkel"), true));
    test('Full name with middle initial and period', () => expect(MagicRegex.isName("Brandon M. Kunkel"), true));
    test('Full name with dash and modifier', () => expect(MagicRegex.isName("Brandon Michael-Kunkel Jr."), true));

    // Look for edge cases
    test('Upper case name with padding', () => expect(MagicRegex.isName(" Brandon "), true));
    test('Lower case name with padding', () => expect(MagicRegex.isName(" brandon "), true));
    test('Full Name with padding', () => expect(MagicRegex.isName(" Brandon Kunkel "), true));
    test('Full name with dash and padding', () => expect(MagicRegex.isName(" Brandon-Kunkel "), true));
    test('Dash and surname', () => expect(MagicRegex.isName(" Brandon-Kunkel Jr. "), true));
  });

  test('MagicRegex incorrect isname()', () {
    // Not Correct tests
    expect(MagicRegex.isName("1"), false);
  });

  group('MagicRegex correct isnumber()', () {
    // Correct Tests
    test('Ten digit', () => expect(MagicRegex.isNumber("4406675647"), true));
    test('Country code with ten digit', () => expect(MagicRegex.isNumber("14406675647"), true));
    test('Dashed ten digit', () => expect(MagicRegex.isNumber("440-667-5647"), true));
    test('Country code dashed', () => expect(MagicRegex.isNumber("1-440-667-5647"), true));
    test('Parentheses with dashing and country code', () => expect(MagicRegex.isNumber("1(440)667-5647"), true));

    // Look for edge cases
    test('Ten digit with padding', () => expect(MagicRegex.isNumber(" 4406675647 "), true));
    test('Eleven digit with padding', () => expect(MagicRegex.isNumber(" 14406675647 "), true));
    test('Dashed ten digit with padding', () => expect(MagicRegex.isNumber(" 440-667-5647 "), true));
    test('Dashed eleven digit with padding', () => expect(MagicRegex.isNumber(" 1-440-667-5647 "), true));
    test('Parentheses with padding', () => expect(MagicRegex.isNumber(" 1(440)667-5647 "), true));
  });

  test('MagicRegex incorrect isnumber()', () {
    // Not Correct Tests
    expect(MagicRegex.isNumber("brandon"), false);
    expect(MagicRegex.isNumber(""), false);
    expect(MagicRegex.isNumber("ebay@gmail.com"), false);
  });

  group('MagicRegex correct isemail()', () {
    // Correct tests
    test('short', () => expect(MagicRegex.isEmail("a@b.com"), true));
    test('dotted', () => expect(MagicRegex.isEmail("stuff.stuff@yeah.com"), true));
    test('plussed', () => expect(MagicRegex.isEmail("brandon+food@yum.com"), true));
    test('dashed', () => expect(MagicRegex.isEmail("brandon-food@yum.com"), true));

    // Weird combinations
    test('weird combo 1', () => expect(MagicRegex.isEmail("brandon-food+yeah@yum.com"), true));
    test('weird combo 2', () => expect(MagicRegex.isEmail("brandon_food+more@yum.com"), true));

    // Spaces in front/end
    test('small with padding', () => expect(MagicRegex.isEmail(" a@b.com "), true));
    test('dotted with padding', () => expect(MagicRegex.isEmail(" stuff.stuff@yeah.com "), true));
    test('weird with padding', () => expect(MagicRegex.isEmail(" brandon+food@yum.com "), true));
  });
}
