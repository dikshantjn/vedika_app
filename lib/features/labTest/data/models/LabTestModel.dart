class LabTestModel {
  final String id;
  final String name;
  final double price;

  LabTestModel({required this.id, required this.name, required this.price});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is LabTestModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
