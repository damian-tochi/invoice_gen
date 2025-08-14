import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:invoice_gen/model/preference_object.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

import '../../constants/preferences_service.dart';

class PreferencePage extends StatefulWidget {
  const PreferencePage({super.key});

  @override
  State<PreferencePage> createState() => _PreferencePageState();
}

class _PreferencePageState extends State<PreferencePage> {
  double _tax = 0.0;
  Color _color1 = Colors.blue;
  Color _color2 = Colors.green;
  String? _signaturePath;
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await PreferenceService.load();
    if (prefs != null) {
      setState(() {
        _tax = prefs.taxDeduction;
        _color1 = Color(int.parse(prefs.dominantColor1));
        _color2 = Color(int.parse(prefs.dominantColor2));
        _signaturePath = prefs.signaturePath;
      });
    }
  }

  Future<void> _savePrefs() async {
    final settings = PreferenceObject(
      taxDeduction: _tax,
      signaturePath: _signaturePath,
      dominantColor1: _color1.value.toString(),
      dominantColor2: _color2.value.toString(),
    );
    await PreferenceService.save(settings);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Preferences saved")));
  }

  Future<void> _pickSignatureImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _signaturePath = picked.path);
    }
  }

  Future<void> _saveDrawnSignature() async {
    if (_controller.isNotEmpty) {
      final export = await _controller.toPngBytes();
      if (export != null) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File("${dir.path}/signature.png");
        await file.writeAsBytes(export);
        setState(() => _signaturePath = file.path);
      }
    }
  }

  void _showColorPicker(Color current, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Pick Color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            hexInputBar: true,
            pickerColor: current,
            onColorChanged: onColorChanged,
            showLabel: true,
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Done"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Preference Settings"),
        titleTextStyle: TextStyle(fontSize: 16, color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(children: [Text("Tax Deduction: ${_tax.round()}%"), Spacer()]),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white70),
                color: Colors.grey[100],
              ),
              child: Slider(
                value: _tax,
                min: 0,
                max: 50,
                divisions: 50,
                label: "${_tax.round()}%",
                onChanged: (val) => setState(() => _tax = val),
              ),
            ),

            const SizedBox(height: 30),
            Row(children: [const Text("Dominant Colors: "), Spacer()]),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white70),
                    color: Colors.grey[100],
                  ),
                  padding: EdgeInsets.all(9),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => _showColorPicker(
                              _color1,
                              (color) => setState(() => _color1 = color),
                            ),
                            child: CircleAvatar(backgroundColor: _color1),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => _showColorPicker(
                              _color2,
                              (color) => setState(() => _color2 = color),
                            ),
                            child: CircleAvatar(backgroundColor: _color2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Spacer(),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Text("Signature: "),
                const Spacer(),
                TextButton(
                  onPressed: _pickSignatureImage,
                  child: const Text("Upload"),
                ),
              ],
            ),

            if (_signaturePath != null)
              Image.file(File(_signaturePath!), height: 100),
            const Divider(),
            const Text("Or draw signature below:"),
            Container(
              height: 150,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey),),
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.white,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () => _controller.clear(),
                  child: const Text("Clear"),
                ),
                TextButton(
                  onPressed: _saveDrawnSignature,
                  child: const Text("Save Signature"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePrefs,
              child: const Text("Save Preferences"),
            ),
          ],
        ),
      ),
    );
  }
}
