import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../state/finance_store.dart';

class CsvExportService {
  Future<void> exportLedger(FinanceStore store) async {
    final rows = <List<dynamic>>[
      ['Type', 'Title', 'Amount', 'Meta', 'Date'],
      ...store.expenses.map(
        (e) => ['expense', e.title, e.amount, e.category, e.loggedAt.toIso8601String()],
      ),
      ...store.incomes.map(
        (e) => ['income', e.label, e.amount, e.cadence.name, ''],
      ),
      ...store.debts.map(
        (e) => [
          e.direction.name,
          e.contactName,
          e.amount,
          e.settled ? 'settled' : 'open',
          e.dueDate.toIso8601String(),
        ],
      ),
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/campusledger_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString(csv);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: 'CampusLedger export',
        text: 'Your CampusLedger CSV export',
      ),
    );
  }
}
