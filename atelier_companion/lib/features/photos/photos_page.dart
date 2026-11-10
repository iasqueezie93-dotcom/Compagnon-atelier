import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/torch_service.dart';
import '../../shared/widgets/common.dart';

/// Galerie de photos d'intervention (démo en mémoire).
/// Production : brancher `camera`/`image_picker` pour la capture réelle,
/// et un upload vers un stockage autorisé.
class PhotosPage extends ConsumerStatefulWidget {
  const PhotosPage({super.key});
  @override
  ConsumerState<PhotosPage> createState() => _PhotosPageState();
}

class _PhotosPageState extends ConsumerState<PhotosPage> {
  final List<_Photo> _photos = [];

  void _addMock() {
    setState(() => _photos.add(_Photo(
          'Photo ${_photos.length + 1}',
          DateTime.now(),
        )));
  }

  @override
  Widget build(BuildContext context) {
    final torch = ref.watch(torchProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photos'),
        actions: [
          IconButton(
            tooltip: 'Flash',
            icon: Icon(torch.isOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () => ref.read(torchProvider).toggle(),
          ),
        ],
      ),
      body: _photos.isEmpty
          ? const EmptyState(icon: Icons.photo_library_outlined, message: 'Aucune photo.\nAppuie sur + pour simuler une capture.')
          : GridView.count(
              padding: const EdgeInsets.all(12),
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (final p in _photos)
                  Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.image_outlined, size: 32),
                        const SizedBox(height: 4),
                        Text(p.label, style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMock,
        tooltip: 'Simuler une capture',
        child: const Icon(Icons.add_a_photo_outlined),
      ),
    );
  }
}

class _Photo {
  final String label;
  final DateTime at;
  _Photo(this.label, this.at);
}
