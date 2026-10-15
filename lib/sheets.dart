import 'package:flutter/material.dart';

import 'app_state.dart';
import 'main.dart';
import 'screens.dart';

Future<void> _openSheet(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (c) => Padding(
      padding: EdgeInsets.fromLTRB(22, 0, 22, 20 + MediaQuery.of(c).viewInsets.bottom),
      child: SingleChildScrollView(child: builder(c)),
    ),
  );
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Column(children: [
        Row(children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ]),
        const Divider(height: 1),
        const SizedBox(height: 14),
      ]);
}

Widget _labeled(String label, Widget child) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        child,
      ]),
    );

InputDecoration _dec(BuildContext c, {String? hint}) => InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(c).brightness == Brightness.dark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(c).dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(c).dividerColor),
      ),
    );

Widget _field(TextEditingController c, String label, {String? hint, String? Function(String?)? validator}) =>
    Builder(builder: (ctx) => _labeled(label, TextFormField(controller: c, validator: validator, decoration: _dec(ctx, hint: hint))));

Widget _actions(BuildContext context, String cancel, String save, VoidCallback onSave) => Column(children: [
      SizedBox(
        width: double.infinity,
        height: 56,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: brand,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          onPressed: onSave,
          child: Text(save, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ),
      const SizedBox(height: 4),
      SizedBox(
        width: double.infinity,
        height: 44,
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancel, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
    ]);

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.minutes, required this.onPicked});
  final String label;
  final int minutes;
  final ValueChanged<int> onPicked;

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return _la