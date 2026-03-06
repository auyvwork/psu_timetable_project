import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../viewmodels/timetable_viewmodel.dart';
import '../widgets/lesson_card.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key, this.onHeaderUpdate});

  final void Function({
    required String subtitle,
    IconData? icon,
    VoidCallback? onPressed,
  })? onHeaderUpdate;

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _tabAnimDuration = Duration(milliseconds: 200);

  final TimetableViewModel _viewModel = TimetableViewModel();
  late final TabController _tabController;
  late final List<DateTime> _dates;

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

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _viewModel.removeListener(_updateState);
    super.dispose();
  }

  void _handleTabChange() {
    if (!mounted) return;

    _updateHeader();
    if (!_tabController.indexIsChanging) {
      _viewModel.autoFetchNext(_tabController.index);
    }
    setState(() {});
  }

  void _updateHeader() {
    final DateTime date = _dates[_tabController.index];
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
      locale: const Locale('ru', 'RU'),
    );

    if (picked == null) return;

    final int index = _dates.indexWhere(
      (DateTime d) =>
          d.year == picked.year &&
          d.month == picked.month &&
          d.day == picked.day,
    );
    if (index != -1) {
      _tabController.animateTo(index);
    }
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colorScheme.secondaryContainer.withOpacity(0.5),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: const BoxDecoration(),
              dividerColor: Colors.transparent,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              tabs: List<Widget>.generate(_dates.length, (int index) {
                final DateTime date = _dates[index];
                return AnimatedBuilder(
                  animation: _tabController.animation!,
                  builder: (BuildContext context, Widget? _) {
                    final int currentIndex =
                        (_tabController.animation?.value ?? 0).round();
                    final bool isSelected = currentIndex == index;

                    return Tab(
                      height: 80,
                      child: SizedBox(
                        width: 48,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            AnimatedContainer(
                              duration: _tabAnimDuration,
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.surface,
                                boxShadow: <BoxShadow>[
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
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('E', 'ru_RU')
                                  .format(date)
                                  .toLowerCase(),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _dates
            .map((DateTime date) => _buildDayList(date, theme))
            .toList(),
      ),
    );
  }

  Widget _buildDayList(DateTime date, ThemeData theme) {
    final lessons = _viewModel.getLessonsForDate(date);
    if (lessons.isEmpty && _viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => _viewModel.fetchWeek(),
      child: lessons.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: <Widget>[
                SizedBox(
                  height: 400,
                  child: Center(
                    child: Text(
                      'Занятий нет',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: lessons.length,
              itemBuilder: (BuildContext context, int i) {
                final lesson = lessons[i];
                return LessonCard(
                  name: lesson.name,
                  room: lesson.room,
                  teacher: lesson.teacher,
                  startTime: lesson.startTime,
                  endTime: lesson.endTime,
                  date: lesson.date,
                  link: lesson.link,
                );
              },
            ),
    );
  }
}