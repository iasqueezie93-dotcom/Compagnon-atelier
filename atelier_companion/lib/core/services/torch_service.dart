import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service torche global — « flash accessible partout ».
/// Démo : stub sans plugin natif. Production : brancher `torch_light`
/// (TorchLight.enableTorch / disableTorch) derrière cette interface.
class TorchService extends ChangeNotifier {
  bool _on = false;
  bool get isOn => _on;

  Future<void> toggle() async {
    _on = !_on;
    // TODO(jalon 2): if (_on) await TorchLight.enableTorch(); else await TorchLight.disableTorch();
    notifyListeners();
  }

  Future<void> turnOff() async {
    if (!_on) return;
    _on = false;
    notifyListeners();
  }
}

final torchProvider = ChangeNotifierProvider<TorchService>((_) => TorchService());
