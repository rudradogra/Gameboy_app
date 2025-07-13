import 'package:flutter/material.dart';

class GameboyProfileCard extends StatefulWidget {
  final List<String> imageUrl;
  final String name;
  final int age;
  final List<String> info;
  final int currentImageIndex;
  final bool showInfo;

  const GameboyProfileCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.age,
    required this.info,
    required this.currentImageIndex,
    required this.showInfo,
  }) : assert(info.length == 3),
       super(key: key);

  @override
  GameboyProfileCardState createState() => GameboyProfileCardState();
}

class GameboyProfileCardState extends State<GameboyProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Set initial animation state based on showInfo
    if (widget.showInfo) {
      _animationController.value = 1.0;
    } else {
      _animationController.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(GameboyProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation when showInfo changes
    if (oldWidget.showInfo != widget.showInfo) {
      if (widget.showInfo) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix([
              1.2, 0.0, 0.0, 0.0, 0.0, // Red channel boost
              0.0, 1.1, 0.0, 0.0, 0.0, // Green channel boost
              0.0, 0.0, 1.3, 0.0, 0.0, // Blue channel boost
              0.0, 0.0, 0.0, 1.0, 0.0, // Alpha channel
            ]),
            child: Image.network(
              widget.imageUrl[widget.currentImageIndex],
              fit: BoxFit.cover,
              filterQuality:
                  FilterQuality.none, // Pixelated display for retro look
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.grey[600], size: 60),
              ),
            ),
          ),
        ),

        // Info Panel (collapsible)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info Content
              SizeTransition(
                sizeFactor: _animation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.info.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text(
                            '• $item',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'PublicPixel',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Name Bar (always visible)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(12),
                    bottomRight: const Radius.circular(12),
                    topLeft: widget.showInfo
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                    topRight: widget.showInfo
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.name}, ${widget.age}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'PublicPixel',
                        fontWeight: FontWeight.bold,
                        fontSize: 10, // Reduced from 16
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
