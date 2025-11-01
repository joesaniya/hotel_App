import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotel_app/business_logic/app_settings_provider.dart';
import 'package:hotel_app/models/app_settings_modal.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppSettingsProvider>().fetchSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'App Settings',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: () {
              context.read<AppSettingsProvider>().refreshSettings();
            },
          ),
        ],
      ),
      body: Consumer<AppSettingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return _buildErrorState(provider.errorMessage!);
          }

          if (!provider.hasSettings) {
            return _buildEmptyState();
          }

          return _buildSettingsContent(provider);
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error Loading Settings',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AppSettingsProvider>().refreshSettings();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Settings Available',
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(AppSettingsProvider provider) {
    final settings = provider.appSettings!;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildAppVersionSection(settings),
          const SizedBox(height: 16),
          _buildAppStatusSection(settings),
          const SizedBox(height: 16),
          _buildContactSection(settings),
          const SizedBox(height: 16),
          _buildAdditionalInfoSection(settings),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAppVersionSection(AppSettings settings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.phone_android, color: Colors.blue[700]),
              ),
              const SizedBox(width: 12),
              Text(
                'App Versions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            'Android Version',
            settings.appAndroidVersion,
            Icons.android,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'iOS Version',
            settings.appIosVersion,
            Icons.apple,
            Colors.grey,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Android Force Update',
            settings.appAndroidForceUpdate ? 'Enabled' : 'Disabled',
            settings.appAndroidForceUpdate ? Icons.update : Icons.check_circle,
            settings.appAndroidForceUpdate ? Colors.orange : Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'iOS Force Update',
            settings.appIosForceUpdate ? 'Enabled' : 'Disabled',
            settings.appIosForceUpdate ? Icons.update : Icons.check_circle,
            settings.appIosForceUpdate ? Colors.orange : Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildAppStatusSection(AppSettings settings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: settings.appMaintenanceMode
                      ? Colors.red[50]
                      : Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  settings.appMaintenanceMode
                      ? Icons.construction
                      : Icons.check_circle,
                  color: settings.appMaintenanceMode
                      ? Colors.red[700]
                      : Colors.green[700],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'App Status',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: settings.appMaintenanceMode
                  ? Colors.red[50]
                  : Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: settings.appMaintenanceMode
                    ? Colors.red[200]!
                    : Colors.green[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  settings.appMaintenanceMode
                      ? Icons.warning_amber_rounded
                      : Icons.cloud_done,
                  color: settings.appMaintenanceMode
                      ? Colors.red[700]
                      : Colors.green[700],
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.appMaintenanceMode
                            ? 'Maintenance Mode'
                            : 'Operational',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: settings.appMaintenanceMode
                              ? Colors.red[900]
                              : Colors.green[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        settings.appMaintenanceMode
                            ? 'App is currently under maintenance'
                            : 'All systems operational',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(AppSettings settings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.contact_support, color: Colors.purple[700]),
              ),
              const SizedBox(width: 12),
              Text(
                'Contact Information',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactItem(
            'Support Email',
            settings.supportEmailId,
            Icons.email_outlined,
            () => _launchEmail(settings.supportEmailId),
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            'Contact Email',
            settings.contactEmailId,
            Icons.mail_outline,
            () => _launchEmail(settings.contactEmailId),
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            'Phone Number',
            settings.contactNumber,
            Icons.phone_outlined,
            () => _launchPhone(settings.contactNumber),
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            'WhatsApp',
            settings.whatsappNumber,
            Icons.chat_bubble_outline,
            () => _launchWhatsApp(settings.whatsappNumber),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection(AppSettings settings) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.info_outline, color: Colors.orange[700]),
              ),
              const SizedBox(width: 12),
              Text(
                'Additional Information',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            'Google Maps API',
            settings.googleMapApi.isNotEmpty ? 'Configured' : 'Not Set',
            Icons.map,
            settings.googleMapApi.isNotEmpty ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final uri = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
