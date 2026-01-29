import 'package:flutter/material.dart';

class QuickEditTile extends StatefulWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final bool isInt;
  final String unit;
  final String? info;
  final ValueChanged<double> onChanged;

  const QuickEditTile({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.isInt,
    this.unit = "",
    this.info,
    required this.onChanged,
  });

  @override
  State<QuickEditTile> createState() => _QuickEditTileState();
}

class _QuickEditTileState extends State<QuickEditTile> {
  // Local state to handle the slider movement inside the dialog
  void _showEditDialog() {
    double tempValue = widget.value < widget.max ? widget.value : widget.max;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Allows the slider to move inside the dialog
          builder: (context, setDialogState) {
            String valText = widget.isInt ? tempValue.round().toString() : tempValue.toStringAsFixed(1);

            return AlertDialog(
              title: Text("Edit ${widget.title}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${valText}${widget.unit}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: tempValue,
                    min: widget.min,
                    max: widget.max,
                    onChanged: (value) {
                      setDialogState(() {
                        tempValue = (value * 10).round() / 10;
                         } );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onChanged(tempValue);
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String valText = widget.isInt ? widget.value.round().toString() : widget.value.toStringAsFixed(1);
    return GestureDetector(
      onTap: _showEditDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          //boxShadow: [BoxShadow(color: Colors.black10, blurRadius: 4)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text(
              "${valText}${widget.unit}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if(widget.info != null)
            Text(widget.info!, style: TextStyle(fontSize: 12, color: Colors.grey[900])),
          ],
        ),
      ),
    );
  }
}