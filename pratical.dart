import 'dart:io';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

Future<void> main() async {
  final pdf = pw.Document();

  // Sample information
  String jobSite = '';
  String timeIn = '';
  String timeOut = '';
  String docketNo = '0861';

  bool scheduleMaintenance = true;
  bool technicalSupport = false;
  bool emergencySupport = true;
  bool others = false;

  List<bool> everyTwoMonthsChecked = [
    true,
    false,
    true,
    false,
    true,
    false,
    false,
  ];

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(25, 22, 25, 22),
      build: (context) {
        return pw.Column(
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
                  'Service Docket',
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
                pw.Expanded(flex: 4, child: inputBox(jobSite)),
                pw.SizedBox(width: 8),
                smallLabel('Time In'),
                pw.SizedBox(width: 4),
                pw.Expanded(flex: 2, child: inputBox(timeIn)),
                pw.SizedBox(width: 8),
                smallLabel('Time Out'),
                pw.SizedBox(width: 4),
                pw.Expanded(flex: 2, child: inputBox(timeOut)),
              ],
            ),

            pw.SizedBox(height: 5),

            // TYPE OF SERVICE
            pw.Row(
              children: [
                smallLabel('Type Of Service'),
                pw.SizedBox(width: 5),
                serviceOption('Schedule Maintenance', scheduleMaintenance),
                serviceOption('Technical Support', technicalSupport),
                serviceOption('Emergency Support', emergencySupport),
                serviceOption('Others', others),
              ],
            ),

            pw.SizedBox(height: 7),

            // MAIN ORIGINAL THREE-COLUMN LAYOUT
            pw.Expanded(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  // LEFT: MAINTENANCE SCOPE
                  pw.Expanded(
                    flex: 43,
                    child: pw.Column(
                      children: [
                        sectionTitle('Maintenance Scope'),

                        maintenanceSection(
                          'Every Two Months',
                          'LED Display / LCD Panel & Equipment',
                          [
                            'Inspect LED Display / LCD panels for any faulty display and rectify.',
                            'Inspect the display brightness / contrast.',
                            'Check cooling fan / ventilation fan blade.',
                            'Check functionality of light sensor.',
                            'Check DC power supply voltage level.',
                            'Check temperature and humidity inside the screen.',
                            'Replace and rotate spare module for testing.',
                          ],
                          [34, 30, 38, 34, 40, 40, 32],
                          checkedItems: everyTwoMonthsChecked,
                        ),

                        maintenanceSection(
                          'Control System',
                          '',
                          [
                            'Check the CCTV / Web cam is function properly.',
                            'Inspect the sending card / receiving card is function properly.',
                            'Inspect and check the system timer’s auto ON / OFF function is working properly according to the preset timing.',
                            'Check the internet connectivity is working properly, reboot modem and ensure the internet connection.',
                            'Reboot control system & backup system data file.',
                          ],
                          [30, 30, 40, 40, 30],
                        ),

                        maintenanceSection(
                          'Electrical System',
                          '',
                          [
                            'Inspect and check lighting fixture is function properly. Replace if necessary.',
                          ],
                          [42],
                        ),

                        maintenanceSection(
                          'Aircond System',
                          '',
                          [
                            'Check the air-conditioner units function properly, records the temperature.',
                          ],
                          [38],
                        ),

                        maintenanceSection(
                          'Housekeeping',
                          '',
                          [
                            'To perform general cleaning and dust off control room by vacuum.',
                          ],
                          [38],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 5),

                  // MIDDLE: TEAM / CUSTOMER / VOLTAGE
                  pw.Expanded(
                    flex: 20,
                    child: pw.Column(
                      children: [
                        fixedSection(
                          'Technical Team',
                          pw.Column(
                            children: [
                              labelRow('Technician Name:'),
                              ...List.generate(7, (i) => numberedRow(i + 1)),
                            ],
                          ),
                          190,
                        ),

                        pw.SizedBox(height: 4),

                        fixedSection(
                          'IT Team',
                          pw.Column(
                            children: [
                              labelRow('IT Support Name:'),
                              ...List.generate(4, (i) => numberedRow(i + 1)),
                            ],
                          ),
                          130,
                        ),

                        pw.SizedBox(height: 4),

                        fixedSection(
                          'Customer',
                          pw.Column(
                            children: [
                              labelRow('Company & Chop'),
                              pw.Container(height: 90),
                              labelRow('Customer Name:'),
                              pw.Container(height: 38),
                              labelRow('Date:'),
                              pw.Container(height: 25),
                            ],
                          ),
                          195,
                        ),

                        pw.SizedBox(height: 4),

                        fixedSection(
                          'Screen Power Supply Voltage',
                          pw.Column(
                            children: [
                              voltageRow('1st reading'),
                              voltageRow('2nd reading'),
                            ],
                          ),
                          110,
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 5),

                  // RIGHT: COMMENT BOXES
                  pw.Expanded(
                    flex: 37,
                    child: pw.Column(
                      children: [
                        commentSection('Technical Team\nOther / Comment', 1),
                        pw.SizedBox(height: 5),
                        commentSection('IT Team\nOther / Comment', 1),
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

  final bytes = await pdf.save();
  final file = File('service_docket.pdf');
  await file.writeAsBytes(bytes);

  print('PDF saved to: ${file.absolute.path}');
}

// SMALL LABEL
pw.Widget smallLabel(String text) {
  return pw.Text(text, style: const pw.TextStyle(fontSize: 6.5));
}

// INPUT FIELD
pw.Widget inputBox(String value) {
  return pw.Container(
    height: 19,
    padding: const pw.EdgeInsets.symmetric(horizontal: 3),
    alignment: pw.Alignment.centerLeft,
    decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.6)),
    child: pw.Text(value, style: const pw.TextStyle(fontSize: 7)),
  );
}

// SERVICE CHECKBOX
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

// SECTION TITLE
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

// MAINTENANCE SECTION
pw.Widget maintenanceSection(
  String title,
  String subtitle,
  List<String> items,
  List<double> heights, {
  List<bool>? checkedItems,
}) {
  return pw.Column(
    children: [
      pw.Container(
        width: double.infinity,
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.all(3),
        decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.6)),
        child: pw.Column(
          children: [
            pw.Text(
              title,
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

      ...List.generate(items.length, (i) {
        final bool isChecked =
            checkedItems != null && i < checkedItems.length && checkedItems[i];

        return pw.Container(
          height: heights[i],
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
                child: isChecked
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
                    items[i],
                    style: const pw.TextStyle(fontSize: 5.5),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    ],
  );
}

// MIDDLE COLUMN SECTION
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

pw.Widget numberedRow(int number) {
  return pw.Expanded(
    child: pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 3),
      alignment: pw.Alignment.centerLeft,
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
      ),
      child: pw.Text('$number.', style: const pw.TextStyle(fontSize: 6)),
    ),
  );
}

pw.Widget voltageRow(String title) {
  return pw.Expanded(
    child: pw.Container(
      width: double.infinity,
      alignment: pw.Alignment.topCenter,
      padding: const pw.EdgeInsets.all(4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 0.5)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 6,
          decoration: pw.TextDecoration.underline,
        ),
      ),
    ),
  );
}

// RIGHT COLUMN COMMENT SECTION
pw.Widget commentSection(String title, int flex) {
  return pw.Expanded(
    flex: flex,
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
          pw.Expanded(child: pw.Container()),
        ],
      ),
    ),
  );
}
