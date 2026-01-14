import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/widgets/app_scaffold.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class qrcode extends StatefulWidget {
  const qrcode({super.key});

  @override
  State<qrcode> createState() => _qrcodeState();
}

class _qrcodeState extends State<qrcode> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  String _qrValue = '';
  bool _saving = false;
  int _selectedTemplate = 0;
  _QrShape _customShape = _QrShape.rounded;
  Color _customForeground = const Color(0xFF111827);
  Color _customBackground = Colors.white;
  double _customRadius = 6;
  XFile? _logoFile;

  static final List<_QrTemplate> _templates = [
    _QrTemplate(
      name: 'Classic',
      decoration: PrettyQrDecoration(
        shape: PrettyQrSmoothSymbol(color: Color(0xFF111827)),
        background: Colors.white,
      ),
      cardDecoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    _QrTemplate(
      name: 'Ocean',
      decoration: PrettyQrDecoration(
        shape: PrettyQrSmoothSymbol(color: Color(0xFF1D4ED8)),
        background: Color(0xFFEFF6FF),
      ),
      cardDecoration: BoxDecoration(
        color: Color(0xFFEFF6FF),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    _QrTemplate(
      name: 'Sunset',
      decoration: PrettyQrDecoration(
        shape: PrettyQrRoundedSymbol(
          color: Color(0xFFEA580C),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        background: Color(0xFFFFF7ED),
      ),
      cardDecoration: BoxDecoration(
        color: Color(0xFFFFF7ED),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    _QrTemplate(
      name: 'Forest',
      decoration: PrettyQrDecoration(
        shape: PrettyQrRoundedSymbol(
          color: Color(0xFF15803D),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        background: Color(0xFFF0FDF4),
      ),
      cardDecoration: BoxDecoration(
        color: Color(0xFFF0FDF4),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    _QrTemplate(
      name: 'Split Blue',
      decoration: PrettyQrDecoration(
        shape: PrettyQrSmoothSymbol(color: Color(0xFF0F172A)),
        background: Colors.white,
      ),
      cardDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        gradient: LinearGradient(
          colors: [Color(0xFFE0F2FE), Color(0xFFF8FAFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    ),
    _QrTemplate(
      name: 'Split Peach',
      decoration: PrettyQrDecoration(
        shape: PrettyQrRoundedSymbol(
          color: Color(0xFF7C2D12),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        background: Colors.white,
      ),
      cardDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        gradient: LinearGradient(
          colors: [Color(0xFFFFEDD5), Color(0xFFFFFBEB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    ),
    _QrTemplate.custom(),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final surface = colors.surface;
    final surfaceVariant = colors.surfaceVariant;
    final onSurface = colors.onSurface;
    final onSurfaceMuted = onSurface.withOpacity(0.7);
    final decoration = _activeDecoration();
    final previewDecoration = _activePreviewDecoration();
    return AppScaffold(
      title: 'QR Code Generator',
      actions: [
        IconButton(
          icon: const Icon(Icons.download_rounded),
          onPressed: _saving ? null : _handleSave,
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            'Create and save QR codes in seconds.',
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: onSurfaceMuted,
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: RepaintBoundary(
                    key: _qrKey,
                    child: Container(
                      decoration: previewDecoration,
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: PrettyQrView.data(
                          data: _qrValue.isEmpty ? 'One App' : _qrValue,
                          decoration: decoration,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  onChanged: (value) => setState(() => _qrValue = value.trim()),
                  decoration: InputDecoration(
                    labelText: 'QR content',
                    hintText: 'Paste a link or type text',
                    filled: true,
                    fillColor: surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _handleSave,
                    icon: const Icon(Icons.download_rounded),
                    label: Text(_saving ? 'Saving...' : 'Save to gallery'),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Design templates',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _templates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final template = _templates[index];
                      final isSelected = _selectedTemplate == index;
                      final templateDecoration =
                          template.isCustom ? decoration : template.decoration!;
                      final templateBackground = template.isCustom
                          ? previewDecoration
                          : template.cardDecoration;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTemplate = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 86,
                          padding: const EdgeInsets.all(8),
                          decoration: templateBackground.copyWith(
                            border: Border.all(
                              color: isSelected
                                  ? colors.primary
                                  : colors.outlineVariant,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: PrettyQrView.data(
                                  data: 'oneapp',
                                  decoration: templateDecoration,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                template.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_isCustomSelected()) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Custom design',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _ColorButton(
                        label: 'Foreground',
                        color: _customForeground,
                        onTap: () => _pickColor(context, true),
                      ),
                      const SizedBox(width: 12),
                      _ColorButton(
                        label: 'Background',
                        color: _customBackground,
                        onTap: () => _pickColor(context, false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Smooth'),
                        selected: _customShape == _QrShape.smooth,
                        onSelected: (_) =>
                            setState(() => _customShape = _QrShape.smooth),
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('Rounded'),
                        selected: _customShape == _QrShape.rounded,
                        onSelected: (_) =>
                            setState(() => _customShape = _QrShape.rounded),
                      ),
                    ],
                  ),
                  if (_customShape == _QrShape.rounded) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Corner radius'),
                        Expanded(
                          child: Slider(
                            value: _customRadius,
                            min: 2,
                            max: 16,
                            divisions: 7,
                            label: _customRadius.round().toString(),
                            onChanged: (value) =>
                                setState(() => _customRadius = value),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickLogo,
                          icon: const Icon(Icons.image_rounded),
                          label: Text(
                            _logoFile == null ? 'Add logo' : 'Change logo',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_logoFile != null)
                        OutlinedButton(
                          onPressed: () => setState(() => _logoFile = null),
                          child: const Text('Remove'),
                        ),
                    ],
                  ),
                  if (_logoFile != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Logo added',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: onSurfaceMuted,
                            ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    final value = _qrValue.trim();
    if (value.isEmpty) {
      Get.snackbar('QR Code', 'Please enter text or a link first.');
      return;
    }

    setState(() => _saving = true);
    try {
      final status = await _requestSavePermission();
      if (!status.isGranted) {
        if (status.isPermanentlyDenied) {
          _showToast(context, 'Permission denied. Enable it in Settings.');
          await openAppSettings();
        } else {
          _showToast(context, 'Storage permission denied.');
        }
        return;
      }

      final bytes = await _captureQr();
      final result = await ImageGallerySaver.saveImage(
        bytes,
        name: 'oneapp_qr_${DateTime.now().millisecondsSinceEpoch}',
        quality: 100,
      );
      final success = result is Map && (result['isSuccess'] == true);
      final error = result is Map ? result['errorMessage'] as String? : null;
      _showToast(
        context,
        success
            ? 'QR code saved to gallery.'
            : (error?.isNotEmpty == true
                ? 'Failed to save: $error'
                : 'Failed to save QR code.'),
      );
    } catch (e) {
      _showToast(context, 'Failed to save QR code.');
    } finally {
      setState(() => _saving = false);
    }
  }

  Future<PermissionStatus> _requestSavePermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return PermissionStatus.granted;
    }

    var status = await Permission.photos.status;
    if (status.isGranted) {
      return status;
    }
    status = await Permission.photos.request();
    if (status.isGranted) {
      return status;
    }
    var storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) {
      return storageStatus;
    }
    storageStatus = await Permission.storage.request();
    return storageStatus;
  }

  Future<Uint8List> _captureQr() async {
    final boundary =
        _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('QR preview not ready');
    }
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  PrettyQrDecoration _activeDecoration() {
    if (_isCustomSelected()) {
      final logo = _logoFile != null
          ? PrettyQrDecorationImage(
              image: FileImage(File(_logoFile!.path)),
              position: PrettyQrDecorationImagePosition.embedded,
            )
          : null;
      final shape = _customShape == _QrShape.rounded
          ? PrettyQrRoundedSymbol(
              color: _customForeground,
              borderRadius: BorderRadius.circular(_customRadius),
            )
          : PrettyQrSmoothSymbol(color: _customForeground);
      return PrettyQrDecoration(
        shape: shape,
        background: _customBackground,
        image: logo,
      );
    }
    return _templates[_selectedTemplate].decoration!;
  }

  bool _isCustomSelected() =>
      _templates[_selectedTemplate].isCustom == true;

  BoxDecoration _activePreviewDecoration() {
    if (_isCustomSelected()) {
      return BoxDecoration(
        color: _customBackground,
        borderRadius: BorderRadius.circular(18),
      );
    }
    return _templates[_selectedTemplate]
        .cardDecoration
        .copyWith(borderRadius: BorderRadius.circular(18));
  }

  Future<void> _pickColor(BuildContext context, bool isForeground) async {
    final selected = await showModalBottomSheet<Color>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ColorPickerSheet(
        initial: isForeground ? _customForeground : _customBackground,
      ),
    );
    if (selected == null) return;
    setState(() {
      if (isForeground) {
        _customForeground = selected;
      } else {
        _customBackground = selected;
      }
    });
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _logoFile = picked);
  }
}

enum _QrShape { smooth, rounded }

class _QrTemplate {
  const _QrTemplate({
    required this.name,
    required this.decoration,
    required this.cardDecoration,
  }) : isCustom = false;

  const _QrTemplate.custom()
      : name = 'Custom',
        decoration = null,
        cardDecoration = const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        isCustom = true;

  final String name;
  final PrettyQrDecoration? decoration;
  final BoxDecoration cardDecoration;
  final bool isCustom;
}

class _ColorButton extends StatelessWidget {
  const _ColorButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colors.outlineVariant),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorPickerSheet extends StatelessWidget {
  const _ColorPickerSheet({required this.initial});

  final Color initial;

  static const List<Color> _swatches = [
    Color(0xFF111827),
    Color(0xFF1D4ED8),
    Color(0xFF0EA5E9),
    Color(0xFF7C3AED),
    Color(0xFFEA580C),
    Color(0xFFF43F5E),
    Color(0xFF15803D),
    Color(0xFF0F172A),
    Color(0xFFFFFFFF),
    Color(0xFFF8FAFF),
    Color(0xFFFFF7ED),
    Color(0xFFF0FDF4),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _swatches
            .map(
              (color) => GestureDetector(
                onTap: () => Navigator.of(context).pop(color),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color == initial
                          ? colors.primary
                          : colors.outlineVariant,
                      width: color == initial ? 2 : 1,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
