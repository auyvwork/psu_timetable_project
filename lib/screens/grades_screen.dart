import 'package:flutter/material.dart';
import '../models/grade.dart';
import '../viewmodels/grades_viewmodel.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final GradesViewModel _viewModel = GradesViewModel();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _viewModel.selectedTerm - 1);
    _viewModel.addListener(_onStateChange);
    _viewModel.fetchGrades(quiet: true);
  }

  void _onStateChange() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onStateChange);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: <Widget>[
          const SizedBox(height: 8),
          _buildSlidingSelector(theme),
          Expanded(
            child: (_viewModel.isLoading &&
                    _viewModel.getDisciplinesForTerm(1).isEmpty &&
                    _viewModel.getDisciplinesForTerm(2).isEmpty)
                ? const Center(child: CircularProgressIndicator.adaptive())
                : PageView(
                    controller: _pageController,
                    onPageChanged: (int index) =>
                        _viewModel.setTerm(index + 1),
                    children: <Widget>[
                      _buildGradesListForTerm(theme, 1),
                      _buildGradesListForTerm(theme, 2),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradesListForTerm(ThemeData theme, int term) {
    final List<DisciplineGrades> list =
        _viewModel.getDisciplinesForTerm(term);

    if (list.isEmpty && !_viewModel.isLoading) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        _viewModel.setTerm(term);
        await _viewModel.fetchGrades(quiet: false);
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) =>
            _buildDisciplineCard(theme, list[index]),
      ),
    );
  }

  Widget _buildSlidingSelector(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment: _viewModel.selectedTerm == 1 ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: (MediaQuery.of(context).size.width - 28) / 2 - 4,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
            ),
          ),
          Row(
            children: [
              _selectorButton(1, "1 семестр"),
              _selectorButton(2, "2 семестр"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _selectorButton(int term, String label) {
    final theme = Theme.of(context);
    final isSelected = _viewModel.selectedTerm == term;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _viewModel.setTerm(term);
          _pageController.animateToPage(
            term - 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
          );
        },
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildDisciplineCard(ThemeData theme, DisciplineGrades disc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.4),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(disc.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (disc.currentTotalPoints / 100).clamp(0.0, 1.0),
                minHeight: 7,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                    disc.currentTotalPoints >= 60 ? Colors.green.withOpacity(0.7) : theme.colorScheme.primary
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Баллы: ${disc.currentTotalPoints.toStringAsFixed(1)} / 100",
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        children: [
          const Divider(height: 1),
          ...disc.items.map((item) => _buildGradeDetail(theme, item)),
        ],
      ),
    );
  }

  Widget _buildGradeDetail(ThemeData theme, GradeItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.theme, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _badge(theme, item.workType),
                    const SizedBox(width: 8),
                    Text(item.date, style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, color: theme.colorScheme.outline)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.mark.isEmpty ? "—" : item.mark,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
              Text("из ${item.maxRating}", style: theme.textTheme.labelSmall?.copyWith(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text.toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(fontSize: 8, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_graph_rounded, size: 64, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text("Оценок еще нет", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}