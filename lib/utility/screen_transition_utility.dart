import 'package:flutter/material.dart';

void screenTransition(BuildContext context, Widget page) {
  Navigator.of(context).push<Widget>(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const double begin = 0.0;
        const double end = 1.0;
        final Animatable<double> tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));
        final Animation<double> doubleAnimation = animation.drive(tween);
        return FadeTransition(
          opacity: doubleAnimation,
          child: child,
        );
      },
    ),
  );
}

void screenTransitionToTop(BuildContext context, Widget page) {
  Navigator.of(context).push<Widget>(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return page;
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const Offset begin = Offset(-0, 1.0);
        const Offset end = Offset.zero;
        final Animatable<Offset> tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));
        final Animation<Offset> offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    ),
  );
}

void screenTransitionNormal(BuildContext context, Widget page) {
  if (context.mounted) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return page; // 遷移先の画面widgetを指定
        },
      ),
    );
  }
}

void screenTransitionHero(BuildContext context, Widget page) {
  Navigator.push<Widget>(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => page,
    ),
  );
}
