import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_project/main.dart';

void main() {
  testWidgets('App boots and shows auth screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Auth screen contains the app title.
    expect(find.text('Виртуальный холодильник'), findsWidgets);
  });
}
