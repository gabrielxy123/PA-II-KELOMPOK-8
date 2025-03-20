import 'package:flutter/material.dart';

class CustomField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType textInputType;
  final double radius;

  const CustomField({
    super.key,
    required this.label,
    required this.controller,
    required this.isPassword,
    required this.textInputType,
    required this.radius,
  });

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  bool _obScureText = true;
  bool _isHovered = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obScureText = widget.isPassword;
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {}); // Perbarui tampilan saat fokus berubah.
    });
    widget.controller.addListener(() {
      setState(() {}); // Perbarui tampilan saat teks berubah.
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isFilled = widget.controller.text.isNotEmpty;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: TextField(
        focusNode: _focusNode,
        keyboardType: widget.textInputType,
        controller: widget.controller,
        obscureText: widget.isPassword ? _obScureText : false,
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(
            color: _focusNode.hasFocus || isFilled ? Colors.green : Colors.grey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius),
            borderSide: BorderSide(
              color: isFilled || _focusNode.hasFocus ? Colors.green : Colors.grey,
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius),
            borderSide: BorderSide(
              color: Colors.green,
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.radius),
            borderSide: BorderSide(
              color: isFilled ? Colors.green : Colors.grey,
              width: 2.0,
            ),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obScureText ? Icons.visibility_off : Icons.visibility,
                    color: _focusNode.hasFocus || isFilled
                        ? Colors.green
                        : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obScureText = !_obScureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
