import 'package:business_card_flutter/models/parsed_card_data.dart';

class CardParserService {
  static final RegExp _emailPattern = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+',
  );
  static final RegExp _phonePattern = RegExp(
    r'(?<!\w)\+?[\d][\d\s()-]{6,}[\d](?!\w)',
  );
  static final RegExp _websitePattern = RegExp(
    r'(?:https?://\S+|www\.\S+|\b\S+\.(?:com|in|org)\b\S*)',
    caseSensitive: false,
  );

  ParsedCardData parse(String rawText) {
    final lines = rawText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    return ParsedCardData(
      company: _lineAt(lines, 0),
      name: _lineAt(lines, 1),
      designation: _lineAt(lines, 2),
      email: _firstMatch(_emailPattern, rawText),
      phone: _firstMatch(_phonePattern, rawText),
      website: _firstMatch(_websitePattern, rawText),
    );
  }

  String? _lineAt(List<String> lines, int index) {
    return index < lines.length ? lines[index] : null;
  }

  String? _firstMatch(RegExp pattern, String value) {
    return pattern.firstMatch(value)?.group(0)?.trim();
  }
}
