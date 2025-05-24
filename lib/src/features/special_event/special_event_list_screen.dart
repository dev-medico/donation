import 'package:donation/responsive.dart';
import 'package:donation/src/features/special_event/providers/special_event_provider.dart';
import 'package:donation/src/features/special_event/special_event_data_source.dart';
import 'package:donation/src/features/services/special_event_service.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class SpecialEventListScreen extends ConsumerStatefulWidget {
  const SpecialEventListScreen({Key? key, this.fromHome = false})
      : super(key: key);
  static const routeName = "/special-event-list";
  final bool fromHome;

  @override
  ConsumerState<SpecialEventListScreen> createState() =>
      _SpecialEventListScreenState();
}

class _SpecialEventListScreenState
    extends ConsumerState<SpecialEventListScreen> {
  final ScrollController _scrollController = ScrollController();
  int currentPage = 0;
  List<dynamic> allEvents = [];
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (!isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });

      try {
        final nextPage = currentPage + 1;
        final moreEvents =
            await ref.read(specialEventsProvider(nextPage).future);

        if (moreEvents.isNotEmpty) {
          setState(() {
            currentPage = nextPage;
            allEvents.addAll(moreEvents);
          });
        }
      } catch (e) {
        print('Error loading more data: $e');
      } finally {
        setState(() {
          isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final specialEventsAsync = ref.watch(specialEventsProvider(0));

    return Scaffold(
      appBar: widget.fromHome
          ? null
          : AppBar(
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [primaryColor, primaryDark],
                  ),
                ),
              ),
              centerTitle: true,
              title: const Text(
                "ထူးခြားဖြစ်စဉ်",
                style: TextStyle(fontSize: 17, color: Colors.white),
              ),
            ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            currentPage = 0;
            allEvents.clear();
          });
          ref.invalidate(specialEventsProvider);
        },
        child: specialEventsAsync.when(
          data: (initialEvents) {
            // Initialize allEvents if empty
            if (allEvents.isEmpty && initialEvents.isNotEmpty) {
              allEvents = List.from(initialEvents);
            }

            if (allEvents.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_note,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ထူးခြားဖြစ်စဉ် မရှိသေးပါ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: _buildEventTable(allEvents),
                ),
                if (isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading special events',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(specialEventsProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEventDialog();
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEventTable(List<dynamic> events) {
    final dataSource = SpecialEventDataSource(eventData: events);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SfDataGrid(
          source: dataSource,
          onCellTap: (details) {
            if (details.rowColumnIndex.rowIndex > 0) {
              final index = details.rowColumnIndex.rowIndex - 1;
              if (index < events.length) {
                _showEventDetails(events[index]);
              }
            }
          },
          onQueryRowHeight: (details) {
            // Add more height for header row
            return details.rowIndex == 0 ? 60.0 : 50.0;
          },
          gridLinesVisibility: GridLinesVisibility.both,
          headerGridLinesVisibility: GridLinesVisibility.both,
          columnWidthMode: Responsive.isMobile(context)
              ? ColumnWidthMode.auto
              : ColumnWidthMode.fill,
          columns: <GridColumn>[
            GridColumn(
                columnName: 'စဥ်',
                width: 60,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'စဥ်',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
            GridColumn(
                columnName: 'ရက်စွဲ',
                width: 120,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'ရက်စွဲ',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
            GridColumn(
                columnName: 'Lab Name',
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Lab Name',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
            GridColumn(
                columnName: 'Haemoglobin',
                width: 100,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Haemo',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          'globin',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ))),
            GridColumn(
                columnName: 'HBs Ag',
                width: 80,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'HBs Ag',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ))),
            GridColumn(
                columnName: 'HCV Ab',
                width: 80,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'HCV Ab',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ))),
            GridColumn(
                columnName: 'MP ICT',
                width: 80,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'MP ICT',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ))),
            GridColumn(
                columnName: 'Retro',
                width: 80,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'Retro',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ))),
            GridColumn(
                columnName: 'VDRL',
                width: 80,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'VDRL',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ))),
            GridColumn(
                columnName: 'စုစုပေါင်း',
                width: 100,
                label: Container(
                    color: primaryColor,
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: const Text(
                      'စုစုပေါင်း',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ))),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    DateTime date;
    String formattedDate;

    try {
      // Try to parse the date - handle different formats
      final dateStr = event['date'].toString();

      // Check if it's already in the format we want to display
      if (dateStr.contains(' ')) {
        // If it contains space, it might be in format like "24 Feb 2022"
        // Try to parse it directly
        try {
          date = DateFormat('dd MMM yyyy').parse(dateStr);
          formattedDate = dateStr;
        } catch (e) {
          // If that fails, try other formats
          date = DateTime.parse(dateStr);
          formattedDate = DateFormat('dd MMM yyyy').format(date);
        }
      } else {
        // Standard ISO format
        date = DateTime.parse(dateStr);
        formattedDate = DateFormat('dd MMM yyyy').format(date);
      }
    } catch (e) {
      // If all parsing fails, use current date as fallback
      date = DateTime.now();
      formattedDate = 'Invalid date';
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showEventDetails(event);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      event['lab_name'] ?? 'Unknown Lab',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTestInfo('Haemoglobin', event['haemoglobin']),
                  const SizedBox(width: 16),
                  _buildTestInfo('HBs Ag', event['hbs_ag']),
                  const SizedBox(width: 16),
                  _buildTestInfo('HCV Ab', event['hcv_ab']),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTestInfo('MP ICT', event['mp_ict']),
                  const SizedBox(width: 16),
                  _buildTestInfo('Retro', event['retro_test']),
                  const SizedBox(width: 16),
                  _buildTestInfo('VDRL', event['vdrl_test']),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Tests',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    event['total'].toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestInfo(String label, dynamic value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value?.toString() ?? '0',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    // Parse date safely
    String dateDisplay;
    try {
      final dateStr = event['date'].toString();
      if (dateStr.contains(' ')) {
        try {
          final date = DateFormat('dd MMM yyyy').parse(dateStr);
          dateDisplay = dateStr;
        } catch (e) {
          final date = DateTime.parse(dateStr);
          dateDisplay = DateFormat('dd MMM yyyy').format(date);
        }
      } else {
        final date = DateTime.parse(dateStr);
        dateDisplay = DateFormat('dd MMM yyyy').format(date);
      }
    } catch (e) {
      dateDisplay = 'Invalid date';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event['lab_name'] ?? 'Special Event'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Date', dateDisplay),
              _buildDetailRow('Haemoglobin', event['haemoglobin']),
              _buildDetailRow('HBs Ag', event['hbs_ag']),
              _buildDetailRow('HCV Ab', event['hcv_ab']),
              _buildDetailRow('MP ICT', event['mp_ict']),
              _buildDetailRow('Retro Test', event['retro_test']),
              _buildDetailRow('VDRL Test', event['vdrl_test']),
              _buildDetailRow('Total', event['total']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: primaryColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditEventDialog(event);
            },
            child: Text('Edit', style: TextStyle(color: primaryColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(event['id'].toString());
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value?.toString() ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddSpecialEventDialog(
        onAdded: () {
          setState(() {
            currentPage = 0;
            allEvents.clear();
          });
          ref.invalidate(specialEventsProvider);
        },
      ),
    );
  }

  void _showEditEventDialog(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => _EditSpecialEventDialog(
        event: event,
        onUpdated: () {
          setState(() {
            currentPage = 0;
            allEvents.clear();
          });
          ref.invalidate(specialEventsProvider);
        },
      ),
    );
  }

  void _deleteEvent(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await ref.read(deleteSpecialEventProvider(id).future);

                setState(() {
                  allEvents
                      .removeWhere((event) => event['id'].toString() == id);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting event: $e')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Add Special Event Dialog Widget
class _AddSpecialEventDialog extends ConsumerStatefulWidget {
  final VoidCallback onAdded;

  const _AddSpecialEventDialog({required this.onAdded});

  @override
  ConsumerState<_AddSpecialEventDialog> createState() =>
      _AddSpecialEventDialogState();
}

class _AddSpecialEventDialogState
    extends ConsumerState<_AddSpecialEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labNameController = TextEditingController();
  final _haemoglobinController = TextEditingController();
  final _hbsAgController = TextEditingController();
  final _hcvAbController = TextEditingController();
  final _mpIctController = TextEditingController();
  final _retroController = TextEditingController();
  final _vdrlController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _labNameController.dispose();
    _haemoglobinController.dispose();
    _hbsAgController.dispose();
    _hcvAbController.dispose();
    _mpIctController.dispose();
    _retroController.dispose();
    _vdrlController.dispose();
    super.dispose();
  }

  int _calculateTotal() {
    int total = 0;
    total += int.tryParse(_haemoglobinController.text) ?? 0;
    total += int.tryParse(_hbsAgController.text) ?? 0;
    total += int.tryParse(_hcvAbController.text) ?? 0;
    total += int.tryParse(_mpIctController.text) ?? 0;
    total += int.tryParse(_retroController.text) ?? 0;
    total += int.tryParse(_vdrlController.text) ?? 0;
    return total;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(specialEventServiceProvider);
      final data = {
        'lab_name': _labNameController.text,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'haemoglobin': int.parse(_haemoglobinController.text.isEmpty
            ? '0'
            : _haemoglobinController.text),
        'hbs_ag': int.parse(
            _hbsAgController.text.isEmpty ? '0' : _hbsAgController.text),
        'hcv_ab': int.parse(
            _hcvAbController.text.isEmpty ? '0' : _hcvAbController.text),
        'mp_ict': int.parse(
            _mpIctController.text.isEmpty ? '0' : _mpIctController.text),
        'retro_test': int.parse(
            _retroController.text.isEmpty ? '0' : _retroController.text),
        'vdrl_test': int.parse(
            _vdrlController.text.isEmpty ? '0' : _vdrlController.text),
        'total': _calculateTotal(),
      };

      await service.createSpecialEvent(data);

      Navigator.pop(context);
      widget.onAdded();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ထူးခြားဖြစ်စဉ် အောင်မြင်စွာ ထည့်သွင်းပြီးပါပြီ'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_circle, color: primaryColor),
          const SizedBox(width: 8),
          const Text('ထူးခြားဖြစ်စဉ် အသစ်ထည့်သွင်းမည်'),
        ],
      ),
      content: SingleChildScrollView(
        child: Container(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lab Name
                TextFormField(
                  controller: _labNameController,
                  decoration: const InputDecoration(
                    labelText: 'Lab Name *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lab Name ဖြည့်သွင်းပါ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date Picker
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Test fields in a grid
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: [
                    _buildTestField('Haemoglobin', _haemoglobinController),
                    _buildTestField('HBs Ag', _hbsAgController),
                    _buildTestField('HCV Ab', _hcvAbController),
                    _buildTestField('MP ICT', _mpIctController),
                    _buildTestField('Retro', _retroController),
                    _buildTestField('VDRL', _vdrlController),
                  ],
                ),
                const SizedBox(height: 16),

                // Total display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'စုစုပေါင်း',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _calculateTotal().toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('မလုပ်တော့ပါ'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'သိမ်းမည်',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  Widget _buildTestField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {}); // Update total
      },
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (int.tryParse(value) == null) {
            return 'ကိန်းဂဏန်းသာ';
          }
        }
        return null;
      },
    );
  }
}

// Edit Special Event Dialog Widget
class _EditSpecialEventDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> event;
  final VoidCallback onUpdated;

  const _EditSpecialEventDialog({
    required this.event,
    required this.onUpdated,
  });

  @override
  ConsumerState<_EditSpecialEventDialog> createState() =>
      _EditSpecialEventDialogState();
}

class _EditSpecialEventDialogState
    extends ConsumerState<_EditSpecialEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labNameController;
  late TextEditingController _haemoglobinController;
  late TextEditingController _hbsAgController;
  late TextEditingController _hcvAbController;
  late TextEditingController _mpIctController;
  late TextEditingController _retroController;
  late TextEditingController _vdrlController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _labNameController =
        TextEditingController(text: widget.event['lab_name'] ?? '');
    _haemoglobinController = TextEditingController(
        text: widget.event['haemoglobin']?.toString() ?? '0');
    _hbsAgController =
        TextEditingController(text: widget.event['hbs_ag']?.toString() ?? '0');
    _hcvAbController =
        TextEditingController(text: widget.event['hcv_ab']?.toString() ?? '0');
    _mpIctController =
        TextEditingController(text: widget.event['mp_ict']?.toString() ?? '0');
    _retroController = TextEditingController(
        text: widget.event['retro_test']?.toString() ?? '0');
    _vdrlController = TextEditingController(
        text: widget.event['vdrl_test']?.toString() ?? '0');

    // Parse date
    try {
      final dateStr = widget.event['date'].toString();
      if (dateStr.contains(' ')) {
        try {
          _selectedDate = DateFormat('dd MMM yyyy').parse(dateStr);
        } catch (e) {
          _selectedDate = DateTime.parse(dateStr);
        }
      } else {
        _selectedDate = DateTime.parse(dateStr);
      }
    } catch (e) {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _labNameController.dispose();
    _haemoglobinController.dispose();
    _hbsAgController.dispose();
    _hcvAbController.dispose();
    _mpIctController.dispose();
    _retroController.dispose();
    _vdrlController.dispose();
    super.dispose();
  }

  int _calculateTotal() {
    int total = 0;
    total += int.tryParse(_haemoglobinController.text) ?? 0;
    total += int.tryParse(_hbsAgController.text) ?? 0;
    total += int.tryParse(_hcvAbController.text) ?? 0;
    total += int.tryParse(_mpIctController.text) ?? 0;
    total += int.tryParse(_retroController.text) ?? 0;
    total += int.tryParse(_vdrlController.text) ?? 0;
    return total;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final service = ref.read(specialEventServiceProvider);
      final data = {
        'lab_name': _labNameController.text,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'haemoglobin': int.parse(_haemoglobinController.text.isEmpty
            ? '0'
            : _haemoglobinController.text),
        'hbs_ag': int.parse(
            _hbsAgController.text.isEmpty ? '0' : _hbsAgController.text),
        'hcv_ab': int.parse(
            _hcvAbController.text.isEmpty ? '0' : _hcvAbController.text),
        'mp_ict': int.parse(
            _mpIctController.text.isEmpty ? '0' : _mpIctController.text),
        'retro_test': int.parse(
            _retroController.text.isEmpty ? '0' : _retroController.text),
        'vdrl_test': int.parse(
            _vdrlController.text.isEmpty ? '0' : _vdrlController.text),
        'total': _calculateTotal(),
      };

      await service.updateSpecialEvent(widget.event['id'].toString(), data);

      Navigator.pop(context);
      widget.onUpdated();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ထူးခြားဖြစ်စဉ် အောင်မြင်စွာ ပြင်ဆင်ပြီးပါပြီ'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit, color: primaryColor),
          const SizedBox(width: 8),
          const Text('ထူးခြားဖြစ်စဉ် ပြင်ဆင်မည်'),
        ],
      ),
      content: SingleChildScrollView(
        child: Container(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Lab Name
                TextFormField(
                  controller: _labNameController,
                  decoration: const InputDecoration(
                    labelText: 'Lab Name *',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lab Name ဖြည့်သွင်းပါ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date Picker
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(_selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Test fields in a grid
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: [
                    _buildTestField('Haemoglobin', _haemoglobinController),
                    _buildTestField('HBs Ag', _hbsAgController),
                    _buildTestField('HCV Ab', _hcvAbController),
                    _buildTestField('MP ICT', _mpIctController),
                    _buildTestField('Retro', _retroController),
                    _buildTestField('VDRL', _vdrlController),
                  ],
                ),
                const SizedBox(height: 16),

                // Total display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'စုစုပေါင်း',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _calculateTotal().toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('မလုပ်တော့ပါ'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'သိမ်းမည်',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }

  Widget _buildTestField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {}); // Update total
      },
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          if (int.tryParse(value) == null) {
            return 'ကိန်းဂဏန်းသာ';
          }
        }
        return null;
      },
    );
  }
}
