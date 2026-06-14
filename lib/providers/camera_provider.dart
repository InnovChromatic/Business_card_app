import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CameraState {
  loading,
  ready,
  capturing,
  error,
}

enum ScanMode {
  quick,
  sequential,
  qr,
}

final scanModeProvider = StateProvider<ScanMode>(
  (ref) => ScanMode.quick,
);

final cameraStateProvider = StateProvider<CameraState>(
  (ref) => CameraState.loading,
);
