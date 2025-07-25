import 'package:nigerian_igbo/app/ui/components/app_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

/// Url launcher service for the dashboard module.
class UrlLauncher {
  /// Launches the given URL if it is valid.
  static Future<void> launch({String? url}) async {
    if (url != null) {
      final Uri? uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else {
      appSnackbar(
        message: 'Invalid URL',
        snackbarState: SnackbarState.danger,
      );
    }
  }
}
