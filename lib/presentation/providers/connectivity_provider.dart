import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/connectivity_service.dart';

final isOfflineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityProvider);
  return service.isOfflineStream;
});
