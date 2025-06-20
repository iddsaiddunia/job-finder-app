
/// Simulated user type enum
enum UserType { jobFinder, employer }

/// Simulated user object
class FakeUser {
  final String email;
  final UserType type;
  final String? name;
  final String? company;
  FakeUser({required this.email, required this.type, this.name, this.company});
}

/// Simulated Auth Service for easy migration to real API
typedef LoginResult = ({FakeUser? user, String? error});

typedef RegisterResult = ({bool success, String? error});

class FakeAuthService {
  static final FakeAuthService _instance = FakeAuthService._internal();
  factory FakeAuthService() => _instance;
  FakeAuthService._internal();

  // In-memory users: email -> {password, type, ...}
  final Map<String, Map<String, dynamic>> _users = {
    // Demo Job Finder
    'finder@example.com': {
      'password': 'password123',
      'type': UserType.jobFinder,
      'name': 'Jane JobFinder',
      'company': null,
      'profileComplete': false,
    },
    // Demo Employer
    'employer@example.com': {
      'password': 'password123',
      'type': UserType.employer,
      'name': null,
      'company': 'Acme Corp',
      'profileComplete': false,
    },
  };


  // Register a new user
  RegisterResult register({required String email, required String password, required UserType type, String? name, String? company}) {
    if (_users.containsKey(email)) {
      return (success: false, error: 'Email already registered');
    }
    _users[email] = {
      'password': password,
      'type': type,
      'name': name,
      'company': company,
      'profileComplete': false,
    };
    return (success: true, error: null);
  }

  // Check if profile is complete
  bool isProfileComplete(String email) => _users[email]?['profileComplete'] == true;

  // Mark profile as complete
  void markProfileComplete(String email) {
    if (_users.containsKey(email)) {
      _users[email]!['profileComplete'] = true;
    }
  }

  // Login
  LoginResult login(String email, String password) {
    final user = _users[email];
    if (user == null) {
      return (user: null, error: 'User not found');
    }
    if (user['password'] != password) {
      return (user: null, error: 'Incorrect password');
    }
    return (
      user: FakeUser(
        email: email,
        type: user['type'],
        name: user['name'],
        company: user['company'],
      ),
      error: null,
    );
  }

  // For testing/demo: clear all users
  void clear() => _users.clear();

  // Simulate logout
  Future<void> logout() async {
    // In a real app, clear session, tokens, etc.
    await Future.delayed(Duration(milliseconds: 200));
  }
}
