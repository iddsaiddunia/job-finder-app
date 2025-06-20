import 'package:flutter/material.dart';
import 'screens/shared/splash_screen.dart';
import 'screens/shared/login_screen.dart';
import 'screens/shared/register_screen.dart';
import 'screens/job_finder/home_screen.dart';
import 'screens/job_finder/profile_screen.dart';
import 'screens/job_finder/job_listings_screen.dart';
import 'screens/job_finder/job_details_screen.dart';
import 'screens/job_finder/application_status_screen.dart';
import 'screens/job_finder/register_screen.dart';
import 'screens/employer/home_screen.dart';
import 'screens/employer/profile_screen.dart';
import 'screens/employer/post_job_screen.dart';
import 'screens/employer/job_postings_screen.dart';
import 'screens/employer/applicant_list_screen.dart';
import 'screens/employer/applicant_details_screen.dart';
import 'screens/employer/register_screen.dart';

void main() {
  runApp(const JobFinderApp());
}

class JobFinderApp extends StatelessWidget {
  const JobFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Finder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        // Job Finder routes
        '/job_finder/home': (context) => JobFinderHomeScreen(),
        '/job_finder/profile': (context) => const JobFinderProfileScreen(),
        '/job_finder/job_listings': (context) => JobListingsScreen(),
        '/job_finder/job_details': (context) => const JobDetailsScreen(),
        '/job_finder/application_status': (context) => ApplicationStatusScreen(),
        '/job_finder/register': (context) => const JobFinderRegisterScreen(),
        '/job_finder_profile_setup': (context) => const JobFinderProfileScreen(),
        // Employer routes
        '/employer/home': (context) => EmployerHomeScreen(),
        '/employer/profile': (context) => const EmployerProfileScreen(),
        '/employer/post_job': (context) => const PostJobScreen(),
        '/employer/job_postings': (context) => JobPostingsScreen(),
        '/employer/applicant_list': (context) => ApplicantListScreen(),
        '/employer/applicant_details': (context) => ApplicantDetailsScreen(),
        '/employer/register': (context) => const EmployerRegisterScreen(),
        '/employer_profile_setup': (context) => const EmployerProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
