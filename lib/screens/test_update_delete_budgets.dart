import 'package:flutter/material.dart';
import 'package:budgetbuddy/bloc/Data/data_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _budgetIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _alertThresholdController = TextEditingController();
  final _totalAmountController = TextEditingController();
  
  String _resultMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Budget Updating and Deleting Test Screen"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Logged in as: ${FirebaseAuth.instance.currentUser?.email ?? 'Not logged in'}",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            // Budget ID
            TextField(
              controller: _budgetIdController,
              decoration: InputDecoration(labelText: "Budget ID *"),
            ),
            SizedBox(height: 10),
            
            // Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            SizedBox(height: 10),
            
            // Category
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: "Category"),
            ),
            SizedBox(height: 10),
            
            // Alert Threshold
            TextField(
              controller: _alertThresholdController,
              decoration: InputDecoration(labelText: "Alert Threshold"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
             
            // Update Button
            ElevatedButton(
              onPressed: _updateBudget,
              child: Text("Update Budget"),
            ),
            SizedBox(height: 20),

            // Delete Button
            ElevatedButton(
              onPressed: _deleteBudget,
              child: Text("Delete Budget"),
            ),
            SizedBox(height: 20),
            
            // Result Message
            Text(
              _resultMessage,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _resultMessage.contains('Success') ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateBudget() async {

    final budgetId = _budgetIdController.text;
    
    if (budgetId.isEmpty) {
      setState(() {
        _resultMessage = 'Budget ID is required';
      });
      return;
    }

    // Parse values
    String? name = _nameController.text.isEmpty ? null : _nameController.text;
    String? category = _categoryController.text.isEmpty ? null : _categoryController.text;
    
    double? alertThreshold;
    if (_alertThresholdController.text.isNotEmpty) {
      alertThreshold = double.tryParse(_alertThresholdController.text);
    }

    // Check if at least one field to update is provided
    if (name == null && category == null && alertThreshold == null) {
      setState(() {
        _resultMessage = 'Please provide at least one field to update';
      });
      return;
    }

    setState(() {
      _resultMessage = 'Processing updating budget ...';
    });
    
    try {

      // Refresh data first to ensure the budget is in local state
      await DataEvent.fetchFirebaseUserData(context);

      // Call update
      final result = await DataEvent.updateBudget(
        context,
        budgetId,
        name: name,
        category: category,
        alertThreshold: alertThreshold,
      );

      setState(() {
        _resultMessage = result 
            ? "Success! Budget updated successfully." 
            : "Failed to update budget.";
      });
    } catch (e) {
      setState(() {
        _resultMessage = "Error: $e";
      });
    }
  }

  void _deleteBudget() async {
    setState(() {
      _resultMessage = 'Processing deletion...';
    });

    try {
      final budgetId = _budgetIdController.text;
      
      if (budgetId.isEmpty) {
        setState(() {
          _resultMessage = 'Budget ID is required for deletion';
        });
        return;
      }

      // Refresh data first to ensure the budget is in local state
      // Important when creating a budget direclty on the firebase. so 
      // we fetch everything for this user.
      await DataEvent.fetchFirebaseUserData(context);

      // Call delete function
      final result = await DataEvent.deleteBudget(
        context,
        budgetId,
      );

      setState(() {
        _resultMessage = result 
            ? "Success! Budget deleted successfully." 
            : "Failed to delete budget.";
      });
    } catch (e) {
      setState(() {
        _resultMessage = "Error deleting: $e";
      });
    }
  }

  @override
  void dispose() {
    _budgetIdController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _alertThresholdController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }
}