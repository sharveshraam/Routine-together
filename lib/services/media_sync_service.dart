import 'package:google_sign_in/google_sign_in.dart';

class MediaSyncService {
  Future<void> syncMediaToDrive(GoogleSignInAccount account) async {
    // Placeholder for Google Drive upload flow.
    // Use googleapis + authenticated HTTP client from GoogleSignInAccount.
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}
