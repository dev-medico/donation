import 'package:donation/src/features/donation_member/data/search_member_repository.dart';
import 'package:donation/src/features/donation_member/domain/donor_eligibility.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/ui/blood_chip.dart';
import 'package:flutter/material.dart';

class DonorSearchResults extends StatelessWidget {
  const DonorSearchResults({
    super.key,
    required this.members,
    required this.analysis,
    required this.filteredTotal,
    required this.selectedLevel,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onSelectedLevel,
    required this.onClearFilters,
    required this.onLoadMore,
    required this.onOpenActions,
    required this.onEdit,
    this.loadMoreError,
  });

  final List<Member> members;
  final SearchMemberAnalysis? analysis;
  final int filteredTotal;
  final DonorEligibilityLevel? selectedLevel;
  final bool hasMore;
  final bool isLoadingMore;
  final ValueChanged<DonorEligibilityLevel?> onSelectedLevel;
  final VoidCallback onClearFilters;
  final VoidCallback onLoadMore;
  final ValueChanged<Member> onOpenActions;
  final ValueChanged<Member> onEdit;
  final String? loadMoreError;

  @override
  Widget build(BuildContext context) {
    // Use the backend's Bangkok analysis date so page filtering, counters, and
    // card colours cannot disagree around midnight or on a mis-set device.
    final classificationDate = analysis?.calculatedOn;
    final entries = members
        .map((member) => _DonorEntry(
              member,
              DonorEligibility.fromMember(member, now: classificationDate),
            ))
        .toList(growable: false);

    final serverAnalysis = analysis;
    final counts = <DonorEligibilityLevel, int>{
      DonorEligibilityLevel.eligible: serverAnalysis?.green ?? 0,
      DonorEligibilityLevel.caution: serverAnalysis?.yellow ?? 0,
      DonorEligibilityLevel.disabled: serverAnalysis?.red ?? 0,
    };
    final globalTotal = serverAnalysis?.total ?? filteredTotal;
    final isPartial = entries.length < filteredTotal;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showDesktopRows = constraints.maxWidth >= 900;
        return Column(
          children: [
            _DirectorySummary(
              total: globalTotal,
              counts: counts,
              selectedLevel: selectedLevel,
              onSelected: onSelectedLevel,
            ),
            if (isPartial || selectedLevel != null) ...[
              const SizedBox(height: 4),
              _LoadedCountCaption(
                loaded: entries.length,
                filteredTotal: filteredTotal,
                selectedLevel: selectedLevel,
              ),
            ],
            SizedBox(height: showDesktopRows ? 10 : 3),
            if (showDesktopRows) ...[
              const _DesktopHeader(),
              const SizedBox(height: 6),
            ],
            Expanded(
              child: entries.isEmpty
                  ? _FilteredEmptyState(
                      onClear: selectedLevel == null
                          ? onClearFilters
                          : () => onSelectedLevel(null),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.extentAfter < 320 &&
                            hasMore &&
                            !isLoadingMore) {
                          onLoadMore();
                        }
                        return false;
                      },
                      child: ListView.separated(
                        key: const ValueKey('all-donor-results'),
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: entries.length +
                            ((hasMore || isLoadingMore || loadMoreError != null)
                                ? 1
                                : 0),
                        separatorBuilder: (_, __) => SizedBox(
                          height: showDesktopRows ? 8 : 3,
                        ),
                        itemBuilder: (context, index) {
                          if (index == entries.length) {
                            return _PaginationFooter(
                              isLoading: isLoadingMore,
                              hasError: loadMoreError != null,
                              onRetry: onLoadMore,
                            );
                          }

                          final entry = entries[index];
                          if (showDesktopRows) {
                            return _DesktopDonorRow(
                              entry: entry,
                              onOpenActions: () => onOpenActions(entry.member),
                              onEdit: () => onEdit(entry.member),
                            );
                          }
                          return _MobileDonorCard(
                            entry: entry,
                            onOpenActions: () => onOpenActions(entry.member),
                            onEdit: () => onEdit(entry.member),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _LoadedCountCaption extends StatelessWidget {
  const _LoadedCountCaption({
    required this.loaded,
    required this.filteredTotal,
    required this.selectedLevel,
  });

  final int loaded;
  final int filteredTotal;
  final DonorEligibilityLevel? selectedLevel;

  @override
  Widget build(BuildContext context) {
    final category = switch (selectedLevel) {
      DonorEligibilityLevel.eligible => 'လှူနိုင်သူ',
      DonorEligibilityLevel.caution => 'စစ်ဆေးရန်',
      DonorEligibilityLevel.disabled => 'ပိတ်ထားသူ',
      null => 'ကိုက်ညီသူ',
    };
    return Semantics(
      liveRegion: true,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '$category ${_formatCount(filteredTotal)} ယောက်အနက် '
            '${_formatCount(loaded)} ယောက် ပြထားသည်',
            key: const ValueKey('donor-loaded-count'),
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  const _PaginationFooter({
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
  });

  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 52,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }

    return Center(
      child: TextButton.icon(
        key: const ValueKey('load-more-donors'),
        onPressed: onRetry,
        icon: Icon(hasError ? Icons.refresh : Icons.expand_more, size: 19),
        label: Text(hasError ? 'ထပ်မံကြိုးစားမည်' : 'နောက်ထပ်ပြမည်'),
      ),
    );
  }
}

String _formatCount(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index += 1) {
    if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(',');
    buffer.write(digits[index]);
  }
  return value < 0 ? '-$buffer' : buffer.toString();
}

class _DonorEntry {
  const _DonorEntry(this.member, this.eligibility);

  final Member member;
  final DonorEligibility eligibility;
}

class _EligibilityPalette {
  const _EligibilityPalette({
    required this.background,
    required this.surface,
    required this.border,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color surface;
  final Color border;
  final Color foreground;
  final IconData icon;

  static _EligibilityPalette forLevel(DonorEligibilityLevel level) {
    switch (level) {
      case DonorEligibilityLevel.eligible:
        return const _EligibilityPalette(
          background: Color(0xFFF0FDF4),
          surface: Color(0xFFDCFCE7),
          border: Color(0xFF86EFAC),
          foreground: Color(0xFF166534),
          icon: Icons.check_circle_outline,
        );
      case DonorEligibilityLevel.caution:
        return const _EligibilityPalette(
          background: Color(0xFFFFFBEB),
          surface: Color(0xFFFEF3C7),
          border: Color(0xFFFCD34D),
          foreground: Color(0xFF854D0E),
          icon: Icons.schedule_outlined,
        );
      case DonorEligibilityLevel.disabled:
        return const _EligibilityPalette(
          background: Color(0xFFFEF2F2),
          surface: Color(0xFFFEE2E2),
          border: Color(0xFFFCA5A5),
          foreground: Color(0xFF991B1B),
          icon: Icons.block_outlined,
        );
    }
  }
}

class _DirectorySummary extends StatelessWidget {
  const _DirectorySummary({
    required this.total,
    required this.counts,
    required this.selectedLevel,
    required this.onSelected,
  });

  final int total;
  final Map<DonorEligibilityLevel, int> counts;
  final DonorEligibilityLevel? selectedLevel;
  final ValueChanged<DonorEligibilityLevel?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _AllSummaryChip(
              total: total,
              selected: selectedLevel == null,
              onTap: () => onSelected(null),
            ),
            const SizedBox(width: 5),
            _SummaryChip(
              level: DonorEligibilityLevel.eligible,
              label: 'လှူနိုင်',
              count: counts[DonorEligibilityLevel.eligible] ?? 0,
              selected: selectedLevel == DonorEligibilityLevel.eligible,
              onTap: () => onSelected(DonorEligibilityLevel.eligible),
            ),
            const SizedBox(width: 5),
            _SummaryChip(
              level: DonorEligibilityLevel.caution,
              label: 'စစ်ဆေးရန်',
              count: counts[DonorEligibilityLevel.caution] ?? 0,
              selected: selectedLevel == DonorEligibilityLevel.caution,
              onTap: () => onSelected(DonorEligibilityLevel.caution),
            ),
            const SizedBox(width: 5),
            _SummaryChip(
              level: DonorEligibilityLevel.disabled,
              label: 'ပိတ်ထား',
              count: counts[DonorEligibilityLevel.disabled] ?? 0,
              selected: selectedLevel == DonorEligibilityLevel.disabled,
              onTap: () => onSelected(DonorEligibilityLevel.disabled),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllSummaryChip extends StatelessWidget {
  const _AllSummaryChip({
    required this.total,
    required this.selected,
    required this.onTap,
  });

  final int total;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey('eligibility-filter-all'),
      button: true,
      selected: selected,
      label: 'အားလုံး ${_formatCount(total)} ယောက်',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Material(
          color: selected ? const Color(0xFF334155) : Colors.white,
          shape: StadiumBorder(
            side: BorderSide(
              color:
                  selected ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    const Icon(Icons.check, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    'အားလုံး ${_formatCount(total)}',
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF334155),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.level,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final DonorEligibilityLevel level;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _EligibilityPalette.forLevel(level);
    return Semantics(
      key: ValueKey('eligibility-filter-${level.name}'),
      button: true,
      selected: selected,
      label: '$label ${_formatCount(count)} ယောက်',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Material(
          key: ValueKey('eligibility-count-${level.name}'),
          color: selected ? palette.foreground : palette.surface,
          shape: StadiumBorder(
            side: BorderSide(
              color: selected ? palette.foreground : palette.border,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    selected ? Icons.check_circle : palette.icon,
                    size: 15,
                    color: selected ? Colors.white : palette.foreground,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$label ${_formatCount(count)}',
                    style: TextStyle(
                      color: selected ? Colors.white : palette.foreground,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.filter_alt_off_outlined,
            size: 34,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 8),
          const Text(
            'ဤအခြေအနေတွင် သွေးလှူရှင် မရှိပါ',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onClear,
            child: const Text('အားလုံး ပြန်ပြမည်'),
          ),
        ],
      ),
    );
  }
}

class _MobileDonorCard extends StatelessWidget {
  const _MobileDonorCard({
    required this.entry,
    required this.onOpenActions,
    required this.onEdit,
  });

  final _DonorEntry entry;
  final VoidCallback onOpenActions;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final member = entry.member;
    final eligibility = entry.eligibility;
    final palette = _EligibilityPalette.forLevel(eligibility.level);
    final phone = (member.phone ?? '').trim();
    final isNarrowPhone = MediaQuery.sizeOf(context).width <= 360;

    return Semantics(
      container: true,
      label: '${member.name ?? ''}, ${_memberLocation(member)}, '
          '${_statusLabel(eligibility)}',
      child: Material(
        key: ValueKey('donor-card-${member.id}'),
        color: palette.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
          side: BorderSide(color: palette.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: BloodChip(
                  bloodType: member.bloodType,
                  size: isNarrowPhone ? 36 : 38,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (member.name ?? '').trim().isEmpty
                          ? 'အမည်မရှိ'
                          : member.name!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _contactLine(member),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 1),
                    _MemberLocationLine(member: member, compact: true),
                    const SizedBox(height: 3),
                    _CompactMobileDetails(entry: entry),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: isNarrowPhone ? 92 : 98,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusBadge(
                      eligibility: eligibility,
                      maxWidth: isNarrowPhone ? 92 : 98,
                      compact: true,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _CompactActionButton(
                          tooltip: phone.isEmpty
                              ? 'ဖုန်းနံပါတ် မရှိပါ'
                              : 'ဖုန်းခေါ်မည်',
                          icon: Icons.phone_outlined,
                          onPressed: phone.isEmpty ? null : onOpenActions,
                        ),
                        const SizedBox(width: 4),
                        _CompactActionButton(
                          key: ValueKey('edit-donor-${member.id}'),
                          tooltip: eligibility.level ==
                                  DonorEligibilityLevel.disabled
                              ? 'လှူဒါန်းခွင့် ပြန်ဖွင့်ရန်'
                              : 'အခြေအနေနှင့် မှတ်ချက် ပြင်ရန်',
                          icon: eligibility.level ==
                                  DonorEligibilityLevel.disabled
                              ? Icons.lock_open_outlined
                              : Icons.edit_outlined,
                          foreground: palette.foreground,
                          background: palette.surface,
                          border: palette.border,
                          onPressed: onEdit,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactMobileDetails extends StatelessWidget {
  const _CompactMobileDetails({required this.entry});

  final _DonorEntry entry;

  @override
  Widget build(BuildContext context) {
    final eligibility = entry.eligibility;
    final palette = _EligibilityPalette.forLevel(eligibility.level);

    if (eligibility.hasRemark) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.notes_outlined, size: 14, color: palette.foreground),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  eligibility.remark,
                  key: ValueKey('donor-remark-${entry.member.id}'),
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          if (eligibility.isWaiting &&
              eligibility.level != DonorEligibilityLevel.disabled) ...[
            const SizedBox(height: 3),
            _CompactMetaLine(
              icon: Icons.event_available_outlined,
              text: '${_remainingLabel(eligibility)} ကျန် · '
                  '${_formatDate(eligibility.nextEligibleDate!)} တွင် လှူနိုင်',
              color: palette.foreground,
            ),
          ],
        ],
      );
    }

    return _CompactMetaLine(
      icon: _compactDetailIcon(eligibility),
      text: _compactDetailMessage(eligibility),
      color: palette.foreground,
    );
  }
}

class _CompactMetaLine extends StatelessWidget {
  const _CompactMetaLine({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11.25,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.foreground = const Color(0xFF334155),
    this.background = Colors.white,
    this.border = const Color(0xFFCBD5E1),
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color foreground;
  final Color background;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton.outlined(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        color: foreground,
        style: IconButton.styleFrom(
          backgroundColor: background,
          side: BorderSide(color: border),
          minimumSize: const Size(44, 44),
          maximumSize: const Size(44, 44),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFF7F1D1D),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: _HeaderLabel('သွေးလှူရှင်')),
          SizedBox(width: 18),
          Expanded(flex: 2, child: _HeaderLabel('လှူဒါန်းသည့်ရက်')),
          SizedBox(width: 18),
          Expanded(flex: 4, child: _HeaderLabel('အခြေအနေ / မှတ်ချက်')),
          SizedBox(width: 18),
          SizedBox(width: 150, child: _HeaderLabel('လုပ်ဆောင်ရန်')),
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      );
}

class _DesktopDonorRow extends StatelessWidget {
  const _DesktopDonorRow({
    required this.entry,
    required this.onOpenActions,
    required this.onEdit,
  });

  final _DonorEntry entry;
  final VoidCallback onOpenActions;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final member = entry.member;
    final eligibility = entry.eligibility;
    final palette = _EligibilityPalette.forLevel(eligibility.level);
    final phone = (member.phone ?? '').trim();

    return Semantics(
      button: true,
      label: '${member.name ?? ''}, ${_memberLocation(member)}, '
          '${_statusLabel(eligibility)}',
      child: Material(
        key: ValueKey('donor-row-${member.id}'),
        color: palette.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: palette.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpenActions,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BloodChip(bloodType: member.bloodType, size: 44),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (member.name ?? '').trim().isEmpty
                                  ? 'အမည်မရှိ'
                                  : member.name!.trim(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _contactLine(member),
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            _MemberLocationLine(member: member),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  flex: 2,
                  child: _DonationDates(eligibility: eligibility),
                ),
                const SizedBox(width: 18),
                Expanded(
                  flex: 4,
                  child: _ReasonContent(entry: entry, showDates: false),
                ),
                const SizedBox(width: 18),
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusBadge(
                        eligibility: eligibility,
                        maxWidth: 142,
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Tooltip(
                            message: phone.isEmpty
                                ? 'ဖုန်းနံပါတ် မရှိပါ'
                                : 'ဖုန်းခေါ်မည်',
                            child: IconButton.outlined(
                              onPressed: phone.isEmpty ? null : onOpenActions,
                              icon: const Icon(Icons.phone_outlined, size: 19),
                              constraints: const BoxConstraints.tightFor(
                                width: 44,
                                height: 44,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Tooltip(
                            message: eligibility.level ==
                                    DonorEligibilityLevel.disabled
                                ? 'လှူဒါန်းခွင့် ပြန်ဖွင့်ရန်'
                                : 'အခြေအနေနှင့် မှတ်ချက် ပြင်ရန်',
                            child: IconButton.outlined(
                              key: ValueKey('edit-donor-${member.id}'),
                              onPressed: onEdit,
                              color: palette.foreground,
                              icon: const Icon(Icons.edit_outlined, size: 19),
                              constraints: const BoxConstraints.tightFor(
                                width: 44,
                                height: 44,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberLocationLine extends StatelessWidget {
  const _MemberLocationLine({required this.member, this.compact = false});

  final Member member;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: compact ? 12 : 13,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            _memberLocation(member),
            key: ValueKey('donor-location-${member.id}'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 10.5 : 11,
              color: const Color(0xFF64748B),
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.eligibility,
    required this.maxWidth,
    this.compact = false,
  });

  final DonorEligibility eligibility;
  final double maxWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = _EligibilityPalette.forLevel(eligibility.level);
    return Semantics(
      label: _statusLabel(eligibility),
      child: Container(
        key: ValueKey('donor-status-${eligibility.level.name}'),
        width: maxWidth,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 3 : 5,
        ),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              palette.icon,
              size: compact ? 13 : 14,
              color: palette.foreground,
            ),
            SizedBox(width: compact ? 4 : 5),
            Expanded(
              child: Text(
                _statusLabel(eligibility),
                maxLines: compact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.foreground,
                  fontSize: compact ? 10.75 : 10.5,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonContent extends StatelessWidget {
  const _ReasonContent({required this.entry, required this.showDates});

  final _DonorEntry entry;
  final bool showDates;

  @override
  Widget build(BuildContext context) {
    final eligibility = entry.eligibility;
    final palette = _EligibilityPalette.forLevel(eligibility.level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(palette.icon, size: 17, color: palette.foreground),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                _reasonMessage(eligibility),
                style: TextStyle(
                  color: palette.foreground,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
        if (eligibility.hasRemark) ...[
          const SizedBox(height: 8),
          Container(
            key: ValueKey('donor-remark-${entry.member.id}'),
            width: double.infinity,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'မှတ်ချက်',
                  style: TextStyle(
                    color: palette.foreground,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                SelectableText(
                  eligibility.remark,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (!eligibility.hasRemark && showDates) ...[
          const SizedBox(height: 8),
          _DonationDates(eligibility: eligibility),
        ] else if (eligibility.hasRemark &&
            eligibility.isWaiting &&
            showDates) ...[
          const SizedBox(height: 8),
          _DonationDates(eligibility: eligibility),
        ],
      ],
    );
  }
}

class _DonationDates extends StatelessWidget {
  const _DonationDates({required this.eligibility});

  final DonorEligibility eligibility;

  @override
  Widget build(BuildContext context) {
    final lastDate = eligibility.lastDonationDate;
    final nextDate = eligibility.nextEligibleDate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DateLine(
          icon: Icons.history,
          label: 'နောက်ဆုံး',
          value: lastDate == null ? 'မှတ်တမ်းမရှိ' : _formatDate(lastDate),
        ),
        if (eligibility.isWaiting && nextDate != null) ...[
          const SizedBox(height: 5),
          _DateLine(
            icon: Icons.hourglass_bottom_outlined,
            label: 'ကျန်ချိန်',
            value: _remainingLabel(eligibility),
          ),
          const SizedBox(height: 5),
          _DateLine(
            icon: Icons.event_available_outlined,
            label: 'လှူနိုင်မည့်ရက်',
            value: _formatDate(nextDate),
          ),
        ],
      ],
    );
  }
}

class _DateLine extends StatelessWidget {
  const _DateLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF64748B)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            '$label — $value',
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

IconData _compactDetailIcon(DonorEligibility eligibility) {
  if (eligibility.level == DonorEligibilityLevel.disabled) {
    return Icons.block_outlined;
  }
  if (eligibility.isWaiting) return Icons.event_available_outlined;
  if (eligibility.hasInvalidLastDonationDate) return Icons.warning_amber;
  return Icons.history;
}

String _compactDetailMessage(DonorEligibility eligibility) {
  if (eligibility.level == DonorEligibilityLevel.disabled) {
    return 'လှူဒါန်းခွင့် ပိတ်ထားသည်';
  }
  if (eligibility.isWaiting && eligibility.nextEligibleDate != null) {
    return '${_remainingLabel(eligibility)} ကျန် · '
        '${_formatDate(eligibility.nextEligibleDate!)} တွင် လှူနိုင်';
  }
  if (eligibility.hasInvalidLastDonationDate) {
    return 'နောက်ဆုံးလှူဒါန်းရက်ကို စစ်ဆေးရန်';
  }
  if (eligibility.lastDonationDate == null) {
    return 'လှူဒါန်းမှတ်တမ်း မရှိသေးပါ';
  }
  return 'နောက်ဆုံး ${_formatDate(eligibility.lastDonationDate!)}';
}

String _statusLabel(DonorEligibility eligibility) {
  switch (eligibility.level) {
    case DonorEligibilityLevel.eligible:
      return 'လှူဒါန်းနိုင်';
    case DonorEligibilityLevel.disabled:
      return 'ပိတ်ထားသည်';
    case DonorEligibilityLevel.caution:
      if (eligibility.hasRemark) return 'မှတ်ချက်ရှိ';
      if (eligibility.isWaiting) return 'လ မပြည့်သေး';
      return 'ရက်စွဲစစ်ဆေးရန်';
  }
}

String _reasonMessage(DonorEligibility eligibility) {
  switch (eligibility.level) {
    case DonorEligibilityLevel.disabled:
      return 'လှူဒါန်းခွင့် ပိတ်ထားသည်။ ပြန်ဖွင့်ရန် အခြေအနေကို ပြင်ပါ။';
    case DonorEligibilityLevel.caution:
      if (eligibility.hasRemark && eligibility.isWaiting) {
        return 'မှတ်ချက်ကို စစ်ဆေးပါ · '
            '${_remainingLabel(eligibility)} ကျန်';
      }
      if (eligibility.hasRemark) return 'အောက်ပါမှတ်ချက်ကို စစ်ဆေးပါ။';
      if (eligibility.isWaiting) {
        return '${_remainingLabel(eligibility)} ကျန်';
      }
      return 'နောက်ဆုံးလှူဒါန်းသည့်ရက်ကို အတည်ပြုရန် လိုအပ်ပါသည်။';
    case DonorEligibilityLevel.eligible:
      if (eligibility.lastDonationDate == null) {
        return 'လှူဒါန်းမှတ်တမ်း မရှိသေးပါ။ ယခု လှူဒါန်းနိုင်သည်။';
      }
      return '၄ လ ပြည့်ပြီးဖြစ်၍ ယခု လှူဒါန်းနိုင်သည်။';
  }
}

String _contactLine(Member member) {
  final parts = <String>[
    if ((member.memberId ?? '').trim().isNotEmpty) member.memberId!.trim(),
    if ((member.phone ?? '').trim().isNotEmpty) member.phone!.trim(),
  ];
  return parts.isEmpty ? 'ဖုန်းနံပါတ် မရှိပါ' : parts.join(' · ');
}

String _memberLocation(Member member) {
  final raw = (member.address ?? '').trim();
  if (raw.isEmpty) return 'နေရပ် မသတ်မှတ်ထား';

  // New records use the Myanmar comma. Accept common legacy separators so
  // older addresses still expose the ward/quarter and township at a glance.
  final normalized = raw
      .replaceAll(RegExp(r'[\r\n]+'), '၊')
      .replaceAll(RegExp(r'[,;|]+'), '၊');
  final parts = normalized.split('၊').map((part) => part.trim()).where((part) {
    final lower = part.toLowerCase();
    return part.isNotEmpty && part != '-' && lower != 'n/a' && lower != 'null';
  }).toList(growable: false);

  if (parts.isEmpty) return 'နေရပ် မသတ်မှတ်ထား';
  return parts.skip(parts.length > 2 ? parts.length - 2 : 0).join(' · ');
}

String _remainingLabel(DonorEligibility eligibility) {
  final parts = <String>[
    if (eligibility.remainingMonths > 0) '${eligibility.remainingMonths} လ',
    if (eligibility.remainingDays > 0) '${eligibility.remainingDays} ရက်',
  ];
  return parts.isEmpty ? 'ယနေ့' : parts.join(' ');
}

String _formatDate(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}-${twoDigits(date.month)}-${date.year}';
}
