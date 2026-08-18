/// One comparison table row. Empty values mean "no data" (never invented).
class CompareRowModel {
  const CompareRowModel({
    required this.label,
    required this.valueA,
    required this.valueB,
  });

  final String label;
  final String valueA;
  final String valueB;

  bool get hasAnyValue => valueA.trim().isNotEmpty || valueB.trim().isNotEmpty;
}
