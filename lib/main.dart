import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/notification_provider.dart';
import 'screens/shared/splash_screen.dart';
import 'screens/shared/login_screen.dart';
import 'screens/shared/register_screen.dart';
import 'screens/job_finder/home_screen.dart';
import 'screens/job_finder/profile_screen.dart';
import 'screens/job_finder/job_listings_screen.dart';
import 'screens/job_finder/job_details_screen.dart' as job_seeker;
import 'screens/job_finder/application_status_screen.dart';
import 'screens/job_finder/register_screen.dart';
import 'screens/employer/home_screen.dart';
import 'screens/employer/profile_screen.dart';
import 'screens/employer/post_job_screen.dart';
import 'screens/employer/job_postings_screen.dart';
import 'screens/employer/applicant_list_screen.dart';
import 'screens/employer/applicant_details_screen.dart';
import 'screens/employer/register_screen.dart';
import 'screens/employer/job_details_screen.dart' as employer;
import 'screens/common/notifications_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const JobFinderApp(),
    ),
  );
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
        '/job_finder/job_details': (context) => const job_seeker.JobDetailsScreen(),
        '/job_finder/application_status': (context) => ApplicationStatusScreen(),
        '/job_finder/register': (context) => const JobFinderRegisterScreen(),
        '/job_finder/notifications': (context) => const NotificationsScreen(),
        // Employer routes
        '/employer/home': (context) => EmployerHomeScreen(),
        '/employer/profile': (context) => const EmployerProfileScreen(),
        '/employer/post_job': (context) => const PostJobScreen(),
        '/employer/job_postings': (context) => JobPostingsScreen(),
        '/employer/job_details': (context) => employer.JobDetailsScreen(jobId: ModalRoute.of(context)!.settings.arguments as int),
        '/employer/job_applicants': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ApplicantListScreen(jobId: args['jobId'] as int);
        },
        '/employer/applicant_list': (context) => ApplicantListScreen(),
        '/employer/applicant_details': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ApplicantDetailsScreen(
            applicantName: args['name'] as String,
            skills: args['skills'] as String,
            education: args['education'],
            rating: args['rating'] as double,
            experience: args['experience'] as List<dynamic>?,
            email: args['email'] as String?,
            phone: args['phone'] as String?,
            status: args['status'] as String?,
            resumeUrl: args['resume_url'] as String?,
            coverLetter: args['cover_letter'] as String?,
            appliedDate: args['applied_at'] as String?,
            profileId: args['profile_id'] as int?,
            applicationId: args['application_id'] as int?,
            jobId: args['jobId'] as int?,
            feedbackCount: args['feedback_count'] as int?,
            feedbacks: args['feedbacks'] as List<dynamic>?,
          );
        },
        '/employer/register': (context) => const EmployerRegisterScreen(),
        '/employer/notifications': (context) => const NotificationsScreen(),
        '/employer_profile_setup': (context) => const EmployerProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
