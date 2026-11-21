import 'package:flutter/material.dart';
import 'widgets/bodyweight_section.dart';
import 'widgets/data_section.dart';
import 'widgets/preferences_section.dart';
import 'widgets/profile_header.dart';
import 'widgets/sheets_section.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: const [
      Text('Profil', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
      SizedBox(height: 16),
      ProfileHeader(),
      SheetsSection(),
      BodyweightSection(),
      PreferencesSection(),
      DataSection(),
      SizedBox(height: 32),
    ]);
  }
}
