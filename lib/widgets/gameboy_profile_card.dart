import 'package:flutter/material.dart';

class GameboyProfileCard extends StatefulWidget {
  final List<String>imageUrl;
  final String name;
  final int age;
  final List<String> info;

  const GameboyProfileCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.age,
    required this.info,
  }) : assert(info.length == 3),
       super(key: key);

  @override
  GameboyProfileCardState createState() => GameboyProfileCardState();
}

class GameboyProfileCardState extends State<GameboyProfileCard> with SingleTickerProviderStateMixin {
  bool _showInfo = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentImageIndex = 0;

  void handleDirection(String direction) {
    setState(() {
      if (direction == 'left') {
        _currentImageIndex = (_currentImageIndex - 1) % widget.imageUrl.length;
      } else if (direction == 'right') {
        _currentImageIndex = (_currentImageIndex + 1) % widget.imageUrl.length;
      }
      // Ensure index is not negative
      if (_currentImageIndex < 0) {
        _currentImageIndex = widget.imageUrl.length - 1;
      }
    });
  }

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleInfo() {
    setState(() {
      _showInfo = !_showInfo;
      if (_showInfo) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.imageUrl[_currentImageIndex],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.grey[600], size: 60),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...widget.info.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              '• $item',
                              style: const TextStyle(color: Colors.white, fontFamily: 'PublicPixel'),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              
              // Name Bar (always visible)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: const Radius.circular(12),
                    bottomRight: const Radius.circular(12),
                    topLeft: _showInfo
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                    topRight: _showInfo
                        ? const Radius.circular(0)
                        : const Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
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
                        fontSize: 16,
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
        
        // Hearts in top right
        Positioned(
          top: 12,
          right: 12,
          child: Row(
            children: List.generate(5, (index) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.0),
              child: Icon(
                Icons.favorite,
                color: Colors.red,
                size: 20,
              ),
            )),
          ),
        ),
      ],
    );
  }
}
