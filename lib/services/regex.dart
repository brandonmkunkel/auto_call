
// Regex Strings for use anywhere
class MagicRegex {
  // Regexp patterns
  static final String nameStr = r"^(\s)*[A-Za-z]+((\s)?((\'|\-|\.)?([A-Za-z\.])+))*(\s)*$";
  static final String emailStr = r"^(\s)*[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*(\s)*$";
  static final String numberStr = r"(?:(?:\+?([1-9]|[0-9][0-9]|[0-9][0-9][0-9])\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([0-9][1-9]|[0-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?";

  // Create static RegExp objects
  static RegExp nameReg = RegExp(nameStr);
  static RegExp emailReg = RegExp(emailStr);
  static RegExp numberReg = RegExp(numberStr);

  // Functions for using RegExp objects to check the text to see if they match the RegExp patter
  static bool isName(String text) => nameReg.hasMatch(text);
  static bool isEmail(String text) => emailReg.hasMatch(text);
  static bool isNumber(String text) => numberReg.hasMatch(text);
}