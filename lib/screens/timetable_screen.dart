import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../viewmodels/timetable_viewmodel.dart';
import '../widgets/lesson_card.dart';

class TimetableScreen extends StatefulWidget {
  final Function({required String subtitle, IconData? icon, VoidCallback? onPressed})? onHeaderUpdate;
  const TimetableScreen({super.key, this.onHeaderUpdate});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with SingleTickerProviderStateMixin {
  final TimetableViewModel _viewModel = TimetableViewModel();
  late TabController _tabController;
  late List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    _dates = _viewModel.generateDates();
    _tabController = TabController(length: _dates.length, vsync: this);

    _tabController.addListener(_handleTabChange);
    _viewModel.addListener(_updateState);
    _viewModel.initFetch();

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeader());
  }

  void _handleTabChange() {
    if (mounted) {
      _updateHeader();
      if (!_tabController.indexIsChanging) {
        _viewModel.autoFetchNext(_tabController.index);
      }
      setState(() {});
    }
  }

  void _updateHeader() {
    final date = _dates[_tabController.index];
    String monthStr = DateFormat('LLLL yyyy', 'ru_RU').format(date);
    monthStr = monthStr[0].toUpperCase() + monthStr.substring(1);

    widget.onHeaderUpdate?.call(
      subtitle: monthStr,
      icon: Icons.calendar_month_rounded,
      onPressed: () => _showDatePicker(context),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dates[_tabController.index],
      firstDate: _dates.first,
      lastDate: _dates.last,
      locale: const Locale("ru", "RU"),
    );

    if (picked != null) {
      final index = _dates.indexWhere((d) =>
      d.year == picked.year && d.month == picked.month && d.day == picked.day);
      if (index != -1) {
        _tabController.animateTo(index);
      }
    }
  }

  void _updateState() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _viewModel.removeListener(_updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.secondaryContainer.withOpacity(0.5),
      appBar: AppBar(

        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicator: const BoxDecoration(),
          dividerColor: Colors.transparent,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          tabs: _dates.map((date) {
            final int index = _dates.indexOf(date);
            return ValueListenableBuilder<double>(
              valueListenable: _tabController.animation!,
              builder: (context, anim, _) {
                final isSelected = anim.round() == index;
                return Tab(
                  height: 80,
                  child: SizedBox(
                    width: 48,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? colorScheme.primary : colorScheme.surface,
                            // Добавляем тень здесь
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            DateFormat('d').format(date),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('E', 'ru_RU').format(date).toLowerCase(),
                          style: TextStyle(fontSize: 11, color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _dates.map((date) => _buildDayList(date, theme)).toList(),
      ),
    );
  }

  Widget _buildDayList(DateTime date, ThemeData theme) {
    final lessons = _viewModel.getLessonsForDate(date);
    if (lessons.isEmpty && _viewModel.isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: () => _viewModel.fetchWeek(),
      child: lessons.isEmpty
          ? ListView(children: [SizedBox(height: 400, child: Center(child: Text("Занятий нет", style: theme.textTheme.bodyMedium)))])
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lessons.length,
        itemBuilder: (context, i) => LessonCard(
          name: lessons[i].name,
          room: lessons[i].room,
          teacher: lessons[i].teacher,
          startTime: lessons[i].startTime,
          endTime: lessons[i].endTime,
          date: lessons[i].date,
          link: lessons[i].link,
        ),
      ),
    );
  }
}