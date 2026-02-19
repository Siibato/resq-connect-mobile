import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class CameraService {
  final ImagePicker _imagePicker = ImagePicker();
  final Logger _logger = Logger();

  /// Pick an image from the device camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      return file;
    } catch (e) {
      _logger.e('Error picking image: $e');
      return null;
    }
  }

  /// Record a video from the device camera
  Future<XFile?> recordVideo() async {
    try {
      final XFile? file = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 10),
      );
      return file;
    } catch (e) {
      _logger.e('Error recording video: $e');
      return null;
    }
  }
}
