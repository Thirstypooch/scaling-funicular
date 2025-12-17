import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final ScrollController? scrollController;

  const CustomPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    this.scrollController,
  });

  @override
  State<CustomPullToRefresh> createState() => _CustomPullToRefreshState();
}

class _CustomPullToRefreshState extends State<CustomPullToRefresh>
    with SingleTickerProviderStateMixin {
  static const double _pullThreshold = 80.0;
  static const double _maxPullDistance = 120.0;

  double _pullDistance = 0.0;
  bool _isRefreshing = false;
  late AnimationController _animationController;
  late Animation<double> _pullAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pullAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_isRefreshing) return;

    final scrollController = widget.scrollController;
    final isAtTop = scrollController == null ||
        !scrollController.hasClients ||
        scrollController.offset <= 0;

    if (isAtTop && event.delta.dy > 0) {
      setState(() {
        _pullDistance = (_pullDistance + event.delta.dy * 0.5)
            .clamp(0.0, _maxPullDistance);
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) async {
    if (_isRefreshing) return;

    if (_pullDistance >= _pullThreshold) {
      // Trigger refresh
      setState(() {
        _isRefreshing = true;
        _pullDistance = _pullThreshold;
      });

      await widget.onRefresh();

      if (!mounted) return;

      // Animate back to zero
      _pullAnimation = Tween<double>(
        begin: _pullDistance,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));

      _animationController.forward(from: 0.0).then((_) {
        if (mounted) {
          setState(() {
            _isRefreshing = false;
            _pullDistance = 0.0;
          });
        }
      });

      _animationController.addListener(_updatePullDistance);
    } else {
      // Snap back
      _pullAnimation = Tween<double>(
        begin: _pullDistance,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));

      _animationController.forward(from: 0.0);
      _animationController.addListener(_updatePullDistance);
    }
  }

  void _updatePullDistance() {
    if (mounted && !_isRefreshing) {
      setState(() {
        _pullDistance = _pullAnimation.value;
      });
      if (_animationController.isCompleted) {
        _animationController.removeListener(_updatePullDistance);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_pullDistance / _pullThreshold).clamp(0.0, 1.0);
    final showLoader = _pullDistance > 20 || _isRefreshing;

    return Listener(
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: Stack(
        children: [
          // Refresh indicator area (clean background)
          if (showLoader)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _pullDistance,
              child: Container(
                color: AppTheme.scaffoldBackground,
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  opacity: progress,
                  duration: const Duration(milliseconds: 150),
                  child: _buildRefreshIndicator(progress),
                ),
              ),
            ),

          // Main content (pushed down)
          AnimatedContainer(
            duration: _isRefreshing
                ? Duration.zero
                : const Duration(milliseconds: 50),
            transform: Matrix4.translationValues(0, _pullDistance, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshIndicator(double progress) {
    final isReady = progress >= 1.0;

    if (_isRefreshing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Actualizando...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textGray,
            ),
          ),
        ],
      );
    }

    // Pull indicator (before release)
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isReady
                ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                : AppTheme.primaryBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              isReady ? Icons.refresh_rounded : Icons.keyboard_arrow_down_rounded,
              key: ValueKey(isReady),
              size: 20,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
        const SizedBox(width: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            isReady ? 'Soltar para actualizar' : 'Desliza para actualizar',
            key: ValueKey(isReady),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textGray,
            ),
          ),
        ),
      ],
    );
  }
}
