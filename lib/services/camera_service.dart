import 'package:camera/camera.dart';

class CameraService {
  Future<CameraController> initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw  CameraException(
          'no_cameras',
          'No cameras are available on this device.',
        );
      }

      final rearCamera = cameras.where(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
      final selectedCamera =
          rearCamera.isNotEmpty ? rearCamera.first : cameras.first;
      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      try {
        await controller.initialize();
        return controller;
      } catch (_) {
        await controller.dispose();
        rethrow;
      }
    } on CameraException {
      rethrow;
    } catch (error) {
      throw CameraException(
        'camera_initialization_failed',
        'Unable to initialize the camera: $error',
      );
    }
  }

  Future<XFile> captureImage(CameraController controller) async {
    if (!controller.value.isInitialized) {
      throw  CameraException(
        'camera_not_initialized',
        'The camera is not ready to capture an image.',
      );
    }

    if (controller.value.isTakingPicture) {
      throw  CameraException(
        'capture_in_progress',
        'An image capture is already in progress.',
      );
    }

    try {
      return await controller.takePicture();
    } on CameraException {
      rethrow;
    } catch (error) {
      throw CameraException(
        'capture_failed',
        'Unable to capture the image: $error',
      );
    }
  }

  Future<void> disposeCamera(CameraController controller) async {
    await controller.dispose();
  }
}
