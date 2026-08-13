import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/membership_plan.dart';
import '../../services/cart_manager.dart';
import '../../widgets/responsive_center.dart';
import 'home_page.dart';

class MembershipPage extends StatelessWidget {
  const MembershipPage({super.key, required this.plan});

  final MembershipPlan plan;

  Color get _accent {
    switch (plan.name) {
      case 'Gold':
        return const Color(0xFFFFC107);
      case 'Platinum':
        return const Color(0xFF7E8B92);
      default:
        return const Color(0xFF8A8A8A);
    }
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(plan.image),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.25),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${plan.name} Member',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${NumberFormat('#,###').format(plan.price)} / ${plan.durationDays} days',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsGrid() {
    return GridView.builder(
      itemCount: plan.benefits.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemBuilder: (context, index) {
        final benefit = plan.benefits[index];
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: _accent.withValues(alpha: 0.6)),
            borderRadius: BorderRadius.circular(12),
            color: _accent.withValues(alpha: 0.1),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.black87,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    benefit,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: _accent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _accent.withValues(alpha: 0.5)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Cash',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Icon(Icons.money, color: Colors.green),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context) {
    CartManager.instance.add(plan);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${plan.name} Membership added to your cart.'),
        duration: const Duration(seconds: 1),
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage(initialIndex: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${plan.name} Membership'),
        backgroundColor: _accent.withValues(alpha: 0.9),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ResponsiveCenter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCard(),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBenefitsGrid(),
                        const SizedBox(height: 20),
                        const Text(
                          'Payment Method:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _buildPaymentMethod(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.shopping_cart_checkout_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _addToCart(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
