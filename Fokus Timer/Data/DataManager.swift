//
//  DataManager.swift
//  Fokus Timer
//
//  Created by Indra Permana on 05/10/20.
//

import Foundation

protocol DataManagerProtocol {
    func fetchTasks(for date: Date) -> [Task]
    func fetchUnfinishedTask() -> Task?
    func createTask(timeStart: Date, title: String, type: String, timerState: String)
    func updateUnfinishedTask(for task: Task, timeStop: Date)
  func createFinishedTask(timeStart: Date, timeStop: Date, title: String, type: String, timerState: String)
}

class DataManager: DataManagerProtocol {
    
    static let shared: DataManagerProtocol = DataManager()
    var dbHelper: CoreDataHelper = CoreDataHelper.shared
    
    func fetchTasks(for date: Date) -> [Task] {
        // Fetch all task on the date
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        let fromPredicate = NSPredicate(format: "time_start >= %@", startDate as NSDate)
        let toPredicate = NSPredicate(format: "time_start < %@", endDate as NSDate)
        let predicate = NSCompoundPredicate (andPredicateWithSubpredicates: [fromPredicate, toPredicate])
        let result: Result<[Task], Error> = dbHelper.fetch(Task.self, predicate: predicate, limit: nil)
        switch result {
        case .success(let tasks):
            return tasks.map {$0}
        case .failure(let error):
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchUnfinishedTask() -> Task? {
        // Fetch one unfinished task (should be if the last entry doesn't have stop_time)
        let predicate = NSPredicate(format: "is_finished == false")
        let result: Result<[Task], Error> = dbHelper.fetch(Task.self, predicate: predicate, limit: 1)
        switch result {
        case .success(let tasks):
//            print(tasks)
            if tasks.count > 0 {
                return tasks[0]
            } else {
                return nil
            }
        case .failure(let error):
            fatalError(error.localizedDescription)
        }
    }
    
    func createTask(timeStart: Date, title: String, type: String, timerState: String) {
        let task = Task(context: dbHelper.context)
        task.task_id = UUID()
        task.title = title
        task.time_start = timeStart
        task.type = type
        task.timer = timerState
        dbHelper.create(task)
    }
  
  func createFinishedTask(timeStart: Date, timeStop: Date, title: String, type: String, timerState: String) {
      let task = Task(context: dbHelper.context)
      task.task_id = UUID()
      task.title = title
      task.time_start = timeStart
      task.type = type
      task.timer = timerState
    task.time_stop = timeStop
    task.is_finished = true
      dbHelper.create(task)
  }
    
    func updateUnfinishedTask(for task: Task, timeStop: Date) {
        let taskToEdit = task
        taskToEdit.time_stop = timeStop
        taskToEdit.is_finished = true
        dbHelper.saveContext()
    }
    
    
}
