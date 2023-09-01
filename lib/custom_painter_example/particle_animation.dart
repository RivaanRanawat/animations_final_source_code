import 'package:flutter/material.dart';
import 'dart:math' as math;

class ParticleAnimationPage extends StatefulWidget {
  const ParticleAnimationPage({super.key});

  @override
  State<ParticleAnimationPage> createState() => _ParticleAnimationPageState();
}

class _ParticleAnimationPageState extends State<ParticleAnimationPage>
    with SingleTickerProviderStateMixin {
  List<Particle> particles = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {
          particles.removeWhere((particle) => particle.isExpired);
          particles.map((particle) => particle.update()).toList();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    final particleCount = math.Random().nextInt(50) + 50;
    final particleColor = Color.fromRGBO(math.Random().nextInt(256),
        math.Random().nextInt(256), math.Random().nextInt(256), 1);

    final particleSize = math.Random().nextInt(4) + 4;
    final particleVelocity = math.Random().nextInt(4) + 1;

    for (var i = 0; i < particleCount; i++) {
      final particle = Particle(
        color: particleColor,
        position: details.localPosition,
        size: particleSize.toDouble(),
        velocity: Offset(
          math.Random().nextDouble() * particleVelocity - particleVelocity / 2,
          math.Random().nextDouble() * particleVelocity - particleVelocity / 2,
        ),
        lifespan: Duration(milliseconds: math.Random().nextInt(1000) + 1000),
      );
      particles.add(particle);
    }

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Particle Animation'),
        ),
        body: Container(
          color: Colors.black,
          child: CustomPaint(
            painter: ParticlePainter(particles),
          ),
        ),
      ),
    );
  }
}

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  Duration lifespan;
  Stopwatch stopwatch;

  Particle({
    required this.color,
    required this.position,
    required this.size,
    required this.velocity,
    required this.lifespan,
  }) : stopwatch = Stopwatch()..start();

  bool get isExpired =>
      stopwatch.elapsedMilliseconds >= lifespan.inMilliseconds;

  void update() {
    position += velocity;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    particles.map((particle) {
      final progress = particle.stopwatch.elapsedMilliseconds /
          particle.lifespan.inMilliseconds;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      paint.color = particle.color.withOpacity(opacity);
      canvas.drawCircle(particle.position, particle.size, paint);
    }).toList();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
