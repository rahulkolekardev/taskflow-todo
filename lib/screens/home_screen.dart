import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_card.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_sheet.dart';

enum FilterTab { all, today, upcoming, completed }

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FilterTab _currentTab = FilterTab.all;
  TaskCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Design TaskFlow Mobile UI',
      description: 'Finish modern gradients, glassmorphism cards and icons',
      isCompleted: true,
      priority: TaskPriority.urgent,
      category: TaskCategory.work,
      dueDate: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Task(
      id: '2',
      title: 'Review GitHub Actions CI/CD',
      description: 'Ensure automated APK build and release pipelines are green',
      isCompleted: false,
      priority: TaskPriority.high,
      category: TaskCategory.work,
      dueDate: DateTime.now().add(const Duration(hours: 2)),
    ),
    Task(
      id: '3',
      title: 'Morning 5km Run & Stretching',
      description: 'Stay active, drink 2L water and track on smartwatch',
      isCompleted: true,
      priority: TaskPriority.medium,
      category: TaskCategory.fitness,
      dueDate: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    Task(
      id: '4',
      title: 'Read 2 Chapters of Dart in Action',
      description: 'Focus on asynchronous streams and reactive programming',
      isCompleted: false,
      priority: TaskPriority.medium,
      category: TaskCategory.study,
      dueDate: DateTime.now().add(const Duration(hours: 6)),
    ),
    Task(
      id: '5',
      title: 'Weekly Grocery Shopping',
      description: 'Almond milk, organic avocados, greek yogurt, fresh coffee beans',
      isCompleted: false,
      priority: TaskPriority.low,
      category: TaskCategory.shopping,
      dueDate: DateTime.now().add(const Duration(days: 1)),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Task> get _filteredTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _tasks.where((task) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = task.title.toLowerCase().contains(query);
        final matchesDesc = task.description.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc) return false;
      }

      // Category filter
      if (_selectedCategory != null && task.category != _selectedCategory) {
        return false;
      }

      // Tab filter
      switch (_currentTab) {
        case FilterTab.all:
          return true;
        case FilterTab.today:
          return task.dueDate.isAfter(today.subtract(const Duration(seconds: 1))) &&
              task.dueDate.isBefore(tomorrow);
        case FilterTab.upcoming:
          return task.dueDate.isAfter(tomorrow) && !task.isCompleted;
        case FilterTab.completed:
          return task.isCompleted;
      }
    }).toList();
  }

  void _showAddTaskSheet([Task? taskToEdit]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => AddTaskSheet(
        taskToEdit: taskToEdit,
        onSave: (task) {
          setState(() {
            if (taskToEdit != null) {
              final index = _tasks.indexWhere((t) => t.id == task.id);
              if (index != -1) _tasks[index] = task;
            } else {
              _tasks.insert(0, task);
            }
          });
        },
      ),
    );
  }

  void _deleteTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;

    setState(() {
      _tasks.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task.title}" deleted'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppTheme.primaryCyan,
          onPressed: () {
            setState(() {
              _tasks.insert(index, task);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final filtered = _filteredTasks;
    final totalCount = _tasks.length;
    final completedCount = _tasks.where((t) => t.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text('TaskFlow'),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search_rounded),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Top Progress Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: ProgressCard(
                totalTasks: totalCount,
                completedTasks: completedCount,
              ),
            ),
          ),

          // Tab Selector (All, Today, Upcoming, Done)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTabButton('All', FilterTab.all),
                    _buildTabButton('Today', FilterTab.today),
                    _buildTabButton('Upcoming', FilterTab.upcoming),
                    _buildTabButton('Done', FilterTab.completed),
                  ],
                ),
              ),
            ),
          ),

          // Category Filters
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All Categories'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                    selectedColor: AppTheme.primaryIndigo.withOpacity(0.18),
                    checkmarkColor: AppTheme.primaryIndigo,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  const SizedBox(width: 8),
                  ...TaskCategory.values.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        avatar: Icon(cat.icon, size: 14, color: isSel ? Colors.white : cat.color),
                        label: Text(cat.label),
                        selected: isSel,
                        selectedColor: cat.color,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (val) {
                          setState(() {
                            _selectedCategory = val ? cat : null;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Task List or Empty State
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryIndigo.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.done_all_rounded,
                        size: 40,
                        color: AppTheme.primaryIndigo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty ? 'No tasks found' : 'All clear for now!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Try searching with different keywords'
                          : 'Tap the + button below to create your next task',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(left: 18, right: 18, top: 8, bottom: 90),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = filtered[index];
                    return TaskCard(
                      task: task,
                      onToggleComplete: (val) {
                        setState(() {
                          task.isCompleted = val;
                        });
                      },
                      onDelete: () => _deleteTask(task),
                      onTap: () => _showAddTaskSheet(task),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(),
        elevation: 4,
        highlightElevation: 8,
        backgroundColor: Colors.transparent,
        focusElevation: 0,
        hoverElevation: 0,
        label: Ink(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryIndigo.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'Add Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, FilterTab tab) {
    final isSelected = _currentTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryIndigo : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (widget.isDarkMode ? Colors.white60 : Colors.black54),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
