import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class LegalContent {
  static const String termsOfService = """
Last Updated: October 2023

1. Acceptance of Terms
By accessing and using this application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.

2. User Accounts
You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.

3. Intellectual Property
The application and its original content, features, and functionality are owned by our company and are protected by international copyright, trademark, patent, trade secret, and other intellectual property or proprietary rights laws.

4. User Content
You retain all of your ownership rights in your User Content. However, by submitting User Content to the application, you grant us a worldwide, non-exclusive, royalty-free, sublicensable and transferable license to use, reproduce, distribute, prepare derivative works of, display, and perform the User Content.

5. Prohibited Activities
You agree not to engage in any of the following prohibited activities:
- Copying, distributing, or disclosing any part of the application in any medium.
- Using any automated system, including "robots," "spiders," or "offline readers," to access the application.
- Attempting to interfere with, compromise the system integrity or security or decipher any transmissions to or from the servers running the application.

6. Termination
We may terminate or suspend your account and bar access to the application immediately, without prior notice or liability, under our sole discretion, for any reason whatsoever and without limitation, including but not limited to a breach of the Terms.

7. Limitation of Liability
In no event shall our company, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses.

8. Governing Law
These Terms shall be governed and construed in accordance with the laws, without regard to its conflict of law provisions.

9. Changes
We reserve the right, at our sole discretion, to modify or replace these Terms at any time. What constitutes a material change will be determined at our sole discretion.
""";

  static const String privacyPolicy = """
Last Updated: October 2023

1. Introduction
We value your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, and disclose information about you when you use our application.

2. Information We Collect
- Information you provide to us: We collect information you provide directly to us, such as when you create an account, update your profile, or communicate with us.
- Information we collect automatically: When you use our application, we automatically collect certain information, such as your IP address, device type, and usage patterns.

3. How We Use Information
We use the information we collect to:
- Provide, maintain, and improve our application.
- Communicate with you about products, services, offers, and events.
- Monitor and analyze trends, usage, and activities in connection with our application.
- Detect, investigate, and prevent fraudulent transactions and other illegal activities.

4. Information Sharing
We do not share your personal information with third parties except as described in this Privacy Policy:
- With your consent.
- For legal reasons, such as to comply with a subpoena or similar legal process.
- To protect our rights, your safety, or the safety of others.

5. Data Security
We take reasonable measures to help protect information about you from loss, theft, misuse and unauthorized access, disclosure, alteration and destruction.

6. Your Choices
You may update, correct or delete information about you at any time by logging into your online account or emailing us.

7. Contact Us
If you have any questions about this Privacy Policy, please contact us.
""";
}
