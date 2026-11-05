import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import 'service_step_header.dart';

import 'package:local_auth/local_auth.dart';
import 'package:printing/printing.dart';

import 'service_docket_pdf.dart';

// ============================================================
// IDS SERVICE DOCKET
// ============================================================

const Color idsNavy = Color(0xFF123D78);
const Color idsBlue = Color(0xFF1761C5);
const Color idsBackground = Color(0xFFF5F8FC);
const Color idsText = Color(0xFF172B4D);
const Color idsMuted = Color(0xFF71829B);
const Color idsBorder = Color(0xFFE4EAF2);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IDSServiceDocketApp());
}

class IDSServiceDocketApp extends StatelessWidget {
  const IDSServiceDocketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IDS Service Docket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: idsBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: idsBlue,
          primary: idsBlue,
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: idsNavy,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: idsBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: idsBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: idsBlue, width: 1.5),
          ),
        ),
      ),
      home: const AuthenticationGate(),
    );
  }
}

// ============================================================
// AUTHENTICATION
// ============================================================

class AuthenticationGate extends StatefulWidget {
  const AuthenticationGate({super.key});

  @override
  State<AuthenticationGate> createState() => _AuthenticationGateState();
}

class _AuthenticationGateState extends State<AuthenticationGate>
    with WidgetsBindingObserver {
  final LocalAuthentication _auth = LocalAuthentication();

  bool _authenticated = false;
  bool _checking = true;
  bool _authInProgress = false;
  bool _appPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authenticate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _appPaused = true;
    if (state == AppLifecycleState.resumed && _appPaused) {
      _appPaused = false;
      if (!_authenticated && mounted) _authenticate();
    }
  }

  Future<void> _authenticate() async {
    if (_authInProgress || !mounted) return;
    _authInProgress = true;
    setState(() => _checking = true);

    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) {
        if (!mounted) return;
        setState(() {
          _authenticated = true;
          _checking = false;
        });
        return;
      }

      final result = await _auth.authenticate(
        localizedReason: 'Authenticate to access IDS Service Docket',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (!mounted) return;
      setState(() {
        _authenticated = result;
        _checking = false;
      });
    } on PlatformException {
      if (!mounted) return;
      setState(() {
        _authenticated = false;
        _checking = false;
      });
    } finally {
      _authInProgress = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_authenticated) return const MainNavigation();

    return Scaffold(
      backgroundColor: idsBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const IDSLogo(size: 86),
              const SizedBox(height: 24),
              const Text(
                'IDS Service Docket',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: idsText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Secure access to your project records',
                textAlign: TextAlign.center,
                style: TextStyle(color: idsMuted),
              ),
              const SizedBox(height: 28),
              if (_checking)
                const CircularProgressIndicator(color: idsBlue)
              else
                ElevatedButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.lock_open_rounded),
                  label: const Text('Unlock App'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: idsBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 15,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DATA MODEL
// ============================================================

class ProjectRecord {
  final String jobSite;
  final String timeIn;
  final String timeOut;
  final String serviceType;

  final String id;
  final String companyName;
  final String location;
  final String locationCoordinates;
  final String ledType;
  final String pixelPitch;
  final String dimensions;
  final String controller;
  final String status;
  final DateTime dateAdded;
  final String notes;

  final DateTime? serviceDate;
  final List<String> technicalTeam;
  final List<String> itTeam;
  final String maintenancePerformed;
  final String partsReplaced;
  final String serviceOutcome;
  final Map<String, List<bool>> maintenanceChecklist;
  final String voltageReading1;
  final String voltageReading2;
  final String observations;
  final String outstandingIssues;
  final String recommendations;
  final String technicalTeamOtherComment;
  final String itTeamOtherComment;
  final String clientName;
  final List<Offset?> signaturePoints;
  final DateTime? signedAt;
  final DateTime? signatureDate;
  final bool serviceConfirmed;
  final List<Uint8List> maintenancePhotos;

  ProjectRecord({
    this.jobSite = '',
    this.timeIn = '',
    this.timeOut = '',
    this.serviceType = 'Scheduled Maintenance',
    required this.id,
    required this.companyName,
    required this.location,
    this.locationCoordinates = '',
    required this.ledType,
    required this.pixelPitch,
    required this.dimensions,
    required this.controller,
    required this.status,
    required this.dateAdded,
    required this.notes,
    this.serviceDate,
    this.technicalTeam = const [],
    this.itTeam = const [],
    this.maintenancePerformed = '',
    this.partsReplaced = '',
    this.serviceOutcome = '',
    this.maintenanceChecklist = const {},
    this.voltageReading1 = '',
    this.voltageReading2 = '',
    this.observations = '',
    this.outstandingIssues = '',
    this.recommendations = '',
    this.technicalTeamOtherComment = '',
    this.itTeamOtherComment = '',
    this.clientName = '',
    this.signaturePoints = const [],
    this.signedAt,
    this.signatureDate,
    this.serviceConfirmed = false,
    this.maintenancePhotos = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobSite': jobSite,
      'timeIn': timeIn,
      'timeOut': timeOut,
      'serviceType': serviceType,
      'companyName': companyName,
      'location': location,
      'locationCoordinates': locationCoordinates,
      'ledType': ledType,
      'pixelPitch': pixelPitch,
      'dimensions': dimensions,
      'controller': controller,
      'status': status,
      'dateAdded': dateAdded.toIso8601String(),
      'notes': notes,
      'serviceDate': serviceDate?.toIso8601String(),
      'technicalTeam': technicalTeam,
      'itTeam': itTeam,
      'maintenancePerformed': maintenancePerformed,
      'partsReplaced': partsReplaced,
      'serviceOutcome': serviceOutcome,
      'maintenanceChecklist': maintenanceChecklist,
      'voltageReading1': voltageReading1,
      'voltageReading2': voltageReading2,
      'observations': observations,
      'outstandingIssues': outstandingIssues,
      'recommendations': recommendations,
      'technicalTeamOtherComment': technicalTeamOtherComment,
      'itTeamOtherComment': itTeamOtherComment,
      'clientName': clientName,
      'signaturePoints': signaturePoints.map((point) {
        if (point == null) return null;
        return {'x': point.dx, 'y': point.dy};
      }).toList(),
      'signedAt': signedAt?.toIso8601String(),
      'signatureDate': signatureDate?.toIso8601String(),
      'serviceConfirmed': serviceConfirmed,
      'maintenancePhotos': maintenancePhotos
          .map((photo) => photo.toList())
          .toList(),
    };
  }
}

// ============================================================
// MAIN NAVIGATION
// ============================================================

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String _searchQuery = '';

  final List<ProjectRecord> _records = [
    ProjectRecord(
      id: 'IDS-2026-0048',
      companyName: 'ABC Construction Ltd',
      location: 'Kuala Lumpur',
      ledType: 'Indoor LED Display',
      pixelPitch: 'P2.5',
      dimensions: '320 x 160 mm',
      controller: 'NovaStar',
      status: 'In Progress',
      dateAdded: DateTime(2026, 10, 24),
      notes: 'LED module installation and configuration.',
      jobSite: 'Main Entrance',
    ),
    ProjectRecord(
      id: 'IDS-2026-0047',
      companyName: 'Metro Electrical Services',
      location: 'Petaling Jaya',
      ledType: 'Indoor LED Display',
      pixelPitch: 'P1.8',
      dimensions: '640 x 360 mm',
      controller: 'NovaStar',
      status: 'Pending',
      dateAdded: DateTime(2026, 10, 23),
      notes: 'Screen setup and display testing.',
      jobSite: 'Conference Room',
    ),
    ProjectRecord(
      id: 'IDS-2026-0046',
      companyName: 'Summit Facilities Group',
      location: 'Penang',
      ledType: 'Outdoor LED Display',
      pixelPitch: 'P5',
      dimensions: '960 x 960 mm',
      controller: 'NovaStar',
      status: 'Completed',
      dateAdded: DateTime(2026, 10, 22),
      notes: 'Module replacement and colour calibration.',
      jobSite: 'Outdoor Advertising Board',
    ),
    ProjectRecord(
      id: 'IDS-2026-0045',
      companyName: 'Riverside Industrial',
      location: 'Johor Bahru',
      ledType: 'Indoor LED Display',
      pixelPitch: 'P3.91',
      dimensions: '500 x 500 mm',
      controller: 'NovaStar',
      status: 'In Progress',
      dateAdded: DateTime(2026, 10, 21),
      notes: 'Display inspection and signal testing.',
      jobSite: 'Factory Information Display',
    ),
  ];

  List<ProjectRecord> get _filteredRecords {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return List.of(_records);

    return _records.where((record) {
      return record.companyName.toLowerCase().contains(query) ||
          record.id.toLowerCase().contains(query) ||
          record.location.toLowerCase().contains(query) ||
          record.pixelPitch.toLowerCase().contains(query) ||
          record.jobSite.toLowerCase().contains(query) ||
          record.serviceType.toLowerCase().contains(query);
    }).toList();
  }

  void _addRecord(ProjectRecord record) {
    setState(() {
      _records.insert(0, record);
      _selectedIndex = 0;
      _searchQuery = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New service docket added successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openNewRecordForm() {
    Navigator.push<ProjectRecord>(
      context,
      MaterialPageRoute(builder: (_) => const NewProjectRecordPage()),
    ).then((record) {
      if (record != null && mounted) _addRecord(record);
    });
  }

  void _openRecordDetails(ProjectRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProjectDetailsPage(record: record)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_buildHome(), _buildProjectsPage(), const SettingsPage()];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE6EFFF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_rounded),
            label: 'Projects Record',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    final records = _filteredRecords;
    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: IDSHeader(
              onNotificationTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications.')),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSearchBar(),
                const SizedBox(height: 18),
                _buildAddRecordCard(),
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Recently Added',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: idsText,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _selectedIndex = 1),
                      child: const Row(
                        children: [
                          Text('View All'),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (records.isEmpty)
                  _buildEmptySearch()
                else
                  ...records
                      .take(4)
                      .map(
                        (record) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProjectRecordCard(
                            record: record,
                            onTap: () => _openRecordDetails(record),
                          ),
                        ),
                      ),
                const SizedBox(height: 12),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: const InputDecoration(
        hintText: 'Search job sites, companies, docket numbers...',
        hintStyle: TextStyle(color: idsMuted, fontSize: 14),
        prefixIcon: Icon(Icons.search_rounded, color: idsMuted, size: 25),
      ),
    );
  }

  Widget _buildAddRecordCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF123D78), Color(0xFF1761C5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: idsBlue.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -16,
            child: Opacity(
              opacity: 0.13,
              child: const LEDPixelPattern(
                dotColor: Colors.white,
                rows: 7,
                columns: 8,
                dotSize: 8,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LED SERVICE',
                            style: TextStyle(
                              color: Color(0xFFD8E7FF),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.4,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Service Workspace',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 19),
                const Text(
                  'Create a new service docket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Record service times, LED details, maintenance, and client confirmation.',
                  style: TextStyle(
                    color: Color(0xFFD8E7FF),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openNewRecordForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: idsNavy,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline_rounded, size: 22),
                        SizedBox(width: 9),
                        Text(
                          'Add New Service Docket',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: idsBorder),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, color: idsMuted, size: 38),
          SizedBox(height: 10),
          Text(
            'No matching records found',
            style: TextStyle(color: idsText, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 5),
          Text(
            'Try another job site or docket number.',
            textAlign: TextAlign.center,
            style: TextStyle(color: idsMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsPage() {
    final records = _filteredRecords;
    return SafeArea(
      child: Column(
        children: [
          _buildPageHeader(
            'Projects Record',
            'Manage your LED service dockets',
            trailing: IconButton(
              onPressed: _openNewRecordForm,
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: idsBlue,
              tooltip: 'Add service docket',
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                hintText: 'Search service dockets...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          Expanded(
            child: records.isEmpty
                ? const Center(
                    child: Text(
                      'No service dockets found.',
                      style: TextStyle(color: idsMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ProjectRecordCard(
                          record: record,
                          onTap: () => _openRecordDetails(record),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageHeader(String title, String subtitle, {Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 52, 16, 22),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: idsText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: idsMuted),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class IDSHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;

  const IDSHeader({super.key, required this.onNotificationTap});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good morning,';
    if (hour >= 12 && hour < 17) return 'Good afternoon,';
    if (hour >= 17 && hour < 21) return 'Good evening,';
    return 'Good night,';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 56, 22, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF123D78), Color(0xFF0C2A55)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IDSLogo(size: 52),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'IDS Service Docket',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Service management made simple',
                      style: TextStyle(color: Color(0xFFD3E1F5), fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onNotificationTap,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            _getGreeting(),
            style: const TextStyle(color: Color(0xFFD3E1F5), fontSize: 15),
          ),
          const SizedBox(height: 7),
          const Text(
            'Welcome back 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'What would you like to do today?',
            style: TextStyle(color: Color(0xFFD3E1F5), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// IDS LOGO
// ============================================================

class IDSLogo extends StatelessWidget {
  final double size;

  const IDSLogo({super.key, this.size = 52});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.23),
      ),
      child: Text(
        'IDS',
        style: TextStyle(
          color: idsBlue,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.36,
          letterSpacing: -1,
        ),
      ),
    );
  }
}

// ============================================================
// LED PIXEL PATTERN
// ============================================================

class LEDPixelPattern extends StatelessWidget {
  final Color dotColor;
  final int rows;
  final int columns;
  final double dotSize;

  const LEDPixelPattern({
    super.key,
    required this.dotColor,
    this.rows = 6,
    this.columns = 8,
    this.dotSize = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        rows,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              columns,
              (_) => Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SERVICE DOCKET CARD
// ============================================================

class ProjectRecordCard extends StatelessWidget {
  final ProjectRecord record;
  final VoidCallback onTap;

  const ProjectRecordCard({
    super.key,
    required this.record,
    required this.onTap,
  });

  Color get _statusColor {
    switch (record.status) {
      case 'Completed':
        return const Color(0xFF16825D);
      case 'Pending':
        return const Color(0xFFB7791F);
      default:
        return idsBlue;
    }
  }

  Color get _statusBackground {
    switch (record.status) {
      case 'Completed':
        return const Color(0xFFE2F5EC);
      case 'Pending':
        return const Color(0xFFFFF2D8);
      default:
        return const Color(0xFFE7EFFF);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: idsBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_outlined,
                  color: idsBlue,
                  size: 27,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.jobSite.isEmpty
                          ? 'Service Docket'
                          : record.jobSite,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: idsText,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: idsMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          record.id,
                          style: const TextStyle(color: idsMuted, fontSize: 10),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _statusBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            record.status,
                            style: TextStyle(
                              color: _statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${record.serviceType} • ${_formatDate(record.dateAdded)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: idsMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: idsMuted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ADD NEW SERVICE DOCKET FORM
// ============================================================

class NewProjectRecordPage extends StatefulWidget {
  const NewProjectRecordPage({super.key});

  @override
  State<NewProjectRecordPage> createState() => _NewProjectRecordPageState();
}

class _NewProjectRecordPageState extends State<NewProjectRecordPage> {
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  DateTime _serviceDate = DateTime.now();
  DateTime _signatureDate = DateTime.now();

  final _jobSiteController = TextEditingController();
  TimeOfDay? _timeIn;
  TimeOfDay? _timeOut;
  String _serviceType = 'Scheduled Maintenance';

  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  LatLng? _selectedLocationPoint;
  final MapController _mapController = MapController();
  bool _isDetectingLocation = false;
  String? _locationError;
  final _pitchController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _controllerController = TextEditingController();

  final _maintenanceController = TextEditingController();
  final _partsController = TextEditingController();
  final _outcomeController = TextEditingController();
  final _voltageReading1Controller = TextEditingController();
  final _voltageReading2Controller = TextEditingController();

  static const String _ledEquipmentTitle =
      'Every Two Months LED Display / LCD Panel & Equipment';
  static const String _controlSystemTitle = 'Control System';
  static const String _electricalSystemTitle = 'Electrical System';
  static const String _aircondSystemTitle = 'Aircond System';
  static const String _housekeepingTitle = 'Housekeeping';
  static const String _voltageTitle = 'Screen Power Supply Voltage';

  final Map<String, List<bool>> _maintenanceChecklist = {
    _ledEquipmentTitle: List<bool>.filled(7, false),
    _controlSystemTitle: List<bool>.filled(5, false),
    _electricalSystemTitle: List<bool>.filled(1, false),
    _aircondSystemTitle: List<bool>.filled(1, false),
    _housekeepingTitle: List<bool>.filled(1, false),
  };

  final _observationsController = TextEditingController();
  final _issuesController = TextEditingController();
  final _recommendationsController = TextEditingController();
  final _technicalTeamOtherCommentController = TextEditingController();
  final _itTeamOtherCommentController = TextEditingController();

  final _clientNameController = TextEditingController();

  final List<TextEditingController> _technicalTeam = [TextEditingController()];
  final List<TextEditingController> _itTeam = [TextEditingController()];

  final List<Offset?> _signaturePoints = [];

  final ImagePicker _imagePicker = ImagePicker();
  final List<Uint8List> _maintenancePhotos = [];
  bool _isPickingPhotos = false;

  String _ledType = 'Indoor LED Display';
  String _status = 'Completed';
  bool _serviceConfirmed = false;

  static const List<String> _stepTitles = [
    'Basic Information',
    'Workers Involved',
    'Maintenance Scope',
    'Remarks & Comments',
    'Maintenance Photos',
    'Client Signature',
  ];

  static const List<String> _stepDescriptions = [
    'Enter the service location, time, and type.',
    'Enter the names of the Technical Team and IT Team.',
    'Describe the maintenance and repair work.',
    'Document observations and outstanding issues.',
    'Attach photos of the maintenance work.',
    'Obtain the client’s signature to confirm the service.',
  ];

  @override
  void initState() {
    super.initState();
    // Automatically request the current GPS location when the form opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectCurrentLocation();
    });
  }

  Future<void> _detectCurrentLocation() async {
    if (_isDetectingLocation) return;
    if (mounted) {
      setState(() {
        _isDetectingLocation = true;
        _locationError = null;
      });
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Please turn on Location/GPS on your device.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission was denied. Please allow location access.',
        );
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is blocked. Enable it in your device app settings.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      final point = LatLng(position.latitude, position.longitude);

      String address =
          '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts =
              <String?>[
                    place.name,
                    place.street,
                    place.subLocality,
                    place.locality,
                    place.postalCode,
                    place.administrativeArea,
                    place.country,
                  ]
                  .where((part) => part != null && part.trim().isNotEmpty)
                  .toSet()
                  .toList();
          if (parts.isNotEmpty) address = parts.join(', ');
        }
      } catch (_) {
        // Keep GPS coordinates if reverse geocoding is unavailable.
      }

      if (!mounted) return;
      setState(() {
        _selectedLocationPoint = point;
        _locationController.text = address;
        _locationError = null;
      });
      _mapController.move(point, 16);
    } catch (error) {
      if (mounted) {
        setState(() {
          _locationError = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isDetectingLocation = false);
    }
  }

  @override
  void dispose() {
    _jobSiteController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _pitchController.dispose();
    _dimensionsController.dispose();
    _controllerController.dispose();
    _maintenanceController.dispose();
    _partsController.dispose();
    _outcomeController.dispose();
    _voltageReading1Controller.dispose();
    _voltageReading2Controller.dispose();
    _observationsController.dispose();
    _issuesController.dispose();
    _recommendationsController.dispose();
    _technicalTeamOtherCommentController.dispose();
    _itTeamOtherCommentController.dispose();
    _clientNameController.dispose();

    for (final controller in _technicalTeam) {
      controller.dispose();
    }
    for (final controller in _itTeam) {
      controller.dispose();
    }

    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select time';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _selectTime(bool isTimeIn) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isTimeIn
          ? (_timeIn ?? TimeOfDay.now())
          : (_timeOut ?? TimeOfDay.now()),
    );

    if (picked != null && mounted) {
      setState(() {
        if (isTimeIn) {
          _timeIn = picked;
        } else {
          _timeOut = picked;
        }
      });
    }
  }

  Widget _timePickerField(String label, TimeOfDay? time, bool isTimeIn) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: idsText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _selectTime(isTimeIn),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: idsBorder),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded, color: idsBlue),
                  const SizedBox(width: 12),
                  Text(
                    _formatTime(time),
                    style: TextStyle(color: time == null ? idsMuted : idsText),
                  ),
                  const Spacer(),
                  const Icon(Icons.schedule_rounded, color: idsMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectServiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => _serviceDate = picked);
  }

  Future<void> _selectSignatureDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _signatureDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => _signatureDate = picked);
  }

  Widget _signatureDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Signature Date',
            style: TextStyle(
              color: idsText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectSignatureDate,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: idsBorder),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined, color: idsBlue),
                  const SizedBox(width: 12),
                  Text(
                    _formatDate(_signatureDate),
                    style: const TextStyle(color: idsText),
                  ),
                  const Spacer(),
                  const Icon(Icons.edit_calendar_outlined, color: idsMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addTeamMember(List<TextEditingController> team) {
    setState(() => team.add(TextEditingController()));
  }

  void _removeTeamMember(List<TextEditingController> team, int index) {
    if (team.length <= 1) return;
    team[index].dispose();
    setState(() => team.removeAt(index));
  }

  List<String> _getTeamNames(List<TextEditingController> team) {
    return team
        .map((controller) => controller.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }

  Future<void> _takeMaintenancePhoto() async {
    if (_isPickingPhotos) return;
    setState(() => _isPickingPhotos = true);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (!mounted) return;
        setState(() => _maintenancePhotos.add(bytes));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to take photo: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingPhotos = false);
    }
  }

  Future<void> _chooseMaintenancePhotos() async {
    if (_isPickingPhotos) return;
    setState(() => _isPickingPhotos = true);
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (images.isNotEmpty) {
        final newPhotos = <Uint8List>[];
        for (final image in images) {
          newPhotos.add(await image.readAsBytes());
        }
        if (!mounted) return;
        setState(() => _maintenancePhotos.addAll(newPhotos));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to select photos: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingPhotos = false);
    }
  }

  void _removeMaintenancePhoto(int index) {
    if (index < 0 || index >= _maintenancePhotos.length) return;
    setState(() => _maintenancePhotos.removeAt(index));
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() != true) return false;

      if (_timeIn == null || _timeOut == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both Time In and Time Out.'),
          ),
        );
        return false;
      }

      final inMinutes = _timeIn!.hour * 60 + _timeIn!.minute;
      final outMinutes = _timeOut!.hour * 60 + _timeOut!.minute;
      if (outMinutes <= inMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time Out must be later than Time In.')),
        );
        return false;
      }
      return true;
    }

    if (_currentStep == 1) {
      final technicalNames = _getTeamNames(_technicalTeam);
      final itNames = _getTeamNames(_itTeam);

      if (technicalNames.isEmpty && itNames.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter at least one name in either team.'),
          ),
        );
        return false;
      }
      return true;
    }

    if (_currentStep == 5) {
      if (_clientNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the client name.')),
        );
        return false;
      }
      if (!_signaturePoints.any((point) => point != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please obtain the client signature.')),
        );
        return false;
      }
      if (!_serviceConfirmed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please confirm the service completion with the client.',
            ),
          ),
        );
        return false;
      }
      return true;
    }

    return _formKey.currentState?.validate() ?? false;
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      _saveRecord();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _saveRecord() {
    final now = DateTime.now();

    final record = ProjectRecord(
      jobSite: _jobSiteController.text.trim(),
      timeIn: _formatTime(_timeIn),
      timeOut: _formatTime(_timeOut),
      serviceType: _serviceType,
      id: 'IDS-${now.year}-${now.millisecondsSinceEpoch.toString().substring(8)}',
      companyName: _companyController.text.trim(),
      location: _locationController.text.trim(),
      locationCoordinates: _selectedLocationPoint == null
          ? ''
          : '${_selectedLocationPoint!.latitude.toStringAsFixed(6)}, ${_selectedLocationPoint!.longitude.toStringAsFixed(6)}',
      ledType: _ledType,
      pixelPitch: _pitchController.text.trim(),
      dimensions: _dimensionsController.text.trim(),
      controller: _controllerController.text.trim(),
      status: _status,
      dateAdded: now,
      notes: _observationsController.text.trim(),
      serviceDate: _serviceDate,
      technicalTeam: _getTeamNames(_technicalTeam),
      itTeam: _getTeamNames(_itTeam),
      maintenancePerformed: _maintenanceController.text.trim(),
      partsReplaced: _partsController.text.trim(),
      serviceOutcome: _outcomeController.text.trim(),
      maintenanceChecklist: {
        for (final entry in _maintenanceChecklist.entries)
          entry.key: List<bool>.from(entry.value),
      },
      voltageReading1: _voltageReading1Controller.text.trim(),
      voltageReading2: _voltageReading2Controller.text.trim(),
      observations: _observationsController.text.trim(),
      outstandingIssues: _issuesController.text.trim(),
      recommendations: _recommendationsController.text.trim(),
      technicalTeamOtherComment: _technicalTeamOtherCommentController.text
          .trim(),
      itTeamOtherComment: _itTeamOtherCommentController.text.trim(),
      clientName: _clientNameController.text.trim(),
      signaturePoints: List<Offset?>.from(_signaturePoints),
      signedAt: now,
      signatureDate: _signatureDate,
      serviceConfirmed: _serviceConfirmed,
      maintenancePhotos: List<Uint8List>.from(_maintenancePhotos),
    );

    // Keep this form page alive underneath the preview. If the user goes
    // back, all controllers and checklist values remain in memory.
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDocketPreviewPage(record: record),
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        Navigator.pop(context, record);
      }
    });
  }

  Widget _sectionHeading(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: idsText,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(color: idsMuted, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    String? hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: idsText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(hintText: hint ?? 'Enter $label'),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: idsText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value,
            isExpanded: true,
            decoration: const InputDecoration(),
            items: options
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // STEP 1: BASIC INFORMATION
  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(_stepTitles[0], _stepDescriptions[0]),
        _field(
          'Job Site',
          _jobSiteController,
          hint: 'Enter the project or site name',
          validator: _requiredValidator,
        ),
        _field(
          'Location / Site Address',
          _locationController,
          hint: 'Enter the site address or tap the map to select a point',
          validator: _requiredValidator,
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isDetectingLocation ? null : _detectCurrentLocation,
            icon: _isDetectingLocation
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              _isDetectingLocation
                  ? 'Detecting current GPS location...'
                  : 'Use My Current GPS Location',
            ),
          ),
        ),
        if (_locationError != null) ...[
          const SizedBox(height: 6),
          Text(
            _locationError!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'Your GPS location is detected automatically. You can also tap the map to adjust the site.',
          style: const TextStyle(
            color: idsText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 230,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(3.1390, 101.6869),
                initialZoom: 10,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedLocationPoint = point;
                    if (_locationController.text.trim().isEmpty) {
                      _locationController.text =
                          'Map point: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
                    }
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'my.edu.utar.idsservicedocket',
                ),
                if (_selectedLocationPoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocationPoint!,
                        width: 44,
                        height: 44,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 42,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (_selectedLocationPoint != null) ...[
          const SizedBox(height: 8),
          Text(
            'Selected coordinates: ${_selectedLocationPoint!.latitude.toStringAsFixed(6)}, ${_selectedLocationPoint!.longitude.toStringAsFixed(6)}',
            style: const TextStyle(color: idsMuted, fontSize: 12),
          ),
        ],
        const SizedBox(height: 17),
        _timePickerField('Time In', _timeIn, true),
        _timePickerField('Time Out', _timeOut, false),
        _dropdown(
          'Type of Service',
          _serviceType,
          const [
            'Scheduled Maintenance',
            'Technical Support',
            'Emergency Support',
            'Others',
          ],
          (value) {
            if (value != null) setState(() => _serviceType = value);
          },
        ),
      ],
    );
  }

  Widget _buildTeamSection({
    required String title,
    required List<TextEditingController> controllers,
    required VoidCallback onAdd,
    required ValueChanged<int> onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: idsBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: idsNavy,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(controllers.length, (index) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _field(
                    'Worker Name ${index + 1}',
                    controllers[index],
                    hint: 'Enter name',
                  ),
                ),
                if (controllers.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 25, left: 4),
                    child: IconButton(
                      onPressed: () => onRemove(index),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Remove name',
                    ),
                  ),
              ],
            );
          }),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add Name'),
            style: OutlinedButton.styleFrom(
              foregroundColor: idsBlue,
              minimumSize: const Size(double.infinity, 46),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: WORKERS
  Widget _buildWorkers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(_stepTitles[1], _stepDescriptions[1]),
        _buildTeamSection(
          title: 'Technical Team',
          controllers: _technicalTeam,
          onAdd: () => _addTeamMember(_technicalTeam),
          onRemove: (index) => _removeTeamMember(_technicalTeam, index),
        ),
        _buildTeamSection(
          title: 'IT Team',
          controllers: _itTeam,
          onAdd: () => _addTeamMember(_itTeam),
          onRemove: (index) => _removeTeamMember(_itTeam, index),
        ),
      ],
    );
  }

  Widget _buildChecklistArea({
    required String title,
    required List<String> tasks,
    required List<bool> values,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: idsBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: idsNavy,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(tasks.length, (index) {
            return CheckboxListTile(
              value: values[index],
              onChanged: (_) => onChanged(index),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: idsBlue,
              dense: true,
              title: Text(
                tasks[index],
                style: const TextStyle(
                  color: idsText,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // STEP 3: MAINTENANCE CHECKLIST
  Widget _buildMaintenance() {
    final ledTasks = <String>[
      'Inspect LED Display / LCD panels for faulty displays and rectify. Replace faulty parts if necessary.',
      'Inspect display brightness and contrast are within the setting range.',
      'Check cooling fan / ventilation fan blades function properly. Replace if necessary.',
      'Check light sensor functionality. Clean the sensor surface if necessary.',
      'Check DC power supply voltage level for health and function. Record 2 random voltage readings.',
      'Check temperature and humidity inside the screen. Record the highest and lowest readings.',
      'Replace and rotate spare modules for light-up ageing purposes.',
    ];
    final controlTasks = <String>[
      'Check that the CCTV / webcam is functioning properly.',
      'Inspect that the sending card / receiving card is functioning properly.',
      'Check the system timer auto ON / OFF function against the preset timing.',
      'Check internet connectivity, reboot the modem, and ensure the connection works.',
      'Reboot the control system and back up system data files.',
    ];
    final electricalTasks = <String>[
      'Inspect lighting fixtures for proper functionality. Replace if necessary.',
    ];
    final aircondTasks = <String>[
      'Check that the air-conditioning units function properly and record the temperature.',
    ];
    final housekeepingTasks = <String>[
      'Perform general cleaning and vacuum dust from the control room.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          _stepTitles[2],
          'Complete the six maintenance areas below. Tick each task after checking it.',
        ),
        _buildChecklistArea(
          title: _ledEquipmentTitle,
          tasks: ledTasks,
          values: _maintenanceChecklist[_ledEquipmentTitle]!,
          onChanged: (index) => setState(() {
            _maintenanceChecklist[_ledEquipmentTitle]![index] =
                !_maintenanceChecklist[_ledEquipmentTitle]![index];
          }),
        ),
        _buildChecklistArea(
          title: _controlSystemTitle,
          tasks: controlTasks,
          values: _maintenanceChecklist[_controlSystemTitle]!,
          onChanged: (index) => setState(() {
            _maintenanceChecklist[_controlSystemTitle]![index] =
                !_maintenanceChecklist[_controlSystemTitle]![index];
          }),
        ),
        _buildChecklistArea(
          title: _electricalSystemTitle,
          tasks: electricalTasks,
          values: _maintenanceChecklist[_electricalSystemTitle]!,
          onChanged: (index) => setState(() {
            _maintenanceChecklist[_electricalSystemTitle]![index] =
                !_maintenanceChecklist[_electricalSystemTitle]![index];
          }),
        ),
        _buildChecklistArea(
          title: _aircondSystemTitle,
          tasks: aircondTasks,
          values: _maintenanceChecklist[_aircondSystemTitle]!,
          onChanged: (index) => setState(() {
            _maintenanceChecklist[_aircondSystemTitle]![index] =
                !_maintenanceChecklist[_aircondSystemTitle]![index];
          }),
        ),
        _buildChecklistArea(
          title: _housekeepingTitle,
          tasks: housekeepingTasks,
          values: _maintenanceChecklist[_housekeepingTitle]!,
          onChanged: (index) => setState(() {
            _maintenanceChecklist[_housekeepingTitle]![index] =
                !_maintenanceChecklist[_housekeepingTitle]![index];
          }),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: idsBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _voltageTitle,
                style: const TextStyle(
                  color: idsNavy,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              _field(
                '1st Reading (V)',
                _voltageReading1Controller,
                hint: 'Enter first voltage reading',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              _field(
                '2nd Reading (V)',
                _voltageReading2Controller,
                hint: 'Enter second voltage reading',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 4: REMARKS
  Widget _buildRemarks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(
          _stepTitles[3],
          'Add any additional comments for each team.',
        ),
        _field(
          'Technical Team - Other / Comment',
          _technicalTeamOtherCommentController,
          hint: 'Enter other details or comments for the Technical Team',
          maxLines: 4,
        ),
        _field(
          'IT Team - Other / Comment',
          _itTeamOtherCommentController,
          hint: 'Enter other details or comments for the IT Team',
          maxLines: 4,
        ),
      ],
    );
  }

  // STEP 5: CLIENT SIGNATURE
  // STEP 5: MAINTENANCE PHOTOS
  Widget _buildMaintenancePhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(_stepTitles[4], _stepDescriptions[4]),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF5FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD8E6FA)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: idsBlue),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Attach clear photos showing the maintenance work, equipment condition, or replaced parts. Adding photos is optional.',
                  style: TextStyle(color: idsText, fontSize: 12, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isPickingPhotos ? null : _takeMaintenancePhoto,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Take Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: idsBlue,
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isPickingPhotos ? null : _chooseMaintenancePhotos,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: idsBlue,
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
          ],
        ),
        if (_isPickingPhotos) ...[
          const SizedBox(height: 18),
          const Center(child: CircularProgressIndicator(color: idsBlue)),
        ],
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Selected Photos',
                style: TextStyle(
                  color: idsText,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${_maintenancePhotos.length} photo(s)',
              style: const TextStyle(color: idsMuted, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_maintenancePhotos.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: idsBorder, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              children: [
                Icon(Icons.add_a_photo_outlined, color: idsMuted, size: 38),
                SizedBox(height: 10),
                Text(
                  'No maintenance photos added',
                  style: TextStyle(color: idsText, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 5),
                Text(
                  'Use the camera or choose photos from your gallery.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: idsMuted, fontSize: 12),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _maintenancePhotos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _maintenancePhotos[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: 7,
                    bottom: 7,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        'Photo ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Remove photo',
                        onPressed: () => _removeMaintenancePhoto(index),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.redAccent,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildSignature() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading(_stepTitles[5], _stepDescriptions[5]),
        _signatureDateField(),
        _field(
          'Client Name',
          _clientNameController,
          validator: _requiredValidator,
        ),
        const SizedBox(height: 4),
        const Text(
          'Client Signature',
          style: TextStyle(
            color: idsText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 190,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: idsBorder),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onPanStart: (details) {
                      setState(
                        () => _signaturePoints.add(details.localPosition),
                      );
                    },
                    onPanUpdate: (details) {
                      setState(
                        () => _signaturePoints.add(details.localPosition),
                      );
                    },
                    onPanEnd: (_) => setState(() => _signaturePoints.add(null)),
                    child: CustomPaint(
                      painter: _SignaturePainter(points: _signaturePoints),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                if (!_signaturePoints.any((p) => p != null))
                  const Center(
                    child: Text(
                      'Sign here',
                      style: TextStyle(color: Color(0xFFB0BAC7), fontSize: 18),
                    ),
                  ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 35,
                  child: Container(height: 1, color: const Color(0xFFD5DDE7)),
                ),
                const Positioned(
                  left: 12,
                  bottom: 10,
                  child: Text(
                    'Draw signature above this line',
                    style: TextStyle(color: idsMuted, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => setState(() => _signaturePoints.clear()),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Clear Signature'),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _serviceConfirmed,
            onChanged: (value) => setState(() {
              _serviceConfirmed = value ?? false;
            }),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: idsBlue,
            title: const Text(
              'Service confirmation',
              style: TextStyle(
                color: idsText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            subtitle: const Text(
              'The client confirms the service details above.',
              style: TextStyle(color: idsMuted, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Service date: ${_formatDate(_serviceDate)}',
          style: const TextStyle(color: idsMuted, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildCurrentSection() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfo();
      case 1:
        return _buildWorkers();
      case 2:
        return _buildMaintenance();
      case 3:
        return _buildRemarks();
      case 4:
        return _buildMaintenancePhotos();
      case 5:
        return _buildSignature();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: idsBackground,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: idsNavy,
                        ),
                        const Expanded(
                          child: Text(
                            'New Service Docket',
                            style: TextStyle(
                              color: idsText,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ServiceStepHeader(currentStep: _currentStep, totalSteps: 6),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  key: PageStorageKey<int>(_currentStep),
                  padding: const EdgeInsets.all(20),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: idsBorder),
                      ),
                      child: _buildCurrentSection(),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: idsBorder)),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _previousStep,
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: idsNavy,
                          minimumSize: const Size(0, 52),
                          side: const BorderSide(color: idsBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    )
                  else
                    const Expanded(
                      child: Text(
                        'Step 1 of 6',
                        style: TextStyle(color: idsMuted, fontSize: 12),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: idsBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == 5 ? 'Submit Docket' : 'Next',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _currentStep == 5
                                ? Icons.check_circle_outline
                                : Icons.arrow_forward_rounded,
                            size: 19,
                          ),
                        ],
                      ),
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
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  _SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF123D78)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      if (start != null && end != null) canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}

// ============================================================
// SERVICE DOCKET DETAILS PAGE
// ============================================================

class ProjectDetailsPage extends StatelessWidget {
  final ProjectRecord record;

  const ProjectDetailsPage({super.key, required this.record});

  // 1. Display individual information
  Widget _detail(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: idsBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: idsBlue, size: 22),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: idsMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value.isEmpty ? 'Not specified' : value,
                  style: const TextStyle(
                    color: idsText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Display signature in full screen dialog
  void _showSignatureFullScreen(
    BuildContext context,
    ProjectRecord record,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Client Signature',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: idsText,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: idsBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomPaint(
                    painter: _SignaturePainter(
                      points: record.signaturePoints,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Client: ${record.clientName}',
                  style: const TextStyle(
                    color: idsText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _teamNames(String title, List<String> names, IconData icon) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: idsBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: idsBlue, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: idsText,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (names.isEmpty)
            const Text('No names added', style: TextStyle(color: idsMuted))
          else
            ...names.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 18, color: idsMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(color: idsText, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _maintenanceChecklistDetails(ProjectRecord record) {
    const taskLabels = <String, List<String>>{
      'Every Two Months LED Display / LCD Panel & Equipment': [
        'Inspect LED Display / LCD panels for faulty displays and rectify. Replace faulty parts if necessary.',
        'Inspect display brightness and contrast are within the setting range.',
        'Check cooling fan / ventilation fan blades function properly. Replace if necessary.',
        'Check light sensor functionality. Clean the sensor surface if necessary.',
        'Check DC power supply voltage level for health and function. Record 2 random voltage readings.',
        'Check temperature and humidity inside the screen. Record the highest and lowest readings.',
        'To Replace and rotate spare modules for light-up ageing purposes.',
      ],
      'Control System': [
        'Check that the CCTV / webcam is functioning properly.',
        'Inspect that the sending card / receiving card is functioning properly.',
        'Check the system timer auto ON / OFF function against the preset timing.',
        'Check internet connectivity, reboot the modem, and ensure the connection works.',
        'Reboot the control system and back up system data files.',
      ],
      'Electrical System': [
        'Inspect lighting fixtures for proper functionality. Replace if necessary.',
      ],
      'Aircond System': [
        'Check that the air-conditioning units function properly and record the temperature.',
      ],
      'Housekeeping': [
        'Perform general cleaning and vacuum dust from the control room.',
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...taskLabels.entries.map((area) {
          final savedValues =
              record.maintenanceChecklist[area.key] ?? const <bool>[];
          final values = List<bool>.generate(
            area.value.length,
            (index) => index < savedValues.length && savedValues[index],
          );
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: idsBorder),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  area.key,
                  style: const TextStyle(
                    color: idsText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  area.value.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          values[index]
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          color: values[index] ? idsBlue : idsMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            area.value[index],
                            style: const TextStyle(
                              color: idsText,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        _detail(
          '1st Voltage Reading (V)',
          record.voltageReading1,
          Icons.electrical_services_outlined,
        ),
        _detail(
          '2nd Voltage Reading (V)',
          record.voltageReading2,
          Icons.electrical_services_outlined,
        ),
      ],
    );
  }

  // Maintenance photo gallery
  Widget _maintenancePhotosPreview(BuildContext context, ProjectRecord record) {
    if (record.maintenancePhotos.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: idsBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library_outlined, color: idsBlue, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Maintenance Photos',
                  style: TextStyle(
                    color: idsText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${record.maintenancePhotos.length} photo(s)',
                style: const TextStyle(color: idsMuted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: record.maintenancePhotos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => Dialog(
                      insetPadding: const EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          InteractiveViewer(
                            child: Image.memory(
                              record.maintenancePhotos[index],
                              fit: BoxFit.contain,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: IconButton.filled(
                              onPressed: () => Navigator.pop(dialogContext),
                              icon: const Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    record.maintenancePhotos[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap a photo to view it in full screen.',
            style: TextStyle(color: idsMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // 3. Signature preview section
  Widget _signaturePreview(BuildContext context, ProjectRecord record) {
    final hasSignature = record.signaturePoints.any((point) => point != null);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: idsBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.draw_outlined,
                color: idsBlue,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Client Signature Image',
                  style: TextStyle(
                    color: idsText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'View full screen',
                onPressed: hasSignature
                    ? () => _showSignatureFullScreen(context, record)
                    : null,
                icon: const Icon(
                  Icons.fullscreen,
                  color: idsBlue,
                  size: 26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: idsBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: hasSignature
                ? CustomPaint(
                    painter: _SignaturePainter(
                      points: record.signaturePoints,
                    ),
                    child: const SizedBox.expand(),
                  )
                : const Center(
                    child: Text(
                      'No signature available',
                      style: TextStyle(color: idsMuted),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            'Signature Date: ${record.signatureDate == null ? 'Not specified' : '${record.signatureDate!.day.toString().padLeft(2, '0')}/${record.signatureDate!.month.toString().padLeft(2, '0')}/${record.signatureDate!.year}'}',
            style: const TextStyle(color: idsMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: idsBackground,
      appBar: AppBar(title: const Text('Service Docket Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [idsNavy, idsBlue]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Colors.white,
                  size: 34,
                ),
                const SizedBox(height: 18),
                Text(
                  record.jobSite.isEmpty ? 'Service Docket' : record.jobSite,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  record.companyName,
                  style: const TextStyle(
                    color: Color(0xFFD8E7FF),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  record.id,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Service Information',
            style: TextStyle(
              color: idsText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 13),
          _detail('Job Site', record.jobSite, Icons.location_on_outlined),
          _detail('Time In', record.timeIn, Icons.login_rounded),
          _detail('Time Out', record.timeOut, Icons.logout_rounded),
          _detail(
            'Type of Service',
            record.serviceType,
            Icons.build_circle_outlined,
          ),
          _detail(
            'Service Date',
            record.serviceDate == null
                ? ''
                : '${record.serviceDate!.day}/${record.serviceDate!.month}/${record.serviceDate!.year}',
            Icons.calendar_month_outlined,
          ),
          _detail('Company', record.companyName, Icons.business_rounded),
          _detail('Location', record.location, Icons.location_on_outlined),
          if (record.locationCoordinates.isNotEmpty)
            _detail(
              'Map Coordinates',
              record.locationCoordinates,
              Icons.map_outlined,
            ),
          _detail('LED Display Type', record.ledType, Icons.tv_rounded),
          _detail('Pixel Pitch', record.pixelPitch, Icons.grid_4x4_rounded),
          _detail(
            'Module / Screen Dimensions',
            record.dimensions,
            Icons.aspect_ratio_rounded,
          ),
          _detail(
            'Controller / Sending System',
            record.controller,
            Icons.settings_input_component_rounded,
          ),
          _detail('Status', record.status, Icons.flag_outlined),
          _detail(
            'Date Added',
            '${record.dateAdded.day}/${record.dateAdded.month}/${record.dateAdded.year}',
            Icons.calendar_today_outlined,
          ),
          _detail('Notes', record.notes, Icons.notes_rounded),
          const SizedBox(height: 10),
          const Text(
            'Workers Involved',
            style: TextStyle(
              color: idsText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _teamNames(
            'Technical Team',
            record.technicalTeam,
            Icons.engineering_outlined,
          ),
          _teamNames('IT Team', record.itTeam, Icons.computer_outlined),
          const SizedBox(height: 10),
          const Text(
            'Maintenance Details',
            style: TextStyle(
              color: idsText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _maintenanceChecklistDetails(record),
          _detail(
            'Maintenance / Repair Performed',
            record.maintenancePerformed,
            Icons.handyman_outlined,
          ),
          _detail('Parts Replaced', record.partsReplaced, Icons.build_outlined),
          _detail(
            'Service Outcome',
            record.serviceOutcome,
            Icons.task_alt_rounded,
          ),
          _detail(
            'Observations',
            record.observations,
            Icons.visibility_outlined,
          ),
          _detail(
            'Outstanding Issues',
            record.outstandingIssues,
            Icons.warning_amber_rounded,
          ),
          _detail(
            'Recommendations',
            record.recommendations,
            Icons.tips_and_updates_outlined,
          ),
          _detail(
            'Technical Team - Other / Comment',
            record.technicalTeamOtherComment,
            Icons.comment_outlined,
          ),
          _detail(
            'IT Team - Other / Comment',
            record.itTeamOtherComment,
            Icons.comment_outlined,
          ),
          _detail('Client Name', record.clientName, Icons.person_outline),
          _maintenancePhotosPreview(context, record),
          _signaturePreview(context, record),
          _detail(
            'Service Confirmation',
            record.serviceConfirmed ? 'Confirmed' : 'Not confirmed',
            Icons.verified_outlined,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SETTINGS PAGE
// ============================================================

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: idsBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: idsBlue),
        ),
        title: Text(
          title,
          style: const TextStyle(color: idsText, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: idsMuted, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: idsMuted),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 18),
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: idsText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Manage your app preferences.',
            style: TextStyle(color: idsMuted),
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: idsNavy,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                IDSLogo(size: 52),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IDS Service Docket',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'LED project management',
                        style: TextStyle(
                          color: Color(0xFFD8E7FF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          _settingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Account',
            subtitle: 'Account settings and preferences',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account settings are not configured yet.'),
                ),
              );
            },
          ),
          _settingsTile(
            icon: Icons.security_rounded,
            title: 'App Security',
            subtitle: 'Uses supported phone authentication',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Authentication is configured for app access.'),
                ),
              );
            },
          ),
          _settingsTile(
            icon: Icons.info_outline_rounded,
            title: 'About',
            subtitle: 'IDS Service Docket',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'IDS Service Docket',
                applicationVersion: '1.0.0',
                applicationLegalese: 'LED project and service records',
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SERVICE DOCKET PDF PREVIEW
// ============================================================

// ============================================================
// SERVICE DOCKET PDF PREVIEW
// ============================================================

class ServiceDocketPreviewPage extends StatelessWidget {
  final ProjectRecord record;

  const ServiceDocketPreviewPage({super.key, required this.record});

  void _confirmDocket(BuildContext context) {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Service Docket'),
        leading: IconButton(
          tooltip: 'Back to edit',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _confirmDocket(context),
            icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            label: const Text(
              'Done',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => buildServiceDocketPdf(record),
        canChangePageFormat: false,
        canChangeOrientation: false,
        allowPrinting: true,
        allowSharing: true,
        pdfFileName: '${record.id}.pdf',
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _confirmDocket(context),
              icon: const Icon(Icons.check),
              label: const Text('Confirm and Add Docket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: idsBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
