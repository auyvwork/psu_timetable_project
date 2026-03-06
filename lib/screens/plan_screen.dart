import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../viewmodels/plan_viewmodel.dart';

class AcademicPlanScreen extends StatefulWidget {
  const AcademicPlanScreen({super.key});

  @override
  State<AcademicPlanScreen> createState() => _AcademicPlanScreenState();
}

class _AcademicPlanScreenState extends State<AcademicPlanScreen> {
  final AcademicPlanViewModel _viewModel = AcademicPlanViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onStateChange);
    _loadData();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadData() async {
    try {
      await _viewModel.fetchPlan();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Ошибка обновления данных"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<String, List<Discipline>> groupedPlan = _viewModel.groupedPlan;
    final bool isLoading = _viewModel.isLoading;

    if (isLoading && groupedPlan.isEmpty) {
      return const Center(child: CupertinoActivityIndicator(radius: 15));
    }

    if (groupedPlan.isEmpty) {
      return _buildEmptyState(theme);
    }

    final List<String> semesters = groupedPlan.keys.toList();

    return DefaultTabController(
      length: semesters.length,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 8),
          _buildSemesterTabs(theme, semesters),
          Expanded(
            child: TabBarView(
              children: semesters.map((String sem) {
                final List<Discipline> items = groupedPlan[sem] ?? <Discipline>[];
                return RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: <Widget>[
                      _buildSemesterSection(theme, sem, items),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Column(
          children: [
            Icon(CupertinoIcons.doc_text_search,
                size: 60, color: theme.colorScheme.primary.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              "Учебный план пуст",
              style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant
              ),
            ),
            const SizedBox(height: 8),
            Text("Потяните вниз для загрузки",
                style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildSemesterSection(
    ThemeData theme,
    String title,
    List<Discipline> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 16, bottom: 6),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.3),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: items.map((Discipline discipline) {
              final bool isLast = items.last == discipline;
              return Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            discipline.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            _buildBadge(
                              theme,
                              _shortenControlType(discipline.controlType),
                              isPrimary: true,
                            ),
                            const SizedBox(height: 3),
                            _buildBadge(
                              theme,
                              '${discipline.totalHours} ч.',
                              isPrimary: false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: theme.colorScheme.outlineVariant.withOpacity(0.2),
                      indent: 12,
                      endIndent: 12,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildSemesterTabs(ThemeData theme, List<String> semesters) {
    final ColorScheme colorScheme = theme.colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelMedium,
        indicator: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.6),
          ),
        ),
        tabs: semesters
            .map(
              (String title) => Tab(
                text: title,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildBadge(ThemeData theme, String text, {required bool isPrimary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPrimary
            ? theme.colorScheme.primaryContainer.withOpacity(0.4)
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: isPrimary ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  String _shortenControlType(String type) {
    final t = type.toLowerCase();
    if (t.contains("дифференцированный зачет")) return "Дифф. зачет";
    if (t.contains("курсовая работа")) return "Курсовая";
    if (t.contains("экзамен")) return "Экзамен";
    if (t.contains("зачет")) return "Зачет";
    return type;
  }
}