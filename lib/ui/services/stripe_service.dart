
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_unity_widget_example/ui/utils/snackbar_utils.dart';
import '../constants/libraries/app_libraries.dart';

class SubscriptionPlan {
  final String id;
  final String name;
  final String price;
  final int amount;      // amount in cents — $4.99 = 499
  final String currency;
  final List<String> features;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.amount,
    this.currency = 'usd',
    required this.features,
  });
}


class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();
  Map<String, dynamic>? info=null;
  // ⚠️ TEST KEYS ONLY — replace before production
  static const String _publishableKey = 'pk_test_51R7ZUyQ6ryEcmultaxHXmqu3lT8fYf6K0BpkOQjl42YHcuUGWYIVcQVhGyzt4lVkLIG2ooWzNuD8qeUNCesYgfXU00msjm0lwP';
  static const String _secretKey      = 'sk_test_51R7ZUyQ6ryEcmultKKlUINhk84BGELUfNK65dqGSShXENFVZMzMgxkQkKdDjQOJFHMPDpZU2qhonibhrwHd8q46K00WtQTD7A2';

  static const String _subIdKey        = 'subscription_id';
  static const String _subPlanKey      = 'subscription_plan';
  static const String _subActiveKey    = 'subscription_active';
  static const String _subStartDateKey = 'subscription_start_date';
  static const String _subEndDateKey   = 'subscription_end_date';  // 30 days from start
  static const String _subRenewKey     = 'subscription_renew_date';

  List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      id: 'premium-year',
      name: 'Premium Yearly',
      price: '\$20.99/year',
      amount: 2099,
      features: ['5 Projects', 'Gallery Access', 'Export JSON'],
    ),
    SubscriptionPlan(
      id: 'premium-month',
      name: 'Premium Monthly',
      price: '\$4.99/month',
      amount: 499,
      features: ['5 Projects', 'Gallery Access', 'Export JSON'],
    ),
    SubscriptionPlan(
      id: 'pro-year',
      name: 'Yearly Plan',
      price: '\$50.99/year',
      amount: 5099,
      features: [
        'Unlimited Projects',
        'Gallery Access',
        'Export JSON',
        'Snapshots',
        'Priority Support',
      ],
    ),
    SubscriptionPlan(
      id: 'pro-month',
      name: 'Monthly Plan',
      price: '\$9.99/month',
      amount: 999,
      features: [
        'Unlimited Projects',
        'Gallery Access',
        'Export JSON',
        'Snapshots',
        'Priority Support',
      ],
    ),
  ];

  void init() async {
    try {
      Stripe.publishableKey = _publishableKey;
      Stripe.merchantIdentifier = "merchant.com.auto.planner";
      
      final result = await getSubscriptionInfo();
      if (result != null) {
        info = result;
      }
    } catch (e) {
      print('⚠️ Stripe init error: $e');
    }
  }

  // ⚠️ SECURITY WARNING: Creating PaymentIntents on the client using the Secret Key is insecure.
  // In a production app, this should be done on your backend server.
  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );

      if (response.statusCode != 200) {
        print('Stripe API error: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      return data['client_secret'] as String;
    } catch (e) {
      print('Payment Intent error: $e');
      return null;
    }
  }

  Future<bool> subscribe({required SubscriptionPlan plan}) async {
    try {
      final clientSecret = await _createPaymentIntent(plan.amount, plan.currency);
      if (clientSecret == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppSnackbars.error(title: 'Error', message: 'Could not initialize payment. Please try again later.');
        });
        return false;
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'AutoPlan 3D',
          paymentIntentClientSecret: clientSecret,
          style: Get.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Colors.blueAccent.shade400,
              background: Get.isDarkMode ? const Color(0xFF1F2937) : Colors.white,
            ),
            shapes: const PaymentSheetShape(borderRadius: 12),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      await saveSubscription(plan: plan);
      
      // Update local info state
      info = await getSubscriptionInfo();
      
      return true;
    } on StripeException catch (e) {
      if (e.error.code != FailureCode.Canceled) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppSnackbars.error(title: 'Payment Failed', message: e.error.message ?? 'Payment was unsuccessful');
        });
      }
      return false;
    } catch (e) {
      print('Subscription error: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSnackbars.error(title: 'Error', message: 'An unexpected error occurred.');
      });
      return false;
    }
  }

  // ── Subscribe ─────────────────────────────────────────────────────────────

  // ── Cancel (local only for test) ──────────────────────────────────────────

  Future<void> cancelSubscription() async {
    await _clearSubscription();
  }

  // ── Status ────────────────────────────────────────────────────────────────

  Future<bool> isSubscribed() async {
    final prefs = await SharedPreferences.getInstance();

    final isActive = prefs.getBool(_subActiveKey) ?? false;
    if (!isActive) return false;

    // Check if subscription has expired
    final endDateStr = prefs.getString(_subEndDateKey);
    if (endDateStr == null) return false;

    final endDate = DateTime.parse(endDateStr);
    final now     = DateTime.now();

    if (now.isAfter(endDate)) {
      // Auto-expire — clear subscription
      await _clearSubscription();
      return false;
    }

    return true;
  }

  Future<String?> currentPlanId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_subPlanKey);
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> saveSubscription({required SubscriptionPlan plan}) async {
    // ✅ Wipe any previous subscription first
    await _clearSubscription();  // <-- add this line

    final prefs = await SharedPreferences.getInstance();
    final now   = DateTime.now();
    final isYear = plan.id.endsWith('year');
    final end    = now.add(Duration(days: isYear ? 365 : 30));

    debugPrint('💾 plan=${plan.id} | isYear=$isYear | ends=$end');

    await prefs.setString(_subPlanKey,      plan.id);
    await prefs.setBool  (_subActiveKey,    true);
    await prefs.setString(_subStartDateKey, now.toIso8601String());
    await prefs.setString(_subEndDateKey,   end.toIso8601String());
    await prefs.setString(_subRenewKey,     end.toIso8601String());
    final result=await getSubscriptionInfo();
    if(result!=null){
      info=result;
    }
  }
  Future<Map<String, dynamic>?> getSubscriptionInfo() async {
    final prefs = await SharedPreferences.getInstance();

    final isActive = await isSubscribed();
    if (!isActive) return null;

    final startStr = prefs.getString(_subStartDateKey);
    final endStr   = prefs.getString(_subEndDateKey);
    final renewStr = prefs.getString(_subRenewKey);
    final planId   = prefs.getString(_subPlanKey);

    if (startStr == null || endStr == null) return null;

    final endDate = DateTime.parse(endStr);
    final now     = DateTime.now();
    final daysLeft = endDate.difference(now).inDays;

    return {
      'planId':    planId,
      'startDate': DateTime.parse(startStr),
      'endDate':   endDate,
      'renewDate': renewStr != null ? DateTime.parse(renewStr) : null,
      'daysLeft':  daysLeft,
      'isActive':  true, 
    };
  }
  Future<void> _clearSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_subIdKey);
    await prefs.remove(_subPlanKey);
    await prefs.remove(_subStartDateKey);
    await prefs.remove(_subEndDateKey);
    await prefs.remove(_subRenewKey);
    await prefs.setBool(_subActiveKey, false);
  }
}