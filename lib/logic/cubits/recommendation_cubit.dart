import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/restaurant_repository.dart';
import '../../models/restaurant_model.dart';

// 1. Haversine Formula for Distance
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
  RecLoaded(this.recommendations);
}

// 3. The Cubit (The Brain)
class RecommendationCubit extends Cubit<RecommendationState> {
  final RestaurantRepository repository;
  RecommendationCubit(this.repository) : super(RecInitial());

  void getHybridRecommendations(Restaurant target) async {
    emit(RecLoading());
    try {
      final all = await repository.getAllRestaurants();
      
      // Calculate scores for every restaurant
      List<Map<String, dynamic>> scoredList = all.where((r) => r.name != target.name).map((res) {
        double wTopic = 0.5;
        double wRating = 0.2;
        double wDist = 0.3;

        // LDA Score
        double sTopic = (res.topicId == target.topicId) ? 1.0 : 0.0;
        
        // Rating Score
        double sRating = res.rating / 5.0;

        // Distance Score (KBF Rule)
        double sDist = 0.0;
        if (target.lat != null && res.lat != null) {
          double km = calculateDistance(target.lat!, target.lon!, res.lat!, res.lon!);
          sDist = max(0, 1 - (km / 10)); // 10km radius
        } else {
          sDist = (res.municipality == target.municipality) ? 1.0 : 0.2;
        }

        double finalScore = (sTopic * wTopic) + (sRating * wRating) + (sDist * wDist);
        
        return {'restaurant': res, 'score': finalScore};
      }).toList();

      // Sort by score
      scoredList.sort((a, b) => b['score'].compareTo(a['score']));

      final topResults = scoredList.take(5).map((e) => e['restaurant'] as Restaurant).toList();
      emit(RecLoaded(topResults));
    } catch (e) {
      print(e);
    }
  }
}