class Currency {
  final String iso;
  final String name;

  const Currency({required this.iso, required this.name});

  static Currency fromJson(Map<String, dynamic> json) => Currency(
    iso: json['iso'],
    name: json['name'],
  );
}