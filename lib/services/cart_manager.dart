import 'package:flutter/foundation.dart';

import '../models/membership_plan.dart';

/// Single-item cart shared across pages (home -> cart -> invoice).
/// Kept in memory only; the membership is persisted to the database
/// when the customer confirms the payment.
class CartManager extends ChangeNotifier {
  CartManager._();
  static final CartManager instance = CartManager._();

  MembershipPlan? _item;

  MembershipPlan? get item => _item;

  void add(MembershipPlan plan) {
    _item = plan;
    notifyListeners();
  }

  void clear() {
    _item = null;
    notifyListeners();
  }
}
