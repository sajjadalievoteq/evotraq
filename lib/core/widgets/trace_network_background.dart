// ============================================================
// EVOTRAQ — Animated Trace Network Background (handoff)
// Flutter port of the canvas animation in the client handoff.
// ============================================================
//
// Usage:
//
//   Stack(
//     children: [
//       const Positioned.fill(child: TraceNetworkBackground()),
//       // ...foreground...
//     ],
//   );
//
// Colors come from Evotraq tokens (see `core/theme/evotraq_theme.dart`).
//
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:traqtrace_app/core/theme/evotraq_theme.dart';

class TraceNetworkBackground extends StatefulWidget {
  /// Multiplier on the auto-computed node count. 1.0 matches the handoff reference.
  final double density;

  /// How many glowing "signal" pulses travel along edges.
  final int travelerCount;

  /// Override the line/dot color. Defaults to `EvotraqColors.fg2`.
  final Color? lineColor;

  /// Override the traveler core color. Defaults to `EvotraqColors.sig`.
  final Color? signalCoreColor;

  /// Override the traveler glow color. Defaults to `EvotraqColors.sigGlow`.
  final Color? signalGlowColor;

  /// Random seed — pin this if you want a deterministic layout (tests, goldens).
  final int? seed;

  const TraceNetworkBackground({
    super.key,
    this.density = 0.85,
    this.travelerCount = 18,
    this.lineColor,
    this.signalCoreColor,
    this.signalGlowColor,
    this.seed,
  });

  @override
  State<TraceNetworkBackground> createState() => _TraceNetworkBackgroundState();
}

class _TraceNetworkBackgroundState extends State<TraceNetworkBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _elapsed = 0; // seconds

  _Graph? _graph;
  Size _graphSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration now) {
    if (_last == Duration.zero) {
      _last = now;
      return;
    }
    final dt = (now - _last).inMicroseconds / 1e6;
    _last = now;
    setState(() {
      _elapsed += dt;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _ensureGraph(Size size) {
    if (_graph != null && _graphSize == size) return;
    _graph = _Graph.build(
      size: size,
      density: widget.density,
      travelerCount: widget.travelerCount,
      seed: widget.seed,
    );
    _graphSize = size;
  }

  @override
  Widget build(BuildContext context) {
    final colors = EvotraqColors.of(context);
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (size.isEmpty) return const SizedBox.shrink();
        _ensureGraph(size);

        return IgnorePointer(
          child: CustomPaint(
            size: size,
            painter: _TraceNetworkPainter(
              graph: _graph!,
              elapsed: reduceMotion ? 0 : _elapsed,
              lineColor: widget.lineColor ?? colors.fg2,
              signalCoreColor: widget.signalCoreColor ?? colors.sig,
              signalGlowColor: widget.signalGlowColor ?? colors.sigGlow,
            ),
          ),
        );
      },
    );
  }
}

class _Node {
  final double x, y, s;
  const _Node(this.x, this.y, this.s);
}

class _Edge {
  final int a, b;
  final double d;
  const _Edge(this.a, this.b, this.d);
}

class _Traveler {
  int edgeIndex;
  double t;
  final double speed;
  _Traveler(this.edgeIndex, this.t, this.speed);
}

class _Graph {
  final List<_Node> nodes;
  final List<_Edge> edges;
  final List<_Traveler> travelers;

  _Graph(this.nodes, this.edges, this.travelers);

  factory _Graph.build({
    required Size size,
    required double density,
    required int travelerCount,
    int? seed,
  }) {
    final rng = math.Random(seed);
    final cols = (size.width / 80).floor();
    final rows = (size.height / 80).floor();
    final count = math.max(8, (cols * rows * density).round());

    final nodes = <_Node>[
      for (var i = 0; i < count; i++)
        _Node(
          rng.nextDouble() * size.width,
          rng.nextDouble() * size.height,
          0.5 + rng.nextDouble() * 1.5,
        ),
    ];

    const threshold = 140.0;
    final edges = <_Edge>[];
    for (var i = 0; i < nodes.length; i++) {
      for (var j = i + 1; j < nodes.length; j++) {
        final dx = nodes[i].x - nodes[j].x;
        final dy = nodes[i].y - nodes[j].y;
        final d = math.sqrt(dx * dx + dy * dy);
        if (d < threshold) edges.add(_Edge(i, j, d));
      }
    }

    final travelers = <_Traveler>[];
    if (edges.isNotEmpty) {
      for (var i = 0; i < travelerCount; i++) {
        final speed = 0.12 + rng.nextDouble() * 0.24;
        travelers.add(_Traveler(
          rng.nextInt(edges.length),
          rng.nextDouble(),
          speed,
        ));
      }
    }

    return _Graph(nodes, edges, travelers);
  }
}

class _TraceNetworkPainter extends CustomPainter {
  final _Graph graph;
  final double elapsed;
  final Color lineColor;
  final Color signalCoreColor;
  final Color signalGlowColor;

  _TraceNetworkPainter({
    required this.graph,
    required this.elapsed,
    required this.lineColor,
    required this.signalCoreColor,
    required this.signalGlowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (final e in graph.edges) {
      final a = graph.nodes[e.a];
      final b = graph.nodes[e.b];
      final alpha = math.max(0.0, 0.2 - e.d / 700.0);
      edgePaint.color = lineColor.withOpacity(alpha);
      canvas.drawLine(Offset(a.x, a.y), Offset(b.x, b.y), edgePaint);
    }

    final dotPaint = Paint()..color = lineColor.withOpacity(0.4);
    for (final n in graph.nodes) {
      canvas.drawCircle(Offset(n.x, n.y), n.s, dotPaint);
    }

    if (graph.edges.isEmpty) return;

    final glowPaint = Paint()
      ..color = signalGlowColor.withOpacity(0.55)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final corePaint = Paint()..color = signalCoreColor;

    for (final tr in graph.travelers) {
      if (graph.edges.isEmpty) break;
      final e = graph.edges[tr.edgeIndex % graph.edges.length];
      final a = graph.nodes[e.a];
      final b = graph.nodes[e.b];

      final t = (tr.t + elapsed * tr.speed) % 1.0;
      final x = a.x + (b.x - a.x) * t;
      final y = a.y + (b.y - a.y) * t;

      canvas.drawCircle(Offset(x, y), 3.5, glowPaint);
      canvas.drawCircle(Offset(x, y), 1.6, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TraceNetworkPainter oldDelegate) {
    return oldDelegate.elapsed != elapsed ||
        oldDelegate.graph != graph ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.signalCoreColor != signalCoreColor ||
        oldDelegate.signalGlowColor != signalGlowColor;
  }
}

