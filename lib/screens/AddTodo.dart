import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddTodo extends StatefulWidget {
  const AddTodo({
    super.key,
    this.taskId,
    this.initialTitle,
    this.initialDescription,
    this.initialPriority,
    this.initialDueDate, 
    this.initialCategory,
  });

  final String? taskId;
  final String? initialTitle;
  final String? initialDescription;
  final String? initialPriority;
  final Timestamp? initialDueDate;
  final String? initialCategory;

  @override
  _AddTodoState createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String uid = '';
  bool isEditMode = false; // Flag to check if we are editing an existing task
  bool isLoading = false; // Loading state for the dialog

  // Priority and Due Date
  String selectedPriority = 'Medium';
  DateTime? selectedDueDate;

  @override
  void initState() {
    super.initState();
    getuid();

    // Determine if we are in edit mode based on the presence of taskId
    isEditMode = widget.taskId != null;

    // Initialize controllers with initial values if in edit mode
    titleController = TextEditingController(text: widget.initialTitle ?? '');
    descriptionController =
        TextEditingController(text: widget.initialDescription ?? '');

    // Initialize priority and due date if in edit mode
    selectedPriority = widget.initialPriority ?? 'Medium';
    selectedDueDate = widget.initialDueDate?.toDate();
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Fetch the current user's UID
  getuid() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser; 
    setState(() {
      uid = user!.uid;
    });
  }

  // Function to pick a due date
  Future<void> pickDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDueDate) {
      setState(() {
        selectedDueDate = picked;
      });
    }
  }

  // Function to get color based on priority
  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Update an existing task in the database
  Future<void> updateTaskInDatabase() async {
    if (titleController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Title cannot be empty');
      return;
    }

    setState(() {
      isLoading = true; // Show loading indicator
    });
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(uid)
          .collection('userTasks')
          .doc(widget.taskId)
          .update({
        'title': titleController.text,
        'description': descriptionController.text,
        'priority': selectedPriority,
        'dueDate': selectedDueDate != null
            ? Timestamp.fromDate(selectedDueDate!)
            : null,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task Updated Successfully')),
      );
      setState(() {
        isLoading = false; // Hide loading indicator
      });
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task: $e')),
      );
    }
  }

  // Add a new task to the database
  Future<void> addTaskToDatabase() async {
    if (titleController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Title cannot be empty');
      return;
    }
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(uid)
          .collection('userTasks')
          .add({
        'title': titleController.text,
        'description': descriptionController.text,
        'priority': selectedPriority,
        'dueDate': selectedDueDate != null
            ? Timestamp.fromDate(selectedDueDate!)
            : null,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Fluttertoast.showToast(msg: 'Task Added Successfully');
      setState(() {
        isLoading = false; // Hide loading indicator
      });
      Navigator.pop(context); // Close the AddTodo screen
    } catch (e) {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
      Fluttertoast.showToast(msg: 'Error adding task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[700],
        title: Text(
          isEditMode ? 'Edit Todo' : 'Add Todo',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,// Align to the start
                children: [
                  SizedBox(height: 40.0),
                  Center(
                    child: Text(
                      isEditMode ? 'Edit your Task' : 'Add a New Task',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  SizedBox(height: 50.0),
                  // Title TextField
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: EdgeInsets.all(10.0),
                      hintText: 'Enter task title',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  // Description TextField
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Colors.grey.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      contentPadding: EdgeInsets.all(10.0),
                      hintText: 'Enter task description',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    maxLines: 5,
                  ),
                  SizedBox(height: 20.0),
                  // Priority Label
                  Text(
                    'Priority Level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  // Priority Selection Buttons
                  Row(
                    children: ['High', 'Medium', 'Low'].map((priority) {
                      bool isSelected = selectedPriority == priority;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedPriority = priority;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? getPriorityColor(priority).withOpacity(0.7)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(
                                color: getPriorityColor(priority),
                                width: 2.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                priority,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : getPriorityColor(priority),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.0),

                  // Due Date Picker
                  Text(
                    'Due Date (optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  // Due Date Picker
                  InkWell(
                    onTap: () => pickDueDate(context),
                    child: Container(
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Colors.grey.shade700),
                          SizedBox(width: 10.0),
                          Text(
                            selectedDueDate == null
                                ? 'No due date set'
                                : '${selectedDueDate!.day}/${selectedDueDate!.month}/${selectedDueDate!.year}',
                            style: TextStyle(
                              color: selectedDueDate == null
                                  ? Colors.grey
                                  : Colors.black87,
                              fontSize: 16.0,
                            ),
                          ),
                          Spacer(),
                          if (selectedDueDate != null)
                            IconButton(
                              icon: Icon(Icons.clear, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  selectedDueDate = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 35.0),
                  // Add/Update Button
                  Container(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () {
                        if (isEditMode) {
                          updateTaskInDatabase();
                        } else {
                          addTaskToDatabase();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade300,
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3.0,
                              ),
                            )
                          : Text(
                              isEditMode ? 'Update Todo' : 'Add Todo',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        if (isLoading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: CircularProgressIndicator(),
                ), 
              ),
        ], 
      ),
    );
  }
}
