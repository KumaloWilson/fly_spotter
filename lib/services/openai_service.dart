import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:specifier/supabase_options.dart';
import '../models/fly_information_model.dart';

class OpenAIService {
  final GetStorage _storage = GetStorage();
  final String _cachePrefix = 'fly_info_cache_';

  // Fetch information about a fly species
  Future<FlyInformation> getFlyInformation(String speciesName, {bool forceRefresh = false}) async {
    try {
      // Check cache first if not forcing refresh
      if (!forceRefresh) {
        final cachedInfo = _getCachedInfo(speciesName);
        if (cachedInfo != null) {
          return cachedInfo;
        }
      }

      // Prepare the prompt
      final prompt = _buildPrompt(speciesName);

      // Make API request
      final response = await http.post(
        Uri.parse(DeepInfraConfigs.url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${DeepInfraConfigs.apiKey}',
        },
        body: jsonEncode({
          'model': 'deepseek-ai/DeepSeek-V3-0324',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful entomologist assistant. Provide concise, factual information about fly species.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        // Parse the response
        final flyInfo = _parseResponse(content, speciesName);

        // Cache the result
        _cacheInfo(speciesName, flyInfo);

        return flyInfo;
      } else {
        throw 'API request failed with status: ${response.statusCode}, message: ${response.body}';
      }
    } catch (e) {
      throw 'Failed to get fly information: $e';
    }
  }

  // Build the prompt for the API
  String _buildPrompt(String speciesName) {
    return '''
    Provide information about the fly species "$speciesName" in JSON format with the following fields:
    - description: A brief description of the fly (2-3 sentences)
    - habitat: Where this fly typically lives
    - diet: What this fly eats
    - lifecycle: Brief description of its lifecycle
    - significance: Any ecological or human significance
    - funFact: An interesting fact about this fly
    
    Keep each field concise (1-2 sentences). Format as valid JSON.
    ''';
  }

  // Parse the API response
  FlyInformation _parseResponse(String response, String speciesName) {
    try {
      // Try to extract JSON from the response
      final jsonRegExp = RegExp(r'{[\s\S]*}');
      final match = jsonRegExp.firstMatch(response);

      if (match != null) {
        final jsonStr = match.group(0);
        final data = jsonDecode(jsonStr!);

        return FlyInformation(
          speciesName: speciesName,
          description: data['description'] ?? 'No description available.',
          habitat: data['habitat'] ?? 'Habitat information not available.',
          diet: data['diet'] ?? 'Diet information not available.',
          lifecycle: data['lifecycle'] ?? 'Lifecycle information not available.',
          significance: data['significance'] ?? 'Significance information not available.',
          funFact: data['funFact'] ?? 'No fun facts available.',
        );
      } else {
        // Fallback parsing for non-JSON responses
        return _fallbackParsing(response, speciesName);
      }
    } catch (e) {
      print('Error parsing OpenAI response: $e');
      return _fallbackParsing(response, speciesName);
    }
  }

  // Fallback parsing for non-JSON responses
  FlyInformation _fallbackParsing(String response, String speciesName) {
    // Extract information from text response as best as possible
    final lines = response.split('\n');
    String description = '', habitat = '', diet = '', lifecycle = '', significance = '', funFact = '';

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.toLowerCase().contains('description') || description.isEmpty) {
        description = _extractValue(line);
      } else if (line.toLowerCase().contains('habitat')) {
        habitat = _extractValue(line);
      } else if (line.toLowerCase().contains('diet')) {
        diet = _extractValue(line);
      } else if (line.toLowerCase().contains('lifecycle')) {
        lifecycle = _extractValue(line);
      } else if (line.toLowerCase().contains('significance')) {
        significance = _extractValue(line);
      } else if (line.toLowerCase().contains('fun fact') || line.toLowerCase().contains('funfact')) {
        funFact = _extractValue(line);
      }
    }

    return FlyInformation(
      speciesName: speciesName,
      description: description.isNotEmpty ? description : response.substring(0, response.length > 100 ? 100 : response.length),
      habitat: habitat,
      diet: diet,
      lifecycle: lifecycle,
      significance: significance,
      funFact: funFact,
    );
  }

  // Helper to extract value from a line
  String _extractValue(String line) {
    final parts = line.split(':');
    if (parts.length > 1) {
      return parts.sublist(1).join(':').trim();
    }
    return line;
  }

  // Cache the fly information
  void _cacheInfo(String speciesName, FlyInformation info) {
    try {
      final key = _getCacheKey(speciesName);
      _storage.write(key, info.toJson());
    } catch (e) {
      print('Error caching fly information: $e');
    }
  }

  // Get cached fly information
  FlyInformation? _getCachedInfo(String speciesName) {
    try {
      final key = _getCacheKey(speciesName);
      final data = _storage.read(key);

      if (data != null) {
        return FlyInformation.fromJson(data);
      }
    } catch (e) {
      print('Error retrieving cached fly information: $e');
    }

    return null;
  }

  // Generate cache key for a species
  String _getCacheKey(String speciesName) {
    return _cachePrefix + speciesName.toLowerCase().replaceAll(' ', '_');
  }
}
