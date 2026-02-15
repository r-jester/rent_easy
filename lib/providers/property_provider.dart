import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/booking.dart';
import '../models/property.dart';
import '../services/storage_service.dart';

class PropertyProvider extends ChangeNotifier {
  final List<Property> _properties = [];
  final List<Booking> _bookings = [];
  bool _isLoading = true;

  List<Property> get properties => List.unmodifiable(_properties);
  List<Booking> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    await _loadProperties();
    _loadBookings();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadProperties() async {
    final box = StorageService.instance.propertyStore;

    if (box.isEmpty) {
      final raw = await rootBundle.loadString('assets/data/mock_properties.json');
      final data = jsonDecode(raw) as List<dynamic>;
      for (final item in data) {
        final map = Map<String, dynamic>.from(item as Map);
        await box.put(map['id'] as String, map);
      }
    }

    _properties
      ..clear()
      ..addAll(_safeParseProperties(box.values));
  }

  void _loadBookings() {
    final box = StorageService.instance.bookingStore;
    _bookings
      ..clear()
      ..addAll(_safeParseBookings(box.values));
    _bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Property> searchProperties(String query) {
    final key = query.toLowerCase().trim();
    if (key.isEmpty) return properties;
    return _properties
        .where(
          (p) =>
              p.title.toLowerCase().contains(key) ||
              p.location.toLowerCase().contains(key),
        )
        .toList();
  }

  List<Property> filterByMaxPrice(double maxPrice) {
    return _properties.where((p) => p.pricePerMonth <= maxPrice).toList();
  }

  List<String> favoriteIds(String userId) {
    final raw = StorageService.instance.favoriteStore.get(userId);
    return raw == null ? [] : raw.cast<String>();
  }

  bool isFavorite(String userId, String propertyId) {
    return favoriteIds(userId).contains(propertyId);
  }

  Future<void> toggleFavorite(String userId, String propertyId) async {
    final current = favoriteIds(userId);
    if (current.contains(propertyId)) {
      current.remove(propertyId);
    } else {
      current.add(propertyId);
    }
    await StorageService.instance.favoriteStore.put(userId, current);
    notifyListeners();
  }

  List<Property> favoriteProperties(String userId) {
    final ids = favoriteIds(userId).toSet();
    return _properties.where((p) => ids.contains(p.id)).toList();
  }

  Future<void> addProperty(Property property) async {
    _properties.add(property);
    await StorageService.instance.propertyStore.put(property.id, property.toMap());
    notifyListeners();
  }

  Future<void> editProperty(Property property) async {
    final index = _properties.indexWhere((e) => e.id == property.id);
    if (index == -1) return;

    _properties[index] = property;
    await StorageService.instance.propertyStore.put(property.id, property.toMap());
    notifyListeners();
  }

  Future<void> deleteProperty(String propertyId) async {
    _properties.removeWhere((e) => e.id == propertyId);
    await StorageService.instance.propertyStore.delete(propertyId);
    notifyListeners();
  }

  Future<void> createBooking({
    required String propertyId,
    required String renterId,
    DateTime? moveInDate,
    int leaseMonths = 12,
    String note = '',
    String paymentId = '',
  }) async {
    final property = _properties.firstWhere((p) => p.id == propertyId);
    final booking = Booking(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      propertyId: propertyId,
      propertyTitle: property.title,
      renterId: renterId,
      ownerId: property.ownerId,
      status: 'Pending',
      monthlyRent: property.pricePerMonth,
      moveInDate: moveInDate,
      leaseMonths: leaseMonths,
      note: note.trim(),
      paymentId: paymentId,
      createdAt: DateTime.now(),
    );

    _bookings.insert(0, booking);
    await StorageService.instance.bookingStore.put(booking.id, booking.toMap());
    notifyListeners();
  }

  List<Property> ownerProperties(String ownerId) {
    return _properties.where((p) => p.ownerId == ownerId).toList();
  }

  List<Booking> ownerBookings(String ownerId) {
    return _bookings.where((b) => b.ownerId == ownerId).toList();
  }

  List<Booking> renterBookings(String renterId) {
    return _bookings.where((b) => b.renterId == renterId).toList();
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) return;
    final updated = _bookings[index].copyWith(status: status);
    _bookings[index] = updated;
    await StorageService.instance.bookingStore.put(updated.id, updated.toMap());
    notifyListeners();
  }

  List<Property> _safeParseProperties(Iterable<dynamic> rawValues) {
    final parsed = <Property>[];
    for (final raw in rawValues) {
      try {
        if (raw is! Map) continue;
        final map = <String, dynamic>{};
        raw.forEach((key, value) => map[key.toString()] = value);
        parsed.add(Property.fromMap(map));
      } catch (e) {
        debugPrint('Skipping invalid property record: $e');
      }
    }
    return parsed;
  }

  List<Booking> _safeParseBookings(Iterable<dynamic> rawValues) {
    final parsed = <Booking>[];
    for (final raw in rawValues) {
      try {
        if (raw is! Map) continue;
        final map = <String, dynamic>{};
        raw.forEach((key, value) => map[key.toString()] = value);
        parsed.add(Booking.fromMap(map));
      } catch (e) {
        debugPrint('Skipping invalid booking record: $e');
      }
    }
    return parsed;
  }
}
