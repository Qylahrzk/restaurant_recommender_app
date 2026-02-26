import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant_model.dart';

class RestaurantRepository {
  final _supabase = Supabase.instance.client;

  /// Fetch all restaurants (Used by the Recommendation Engine for comparison)
  Future<List<Restaurant>> getAllRestaurants() async {
    try {
      final response = await _supabase
          .from('restaurants')
          .select();
      
      return (response as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch restaurants: $e');
    }
  }

  /// Search for a specific restaurant by name (Used by the Search Bar)
  /// Using .ilike makes it case-insensitive (e.g., 'KBB' matches 'kbb')
  Future<List<Restaurant>> searchRestaurants(String query) async {
    try {
      if (query.isEmpty) return [];

      final response = await _supabase
          .from('restaurants')
          .select()
          .ilike('Name', '%$query%') // Searches for the query anywhere in the name
          .limit(10); // Limit results for better performance
      
      return (response as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }
}