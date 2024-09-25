import 'package:flutter/material.dart';
import 'package:phone_app/components/main_app_background.dart';
import 'package:phone_app/utilities/constants.dart';

class SmartBikeSummary extends StatelessWidget {
  final String speed;
  final String rpm;
  final String distance;
  final String heartRate;
  final String resistance;
  final String incline;

  const SmartBikeSummary({super.key, 
    required this.speed,
    required this.rpm,
    required this.distance,
    required this.heartRate,
    required this.resistance,
    required this.incline,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kLoginRegisterBtnColour.withOpacity(0.9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: CustomGradientContainerSoft(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workout Summary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Speed:', '$speed RPM'),
            _buildSummaryRow('Cadence (RPM):', rpm),
            _buildSummaryRow('Distance:', '$distance km'),
            _buildSummaryRow('Heart Rate:', '$heartRate BPM'),
            _buildSummaryRow('Resistance:', resistance),
            _buildSummaryRow('Incline:', '$incline %'),
          ],
        ),
      )),
    );
  }

  // Helper method to build summary rows
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
