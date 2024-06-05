// Internal configuration file for the application
import 'dart:convert';

final String api = "http://localhost:8080/api";
final String basicAuth = 'Basic ' + base64.encode(utf8.encode('user1:user1Pass'));

String capitalize(String input) {
  return input
      .split(" ")
      .map((str) => str.isNotEmpty
      ? str[0].toUpperCase() + str.substring(1).toLowerCase()
      : str)
      .join(" ");
}

String capitalizeOnlyFirstLetter(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}