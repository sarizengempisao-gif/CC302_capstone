import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/index.dart';

/// Thrown by a [TipsRepository] when tips cannot be loaded. Carries a
/// human-readable message that the UI can show directly to the user.
class TipException implements Exception {
  final String message;
  const TipException(this.message);
  @override
  String toString() => 'TipException: $message';
}

/// Contract used by the Tips screen so the data source can be swapped in
/// tests (a fake repository replaces the real network call).
abstract class TipsRepository {
  /// Fresh fetch from the live API. Throws [TipException] on any failure.
  Future<List<Tip>> fetchTips();

  /// Offline fallback: cached tips if present, otherwise the seeded samples.
  Future<List<Tip>> fallbackTips();

  const TipsRepository();
}

/// Fetches ride tips/quotes from a free, no-key public API and caches the
/// result so the app still shows content when the device is offline.
///
/// API: https://api.quotable.io/quotes?limit=10  (returns a list of quotes)
class TipService implements TipsRepository {
  TipService._();
  static final TipService instance = TipService._();

  static const _endpoint = 'https://api.quotable.io/quotes?limit=10';
  static const _cacheKey = 'cached_tips';
  static const _timeout = Duration(seconds: 12);

  /// Sample tips shown when the API and the cache are both unavailable.
  static const seeded = <Tip>[
    Tip(id: 'seed-1', content: 'Confirm your pickup is visible from the road before booking.', author: 'TaxiGo Tips'),
    Tip(id: 'seed-2', content: 'Keep exact change ready for faster, smoother service.', author: 'TaxiGo Tips'),
    Tip(id: 'seed-3', content: 'Peak hours mean higher demand — book ahead when you can.', author: 'TaxiGo Tips'),
    Tip(id: 'seed-4', content: 'Rate your driver after the ride to help other passengers.', author: 'TaxiGo Tips'),
    Tip(id: 'seed-5', content: 'Travelling with a child seat? Add it when you book.', author: 'TaxiGo Tips'),
  ];

  @override
  Future<List<Tip>> fetchTips() async {
    final client = http.Client();
    try {
      final response = await client.get(Uri.parse(_endpoint)).timeout(_timeout);
      if (response.statusCode != 200) {
        throw TipException('Server returned ${response.statusCode}.');
      }
      final parsed = _parseTips(jsonDecode(response.body) as dynamic);
      if (parsed.isEmpty) throw const TipException('No tips returned by the server.');
      await cacheTips(parsed);
      return parsed;
    } on TimeoutException {
      throw const TipException('The request timed out. Check your connection.');
    } on FormatException {
      throw const TipException('Could not read the tips response.');
    } on TipException {
      rethrow;
    } catch (error) {
      throw TipException('Could not load tips: $error');
    } finally {
      client.close();
    }
  }

  /// Defensive parser that supports both a `[{...results}]` list response and
  /// a single `{content, author}` quote, so the app keeps working if the API
  /// shape changes slightly.
  List<Tip> _parseTips(dynamic data) {
    final tips = <Tip>[];
    if (data is Map<String, dynamic> && data['results'] is List) {
      for (final item in data['results'] as List) {
        if (item is Map<String, dynamic>) tips.add(Tip.fromJson(item));
      }
    } else if (data is Map<String, dynamic> && data['content'] != null) {
      tips.add(Tip.fromJson(data));
    }
    return tips;
  }

  /// Cache a list of tips to [SharedPreferences] as encoded JSON.
  Future<void> cacheTips(List<Tip> tips) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(tips.map((t) => t.toJson()).toList()));
  }

  @override
  Future<List<Tip>> fallbackTips() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        final cached = list.map((e) => Tip.fromJson(Map<String, dynamic>.from(e))).toList();
        if (cached.isNotEmpty) return cached;
      } catch (_) {
        // ignore: continue
      }
    }
    final copy = List<Tip>.of(seeded)..shuffle(Random());
    return copy;
  }
}
