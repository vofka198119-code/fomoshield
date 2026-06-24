import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vibrationEnabled = true;
  bool _soundEnabled = true;
  bool _saveToGallery = false;
  bool _autoCopy = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: 'Scanner'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              SwitchListTile(
                title: const Text('Vibration on scan'),
                value: _vibrationEnabled,
                onChanged: (v) => setState(() => _vibrationEnabled = v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Sound on scan'),
                value: _soundEnabled,
                onChanged: (v) => setState(() => _soundEnabled = v),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Auto-copy to clipboard'),
                value: _autoCopy,
                onChanged: (v) => setState(() => _autoCopy = v),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Storage'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              SwitchListTile(
                title: const Text('Save to gallery'),
                subtitle: const Text('Scan screenshots'),
                value: _saveToGallery,
                onChanged: (v) => setState(() => _saveToGallery = v),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'About'),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              ListTile(
                title: const Text('Version'),
                trailing: Text(
                  '1.0.0',
                  style: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Developer'),
                trailing: Text(
                  'ScanCo Team',
                  style: GoogleFonts.inter(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}
