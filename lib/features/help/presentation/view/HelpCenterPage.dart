import 'package:flutter/material.dart';
import 'package:vedika_healthcare/core/constants/colorpalette/ColorPalette.dart';
import 'package:vedika_healthcare/core/navigation/MainScreen.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {'q': 'How do I book a doctor appointment?', 'a': 'Go to Clinic or Hospital, select a doctor, choose a slot and confirm.'},
      {'q': 'How can I track my medicine order?', 'a': 'Use Track Order in the Drawer or the orders tab to see live status.'},
      {'q': 'How is my data secured?', 'a': 'We follow industry best practices with encryption and strict access controls.'},
      {'q': 'What is Vedika Plus?', 'a': 'A membership that offers discounts and priority services across the app.'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: ColorPalette.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            final scope = MainScreenScope.maybeOf(context);
            if (scope != null) {
              scope.setIndex(0);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text('Help Center'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _heroCard(),
          const SizedBox(height: 16),
          _sectionHeader('Quick Help'),
          _quickActions(context),
          const SizedBox(height: 16),
          _sectionHeader('FAQs'),
          ...faqs.map((f) => _faqItem(f['q']!, f['a']!)).toList(),
          const SizedBox(height: 24),
          _sectionHeader('Contact Us'),
          _contactCard(),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorPalette.primaryColor, ColorPalette.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: ColorPalette.primaryColor.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            padding: const EdgeInsets.all(14),
            child: const Icon(Icons.support_agent, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'We\'re here to help! Browse FAQs or contact support for assistance.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87, letterSpacing: 0.2),
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    final items = [
      {'icon': Icons.receipt_long, 'label': 'Orders'},
      {'icon': Icons.medical_services_outlined, 'label': 'Health Records'},
      {'icon': Icons.star_outline, 'label': 'Membership'},
      {'icon': Icons.policy_outlined, 'label': 'Policy'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((e) => _quickActionItem(e['icon'] as IconData, e['label'] as String)).toList(),
      ),
    );
  }

  Widget _quickActionItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: ColorPalette.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: ColorPalette.primaryColor),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _faqItem(String q, String a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Icon(Icons.help_outline, color: ColorPalette.primaryColor),
        title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600)),
        children: [Text(a, style: TextStyle(color: Colors.grey[700], height: 1.4))],
      ),
    );
  }

  Widget _contactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.email_outlined, color: Colors.teal),
            title: Text('Email'),
            subtitle: Text('support@vedikahealthcare.com'),
          ),
          Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.chat_bubble_outline, color: Colors.deepPurple),
            title: Text('Live Chat'),
            subtitle: Text('Available 9:00 AM – 6:00 PM (IST)'),
          ),
          Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.call_outlined, color: Colors.indigo),
            title: Text('Phone'),
            subtitle: Text('+91 93703 20066'),
          ),
        ],
      ),
    );
  }
}


