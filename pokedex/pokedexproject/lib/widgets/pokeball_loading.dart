// lib/widgets/pokeball_loading.dart
import 'package:flutter/material.dart';

class PokeballLoading extends StatefulWidget {
  const PokeballLoading({Key? key}) : super(key: key);

  @override
  _PokeballLoadingState createState() => _PokeballLoadingState();
}

class _PokeballLoadingState extends State<PokeballLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
        child: Image.asset(
          'assets/images/loading_pokeball.gif', // Updated path
          height: 50,
          width: 50,
        ),
      ),
    );
  }
}
