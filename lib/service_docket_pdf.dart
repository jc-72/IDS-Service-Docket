import 'dart:typed_data';
import 'dart:ui' show Offset;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'main.dart' show ProjectRecord;

/// Generates a one-page A4 portrait Service Docket PDF.
/// Uses ProjectRecord for all dynamic information.
Future<Uint8List> buildServiceDocketPdf(
  ProjectRecord record, {
  String docketNo = '',
}) async {
  final pdf = pw.Document();

  // ORIGINAL MAINTENANCE CHECKLIST DATA
  const ledKey = 'Every Two Months LED Display / LCD Panel & Equipment';
  const controlKey = 'Control System';
  const electricalKey = 'Electrical System';
  const aircondKey = 'Aircond System';
  const housekeepingKey = 'Housekeeping';

  final checklistSections = <_ChecklistSection>[
    _ChecklistSection('Every Two Months', ledKey, [
        'Inspect LED Display / LCD panels for faulty displays and rectify. Replace faulty parts if necessary.',
        'Inspect display brightness and contrast are within the setting range.',
        'Check cooling fan / ventilation fan blades function properly. Replace if necessary.',
        'Check light sensor functionality. Clean the sensor surface if necessary.',
        'Check DC power supply voltage level for health and function. Record 2 random voltage readings.',
        'Check temperature and humidity inside the screen. Record the highest and lowest readings.',
        'To Replace and rotate spare modules for light-up ageing purposes.',
    ]),
    _ChecklistSection('Control System', controlKey, [
        'Check that the CCTV / webcam is functioning properly.',
        'Inspect that the sending card / receiving card is functioning properly.',
        'Check the system timer auto ON / OFF function against the preset timing.',
        'Check internet connectivity, reboot the modem, and ensure the connection works.',
        'Reboot the control system and back up system data files.',
    ]),
    _ChecklistSection('Electrical System', electricalKey, [
      'Inspect and check lighting fixture function properly. Replace if necessary.',
    ]),
    _ChecklistSection('Aircond System', aircondKey, [
      'Check air-conditioner units function properly and record temperature.',
    ]),
    _ChecklistSection('Housekeeping', housekeepingKey, [
      'Perform general cleaning and dust off control room equipment.',
    ]),
  ];

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(25, 22, 25, 22),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // HEADER
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'IDS BEYOND MEDIA SDN BHD',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'SERVICE DOCKET',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 7),

            // JOB SITE AND TIME
            pw.Row(
              children: [
                smallLabel('Job Site'),
                pw.SizedBox(width: 4),
                pw.Expanded(flex: 4, child: inputBox(record.jobSite)),
                pw.SizedBox(width: 8),
                smallLabel('Time In'),
                pw.SizedBox(width: 4),
                pw.Expanded(flex: 2, child: inputBox(record.timeIn)),
                pw.SizedBox(width: 8),
                smallLabel('Time Out'),
                pw.SizedBox(width: 4),
                pw.Expanded(flex: 2, child: inputBox(record.timeOut)),
              ],
            ),

            pw.SizedBox(height: 5),

            // TYPE OF SERVICE
            pw.Row(
              children: [
                smallLabel('Type Of Service'),
                pw.SizedBox(width: 5),

                pw.Expanded(
                  flex: 6,
                  child: pw.Row(
                    children: [
                      serviceOption(
                        'Scheduled Maintenance',
                        _serviceTypeMatches(
                          record.serviceType,
                          'Scheduled Maintenance',
                        ),
                      ),
                      serviceOption(
                        'Technical Support',
                        _serviceTypeMatches(
                          record.serviceType,
                          'Technical Support',
                        ),
                      ),
                      serviceOption(
                        'Emergency Support',
                        _serviceTypeMatches(
                          record.serviceType,
                          'Emergency Support',
                        ),
                      ),
                      serviceOption(
                        'Others',
                        _serviceTypeMatches(record.serviceType, 'Others'),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(width: 8),

                smallLabel('Location'),
                pw.SizedBox(width: 4),

                pw.Expanded(flex: 3, child: inputBox(record.location)),
              ],
            ),

            pw.SizedBox(height: 7),

            // MAIN THREE-COLUMN LAYOUT
            pw.Expanded(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // LEFT: MAINTENANCE SCOPE
                  pw.Expanded(
                    flex: 43,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        sectionTitle('Maintenance Scope'),

                        ...checklistSections.map((section) {
                          return maintenanceSection(
                            section,
                            record.maintenanceChecklist[section.recordKey] ??
                                const [],
                          );
                        }),
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 5),

                  // MIDDLE: TEAM / CUSTOMER / VOLTAGE
                  pw.Expanded(
                    flex: 20,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        // TECHNICAL TEAM
                        fixedSection(
                          'Technical Team',
                          pw.Column(
                            children: [
                              labelRow('Technician Name:'),
                              ...List.generate(
                                7,
                                (i) => numberedRow(i + 1, record.technicalTeam),
                              ),
                            ],
                          ),
                          190,
                        ),

                        pw.SizedBox(height: 4),

                        // IT TEAM
                        fixedSection(
                          'IT Team',
                          pw.Column(
                            children: [
                              labelRow('IT Support Name:'),
                              ...List.generate(
                                4,
                                (i) => numberedRow(i + 1, record.itTeam),
                              ),
                            ],
                          ),
                          130,
                        ),

                        pw.SizedBox(height: 4),

                        // CUSTOMER
                        fixedSection(
                          'Customer',
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              // CUSTOMER NAME
                              labelRow('Customer Name:'),
                              pw.Container(
                                height: 35,
                                width: double.infinity,
                                alignment: pw.Alignment.centerLeft,
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 2,
                                ),
                                child: pw.Text(
                                  record.clientName.trim().isEmpty
                                      ? ' '
                                      : record.clientName.trim(),
                                  maxLines: 2,
                                  style: const pw.TextStyle(fontSize: 7),
                                ),
                              ),

                              // CUSTOMER SIGNATURE
                              labelRow('Customer Signature:'),
                              pw.Container(
                                height: 95,
                                width: double.infinity,
                                alignment: pw.Alignment.center,
                                padding: const pw.EdgeInsets.all(2),
                                child: _signatureWidget(record.signaturePoints),
                              ),

                              // DATE
                              labelRow('Date:'),
                              pw.Container(
                                height: 25,
                                width: double.infinity,
                                alignment: pw.Alignment.centerLeft,
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                child: pw.Text(
                                  _date(
                                    record.signatureDate ?? record.serviceDate,
                                  ),
                                  style: const pw.TextStyle(fontSize: 6),
                                ),
                              ),
                            ],
                          ),
                          195,
                        ),

                        pw.SizedBox(height: 4),

                        pw.SizedBox(height: 4),

                        // VOLTAGE
                        fixedSection(
                          'Screen Power Supply Voltage',
                          pw.Column(
                            children: [
                              voltageRow('1st reading', record.voltageReading1),
                              voltageRow('2nd reading', record.voltageReading2),
                            ],
                          ),
                          110,
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 5),

                  // RIGHT: COMMENTS
                  pw.Expanded(
                    flex: 37,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        commentSection(
                          'Technical Team\nOther / Comment',
                          record.technicalTeamOtherComment,
                        ),

                        pw.SizedBox(height: 5),

                        commentSection(
                          'IT Team\nOther / Comment',
                          record.itTeamOtherComment,
                        ),

                        pw.SizedBox(height: 5),

                        pw.Container(
                          width: double.infinity,
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Note:\n'
                            '*** All service Docket must complete with Chop & Sign\n'
                            '*** Attach Photo with time & date Stamp during maintenance',
                            style: pw.TextStyle(
                              fontSize: 6,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // FOOTER
            pw.SizedBox(height: 4),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  docketNo,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Revision No: IDS-PMChecklist-Rev02_June26',
                  style: const pw.TextStyle(fontSize: 5.5),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  // Additional maintenance photo pages. The original service docket page
  // above remains unchanged and is always the first page.
  if (record.maintenancePhotos.isNotEmpty) {
    for (var start = 0; start < record.maintenancePhotos.length; start += 4) {
      final end = (start + 4 < record.maintenancePhotos.length)
          ? start + 4
          : record.maintenancePhotos.length;
      final pagePhotos = record.maintenancePhotos.sublist(start, end);

      pw.Widget photoCell(Uint8List bytes, int photoNumber) {
        return pw.Container(
          width: 255,
          height: 330,
          padding: const pw.EdgeInsets.all(7),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey500, width: 0.7),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                'Photo $photoNumber',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Expanded(
                child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
              ),
            ],
          ),
        );
      }

      final rows = <pw.Widget>[];
      for (var i = 0; i < pagePhotos.length; i += 2) {
        final left = photoCell(pagePhotos[i], start + i + 1);
        final right = i + 1 < pagePhotos.length
            ? photoCell(pagePhotos[i + 1], start + i + 2)
            : pw.SizedBox(width: 255, height: 330);
        rows.add(
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [left, right],
          ),
        );
        if (i + 2 < pagePhotos.length) rows.add(pw.SizedBox(height: 12));
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(25, 22, 25, 22),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                'MAINTENANCE PHOTOS',
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Docket: ${record.id}    Job Site: ${record.jobSite}',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.SizedBox(height: 15),
              ...rows,
            ],
          ),
        ),
      );
    }
  }

  return pdf.save();
}

// ======================================================
// CHECKLIST MODEL
// ======================================================

class _ChecklistSection {
  final String title;
  final String recordKey;
  final List<String> items;

  const _ChecklistSection(this.title, this.recordKey, this.items);
}

// ======================================================
// SERVICE TYPE MATCHING
// ======================================================

bool _serviceTypeMatches(String selected, String label) {
  final value = selected.toLowerCase();

  if (label == 'Scheduled Maintenance') {
    return value.contains('scheduled');
  }

  if (label == 'Technical Support') {
    return value.contains('technical');
  }

  if (label == 'Emergency Support') {
    return value.contains('emergency');
  }

  return value == 'others' || value.contains('other');
}

// ======================================================
// SMALL LABEL
// ======================================================

pw.Widget smallLabel(String text) {
  return pw.Text(text, style: const pw.TextStyle(fontSize: 6.5));
}

// ======================================================
// INPUT FIELD
// ======================================================

pw.Widget inputBox(String value) {
  return pw.Container(
    height: 19,
    padding: const pw.EdgeInsets.symmetric(horizontal: 3),
    alignment: pw.Alignment.centerLeft,
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.6)),
    child: pw.Text(value, style: const pw.TextStyle(fontSize: 7)),
  );
}

// ======================================================
// SERVICE CHECKBOX
// ======================================================

pw.Widget serviceOption(String title, bool checked) {
  return pw.Expanded(
    child: pw.Row(
      children: [
        pw.Container(
          width: 8,
          height: 8,
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.6)),
          child: checked
              ? pw.Center(
                  child: pw.Text('X', style: const pw.TextStyle(fontSize: 6)),
                )
              : null,
        ),
        pw.SizedBox(width: 3),
        pw.Expanded(
          child: pw.Text(title, style: const pw.TextStyle(fontSize: 5.5)),
        ),
      ],
    ),
  );
}

// ======================================================
// SECTION TITLE
// ======================================================

pw.Widget sectionTitle(String title) {
  return pw.Container(
    width: double.infinity,
    alignment: pw.Alignment.center,
    padding: const pw.EdgeInsets.all(3),
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.7)),
    child: pw.Text(
      title,
      style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
    ),
  );
}

// ======================================================
// MAINTENANCE SECTION
// ======================================================

pw.Widget maintenanceSection(
  _ChecklistSection section,
  List<bool> checkedItems,
) {
  final isLedSection =
      section.recordKey ==
      'Every Two Months LED Display / LCD Panel & Equipment';

  final subtitle = isLedSection ? section.items.first : '';

  final items = isLedSection ? section.items.skip(1).toList() : section.items;

  final heights = isLedSection
      ? [34.0, 30.0, 38.0, 34.0, 40.0, 40.0, 32.0]
      : section.recordKey == 'Control System'
      ? [30.0, 30.0, 40.0, 40.0, 30.0]
      : section.recordKey == 'Electrical System'
      ? [42.0]
      : section.recordKey == 'Aircond System'
      ? [38.0]
      : [38.0];

  final subtitleChecked =
      isLedSection && checkedItems.isNotEmpty && checkedItems[0];

  return pw.Column(
    children: [
      // SECTION HEADER
      pw.Container(
        width: double.infinity,
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.all(3),
        decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.6)),
        child: pw.Column(
          children: [
            pw.Text(
              section.title,
              style: pw.TextStyle(
                fontSize: 6.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            if (subtitle.isNotEmpty)
              pw.Text(
                subtitle,
                style: pw.TextStyle(
                  fontSize: 6,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
          ],
        ),
      ),

      // SUBTITLE CHECKBOX
      // Preserves the original checklist's first LED item.
      if (subtitle.isNotEmpty) maintenanceRow(subtitle, subtitleChecked, 20),

      // MAINTENANCE CHECKLIST ITEMS
      ...List.generate(items.length, (i) {
        final selectedIndex = isLedSection ? i + 1 : i;

        final checked =
            selectedIndex < checkedItems.length && checkedItems[selectedIndex];

        return maintenanceRow(items[i], checked, heights[i]);
      }),
    ],
  );
}

// ======================================================
// MAINTENANCE ROW
// ======================================================

pw.Widget maintenanceRow(String description, bool checked, double height) {
  return pw.Container(
    height: height,
    decoration: pw.BoxDecoration(
      border: pw.Border(
        left: const pw.BorderSide(width: 0.6),
        right: const pw.BorderSide(width: 0.6),
        bottom: const pw.BorderSide(width: 0.6),
      ),
    ),
    child: pw.Row(
      children: [
        // CHECKBOX COLUMN
        pw.Container(
          width: 13,
          height: double.infinity,
          alignment: pw.Alignment.center,
          decoration: const pw.BoxDecoration(
            border: pw.Border(right: pw.BorderSide(width: 0.6)),
          ),
          child: checked
              ? pw.Text(
                  'X',
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                )
              : null,
        ),

        // DESCRIPTION
        pw.Expanded(
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(3),
            child: pw.Text(
              description,
              style: const pw.TextStyle(fontSize: 5.5),
            ),
          ),
        ),
      ],
    ),
  );
}

// ======================================================
// MIDDLE COLUMN SECTION
// ======================================================

pw.Widget fixedSection(String title, pw.Widget content, double height) {
  return pw.Container(
    height: height,
    width: double.infinity,
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.6)),
    child: pw.Column(
      children: [
        pw.Container(
          width: double.infinity,
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.all(4),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 0.6)),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold),
          ),
        ),

        pw.Expanded(child: content),
      ],
    ),
  );
}

// ======================================================
// LABEL ROW
// ======================================================

pw.Widget labelRow(String title) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(3),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
    ),
    child: pw.Text(title, style: const pw.TextStyle(fontSize: 5.5)),
  );
}

// ======================================================
// NUMBERED TEAM ROW
// ======================================================

pw.Widget numberedRow(int number, List<String> names) {
  final name = number <= names.length ? names[number - 1] : '';

  return pw.Expanded(
    child: pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 3),
      alignment: pw.Alignment.centerLeft,
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
      ),
      child: pw.Text(
        '$number. ${name.isEmpty ? '' : name}',
        style: const pw.TextStyle(fontSize: 6),
      ),
    ),
  );
}

// ======================================================
// VOLTAGE ROW
// ======================================================

pw.Widget voltageRow(String title, String value) {
  return pw.Expanded(
    child: pw.Container(
      width: double.infinity,
      alignment: pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.all(4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 6,
              decoration: pw.TextDecoration.underline,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(value, style: const pw.TextStyle(fontSize: 6)),
        ],
      ),
    ),
  );
}

// ======================================================
// RIGHT COLUMN COMMENT SECTION
// ======================================================

pw.Widget commentSection(String title, String content) {
  return pw.Expanded(
    child: pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.6)),
      child: pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(4),
            alignment: pw.Alignment.center,
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: 0.6)),
            ),
            child: pw.Text(
              title,
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 6.5),
            ),
          ),

          pw.Expanded(
            child: pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(4),
              alignment: pw.Alignment.topLeft,
              child: pw.Text(content, style: const pw.TextStyle(fontSize: 6)),
            ),
          ),
        ],
      ),
    ),
  );
}

// ======================================================
// CLIENT SIGNATURE
// ======================================================

pw.Widget _signatureWidget(List<Offset?> points) {
  final svg = _signatureSvg(points);

  if (svg == null) {
    return pw.Text(
      'No signature provided',
      style: const pw.TextStyle(fontSize: 5, color: PdfColors.grey),
    );
  }

  return pw.SvgImage(svg: svg, fit: pw.BoxFit.contain);
}

/// Converts the captured Flutter signature strokes into an SVG image.
/// The points are fitted to the PDF signature box, so different phone
/// screen sizes do not cause the signature to be drawn off the page.
String? _signatureSvg(List<Offset?> points) {
  final strokes = <List<Offset>>[];
  var currentStroke = <Offset>[];

  for (final point in points) {
    if (point == null) {
      if (currentStroke.isNotEmpty) {
        strokes.add(currentStroke);
        currentStroke = <Offset>[];
      }
    } else {
      currentStroke.add(point);
    }
  }

  if (currentStroke.isNotEmpty) {
    strokes.add(currentStroke);
  }

  final allPoints = strokes.expand((stroke) => stroke).toList();
  if (allPoints.isEmpty) return null;

  final minX = allPoints.map((p) => p.dx).reduce((a, b) => a < b ? a : b);
  final maxX = allPoints.map((p) => p.dx).reduce((a, b) => a > b ? a : b);
  final minY = allPoints.map((p) => p.dy).reduce((a, b) => a < b ? a : b);
  final maxY = allPoints.map((p) => p.dy).reduce((a, b) => a > b ? a : b);

  const padding = 4.0;
  final viewWidth = (maxX - minX) + padding * 2;
  final viewHeight = (maxY - minY) + padding * 2;

  final pathData = <String>[];

  for (final stroke in strokes) {
    if (stroke.isEmpty) continue;

    final first = stroke.first;
    pathData.add(
      'M ${(first.dx - minX + padding).toStringAsFixed(2)} '
      '${(first.dy - minY + padding).toStringAsFixed(2)}',
    );

    for (final point in stroke.skip(1)) {
      pathData.add(
        'L ${(point.dx - minX + padding).toStringAsFixed(2)} '
        '${(point.dy - minY + padding).toStringAsFixed(2)}',
      );
    }
  }

  return '''
<svg xmlns="http://www.w3.org/2000/svg"
     width="${viewWidth.toStringAsFixed(2)}"
     height="${viewHeight.toStringAsFixed(2)}"
     viewBox="0 0 ${viewWidth.toStringAsFixed(2)} ${viewHeight.toStringAsFixed(2)}">
  <path d="${pathData.join(' ')}"
        fill="none"
        stroke="#111111"
        stroke-width="2.2"
        stroke-linecap="round"
        stroke-linejoin="round"/>
</svg>
''';
}

// ======================================================
// DATE FORMAT
// ======================================================

String _date(DateTime? date) {
  if (date == null) return '';

  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
