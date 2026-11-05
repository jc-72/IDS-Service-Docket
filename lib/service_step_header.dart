
import 'package:flutter/material.dart';

class ServiceStepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ServiceStepHeader({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
  }) : assert(currentStep >= 0 && currentStep < totalSteps);

  static const Color navy = Color(0xFF174A7E);
  static const Color lightBlue = Color(0xFFE8F1FA);
  static const Color completedGreen = Color(0xFF27845B);
  static const Color muted = Color(0xFF9AA5B1);

  static const List<String> sectionNames = [
    'Basic Info',
    'Workers',
    'Maintenance',
    'Remarks',
    'Photos',
    'Signature',
  ];

  static const List<IconData> sectionIcons = [
    Icons.assignment_outlined,
    Icons.groups_outlined,
    Icons.build_outlined,
    Icons.chat_bubble_outline,
    Icons.photo_library_outlined,
    Icons.draw_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / totalSteps;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5EAF0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service Docket',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'New service record',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF788493),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${currentStep + 1} / $totalSteps',
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Six section icons
          Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index == currentStep;
              final isCompleted = index < currentStep;

              final Color iconColor = isActive
                  ? Colors.white
                  : isCompleted
                      ? completedGreen
                      : muted;

              final Color backgroundColor = isActive
                  ? navy
                  : isCompleted
                      ? const Color(0xFFE2F3E9)
                      : const Color(0xFFF1F3F6);

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(13),
                        border: isActive
                            ? Border.all(
                                color: const Color(0xFF8BB8E5),
                                width: 2,
                              )
                            : null,
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check
                            : sectionIcons[index],
                        color: iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sectionNames[index],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 8,
                        height: 1.2,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isActive
                            ? navy
                            : isCompleted
                                ? completedGreen
                                : const Color(0xFF8994A2),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFE9EDF2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(navy),
            ),
          ),

          const SizedBox(height: 14),

          // Current section
          Row(
            children: [
              const Icon(
                Icons.edit_note,
                color: navy,
                size: 21,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Currently completing: ${sectionNames[currentStep]}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: navy,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF788493),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
