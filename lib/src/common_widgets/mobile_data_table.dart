import 'package:flutter/material.dart';

/// Mobile-optimized data table with horizontal scrolling
class MobileDataTable extends StatelessWidget {
  final List<MobileDataColumn> columns;
  final List<MobileDataRow> rows;
  final bool showCheckbox;
  final ValueChanged<Set<int>>? onSelectChanged;
  final Set<int> selectedRows;
  final VoidCallback? onSelectAll;
  final bool sortAscending;
  final int? sortColumnIndex;
  final EdgeInsetsGeometry? padding;
  
  const MobileDataTable({
    Key? key,
    required this.columns,
    required this.rows,
    this.showCheckbox = false,
    this.onSelectChanged,
    this.selectedRows = const {},
    this.onSelectAll,
    this.sortAscending = true,
    this.sortColumnIndex,
    this.padding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortAscending: sortAscending,
          sortColumnIndex: sortColumnIndex,
          showCheckboxColumn: showCheckbox,
          columns: columns.map((column) {
            return DataColumn(
              label: Text(
                column.label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: column.numeric,
              onSort: column.onSort,
            );
          }).toList(),
          rows: rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            
            return DataRow(
              selected: selectedRows.contains(index),
              onSelectChanged: showCheckbox
                  ? (selected) {
                      final newSelection = Set<int>.from(selectedRows);
                      if (selected ?? false) {
                        newSelection.add(index);
                      } else {
                        newSelection.remove(index);
                      }
                      onSelectChanged?.call(newSelection);
                    }
                  : null,
              cells: row.cells.map((cell) {
                return DataCell(
                  cell.child,
                  onTap: cell.onTap,
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Mobile data column model
class MobileDataColumn {
  final String label;
  final bool numeric;
  final void Function(int, bool)? onSort;
  
  const MobileDataColumn({
    required this.label,
    this.numeric = false,
    this.onSort,
  });
}

/// Mobile data row model
class MobileDataRow {
  final List<MobileDataCell> cells;
  
  const MobileDataRow({
    required this.cells,
  });
}

/// Mobile data cell model
class MobileDataCell {
  final Widget child;
  final VoidCallback? onTap;
  
  const MobileDataCell({
    required this.child,
    this.onTap,
  });
}

/// Alternative card-based data view for mobile
class MobileCardDataView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final String? emptyMessage;
  final Widget? emptyIcon;
  final bool isLoading;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  
  const MobileCardDataView({
    Key? key,
    required this.items,
    required this.itemBuilder,
    this.emptyMessage,
    this.emptyIcon,
    this.isLoading = false,
    this.scrollController,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            emptyIcon ?? Icon(
              Icons.inbox,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage ?? 'No data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      controller: scrollController,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return itemBuilder(context, items[index], index);
      },
    );
  }
}

/// Expandable data row for detailed view
class ExpandableDataRow extends StatefulWidget {
  final Widget header;
  final Widget content;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? expandedColor;
  
  const ExpandableDataRow({
    Key? key,
    required this.header,
    required this.content,
    this.initiallyExpanded = false,
    this.padding,
    this.backgroundColor,
    this.expandedColor,
  }) : super(key: key);
  
  @override
  State<ExpandableDataRow> createState() => _ExpandableDataRowState();
}

class _ExpandableDataRowState extends State<ExpandableDataRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late bool _isExpanded;
  
  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _isExpanded 
            ? (widget.expandedColor ?? Colors.grey.shade50)
            : (widget.backgroundColor ?? Colors.white),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(child: widget.header),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                    child: const Icon(Icons.expand_more),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: widget.content,
            ),
          ),
        ],
      ),
    );
  }
}