import 'package:flutter/material.dart';

class FooterBar extends StatelessWidget {
  const FooterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Theme.of(context).primaryColor.withOpacity(0.95),
      child: const Center(
        child: Text(
          'Created by JACS: Class of 2027',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
