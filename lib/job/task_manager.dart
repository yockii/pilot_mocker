/// Defines a generic interface for scheduled tasks.
abstract class ScheduledTask {
  /// Starts the task.
  void start();

  /// Stops the task.
  void stop();
}

/// Manages multiple [ScheduledTask]s, allowing to start/stop all of them.
class TaskManager {
  final List<ScheduledTask> _tasks = [];

  /// Registers a new [task] to be managed.
  void register(ScheduledTask task) {
    _tasks.add(task);
  }

  /// Starts all registered tasks.
  void startAll() {
    for (var task in _tasks) {
      task.start();
    }
  }

  /// Stops all registered tasks.
  void stopAll() {
    for (var task in _tasks) {
      task.stop();
    }
  }
}
