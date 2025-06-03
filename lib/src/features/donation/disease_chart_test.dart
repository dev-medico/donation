import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:donation/utils/Colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/report_service.dart';

// Test widget to verify disease stats are being fetched
class DiseaseChartTest extends ConsumerStatefulWidget {
  const DiseaseChartTest({Key? key}) : super(key: key);

  @override
  ConsumerState<DiseaseChartTest> createState() => _DiseaseChartTestState();
}

class _DiseaseChartTestState extends ConsumerState<DiseaseChartTest> {
  List<Map<String, dynamic>>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      log('DiseaseChartTest: Loading data...');
      final reportService = ref.read(reportServiceProvider);
      final result = await reportService.getDiseaseStats();
      log('DiseaseChartTest: Loaded ${result.length} items');
      
      if (mounted) {
        setState(() {
          _data = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      log('DiseaseChartTest: Error = $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log('DiseaseChartTest: build() called, isLoading=$_isLoading, hasData=${_data != null}, error=$_error');
    
    return Container(
      height: 400,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Disease Chart Test Widget",
            style: TextStyle(
              fontSize: 18,
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text('Error: $_error'),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_data == null || _data!.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No data available'),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  Text('Loaded ${_data!.length} diseases'),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _data!.length,
                      itemBuilder: (context, index) {
                        final item = _data![index];
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${index + 1}. ${item['name'] ?? 'Unknown'}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Text(
                                '${item['count'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}