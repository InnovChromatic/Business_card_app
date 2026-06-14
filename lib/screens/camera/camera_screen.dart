import 'package:business_card_flutter/models/scanned_card.dart';
import 'package:business_card_flutter/providers/camera_provider.dart';
import 'package:business_card_flutter/services/camera_service.dart';
import 'package:business_card_flutter/services/card_storage_service.dart';
import 'package:business_card_flutter/services/ocr_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  final CameraService _cameraService = CameraService();
  final OcrService _ocrService = OcrService();
  final CardStorageService _storageService = CardStorageService();

  CameraController? _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    Future.microtask(_initializeCamera);
  }

  Future<void> _initializeCamera() async {
    ref.read(cameraStateProvider.notifier).state = CameraState.loading;

    try {
      final controller = await _cameraService.initializeCamera();

      if (!mounted) {
        await _cameraService.disposeCamera(controller);
        return;
      }

      setState(() {
        _controller = controller;
        _errorMessage = null;
      });
      ref.read(cameraStateProvider.notifier).state = CameraState.ready;
    } on CameraException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _cameraErrorMessage(error);
      });
      ref.read(cameraStateProvider.notifier).state = CameraState.error;
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Unable to start the camera. Please try again.';
      });
      ref.read(cameraStateProvider.notifier).state = CameraState.error;
    }
  }

  Future<void> _captureAndRecognizeText() async {
    final controller = _controller;
    final cameraState = ref.read(cameraStateProvider);

    if (controller == null ||
        cameraState != CameraState.ready ||
        !controller.value.isInitialized) {
      return;
    }

    ref.read(cameraStateProvider.notifier).state = CameraState.capturing;

    try {
      final image = await _cameraService.captureImage(controller);
      final rawText = await _ocrService.extractText(image.path);

      if (!mounted) {
        ref.read(cameraStateProvider.notifier).state = CameraState.ready;
        return;
      }

      ref.read(cameraStateProvider.notifier).state = CameraState.ready;

      final now = DateTime.now();
      final card = ScannedCard(
        id: now.millisecondsSinceEpoch.toString(),
        imagePath: image.path,
        rawText: rawText,
        synced: false,
        createdAt: now,
      );

      try {
        await _storageService.saveCard(card);
      } catch (_) {
        if (!mounted) {
          ref.read(cameraStateProvider.notifier).state = CameraState.ready;
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Scan save failed locally')),
        );
      }

      if (!mounted) return;
      await _showOcrResult(rawText);
    } catch (_) {
      if (!mounted) return;

      ref.read(cameraStateProvider.notifier).state = CameraState.ready;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan failed. Please try again.')),
      );
    }
  }

  Future<void> _showOcrResult(String rawText) {
    final displayText = rawText.trim().isEmpty
        ? 'No text detected'
        : rawText.trim();

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('OCR Result'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: SingleChildScrollView(child: SelectableText(displayText)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _cameraErrorMessage(CameraException error) {
    switch (error.code) {
      case 'CameraAccessDenied':
      case 'CameraAccessDeniedWithoutPrompt':
      case 'CameraAccessRestricted':
        return 'Camera permission is required to scan business cards.';
      case 'no_cameras':
        return 'No camera is available on this device.';
      default:
        return 'Unable to start the camera. Please try again.';
    }
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null) {
      _cameraService.disposeCamera(controller);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraStateProvider);
    final isCapturing = cameraState == CameraState.capturing;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const _CameraTopBar(),
            Expanded(
              child: _CameraContent(
                cameraState: cameraState,
                controller: _controller,
                errorMessage: _errorMessage,
              ),
            ),
            const _ScanModeSelector(),
            const SizedBox(height: 24),
            _CaptureButton(
              onPressed: isCapturing ? null : _captureAndRecognizeText,
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _CameraTopBar extends StatelessWidget {
  const _CameraTopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                tooltip: 'Back',
              ),
            ),
          ),
          const Text(
            'Scan Card',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {}, // placeholder for future flash logic
                icon: const Icon(Icons.flash_off, color: Colors.white),
                tooltip: 'Flash',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraContent extends StatelessWidget {
  const _CameraContent({
    required this.cameraState,
    required this.controller,
    required this.errorMessage,
  });

  final CameraState cameraState;
  final CameraController? controller;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    switch (cameraState) {
      case CameraState.loading:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      case CameraState.capturing:
      case CameraState.ready:
        final cameraController = controller;
        if (cameraController == null || !cameraController.value.isInitialized) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: cameraController.value.previewSize?.height ?? 1,
                  height: cameraController.value.previewSize?.width ?? 1,
                  child: CameraPreview(cameraController),
                ),
              ),
              const _ScannerOverlay(),
              if (cameraState == CameraState.capturing)
                const ColoredBox(
                  color: Color(0x66000000),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      case CameraState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              errorMessage ?? 'Unable to start the camera.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        );
    }
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  static const double _horizontalPadding = 28;
  static const double _cardAspectRatio = 1.586;
  static const double _borderRadius = 16;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final guideWidth = constraints.maxWidth - (_horizontalPadding * 2);
        final guideHeight = guideWidth / _cardAspectRatio;
        final verticalOverlayHeight = (constraints.maxHeight - guideHeight) / 2;

        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: verticalOverlayHeight,
              child: const ColoredBox(color: Color(0x8C000000)),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: verticalOverlayHeight,
              child: const ColoredBox(color: Color(0x8C000000)),
            ),
            Positioned(
              top: verticalOverlayHeight,
              left: 0,
              width: _horizontalPadding,
              height: guideHeight,
              child: const ColoredBox(color: Color(0x8C000000)),
            ),
            Positioned(
              top: verticalOverlayHeight,
              right: 0,
              width: _horizontalPadding,
              height: guideHeight,
              child: const ColoredBox(color: Color(0x8C000000)),
            ),
            Center(
              child: SizedBox(
                width: guideWidth,
                height: guideHeight,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.fromBorderSide(
                      BorderSide(color: Colors.white, width: 2),
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(_borderRadius),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScanModeSelector extends ConsumerWidget {
  const _ScanModeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(scanModeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ScanMode.values.map((mode) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(_labelFor(mode)),
              selected: selectedMode == mode,
              onSelected: (_) {
                ref.read(scanModeProvider.notifier).state = mode;
              },
              selectedColor: const Color(0xFF1D5CFF),
              backgroundColor: Colors.white12,
              labelStyle: TextStyle(
                color: selectedMode == mode ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w600,
              ),
              side: BorderSide.none,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  String _labelFor(ScanMode mode) {
    switch (mode) {
      case ScanMode.quick:
        return 'Quick';
      case ScanMode.sequential:
        return 'Sequential';
      case ScanMode.qr:
        return 'QR';
    }
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 82,
          height: 82,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: onPressed == null
                    ? const Color(0xFF7697E8)
                    : const Color(0xFF1D5CFF),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(width: 62, height: 62),
            ),
          ),
        ),
      ),
    );
  }
}
