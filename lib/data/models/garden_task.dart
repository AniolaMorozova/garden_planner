enum TaskType {
  planting('Посадка'),
  watering('Полив'),
  feeding('Підживлення'),
  pruning('Обрізання'),
  harvesting('Збір врожаю'),
  other('Інше');

  const TaskType(this.label);

  final String label;
}

/// запланована садова робота
class GardenTask {
  const GardenTask({
    required this.id,
    required this.title,
    required this.plotName,
    required this.timeLabel,
    required this.type,
    this.isDone = false, // значення за замовчуванням: ще не виконано
  });

  final String id;
  final String title; // «Полив томатів»
  final String plotName; // «Теплиця»
  final String timeLabel; // «7:00»
  final TaskType type;
  final bool isDone;

  /// обʼєкт незмінний (усі поля final), тому для зміни статусу створюємо копію з новим значенням isDone.
  /// знадобиться, коли користувач поставить галочку на головному екрані
  GardenTask copyWith({bool? isDone}) => GardenTask(
    id: id,
    title: title,
    plotName: plotName,
    timeLabel: timeLabel,
    type: type,
    isDone: isDone ?? this.isDone, // ?? — якщо null, лишаємо старе значення
  );
}