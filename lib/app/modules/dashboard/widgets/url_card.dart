import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          padding: REdgeInsets.symmetric(vertical: 4),
          margin: REdgeInsets.only(
            bottom: 8,
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
              10.horizontalSpace,
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
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      4.verticalSpace,
                    ],
                    Text(
                      source.url ?? '-',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
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
