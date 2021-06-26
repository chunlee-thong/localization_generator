import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class LocalizationGenerator {
  static String? oneLanguageName;

  final String excelFilePathOrGoogleSheetId;
  final String saveJsonPath;
  final String saveLocaleKeyClassPath;

  LocalizationGenerator({
    required this.excelFilePathOrGoogleSheetId,
    required this.saveJsonPath,
    required this.saveLocaleKeyClassPath,
  });

  Future<void> generate() async {
    String path = "";
    if (isExcelPath(excelFilePathOrGoogleSheetId)) {
      path = excelFilePathOrGoogleSheetId;
    } else {
      path = await getDataFromGoogleSheet(excelFilePathOrGoogleSheetId);
    }
    print(path);
    final bytes = File(path).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    final sheetName = "Translation";
    final sheet = excel.tables[sheetName];
    if (sheet == null) throw "Can't find a Translation sheet";

    await _generateJSONFile(sheet);
    await _generateDartClass();
  }

  bool isExcelPath(String value) {
    return value.contains("xlsx");
  }

  Future getDataFromGoogleSheet(String googleSheetId) async {
    final headers = {
      'Content-Type': 'text/xlsx; charset=utf-8',
      'Accept': '*/*',
    };
    String link = "https://docs.google.com/spreadsheets/export?format=xlsx&id=$googleSheetId";
    try {
      final response = await http.get(Uri.parse(link), headers: headers);
      Directory supportDir = await getApplicationSupportDirectory();
      final excelFile = File("${supportDir.path}/data.xlsx");
      if (!excelFile.existsSync()) {
        excelFile.createSync(recursive: true);
      }
      await excelFile.writeAsBytes(response.bodyBytes);
      return excelFile.path;
    } catch (e) {
      throw e;
    }
  }

  Future<void> _generateJSONFile(Sheet sheet) async {
    //get language count by column count minus 1 (minus 1 because first column is a key column)
    int languageCount = sheet.maxCols - 1;

    //get key count by row count minus 1 (minus 1 because first row is a title row)
    int keyCount = sheet.maxRows - 1;

    //generate language list
    List<int> languageList = List<int>.generate(languageCount, (i) => i + 1);
    for (int lang in languageList) {
      //SplayTreeMap auto sort it's key
      SplayTreeMap<String, dynamic> data = SplayTreeMap<String, dynamic>();

      List<int> keyList = List<int>.generate(keyCount, (i) => i + 1);
      for (var key_index in keyList) {
        String key = sheet
            .cell(CellIndex.indexByColumnRow(
              columnIndex: 0,
              rowIndex: key_index,
            ))
            .value
            .toString();
        String value = sheet
            .cell(CellIndex.indexByColumnRow(
              columnIndex: lang,
              rowIndex: key_index,
            ))
            .value
            .toString();
        key = key.replaceAll(" ", "-");
        data[key] = value;
      }
      //get language name
      String languageName = sheet
          .cell(CellIndex.indexByColumnRow(
            columnIndex: lang,
            rowIndex: 0,
          ))
          .value
          .toString();

      //Save file language name to access json file and read key for LocaleKeys class
      oneLanguageName = languageName;

      //
      data.keys.toList()..sort();
      String jsonData = json.encode(data);
      File languageFile = await File("$saveJsonPath/$languageName.json").create(recursive: true);
      await languageFile.writeAsString(jsonData);
    }
  }

  Future<void> _generateDartClass() async {
    File jsonFile = File("$saveJsonPath/$oneLanguageName.json");
    String jsonData = await jsonFile.readAsString();
    Map<String, dynamic> mapData = json.decode(jsonData);
    String dartClass = "class LocaleKeys {\n";

    for (var key in mapData.keys.toList()) {
      String keyDataType = key.runtimeType.toString();
      String keyValue = checkKeyConflict(key);
      String keyFieldName = keyValue.replaceAll("-", "_");
      dartClass += "    static const $keyDataType $keyFieldName = " + '"$key";\n';
    }

    dartClass += "}";

    File dartClassFile = await File("$saveLocaleKeyClassPath/locale_keys.dart").create(recursive: true);
    dartClassFile.writeAsString(dartClass);
  }

  String checkKeyConflict(String key) {
    if (DART_KEYWORD_LIST.contains(key)) {
      return "${key}_";
    }
    return key;
  }
}

const List<String> DART_KEYWORD_LIST = [
  "abstract ",
  "else",
  "import",
  "super",
  "as",
  "enum",
  "in",
  "switch",
  "assert",
  "export",
  "interface",
  "sync",
  "async",
  "extends",
  "is",
  "this",
  "await",
  "extension",
  "library",
  "throw",
  "break",
  "external",
  "mixin",
  "true",
  "case",
  "factory",
  "new",
  "try",
  "catch",
  "false",
  "null",
  "typedef",
  "class",
  "final",
  "on",
  "var",
  "const",
  "finally",
  "operator",
  "void",
  "continue",
  "for",
  "part",
  "while",
  "covariant",
  "Function",
  "rethrow",
  "with",
  "default",
  "get",
  "return",
  "yield",
  "deferred",
  "hide",
  "set",
  "do",
  "if",
  "show",
  "dynamic",
  "implements",
  "static"
];
