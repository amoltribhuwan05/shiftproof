import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/data/models/models.dart';
import 'package:shiftproof/providers/service_providers.dart';
import 'package:shiftproof/screens/properties/room_bed_setup_screen.dart';
import 'package:shiftproof/widgets/buttons/notification_bell_button.dart';

class AddPropertyScreen extends ConsumerStatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  ConsumerState<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedType = 'pg';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final priceText = _priceController.text.trim();

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter a property name.');
      return;
    }
    if (location.isEmpty) {
      setState(() => _errorMessage = 'Please enter the area or locality.');
      return;
    }
    final price = int.tryParse(priceText);
    if (price == null || price <= 0) {
      setState(() => _errorMessage = 'Please enter a valid monthly rent.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final property = await ref.read(propertyServiceProvider).createProperty(
            CreatePropertyRequest(
              title: name,
              location: location,
              price: price,
              type: _selectedType,
            ),
          );
      ref.invalidate(propertiesProvider);
      if (mounted) {
        unawaited(
          Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(
              builder: (_) =>
                  RoomBedSetupScreen(propertyId: property.id ?? ''),
            ),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          'Add Property',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [NotificationBellButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Property Details',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us about your property to get started with ShiftProof.',
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Property Name
            _buildLabel(context, 'Property Name'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'e.g. Skyline Residency',
              colorScheme: colorScheme,
              isDark: isDark,
            ),
            const SizedBox(height: 20),

            // Area / Locality
            _buildLabel(context, 'Area / Locality'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _locationController,
              hint: 'Enter neighborhood or city',
              colorScheme: colorScheme,
              isDark: isDark,
              suffixIcon: Icon(
                Icons.location_on,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),

            // Property Type
            _buildLabel(context, 'Property Type'),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTypeChip(context, label: 'PG', value: 'pg', isDark: isDark),
                const SizedBox(width: 12),
                _buildTypeChip(context, label: 'Flat', value: 'flat', isDark: isDark),
                const SizedBox(width: 12),
                _buildTypeChip(context, label: 'House', value: 'house', isDark: isDark),
              ],
            ),
            const SizedBox(height: 20),

            // PG Configuration Block
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: colorScheme.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'PRICING',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Base Monthly Rent (₹)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'e.g. 8000',
                      prefixText: '₹ ',
                      filled: true,
                      fillColor: isDark
                          ? theme.scaffoldBackgroundColor
                          : theme.colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? 0.3 : 0.2,
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? 0.3 : 0.2,
                          ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() => _errorMessage = null);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Map Preview
            Container(
              height: (MediaQuery.of(context).size.height * 0.18)
                  .clamp(130.0, 180.0),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                ),
                image: const DecorationImage(
                  image: CachedNetworkImageProvider(
                    'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=2074&auto=format&fit=crop',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: colorScheme.primary, size: 36),
                    const SizedBox(height: 4),
                    const Text(
                      'PIN LOCATION ON MAP',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Error message
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
              ),
              const SizedBox(height: 12),
            ],

            // Bottom Continue
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : _handleContinue,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.chevron_right),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Step 1 of 2: General Information',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required ColorScheme colorScheme,
    required bool isDark,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      onChanged: (_) {
        if (_errorMessage != null) setState(() => _errorMessage = null);
      },
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildTypeChip(
    BuildContext context, {
    required String label,
    required String value,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedType == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.05),
          border: isSelected
              ? null
              : Border.all(
                  color: theme.colorScheme.primary
                      .withValues(alpha: isDark ? 0.3 : 0.2),
                ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check, color: theme.colorScheme.onPrimary, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.textTheme.bodyMedium?.color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
