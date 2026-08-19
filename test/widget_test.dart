import 'package:flutter_test/flutter_test.dart';
import 'package:my_finance_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CampusLedger shell loads', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(find.text('CampusLedger'), findsWidgets);
  });
}
