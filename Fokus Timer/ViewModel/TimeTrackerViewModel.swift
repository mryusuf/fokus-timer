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
    @Published var selectedDate = Date()
    
    @Published var isTrackerScreenFullyShown = false
    var startedTask: Task?
    @Published var timerTime:Int = 15
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
                let tasks = self?.dataManager.fetchTasks(for: date)
                print("fetched task after selected date changes: \(tasks?.count ?? 0)")
                self?.todayFocusTasks = tasks?.filter {$0.type == ActivityState.focus_time.rawValue} ?? []
                self?.todayBreakTasks = tasks?.filter {$0.type == ActivityState.break_time.rawValue} ?? []
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
    func isTimerStarted() -> Bool {
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
            if selectedActivity == .focus_time {
                timerTime = UserDefaults.standard.integer(forKey: "focus-time")
            } else if selectedActivity == .break_time {
                timerTime = UserDefaults.standard.integer(forKey: "break-time")
            }
            print("Timer is set \(timerTime) s")
            notificationManager.notifications = [NotificationText(id: "com.indrapp.fokus", title: "Yeay! You have finished your Activity", timeInterval: Double(timerTime))]
            notificationManager.schedule()
            timerTimeElapsed = timerTime
            // cancel timerCancellable when timerTimeElapsed is equal to alarm time
            $timerTimeElapsed
                .receive(on: RunLoop.main)
                .sink { [weak self] value in
                    if (value) == 0 {
                        // TODO: This doesn't stop the timer if app is in background !!
                        // Workaround: save current data in db, then if app reappear in foreground, check with db if is finished
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
        
//        let startActivityTime = Date()
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
                print(recievedTimeStamp)
                self?.timerTimeElapsed = recievedTimeStamp
//                print(self?.timerTimeElapsed ?? 0)
            }.store(in: &trackerBags)

        
            
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
        // Check notif and if there's one scheduled cancel em
        let notification = UNUserNotificationCenter.current()
        notification.removeAllPendingNotificationRequests()
        print("stopTimer()")
        trackerBags.removeAll()
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


