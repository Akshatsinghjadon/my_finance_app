enum IncomeCadence { daily, weekly, gig, monthly }

class IncomeStream {
  IncomeStream({
    required this.id,
    required this.label,
    required this.amount,
    required this.cadence,
  });

  final String id;
  String label;
  double amount;
  IncomeCadence cadence;

  double get monthlyEstimate {
    switch (cadence) {
      case IncomeCadence.daily:
        return amount * 30;
      case IncomeCadence.weekly:
        return amount * 4.33;
      case IncomeCadence.gig:
        return amount * 4;
      case IncomeCadence.monthly:
        return amount;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'amount': amount,
        'cadence': cadence.name,
      };

  factory IncomeStream.fromJson(Map<String, dynamic> json) => IncomeStream(
        id: json['id'] as String,
        label: json['label'] as String,
        amount: (json['amount'] as num).toDouble(),
        cadence: IncomeCadence.values.byName(json['cadence'] as String),
      );
}

class BaselineNeeds {
  BaselineNeeds({
    this.food = 0,
    this.hostelRent = 0,
    this.messFees = 0,
    this.utilities = 0,
    this.transport = 0,
  });

  double food;
  double hostelRent;
  double messFees;
  double utilities;
  double transport;

  double get monthlyTotal =>
      food + hostelRent + messFees + utilities + transport;

  Map<String, dynamic> toJson() => {
        'food': food,
        'hostelRent': hostelRent,
        'messFees': messFees,
        'utilities': utilities,
        'transport': transport,
      };

  factory BaselineNeeds.fromJson(Map<String, dynamic> json) => BaselineNeeds(
        food: (json['food'] as num?)?.toDouble() ?? 0,
        hostelRent: (json['hostelRent'] as num?)?.toDouble() ?? 0,
        messFees: (json['messFees'] as num?)?.toDouble() ?? 0,
        utilities: (json['utilities'] as num?)?.toDouble() ?? 0,
        transport: (json['transport'] as num?)?.toDouble() ?? 0,
      );
}

class ExpenseEntry {
  ExpenseEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.loggedAt,
  });

  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime loggedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'loggedAt': loggedAt.toIso8601String(),
      };

  factory ExpenseEntry.fromJson(Map<String, dynamic> json) => ExpenseEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        loggedAt: DateTime.parse(json['loggedAt'] as String),
      );
}

enum EventKind { cultural, personal }

class EventBudget {
  EventBudget({
    required this.id,
    required this.name,
    required this.kind,
    required this.cap,
    this.spent = 0,
    this.eventDate,
  });

  final String id;
  String name;
  EventKind kind;
  double cap;
  double spent;
  DateTime? eventDate;

  double get remaining => (cap - spent).clamp(0, double.infinity);
  double get progress => cap <= 0 ? 0 : (spent / cap).clamp(0, 1.5);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kind': kind.name,
        'cap': cap,
        'spent': spent,
        'eventDate': eventDate?.toIso8601String(),
      };

  factory EventBudget.fromJson(Map<String, dynamic> json) => EventBudget(
        id: json['id'] as String,
        name: json['name'] as String,
        kind: EventKind.values.byName(json['kind'] as String),
        cap: (json['cap'] as num).toDouble(),
        spent: (json['spent'] as num?)?.toDouble() ?? 0,
        eventDate: json['eventDate'] == null
            ? null
            : DateTime.parse(json['eventDate'] as String),
      );
}

enum DebtDirection { lent, borrowed }

class DebtRecord {
  DebtRecord({
    required this.id,
    required this.contactName,
    required this.amount,
    required this.direction,
    required this.dueDate,
    this.note = '',
    this.settled = false,
    this.notificationId,
  });

  final String id;
  String contactName;
  double amount;
  DebtDirection direction;
  DateTime dueDate;
  String note;
  bool settled;
  int? notificationId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'contactName': contactName,
        'amount': amount,
        'direction': direction.name,
        'dueDate': dueDate.toIso8601String(),
        'note': note,
        'settled': settled,
        'notificationId': notificationId,
      };

  factory DebtRecord.fromJson(Map<String, dynamic> json) => DebtRecord(
        id: json['id'] as String,
        contactName: json['contactName'] as String,
        amount: (json['amount'] as num).toDouble(),
        direction: DebtDirection.values.byName(json['direction'] as String),
        dueDate: DateTime.parse(json['dueDate'] as String),
        note: json['note'] as String? ?? '',
        settled: json['settled'] as bool? ?? false,
        notificationId: json['notificationId'] as int?,
      );
}
