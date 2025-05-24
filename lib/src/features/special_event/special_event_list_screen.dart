import 'package:donation/responsive.dart';
import 'package:donation/src/features/special_event/providers/special_event_provider.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class SpecialEventListScreen extends ConsumerStatefulWidget {
  const SpecialEventListScreen({Key? key, this.fromHome = false}) : super(key: key);
  static const routeName = "/special-event-list";
  final bool fromHome;

  @override
  ConsumerState<SpecialEventListScreen> createState() => _SpecialEventListScreenState();
}

class _SpecialEventListScreenState extends ConsumerState<SpecialEventListScreen> {
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
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
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
        final moreEvents = await ref.read(specialEventsProvider(nextPage).future);
        
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
            
            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: allEvents.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == allEvents.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final event = allEvents[index];
                return _buildEventCard(event);
              },
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
  
  Widget _buildEventCard(Map<String, dynamic> event) {
    final date = DateTime.parse(event['date']);
    final formattedDate = DateFormat('dd MMM yyyy').format(date);
    
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                    event['total'] ?? '0',
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event['lab_name'] ?? 'Special Event'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Date', DateFormat('dd MMM yyyy').format(DateTime.parse(event['date']))),
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
    // TODO: Implement add event dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add event feature coming soon')),
    );
  }
  
  void _showEditEventDialog(Map<String, dynamic> event) {
    // TODO: Implement edit event dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit event feature coming soon')),
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
                  allEvents.removeWhere((event) => event['id'].toString() == id);
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