import 'package:flutter/material.dart';
import '../viewmodel/herPhasesViewmodel.dart';
import '../../data/models/MensuralPredictor.dart';

class HerPhasesScreen extends StatefulWidget {
  @override
  _HerPhasesScreenState createState() => _HerPhasesScreenState();
}

class _HerPhasesScreenState extends State<HerPhasesScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _cycleController = TextEditingController();

  List<CyclePrediction> predictions = [];

  //  Date Picker
  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text =
        "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  //  Calculate Prediction
  void _calculate() {
    if (_formKey.currentState!.validate()) {
      final viewModel = HerPhasesViewModel();
      final result = viewModel.predictCycle2Months(
        name: _nameController.text,
        lastPeriodDate: _dateController.text,
        cycleLength: int.tryParse(_cycleController.text) ?? 28,
      );

      setState(() {
        predictions = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Her Phases")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 👤 Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Enter your name"),
                validator: (value) =>
                value == null || value.isEmpty ? "Name is required" : null,
              ),

              //  Last Period Date
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Last period start date",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _pickDate,
                  ),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Date is required" : null,
              ),

              //  Cycle Length
              TextFormField(
                controller: _cycleController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Cycle length (days)"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Cycle length is required";
                  }
                  final num? cycle = num.tryParse(value);
                  if (cycle == null || cycle < 20 || cycle > 40) {
                    return "Enter a valid cycle length (20–40 days)";
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              //  Button
              ElevatedButton(
                onPressed: _calculate,
                child: Text("Predict"),
              ),

              //  Predictions List
              Expanded(
                child: ListView.builder(
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    final p = predictions[index];
                    return Card(
                      child: ListTile(
                        title: Text("Cycle ${p.cycle} (${p.month})"),
                        subtitle: Text(
                          "Next Period: ${p.nextPeriod}\n"
                              "Ovulation: ${p.ovulationDate}\n"
                              "Fertile Window: ${p.fertileWindow}",
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
