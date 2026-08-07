import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:traqtrace_app/features/automation_center/widgets/lazy_indexed_stack.dart';

class _Probe extends StatefulWidget {
  const _Probe(this.label, this.onCreate);

  final String label;
  final VoidCallback onCreate;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  int value = 0;

  @override
  void initState() {
    super.initState();
    widget.onCreate();
  }

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => setState(() => value++),
    child: Text('${widget.label}:$value'),
  );
}

void main() {
  testWidgets('builds a panel on first selection and retains visited state', (
    tester,
  ) async {
    var index = 0;
    var firstCreates = 0;
    var secondCreates = 0;
    late StateSetter setHostState;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            setHostState = setState;
            return LazyIndexedStack(
              index: index,
              children: [
                _Probe('first', () => firstCreates++),
                _Probe('second', () => secondCreates++),
              ],
            );
          },
        ),
      ),
    );

    expect(firstCreates, 1);
    expect(secondCreates, 0);
    await tester.tap(find.text('first:0'));
    await tester.pump();

    setHostState(() => index = 1);
    await tester.pump();
    expect(firstCreates, 1);
    expect(secondCreates, 1);

    setHostState(() => index = 0);
    await tester.pump();
    expect(find.text('first:1'), findsOneWidget);
    expect(firstCreates, 1);
    expect(secondCreates, 1);
  });
}
