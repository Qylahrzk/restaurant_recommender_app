import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Your imports
import 'data/restaurant_repository.dart';
import 'logic/cubits/recommendation_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Load the security variables
  await dotenv.load(fileName: ".env");

  // 2. Initialize Supabase using the .env file
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => RestaurantRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => RecommendationCubit(
              context.read<RestaurantRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Terengganu Restaurant Recommender',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const RestaurantListScreen(),
        ),
      ),
    );
  }
}

// Just a temporary screen to test if data loads
class RestaurantListScreen extends StatelessWidget {
  const RestaurantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terengganu Eateries')),
      body: const Center(
        child: Text('Setup Complete! Ready to load restaurants.'),
      ),
    );
  }
}