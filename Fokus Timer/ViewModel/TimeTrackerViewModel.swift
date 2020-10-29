//
//  TimeTrackerViewModel.swift
//  Fokus Timer
//
//  Created by Indra Permana on 11/09/20.
//

import Foundation
import UIKit
import Combine

class TimeTrackerViewModel: ObservableObject {
    @Published var selectedActivity: ActivityState = .focus_time
    @Published var timeTrackerState: TimeTrackerState = .idle
    @Published var timerState: TimerState = .off
    @Published var activityTime: Date = Date()
    @Published var timerTimeElapsed = 0
    @Published var activityTitle: String = "" {
        didSet {
            if activityTitle.count > titleCharacterLimit && oldValue.count <= titleCharacterLimit {
                activityTitle = oldValue
            }
        }
    }
    @Published var timerTimeElapsedDisplay = ""
    @Published var todayFocusTasks: [Task] = []
    @Published var todayBreakTasks: [Task] = []
    @Published var totalFocusTime: String = ""
    @Published var totalBreakTime: String = ""
    @Published var selectedDate = Date()
    
    @Published var isTrackerScreenFullyShown = false
    var startedTask: Task?
    var timerTime:Int  {
        get {
            if selectedActivity == .focus_time {
                return UserDefaults.standard.integer(forKey: "focus-time")
            } else  {
                return UserDefaults.standard.integer(forKey: "break-time")
            }
        }
    }
    var trackerBags = Set<AnyCancellable>()
    var bags = Set<AnyCancellable>()
    let notificationManager = NotificationManager()
    let settingsValues = SettingsValues()
    var dataManager = DataManager.shared
    var titleCharacterLimit = 50
    init() {
        $selectedDate
            .receive(on: RunLoop.main)
            .sink { [weak self] date in
                print("selected date: \(date)")
                let tasks: [Task]? = self?.dataManager.fetchTasks(for: date)
                self?.todayFocusTasks = tasks?.filter {$0.type == ActivityState.focus_time.rawValue} ?? []
                self?.todayBreakTasks = tasks?.filter {$0.type == ActivityState.break_time.rawValue} ?? []
                self?.totalFocusTime = self?.displayTime(second: self?.todayFocusTasks.reduce(0) {$0 + $1.totalTimeInSeconds} ?? 0) ?? ""
                self?.totalBreakTime = self?.displayTime(second: self?.todayBreakTasks.reduce(0) {$0 + $1.totalTimeInSeconds} ?? 0) ?? ""
            }.store(in: &bags)
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
    func isTrackerStarted() -> Bool {
        return timeTrackerState == .started ? true : false
    }
    func startTimer(at time: Date = Date()){
        let dateNow = Date()
        var startActivityTime = time
        if startActivityTime < dateNow {
            timerTimeElapsed = Int(dateNow.timeIntervalSince(startActivityTime))
        } else {
            print("time is same")
        }
        if timerState == .on {
            
            
            print("Timer is set \(timerTime) s")
            notificationManager.notifications = [NotificationText(id: "com.indrapp.fokus", title: "Congrats!", body: "You have finished your task", timeInterval: Double(timerTime))]
            notificationManager.schedule()
            timerTimeElapsed = timerTime
            // cancel timerCancellable when timerTimeElapsed is equal to alarm time
            $timerTimeElapsed
                .receive(on: RunLoop.main)
                .sink { [weak self] value in
                    if (value) == 0 {
                        self?.stopTimer()
                        // TODO: Fire up sound
                        
                    }
                }.store(in: &trackerBags)
            startActivityTime.addTimeInterval(Double(timerTime + 1))
        }
        
        $timerTimeElapsed
            .receive(on: RunLoop.main)
            .sink { [weak self] int in
                self?.timerTimeElapsedDisplay = self?.displayTime(second: int) ?? ""
            }
            .store(in: &trackerBags)
        
        print("time started: \(startActivityTime)")
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .map {(output) in
                return output.timeIntervalSince(startActivityTime)
            }
            .map {(timeInterval) in
                return abs(Int(timeInterval))
            }
            .sink {[weak self] (recievedTimeStamp) in
                self?.timerTimeElapsed = recievedTimeStamp
            }.store(in: &trackerBags)

        
            
    }
    func saveStartedTimerToCoreData() {
        let timeStart = Date()
        let type = selectedActivity.rawValue
        print(selectedActivity.rawValue)
        dataManager.createTask(timeStart: timeStart, title: activityTitle, type: type, timerState: timerState.rawValue)
        
    }
    
    func updateStopTimerToCoreData(timeStop: Date) {
        if let unfinishedTask = dataManager.fetchUnfinishedTask() {
            dataManager.updateUnfinishedTask(for: unfinishedTask, timeStop: timeStop)
        }
    }
    
    
    func stopTimer(cancelNotif: Bool = true, timeStop:Date = Date()) {
        if cancelNotif {
            // Check notif and if there's one scheduled cancel em
            let notification = UNUserNotificationCenter.current()
            notification.removeAllPendingNotificationRequests()
        }

        trackerBags.removeAll()
        timeTrackerState = .stopped
        updateStopTimerToCoreData(timeStop: timeStop)
        let date = selectedDate
        timeTrackerState = .idle
        selectedDate = date
    }
    
    func unfinishedTaskExist() -> Bool {
        if let unfinishedTask = dataManager.fetchUnfinishedTask(), let timeStart = unfinishedTask.time_start {
            selectedActivity = unfinishedTask.taskType
            activityTitle = unfinishedTask.titleText
            timeTrackerState = .started
            timerState = TimerState(rawValue: unfinishedTask.timer ?? "off")!
            let expectedTimeFinished = timeStart.addingTimeInterval(Double(timerTime))
            print("expectedTimeFinished = \(expectedTimeFinished), timerTime = \(timerTime)")
            if timerState == .on && expectedTimeFinished <= Date() {
                print("yes cancel")
                stopTimer(cancelNotif: false, timeStop: expectedTimeFinished)
            } else {
                startTimer(at: timeStart)
            }
            return true
            
        } else {
            return false
        }
    }
    
    func playHapticEngine() {
        let hapticGenerator = UIImpactFeedbackGenerator()
        hapticGenerator.impactOccurred()
    }
    
    func playSuccessHapticEngine() {
        let hapticGenerator = UINotificationFeedbackGenerator()
        hapticGenerator.notificationOccurred(.success)
    }
    
    func displayTime(second: Int) -> String {
        let hours = "\(second / 3600)"
        let minutes = "\((second % 3600) / 60)"
        let seconds = "\((second % 3600) % 60)"
        let minuteStamp = minutes.count > 1 ? minutes : "0" + minutes
        let secondStamp = seconds.count > 1 ? seconds : "0" + seconds
        
        return "\(hours):\(minuteStamp):\(secondStamp)"
    }
    
}


