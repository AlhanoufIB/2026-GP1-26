import 'package:flutter/material.dart';

import 'property_image.dart';

/// Swipeable photo gallery with dots. Tap a photo to open it full screen.
class PropertyGallery extends StatefulWidget {
  final List<String> images;

  const PropertyGallery({super.key, required this.images});

  @override
  State<PropertyGallery> createState() => _PropertyGalleryState();
}

class _PropertyGalleryState extends State<PropertyGallery> {
  int _current = 0; // which photo is showing

  void _openFullScreen(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            _FullScreenGallery(images: widget.images, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    if (images.isEmpty) return const PropertyImage(path: null);

    return Stack(
      children: [
        PageView.builder(
          itemCount: images.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (context, i) => GestureDetector(
            onTap: () => _openFullScreen(i),
            child: PropertyImage(path: images[i]),
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < images.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _current ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _current ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Black full-screen viewer: swipe between photos, pinch to zoom.
class _FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenGallery({required this.images, required this.initialIndex});

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);
  late int _current = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose(); // free the controller when the page closes
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) => InteractiveViewer(
              maxScale: 4,
              child: Center(
                child: PropertyImage(
                  path: widget.images[i],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(
                    '${_current + 1} / ${widget.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}