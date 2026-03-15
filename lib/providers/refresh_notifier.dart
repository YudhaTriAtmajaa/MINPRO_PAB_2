import 'package:flutter/material.dart';

/// auto-refresh trigger for stook and produk tabs
class RefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
