import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant_model.dart';

class RestaurantRepository {
  final _supabase = Supabase.instance.client;

  // Fetch all restaurants for the recommendation engine
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
}