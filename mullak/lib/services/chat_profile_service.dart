import 'package:firebase_auth/firebase_auth.dart';

import '../dataconnect_generated/generated.dart';

class ChatProfileService {
  ChatProfileService._();

  static final ChatProfileService instance =
      ChatProfileService._();

  final MullakConnector _connector =
      MullakConnector.instance;

  Future<String?> getCurrentUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw StateError('User is not signed in.');
    }

    // Get the signed-in user's profile from Data Connect.
    final result = await _connector
        .getMyProfile()
        .execute();

    final profile = result.data.user;

    if (profile == null) {
      return null;
    }

    // Ensure the returned profile belongs to
    // the currently authenticated Firebase user.
    if (profile.id != currentUser.uid) {
      throw StateError('Profile does not match current user.');
    }

    final fullName = profile.fullName.trim();

    if (fullName.isEmpty) {
      return null;
    }

    return fullName;
  }
}