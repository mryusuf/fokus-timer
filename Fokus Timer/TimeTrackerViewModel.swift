//
//  TimeTrackerViewModel.swift
//  Fokus Timer
//
//  Created by Indra Permana on 11/09/20.
//

import Foundation
import Combine

class TimeTrackerViewModel: ObservableObject {
    @Published var selectedActivity: ActivityState = .focus_time
    @Published var timeTrackerState: TimeTrackerState = .idle
    @Published var timerState: TimerState = .off
    @Published var activityTime: Date = Date()
    @Published var timerTimeElapsed = 0
    @Published var activityTitle: String = ""
    @Published var timerTimeElapsedDisplay = ""
    @Published var todayFocusTasks: [Task] = []
    @Published var todayBreakTasks: [Task] = []
    @Published var selectedDate = Date()
    var startedTask: Task?
    var timerTime:Double = 15
    var bags = Set<AnyCancellable>()
    var selectedDateCancellable: AnyCancellable?
    let notificationManager = NotificationManager()
    
    var dataManager = DataManager.shared
    
    init() {
        selectedDateCancellable =
            $selectedDate
                .receive(on: RunLoop.main)
            .sink { [weak self] date in
                print("selected date: \(date)")
                let tasks = self?.dataManager.fetchTasks(for: date)
                print("fetched task after selected date changes: \(tasks?.count ?? 0)")
                self?.todayFocusTasks = tasks?.filter {$0.type == ActivityState.focus_time.rawValue} ?? []
                self?.todayBreakTasks = tasks?.filter {$0.type == ActivityState.break_time.rawValue} ?? []
            }
    }
    // MARK: - Intents
    func toggleSelectedActivity() {
        switch selectedActivity {
        case .focus_time:
            selectedActivity = .break_time
        case .break_time:
            selectedActivity = .focus_time
        }
    }
    
    func toggleAlarmState() {
        switch timerState {
        case .off:
            timerState = .on
        case .on:
            timerState = .off
        }
    }
    
    func toggleTimer() {
        switch timeTrackerState {
        case .idle:
            print("timer started")
            // Start Timer and save date to db
            saveStartedTimerToCoreData()
            timeTrackerState = .started
            startTimer()
        case .started:
            print("timer stopped")
            stopTimer()
            // TODO: - make func to update db, then when finished, reset timerState to .idle
        default:
            print("not avalilable")
        }
    }
    func isTimerStarted() -> Bool {
        return timeTrackerState == .started ? true : false
    }
    func startTimer(at startActivityTime: Date = Date()){
        let dateNow = Date()
        if startActivityTime < dateNow {
            timerTimeElapsed = Int(dateNow.timeIntervalSince(startActivityTime))
        } else {
            print("time is same")
        }
        $timerTimeElapsed
            .receive(on: RunLoop.main)
            .sink { [weak self] int in
                self?.timerTimeElapsedDisplay = self?.displayTime(second: int) ?? ""
            }
            .store(in: &bags)
        
//        let startActivityTime = Date()
        print("time started: \(startActivityTime)")
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .map {(output) in
                return output.timeIntervalSince(startActivityTime)
            }
            .map {(timeInterval) in
                return Int(timeInterval)
            }
            .sink {[weak self] (recievedTimeStamp) in
                self?.timerTimeElapsed = recievedTimeStamp
//                print(self?.timerTimeElapsed ?? 0)
            }.store(in: &bags)

        if timerState == .on {
            print("Timer is on")
            notificationManager.notifications = [NotificationText(id: "com.indrapp.fokus", title: "Yeay! You have finished your Activity", timeInterval: timerTime)]
            notificationManager.schedule()
            // cancel timerCancellable when timerTimeElapsed is equal to alarm time
            $timerTimeElapsed
                .receive(on: RunLoop.main)
                .sink(receiveValue: {value in
                    if Double(value) == self.timerTime {
                        // TODO: This doesn't stop the timer if app is in background !!
                        // Workaround: save current data in db, then if app reappear in foreground, check with db if is finished
                        self.stopTimer()
                        // TODO: Fire up sound
                        
                    }
                }).store(in: &bags)
        }
            
    }
    func saveStartedTimerToCoreData() {
        let timeStart = Date()
        let type = selectedActivity.rawValue
        print(selectedActivity.rawValue)
        dataManager.createTask(timeStart: timeStart, title: activityTitle, type: type, timerState: timerState.rawValue)
        
    }
    
    func updateStopTimerToCoreData() {
        if let unfinishedTask = dataManager.fetchUnfinishedTask() {
            dataManager.updateUnfinishedTask(for: unfinishedTask, timeStop: Date())
        }
    }
    
    
    func stopTimer() {
        bags.removeAll()
        timeTrackerState = .stopped
        updateStopTimerToCoreData()
        let date = selectedDate
        timeTrackerState = .idle
        selectedDate = date
    }
    
    func unfinishedTaskExist() -> Bool {
        if let unfinishedTask = dataManager.fetchUnfinishedTask(), let timeStart = unfinishedTask.time_start {
            timeTrackerState = .started
            timerState = TimerState(rawValue: unfinishedTask.timer ?? "off")!
            startTimer(at: timeStart)
            return true
            
        } else {
            return false
        }
    }
    
    func displayTime(second: Int) -> String {
        let hours = "\(second / 3600)"
        let minutes = "\((second % 3600) / 60)"
        let seconds = "\((second % 3600) % 60)"
        let hourStamp = hours.count > 1 ? hours : "0" + hours
        let minuteStamp = minutes.count > 1 ? minutes : "0" + minutes
        let secondStamp = seconds.count > 1 ? seconds : "0" + seconds
        
        return "\(hourStamp):\(minuteStamp):\(secondStamp)"
    }
    
}


