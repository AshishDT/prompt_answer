import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nigerian_igbo/app/modules/dashboard/services/url_launcher.dart';
import '../models/source_link.dart';

/// UrlCard widget to display a card with URL information
class UrlCard extends StatelessWidget {
  /// Constructor for UrlCard
  const UrlCard({
    required this.source,
    super.key,
  });

  /// Url
  final SourceLink source;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {
          UrlLauncher.launch(
            url: source.url,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          margin: const EdgeInsets.only(
            bottom: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (source.favicon != null) ...<Widget>[
                Image.network(
                  source.favicon!,
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) =>
                      const Icon(Icons.link, size: 24),
                ),
                const SizedBox(
                  width: 8,
                )
              ],
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (source.domain != null) ...<Widget>[
                      Text(
                        source.domain!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                    ],
                    Text(
                      source.url ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
