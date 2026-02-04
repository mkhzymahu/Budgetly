import 'package:flutter/material.dart';

class CurrencyCoin extends StatefulWidget {
  final String currentCurrency;
  final VoidCallback onTap;
  final bool isMenuOpen;
  
  const CurrencyCoin({
    Key? key,
    required this.currentCurrency,
    required this.onTap,
    required this.isMenuOpen,
  }) : super(key: key);

  @override
  _CurrencyCoinState createState() => _CurrencyCoinState();
}

class _CurrencyCoinState extends State<CurrencyCoin> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _animation = Tween<double>(begin: 0, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void didUpdateWidget(CurrencyCoin oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMenuOpen && !oldWidget.isMenuOpen) {
      _playAnimation();
    }
  }
  
  void _playAnimation() {
    _controller.reset();
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateY(_animation.value * 3.14159), // 2π radians = 360 degrees
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700), // Gold
                    Color(0xFFDAA520), // Goldenrod
                    Color(0xFFFFD700),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFB8860B),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Coin shine effect
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.white54,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Currency symbol
                  Center(
                    child: Text(
                      widget.currentCurrency.substring(0, 1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black45,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Coin rim
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF4C542),
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}