import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
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
  Widget build(BuildContext context) => GestureDetector(
        onTap: () async {
          if (source.url != null) {
            final Uri? uri = Uri.tryParse(source.url ?? '');
            if (uri != null && await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          }
        },
        child: Container(
          padding: REdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: REdgeInsets.only(
            bottom: 4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 1.w,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (source.favicon != null) ...<Widget>[
                Image.network(
                  source.favicon!,
                  width: 24.w,
                  height: 24.h,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) =>
                      const Icon(Icons.link, size: 24),
                ),
                8.horizontalSpace,
              ],
              Expanded(
                child: Text(
                  source.url ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
