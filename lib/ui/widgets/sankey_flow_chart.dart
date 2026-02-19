import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

class SankeyFlowChart extends StatefulWidget {
  final double income;
  final double expenses;
  final List<CategoryVolume> incomeBreakdown;
  final List<CategoryVolume> expenseBreakdown;

  final double investments;
  final List<CategoryVolume> investmentBreakdown;
  final bool isPrivacyMode;
  final double height;

  const SankeyFlowChart({
    super.key,
    required this.income,
    required this.expenses,
    required this.incomeBreakdown,
    required this.expenseBreakdown,
    this.investments = 0,
    this.investmentBreakdown = const [],
    this.isPrivacyMode = false,
    this.height = 350,
  });

  @override
  State<SankeyFlowChart> createState() => _SankeyFlowChartState();
}

class _SankeyFlowChartState extends State<SankeyFlowChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
    _controller.forward();
  }

  @override
  void didUpdateWidget(SankeyFlowChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.income != widget.income || oldWidget.expenses != widget.expenses) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.income == 0 && widget.expenses == 0) {
      return const Center(
        child: Text(
          'Akış gösterilecek veri bulunamadı',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: FlowPainter(
            income: widget.income,
            expenses: widget.expenses,
            investments: widget.investments,
            incomeBreakdown: widget.incomeBreakdown,
            expenseBreakdown: widget.expenseBreakdown,
            investmentBreakdown: widget.investmentBreakdown,
            isPrivacyMode: widget.isPrivacyMode,
            progress: _animation.value,
          ),
        );
      },
    );
  }
}

class CategoryVolume {
  final String name;
  final double amount;
  final Color color;

  CategoryVolume({required this.name, required this.amount, required this.color});
}

class FlowPainter extends CustomPainter {
  final double income;
  final double expenses;
  final double investments;
  final List<CategoryVolume> incomeBreakdown;
  final List<CategoryVolume> expenseBreakdown;
  final List<CategoryVolume> investmentBreakdown;
  final bool isPrivacyMode;
  final double progress;

  FlowPainter({
    required this.income,
    required this.expenses,
    required this.investments,
    required this.incomeBreakdown,
    required this.expenseBreakdown,
    required this.investmentBreakdown,
    required this.isPrivacyMode,
    required this.progress,
  });

  // Sqrt-based scaling to compress large values and boost small ones
  double _sqrtTransform(double value) {
    if (value <= 0) return 0;
    return math.sqrt(value);
  }

  // Distribute available height among nodes using sqrt scaling
  List<double> _distributeHeights(List<_Node> nodes, double availableHeight, double minHeight) {
    if (nodes.isEmpty) return [];
    
    // Calculate sqrt values
    final sqrtValues = nodes.map((n) => _sqrtTransform(n.value)).toList();
    final totalSqrt = sqrtValues.fold(0.0, (sum, v) => sum + v);
    
    if (totalSqrt <= 0) return List.filled(nodes.length, minHeight);
    
    // Distribute proportionally based on sqrt
    final heights = sqrtValues.map((sv) {
      final h = (sv / totalSqrt) * availableHeight;
      return h < minHeight ? minHeight : h;
    }).toList();
    
    return heights;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0 || size.width <= 0) return;

    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);

    // Layout Constants
    const double nodeWidth = 12.0;
    const double padding = 20.0;
    const double nodeGap = 5.0;
    const double minNodeHeight = 20.0;
    
    // Coordinates
    final double leftX = padding;
    final double midX = size.width / 2 - nodeWidth / 2;
    final double rightX = size.width - padding - nodeWidth;
    final double topPad = 30.0;
    final double bottomPad = 10.0;

    final double availableHeight = size.height - topPad - bottomPad;

    // 1. Prepare Node Lists
    
    // --- Left Layout (Sources) ---
    List<_Node> leftNodes = [];
    if (incomeBreakdown.isEmpty && income > 0) {
      leftNodes.add(_Node(
        label: "Gelir", 
        value: income, 
        color: const Color(0xFF0055D4), 
        isFallback: true
      ));
    } else {
      for (var inc in incomeBreakdown) {
        leftNodes.add(_Node(label: inc.name, value: inc.amount, color: inc.color));
      }
    }

    // --- Right Layout (Destinations) ---
    final double currentSavings = (income - expenses - investments).clamp(0.0, income);
    List<_Node> rightNodes = [];
    for (var exp in expenseBreakdown) rightNodes.add(_Node(label: exp.name, value: exp.amount, color: exp.color, isRight: true));
    for (var inv in investmentBreakdown) rightNodes.add(_Node(label: inv.name, value: inv.amount, color: inv.color, isRight: true));
    if (currentSavings > 0) {
      rightNodes.add(_Node(label: "Artan Gelir", value: currentSavings, color: const Color(0xFF4CAF50), isRight: true));
    }

    // 2. Calculate Heights using sqrt scaling
    
    // Left column
    final double leftGapTotal = (leftNodes.length > 1 ? leftNodes.length - 1 : 0) * nodeGap;
    final double leftAvailable = availableHeight - leftGapTotal;
    final leftHeights = _distributeHeights(leftNodes, leftAvailable > 0 ? leftAvailable : 1, minNodeHeight);
    
    // Right column
    final double rightGapTotal = (rightNodes.length > 1 ? rightNodes.length - 1 : 0) * nodeGap;
    final double rightAvailable = availableHeight - rightGapTotal;
    final rightHeights = _distributeHeights(rightNodes, rightAvailable > 0 ? rightAvailable : 1, minNodeHeight);
    
    // Assign Y positions
    double currentY = topPad;
    for (int i = 0; i < leftNodes.length; i++) {
      leftNodes[i].height = leftHeights[i];
      leftNodes[i].y = currentY;
      currentY += leftHeights[i] + nodeGap;
    }
    
    currentY = topPad;
    for (int i = 0; i < rightNodes.length; i++) {
      rightNodes[i].height = rightHeights[i];
      rightNodes[i].y = currentY;
      currentY += rightHeights[i] + nodeGap;
    }

    // 3. Draw & Animate
    
    // Helper to draw a node
    void drawNodeRect(double x, double y, double h, Color c, double opacity) {
      if (h < 0) return;
      final double visualsH = h < 2 ? 2 : h;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, nodeWidth, visualsH), const Radius.circular(4)),
        Paint()..color = c.withOpacity(opacity),
      );
    }
    
    // Animation phases
    double leftBarsProgress = (progress / 1.5).clamp(0.0, 1.0); 
    double leftToMidProgress = ((progress - 0.2) / 0.4).clamp(0.0, 1.0);
    double midBarProgress = ((progress - 0.5) / 0.2).clamp(0.0, 1.0);
    double midToRightProgress = ((progress - 0.6) / 0.4).clamp(0.0, 1.0);
    double rightBarsProgress = ((progress - 0.9) / 0.1).clamp(0.0, 1.0);

    // --- DRAW LEFT COLUMN ---
    for (var node in leftNodes) {
      if (leftBarsProgress > 0) {
        drawNodeRect(leftX, node.y, node.height, node.color, leftBarsProgress);
        if (node.height >= 30) {
          _drawLabel(
            canvas, 
            node.label, 
            isPrivacyMode ? '***₺' : currencyFormat.format(node.value), 
            Offset(leftX + 20, node.y + node.height / 2),
            opacity: leftBarsProgress
          );
        }
      }
    }

    // --- DRAW MIDDLE COLUMN ---
    // Single blue bar for "Toplam Gelir"
    final double midBarHeight = leftNodes.fold(0.0, (sum, n) => sum + n.height) + 
                                 (leftNodes.length > 1 ? (leftNodes.length - 1) * nodeGap : 0);
    
    // Draw flows Left -> Mid
    // Mid bar occupies from topPad to topPad + midBarHeight as a single unit
    double midYCursor = topPad;
    for (var node in leftNodes) {
      final double sy = node.y + node.height / 2;
      final double ty = midYCursor + node.height / 2;
      
      if (leftToMidProgress > 0) {
        _drawSingleFlow(
          canvas, 
          leftX + nodeWidth, sy, 
          midX, ty, 
          node.height, 
          node.color.withOpacity(0.3), 
          leftToMidProgress
        );
      }
      midYCursor += node.height + nodeGap;
    }
    
    // Draw the single blue middle bar
    if (midBarProgress > 0) {
      const Color midBarColor = Color(0xFF1565C0);
      drawNodeRect(midX, topPad, midBarHeight, midBarColor, midBarProgress);
      
      // "Toplam Gelir" label centered on the blue bar
      final incomeStr = isPrivacyMode ? '***₺' : currencyFormat.format(income);
      _drawLabel(
        canvas, "Toplam Gelir", incomeStr, 
        Offset(midX + nodeWidth / 2, topPad + midBarHeight / 2), 
        alignRight: false, opacity: midBarProgress, isCenter: true
      );
    }

    // --- DRAW RIGHT COLUMN ---
    for (var node in rightNodes) {
      if (rightBarsProgress > 0) {
        drawNodeRect(rightX, node.y, node.height, node.color, rightBarsProgress);
        _drawLabel(
          canvas, 
          node.label, 
          isPrivacyMode ? '***₺' : currencyFormat.format(node.value), 
          Offset(rightX - 10, node.y + node.height / 2),
          alignRight: true,
          opacity: rightBarsProgress
        );
      }
    }
    
    // Draw flows Mid -> Right
    // Distribute the mid bar evenly among right nodes proportionally
    double midOutCursor = topPad;
    final double totalRightSqrt = rightNodes.fold(0.0, (sum, n) => sum + _sqrtTransform(n.value));
    
    for (var node in rightNodes) {
      // Flow source height proportional to this node's share of the mid bar
      final double flowShare = totalRightSqrt > 0 
          ? (_sqrtTransform(node.value) / totalRightSqrt) * midBarHeight 
          : node.height;
      
      final double sy = midOutCursor + flowShare / 2;
      final double ty = node.y + node.height / 2;
      
      if (midToRightProgress > 0) {
        _drawSingleFlow(
          canvas, 
          midX + nodeWidth, sy, 
          rightX, ty, 
          math.min(flowShare, node.height), 
          node.color.withOpacity(0.3), 
          midToRightProgress
        );
      }
      midOutCursor += flowShare;
    }
  }

  // Flow Drawing: Center-to-Center with thickness
  void _drawSingleFlow(Canvas canvas, double sx, double sy, double tx, double ty, double thickness, Color color, double progress) {
    if (progress <= 0 || thickness <= 0) return;

    final Path path = Path();
    final double cpDist = (tx - sx) * 0.5;

    final double halfThick = thickness / 2;
    
    path.moveTo(sx, sy - halfThick);
    path.cubicTo(
      sx + cpDist, sy - halfThick,
      tx - cpDist, ty - halfThick,
      tx, ty - halfThick
    );
    path.lineTo(tx, ty + halfThick);
    path.cubicTo(
      tx - cpDist, ty + halfThick,
      sx + cpDist, sy + halfThick,
      sx, sy + halfThick
    );
    path.close();

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(sx, 0, (tx - sx) * progress, 10000));
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  void _drawLabel(Canvas canvas, String label, String value, Offset offset, {bool alignRight = false, double opacity = 1.0, bool isCenter = false}) {
    if (opacity <= 0) return;

    final span = TextSpan(
      children: [
        TextSpan(text: '$label\n', style: TextStyle(color: Colors.white.withOpacity(0.9 * opacity), fontSize: 9, fontWeight: FontWeight.w500)),
        TextSpan(text: value, style: TextStyle(color: Colors.white.withOpacity(opacity), fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
    final tp = TextPainter(
      text: span,
      textAlign: isCenter ? TextAlign.center : (alignRight ? TextAlign.right : TextAlign.left),
      textDirection: ui.TextDirection.ltr,
    );
    tp.layout();
    
    final double rectWidth = tp.width + 10;
    final double rectHeight = tp.height + 4;
    
    double rx;
    if (isCenter) {
      rx = offset.dx - rectWidth / 2;
    } else if (alignRight) {
      rx = offset.dx - rectWidth - 5;
    } else {
      rx = offset.dx + 5;
    }
    final double ry = offset.dy - rectHeight / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rx, ry, rectWidth, rectHeight), const Radius.circular(6)),
      Paint()..color = Colors.black.withOpacity(0.6 * opacity)
    );

    tp.paint(canvas, Offset(rx + 5, ry + 2));
  }

  @override
  bool shouldRepaint(FlowPainter oldDelegate) => oldDelegate.progress != progress;
}

class _Node {
  final String label;
  final double value;
  final Color color;
  final bool isFallback;
  final bool isRight;
  
  // Calculated layout props
  double y = 0;
  double height = 0;

  _Node({
    required this.label, 
    required this.value, 
    required this.color, 
    this.isFallback = false,
    this.isRight = false
  });
}
