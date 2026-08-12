class GymLocation {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String hours;
  final String imageUrl;

  const GymLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.hours,
    required this.imageUrl,
  });

  factory GymLocation.fromRTDB(String key, Map<dynamic, dynamic> data) {
    return GymLocation(
      id: data['id']?.toString() ?? key,
      name: data['name']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      hours: data['hours']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
    );
  }
}
