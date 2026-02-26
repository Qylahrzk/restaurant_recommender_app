import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/restaurant_repository.dart';
import '../../models/restaurant_model.dart';

// 1. Haversine Formula for Distance Calculation
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 - c((lat2 - lat1) * p) / 2 + 
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

// 2. States
abstract class RecommendationState {}
class RecInitial extends RecommendationState {}
class RecLoading extends RecommendationState {}

class RecLoaded extends RecommendationState {
  final List<Restaurant> recommendations;
  final Restaurant targetRestaurant; // Added to help the UI show the "Source"
  
  RecLoaded({required this.recommendations, required this.targetRestaurant});
}

class RecError extends RecommendationState {
  final String message;
  RecError(this.message);
}

// 3. The Cubit (The Brain)
class RecommendationCubit extends Cubit<RecommendationState> {
  final RestaurantRepository repository;
  RecommendationCubit(this.repository) : super(RecInitial());

  void getHybridRecommendations(Restaurant target) async {
    emit(RecLoading());
    try {
      // Fetch the master list from Supabase
      final all = await repository.getAllRestaurants();
      
      // Calculate scores for every restaurant using the Hybrid Formula
      List<Map<String, dynamic>> scoredList = all
          .where((r) => r.name != target.name) // Don't recommend the same restaurant
          .map((res) {
        
        // --- HYBRID WEIGHTS ---
        double wTopic = 0.5;  // LDA Weight
        double wRating = 0.2; // Knowledge-Based Weight
        double wDist = 0.3;   // Location Weight

        // A. LDA Score (Vibe Similarity)
        double sTopic = (res.topicId == target.topicId) ? 1.0 : 0.0;
        
        // B. Rating Score (Popularity/Quality)
        double sRating = res.rating / 5.0;

        // C. Distance Score (Knowledge-Based Rule)
        double sDist = 0.0;
        if (target.lat != null && res.lat != null && target.lon != null && res.lon != null) {
          double km = calculateDistance(target.lat!, target.lon!, res.lat!, res.lon!);
          // Normalize distance: 1.0 if at same spot, 0.0 if > 10km away
          sDist = max(0, 1 - (km / 10)); 
        } else {
          // Fallback if coordinates are missing: use Municipality
          sDist = (res.municipality == target.municipality) ? 0.8 : 0.0;
        }

        // --- FINAL HYBRID CALCULATION ---
        double finalScore = (sTopic * wTopic) + (sRating * wRating) + (sDist * wDist);
        
        return {'restaurant': res, 'score': finalScore};
      }).toList();

      // Sort: Highest score first
      scoredList.sort((a, b) => b['score'].compareTo(a['score']));

      // Take Top 5 recommendations
      final topResults = scoredList
          .take(5)
          .map((e) => e['restaurant'] as Restaurant)
          .toList();

      emit(RecLoaded(recommendations: topResults, targetRestaurant: target));
    } catch (e) {
      emit(RecError("Failed to calculate recommendations: $e"));
    }
  }
}