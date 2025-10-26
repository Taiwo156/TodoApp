import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/screens/AddTodo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String uid = '';
  String searchQuery = '';
  String selectedFilter = 'All'; // 'All', 'Completed', 'Pending'
  String selectedSort = 'Date'; // 'Date', 'Priority'
  String selectedCategoryFilter = 'All'; // 'All', 'Work', 'Personal', etc.

  @override
  void initState() {
    super.initState();
    getuid();
  }

  getuid() async {
    // Fetch the current user's UID
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    setState(() {
      uid = user!.uid;
    });
  }

  // Function to toggle task completion status
  void toggleTaskCompletion(String taskId, bool currentStatus) {
    FirebaseFirestore.instance
        .collection('tasks')
        .doc(uid)
        .collection('userTasks')
        .doc(taskId)
        .update({'isCompleted': !currentStatus});
  }

  // Function to get color based on priority
  Color getPriorityColor(String? priority) {
    switch (priority) {
      case 'High':
        return Colors.red.shade100;
      case 'Medium':
        return Colors.orange.shade100;
      case 'Low':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Widget getPriorityIndicator(String? priority) {
    Color color;
    switch (priority) {
      case 'High':
        color = Colors.red;
        break;
      case 'Medium':
        color = Colors.orange;
        break;
      case 'Low':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      width: 4,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }

  //Format due date
  String formatDueDate(Timestamp? dueDate) {
    if (dueDate == null) return 'No due date';
    final date = dueDate.toDate();
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else {
      return 'In $difference days';
    }
  }

  // Get color based on due date urgency
  Color getDueDateColor(Timestamp? dueDate) {
    if (dueDate == null) return Colors.grey;
    final date = dueDate.toDate();
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return Colors.red; // Overdue
    } else if (difference <= 1) {
      return Colors.orange; // Due soon
    } else {
      return Colors.blue; // Not urgent
    }
  }

  // Get priority value for sorting
  int getPriorityValue(String? priority) {
    switch (priority) {
      case 'High':
        return 3;
      case 'Medium':
        return 2;
      case 'Low':
        return 1;
      default:
        return 0;
    }
  }

  // Filter and sort tasks based on user selection
  List<DocumentSnapshot> filterAndSortTasks(List<DocumentSnapshot> docs) {
    // Filter tasks based on search query and selected filter
    var filtered = docs.where((doc) {
      final title = doc['title'].toString().toLowerCase();
      final description = doc['description'].toString().toLowerCase();
      return title.contains(searchQuery.toLowerCase()) ||
          description.contains(searchQuery.toLowerCase());
    }).toList();

// COMPLETED filter
    if (selectedFilter == 'Completed') {
      filtered = filtered.where((doc) {
        if (!doc.data().toString().contains('isCompleted')) {
          return false; // Exclude tasks without field
        }
        return doc['isCompleted'] == true; // Only show completed
      }).toList();
    }

// PENDING filter
    if (selectedFilter == 'Pending') {
      filtered = filtered.where((doc) {
        if (!doc.data().toString().contains('isCompleted')) {
          return true; // Include old tasks (treat as pending)
        }
        return doc['isCompleted'] == false; // Only show uncompleted
      }).toList();
    }
    // Sort tasks based on selected sort option
    if (selectedSort == 'Priority') {
      filtered.sort((a, b) {
        final priorityA =
            a.data().toString().contains('priority') ? a['priority'] : 'Low';
        final priorityB =
            b.data().toString().contains('priority') ? b['priority'] : 'Low';
        return getPriorityValue(priorityB)
            .compareTo(getPriorityValue(priorityA));
      });
    } else if (selectedSort == 'Title') {
      filtered.sort(
          (a, b) => a['title'].toString().compareTo(b['title'].toString()));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Todo', style: TextStyle(color: Colors.white)),
            Text('List', style: TextStyle(color: Colors.green.shade200)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: Colors.white),
            // Show sorting options
            onSelected: (value) {
              setState(() {
                selectedSort = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Date',
                child: Text('Sort by Date'),
              ),
              PopupMenuItem(
                value: 'Priority',
                child: Text('Sort by Priority'),
              ),
              PopupMenuItem(
                value: 'Title',
                child: Text('Sort by Title'),
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.exit_to_app, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: EdgeInsets.all(12.0),
            color: Colors.grey.shade200,
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                      hintText: 'Search Tasks...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 10)),
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Pending', 'Completed'].map((filter) {
                      return Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(filter),
                          selected: selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                          selectedColor: Colors.green.shade300,
                          labelStyle: TextStyle(
                              color: selectedFilter == filter
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Work', 'Personal', 'Shopping', 'Others']
                        .map((category) {
                      bool isSelected = selectedCategoryFilter == category;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          avatar: category != 'All'
                              ? Icon(
                                  category == 'Work'
                                      ? Icons.work
                                      : category == 'Personal'
                                          ? Icons.person
                                          : category == 'Shopping'
                                              ? Icons.shopping_cart
                                              : category == 'Others'
                                                  ? Icons.category
                                                  : Icons.label,
                                  size: 20,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black54,
                                )
                              : null,
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategoryFilter = category;
                            });
                          },
                          selectedColor: category == 'Work'
                              ? Colors.blue.shade300
                              : category == 'Personal'
                                  ? Colors.purple.shade300
                                  : category == 'Shopping'
                                      ? Colors.orange.shade300
                                      : category == 'Others'
                                          ? Colors.grey.shade400
                                          : Colors.green.shade300,
                          labelStyle: TextStyle(
                            color: selectedCategoryFilter == category
                                ? Colors.white
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              // to fetch tasks from Firestore
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .doc(uid)
                  .collection('userTasks')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // Display a loading indicator while fetching data
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                // Display a message if there are no tasks
                else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No tasks available',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Tap the + button to add a new task',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  final filteredTasks = filterAndSortTasks(snapshot.data!.docs);

                  if (filteredTasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 80, color: Colors.grey.shade400),
                          SizedBox(height: 20),
                          Text(
                            'No tasks found',
                            style: TextStyle(
                                fontSize: 20, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    // to display the list of tasks
                    padding: EdgeInsets.all(8.0),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final taskDoc = filteredTasks[index];
                      final taskId = taskDoc.id;
                      final taskTitle = taskDoc['title'];
                      final taskDescription = taskDoc['description'];
                      // Handle optional fields with default values
                      final isCompleted =
                          taskDoc.data().toString().contains('isCompleted')
                              ? taskDoc['isCompleted']
                              : false;
                      final priority =
                          taskDoc.data().toString().contains('priority')
                              ? taskDoc['priority']
                              : 'Medium';
                      final dueDate =
                          taskDoc.data().toString().contains('dueDate')
                              ? taskDoc['dueDate'] as Timestamp?
                              : null;
                      final category =
                          taskDoc.data().toString().contains('category')
                              ? taskDoc['category']
                              : 'Others';

                      // Build each task item
                      return Dismissible(
                        key: Key(taskId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20.0),
                          margin: EdgeInsets.symmetric(vertical: 6.0),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              Icon(Icons.delete, color: Colors.white, size: 30),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Delete Todo'),
                                content: Text(
                                    'Are you sure you want to delete this todo?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) {
                          FirebaseFirestore.instance
                              .collection('tasks')
                              .doc(uid)
                              .collection('userTasks')
                              .doc(taskId)
                              .delete();
                        },
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 6.0),
                          color: getPriorityColor(priority),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddTodo(
                                    taskId: taskId,
                                    initialTitle: taskTitle,
                                    initialDescription: taskDescription,
                                    initialPriority: priority,
                                    initialDueDate: dueDate,
                                    initialCategory: category,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                getPriorityIndicator(priority),
                                SizedBox(width: 8),
                                Checkbox(
                                  value: isCompleted,
                                  onChanged: (value) {
                                    toggleTaskCompletion(taskId, isCompleted);
                                  },
                                  activeColor: Colors.green,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          taskTitle,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            decoration: isCompleted
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                            color: isCompleted
                                                ? Colors.grey
                                                : Colors.black87,
                                          ),
                                        ),
                                        if (taskDescription.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              taskDescription,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isCompleted
                                                    ? Colors.grey
                                                    : Colors.grey.shade700,
                                                decoration: isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                              ),
                                            ),
                                          ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 8.0),
                                          child: Wrap(
                                            spacing: 8.0,
                                            runSpacing: 4.0,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              Chip(
                                                label: Text(
                                                  category,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                backgroundColor: category ==
                                                        'Work'
                                                    ? Colors.blue
                                                    : category == 'Personal'
                                                        ? Colors.purple
                                                        : category == 'Shopping'
                                                            ? Colors.orange
                                                            : Colors.grey,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 0.0),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: priority == 'High'
                                                        ? Colors.red
                                                        : priority == 'Medium'
                                                            ? Colors.orange
                                                            : Colors.green,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  priority ?? 'Medium',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: priority == 'High'
                                                        ? Colors.red.shade700
                                                        : priority == 'Medium'
                                                            ? Colors
                                                                .orange.shade700
                                                            : Colors
                                                                .green.shade700,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              if (dueDate != null)
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      size: 12,
                                                      color: getDueDateColor(
                                                          dueDate),
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      formatDueDate(dueDate),
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          color:
                                                              getDueDateColor(
                                                                  dueDate),
                                                          fontWeight:
                                                              FontWeight.w600),
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
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Delete Todo'),
                                          content: Text(
                                              'Are you sure you want to delete this todo?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                FirebaseFirestore.instance
                                                    .collection('tasks')
                                                    .doc(uid)
                                                    .collection('userTasks')
                                                    .doc(taskId)
                                                    .delete();
                                              },
                                              child: Text('Delete'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.delete, color: Colors.red),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the AddTodo screen
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddTodo()));
        },
        backgroundColor: Colors.green.shade300,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(Icons.add),
      ),
    );
  }
}
