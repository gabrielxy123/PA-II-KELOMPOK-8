import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  final Widget nextPage;

  const NextButton({
    Key? key,
    required this.nextPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      },
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50), // Tombol full width
      ),
      child: const Text("Selanjutnya"),
    );
  }
}
