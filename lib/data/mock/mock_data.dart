import '../models/app_user.dart';
import '../models/garden_task.dart';

/// захардкоджені дані для відображення інтерфейсу до підключення Firebase
abstract final class MockData {
  static const AppUser user = AppUser(
    fullName: 'Анна Морозова',
    vocativeName: 'Анно',
    email: 'anna.morozova@gmail.com',
    plotsCount: 6,
    plantsCount: 18,
    tasksCount: 42,
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