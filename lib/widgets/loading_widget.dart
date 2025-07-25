import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitThreeBounce(
                color: Theme.of(context).colorScheme.primary,
                size: 24.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
