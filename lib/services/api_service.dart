import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pack.dart';

class ApiService {
  static const String _truthUrl = 'https://api.truthordarebot.xyz/api/truth';
  static const String _dareUrl = 'https://api.truthordarebot.xyz/api/dare';

  /// Fetch a single truth prompt from the API
  static Future<GameCardPrompt?> fetchTruth({bool is18Plus = false}) async {
    try {
      final url = is18Plus ? '$_truthUrl?rating=r' : '$_truthUrl?rating=pg13';
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GameCardPrompt(
          id: 'api_truth_${DateTime.now().millisecondsSinceEpoch}',
          text: data['question'] ?? data['text'] ?? 'Tell us a secret!',
          type: 'truth',
        );
      }
    } catch (e) {
      // Silently fail, we have fallback prompts
    }
    return null;
  }

  /// Fetch a single dare prompt from the API
  static Future<GameCardPrompt?> fetchDare({bool is18Plus = false}) async {
    try {
      final url = is18Plus ? '$_dareUrl?rating=r' : '$_dareUrl?rating=pg13';
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GameCardPrompt(
          id: 'api_dare_${DateTime.now().millisecondsSinceEpoch}',
          text: data['question'] ?? data['dare'] ?? data['text'] ?? 'Do something wild!',
          type: 'dare',
        );
      }
    } catch (e) {
      // Silently fail, we have fallback prompts
    }
    return null;
  }

  /// Fetch a batch of truths for pre-loading
  static Future<List<GameCardPrompt>> fetchTruths(int count, {bool is18Plus = false}) async {
    final results = await Future.wait(
      List.generate(count, (_) => fetchTruth(is18Plus: is18Plus)),
    );
    return results.whereType<GameCardPrompt>().toList();
  }

  /// Fetch a batch of dares for pre-loading
  static Future<List<GameCardPrompt>> fetchDares(int count, {bool is18Plus = false}) async {
    final results = await Future.wait(
      List.generate(count, (_) => fetchDare(is18Plus: is18Plus)),
    );
    return results.whereType<GameCardPrompt>().toList();
  }

  /// Fetch Would You Rather
  static Future<GameCardPrompt?> fetchWouldYouRather() async {
    try {
      final response = await http.get(Uri.parse('https://api.truthordarebot.xyz/api/wyr')).timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GameCardPrompt(
          id: data['id'] ?? 'api_wyr_${DateTime.now().millisecondsSinceEpoch}',
          text: data['question'] ?? 'Would you rather...?',
          type: 'wyr',
        );
      }
    } catch (e) {
      // Silently fail
    }
    return null;
  }

  /// Fetch Never Have I Ever
  static Future<GameCardPrompt?> fetchNeverHaveIEver() async {
    try {
      final response = await http.get(Uri.parse('https://api.truthordarebot.xyz/api/nhie')).timeout(
        const Duration(seconds: 5),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GameCardPrompt(
          id: data['id'] ?? 'api_nhie_${DateTime.now().millisecondsSinceEpoch}',
          text: data['question'] ?? 'Never have I ever...',
          type: 'nhie',
        );
      }
    } catch (e) {
      // Silently fail
    }
    return null;
  }
}
