import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class SankeyFlowChart extends StatefulWidget {
  final double income;
  final double expenses;
  final List<CategoryVolume> incomeBreakdown;
  final List<CategoryVolume> expenseBreakdown;

  final double investments;
  final List<CategoryVolume> investmentBreakdown;
  final bool isPrivacyMode;

  const SankeyFlowChart({
    super.key,
    required this.income,
    required this.expenses,
    required this.incomeBreakdown,
    required this.expenseBreakdown,
    this.investments = 0,
    this.investmentBreakdown = const [],
    this.isPrivacyMode = false,
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
          size: const Size(double.infinity, 350),
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

  @override
  void paint(Canvas canvas, Size size) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);
    
    final double nodeWidth = 14.0;
    final double padding = 20.0;
    final double chartHeight = size.height;
    final double leftX = padding;
    final double midX = size.width / 2;
    final double rightX = size.width - padding - nodeWidth;

    final double totalScale = income > 0 ? income : 100;
    final double heightScale = (chartHeight - 60) / totalScale;

    // Animation phases (Simplified for 2-column)
    double leftBarProgress = (progress / 0.3).clamp(0.0, 1.0);
    double flowProgress = ((progress - 0.3) / 0.4).clamp(0.0, 1.0);
    double rightBarsProgress = ((progress - 0.7) / 0.2).clamp(0.0, 1.0);

    // --- LEFT NODE (Total Income) ---
    final double leftNodeHeight = income * heightScale;
    
    if (leftBarProgress > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(leftX, 30, nodeWidth, leftNodeHeight * leftBarProgress), const Radius.circular(4)), 
        Paint()..color = const Color(0xFF0055D4).withOpacity(leftBarProgress)
      );
      // Label for Total Income
      final incomeStr = isPrivacyMode ? '***₺' : currencyFormat.format(income);
      _drawLabel(canvas, "Toplam Gelir", incomeStr, Offset(leftX + nodeWidth, 8 + leftNodeHeight / 2), alignRight: false, opacity: leftBarProgress);
    }

    // --- RIGHT NODES (Expenses, Investments, Savings) ---
    double currentRightY = 30.0;
    double currentLeftExitY = 30.0;

    // 1. Expenses flows
    for (var exp in expenseBreakdown) {
      final double expHeight = exp.amount * heightScale;
      final double drawHeight = expHeight < 2 ? 2 : expHeight;

      if (flowProgress > 0) {
        _drawCurvedFlow(
          canvas, 
          leftX + nodeWidth, currentLeftExitY, 
          rightX, currentRightY, 
          drawHeight, 
          exp.color.withOpacity(0.3), 
          flowProgress
        );
      }

      if (rightBarsProgress > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(rightX, currentRightY, nodeWidth, drawHeight * rightBarsProgress), const Radius.circular(4)),
          Paint()..color = exp.color.withOpacity(rightBarsProgress)
        );
        final expStr = isPrivacyMode ? '***₺' : currencyFormat.format(exp.amount);
        _drawLabel(canvas, exp.name, expStr, Offset(rightX - 10, currentRightY + drawHeight / 2), alignRight: true, opacity: rightBarsProgress);
      }
      
      currentRightY += drawHeight + 10;
      currentLeftExitY += drawHeight;
    }

    // 2. Investment flows
    for (var inv in investmentBreakdown) {
      final double invHeight = inv.amount * heightScale;
      final double drawHeight = invHeight < 2 ? 2 : invHeight;

      if (flowProgress > 0) {
        _drawCurvedFlow(
          canvas, 
          leftX + nodeWidth, currentLeftExitY, 
          rightX, currentRightY, 
          drawHeight, 
          inv.color.withOpacity(0.3), 
          flowProgress
        );
      }

      if (rightBarsProgress > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(rightX, currentRightY, nodeWidth, drawHeight * rightBarsProgress), const Radius.circular(4)),
          Paint()..color = inv.color.withOpacity(rightBarsProgress)
        );
        final invStr = isPrivacyMode ? '***₺' : currencyFormat.format(inv.amount);
        _drawLabel(canvas, inv.name, invStr, Offset(rightX - 10, currentRightY + drawHeight / 2), alignRight: true, opacity: rightBarsProgress);
      }
      
      currentRightY += drawHeight + 10;
      currentLeftExitY += drawHeight;
    }

    // 3. Savings flow (Remaining)
    final double savings = income - expenses - investments;
    if (savings > 0) {
      final double savingsHeight = savings * heightScale;
      final double drawHeight = savingsHeight < 2 ? 2 : savingsHeight;

       if (flowProgress > 0) {
        _drawCurvedFlow(
          canvas, 
          leftX + nodeWidth, currentLeftExitY, 
          rightX, currentRightY, 
          drawHeight, 
          const Color(0xFF4CAF50).withOpacity(0.3), // Green for savings
          flowProgress
        );
      }

      if (rightBarsProgress > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(rightX, currentRightY, nodeWidth, drawHeight * rightBarsProgress), const Radius.circular(4)),
          Paint()..color = const Color(0xFF4CAF50).withOpacity(rightBarsProgress)
        );
        final savingsStr = isPrivacyMode ? '***₺' : currencyFormat.format(savings);
        _drawLabel(canvas, "Artan Gelir", savingsStr, Offset(rightX - 10, currentRightY + drawHeight / 2), alignRight: true, opacity: rightBarsProgress);
      }
    }
  }

  void _drawCurvedFlow(Canvas canvas, double sx, double sy, double tx, double ty, double height, Color color, double flowProgress) {
    if (flowProgress <= 0) return;

    final Path path = Path();
    final double controlPointDistance = (tx - sx) * 0.5;

    // Top curve
    path.moveTo(sx, sy);
    path.cubicTo(
      sx + controlPointDistance, sy,
      tx - controlPointDistance, ty,
      tx, ty
    );

    // Right edge
    path.lineTo(tx, ty + height);

    // Bottom curve
    path.cubicTo(
      tx - controlPointDistance, ty + height,
      sx + controlPointDistance, sy + height,
      sx, sy + height
    );
    path.close();

    // Use a clipping rect or PathMeasure to animate the flow from left to right
    canvas.save();
    final double clipWidth = (tx - sx) * flowProgress;
    canvas.clipRect(Rect.fromLTWH(sx, 0, clipWidth, 1000));
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  void _drawLabel(Canvas canvas, String label, String value, Offset offset, {bool alignRight = false, double opacity = 1.0}) {
    if (opacity <= 0) return;

    final span = TextSpan(
      children: [
        TextSpan(text: '$label\n', style: TextStyle(color: Colors.white.withOpacity(0.9 * opacity), fontSize: 10, fontWeight: FontWeight.w500)),
        TextSpan(text: value, style: TextStyle(color: Colors.white.withOpacity(opacity), fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
    final tp = TextPainter(
      text: span,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      textDirection: ui.TextDirection.ltr,
    );
    tp.layout();
    
    final double rectWidth = tp.width + 12;
    final double rectHeight = tp.height + 6;
    
    // Adjusted positioning to avoid overlap with lines
    final double rx = alignRight ? offset.dx - rectWidth - 5 : offset.dx + 5;
    final double ry = offset.dy - rectHeight / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rx, ry, rectWidth, rectHeight), const Radius.circular(6)),
      Paint()..color = Colors.black.withOpacity(0.6 * opacity)
    );

    tp.paint(canvas, Offset(rx + 6, ry + 3));
  }

  @override
  bool shouldRepaint(FlowPainter oldDelegate) => oldDelegate.progress != progress;
}
