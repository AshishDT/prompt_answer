import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nigerian_igbo/app/modules/dashboard/models/source_link.dart';
import '../services/url_launcher.dart';

/// SourceCard widget to display a card with source information
class SourceCard extends StatelessWidget {
  /// Constructor for SourceCard
  const SourceCard({
    required this.source,
    super.key,
  });

  /// Source link information to display in the card
  final SourceLink source;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          UrlLauncher.launch(
            url: source.url,
          );
        },
        child: Container(
          padding: REdgeInsets.all(12),
          margin: REdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12).r,
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Image.network(
                    source.favicon ?? '',
                    width: 24.w,
                    height: 24.h,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) =>
                        const Icon(
                      Icons.link,
                      size: 24,
                    ),
                  ),
                  16.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          source.domain ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          source.url ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (source.title != null && source.title!.isNotEmpty) ...<Widget>[
                8.verticalSpace,
                Text(
                  source.title!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
              if (source.description != null &&
                  source.description!.isNotEmpty) ...[
                8.verticalSpace,
                Text(
                  source.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}
