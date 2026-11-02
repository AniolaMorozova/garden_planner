import '../models/garden_task.dart';

/// захардкоджені дані, які ще не зберігаються у cloud firestore
/// дані користувача (імʼя, пошта, фото) тепер беруться з firebase auth
abstract final class MockData {
  // заглушка статистики профілю до підключення firestore
  static const ({int plots, int plants, int tasks}) stats = (
    plots: 6,
    plants: 18,
    tasks: 42,
  );

  // роботи на сьогодні
  static const List<GardenTask> todayTasks = [
    GardenTask(
      id: 't1',
      title: 'Полив томатів',
      plotName: 'Теплиця',
      timeLabel: '7:00',
      type: TaskType.watering,
      isDone: true,
    ),
    GardenTask(
      id: 't2',
      title: 'Підживлення троянд',
      plotName: 'Квітник',
      timeLabel: '10:00',
      type: TaskType.feeding,
    ),
    GardenTask(
      id: 't3',
      title: 'Обрізання малини',
      plotName: 'Ділянка №2',
      timeLabel: '14:00',
      type: TaskType.pruning,
    ),
    GardenTask(
      id: 't4',
      title: 'Прополювання грядок',
      plotName: 'Город',
      timeLabel: '17:30',
      type: TaskType.other,
    ),
  ];
}
