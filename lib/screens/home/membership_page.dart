import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/membership_plan.dart';
import '../../services/cart_manager.dart';
import 'home_page.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key, required this.plan});

  final MembershipPlan plan;

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  final _price = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  void _addToCart() {
    CartManager.instance.add(widget.plan);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    return Scaffold(
      appBar: AppBar(title: Text('${plan.name} Privilege')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                plan.image,
                width: 180,
                height: 180,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                plan.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3357A4),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                '${_price.format(plan.price)} / ${plan.durationDays} hari',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Keuntungan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final benefit in plan.benefits)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF4C7FFF),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(benefit)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF4C7FFF).withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.payments_outlined, color: Color(0xFF4C7FFF)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pembayaran dilakukan secara tunai dengan menunjukkan kode QR pada kasir setelah checkout.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _addToCart,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4C7FFF),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text(
                'Masukkan ke Keranjang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
