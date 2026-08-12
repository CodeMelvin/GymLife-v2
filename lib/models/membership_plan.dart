class MembershipPlan {
  final String id;
  final String name;
  final int price;
  final int durationDays;
  final List<String> benefits;
  final String image;

  const MembershipPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.benefits,
    required this.image,
  });

  factory MembershipPlan.fromRTDB(String key, Map<dynamic, dynamic> data) {
    return MembershipPlan(
      id: data['id']?.toString() ?? key,
      name: data['name']?.toString() ?? '',
      price: (data['price'] is num) ? (data['price'] as num).toInt() : 0,
      durationDays: (data['durationDays'] is num)
          ? (data['durationDays'] as num).toInt()
          : 30,
      benefits: (data['benefits'] is List)
          ? List<String>.from(data['benefits'])
          : const [],
      image: data['image']?.toString() ?? '',
    );
  }
}
