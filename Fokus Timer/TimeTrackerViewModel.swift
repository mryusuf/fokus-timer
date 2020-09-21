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
    
    var timerTime:Double = 15
    var timerCancellable = Set<AnyCancellable>()
    let notificationManager = NotificationManager()
    
    // MARK: - Intents
    // TODO: This is naive approach, change this to Combine !
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
            timeTrackerState = .started
            startTimer()
        case .started:
            print("timer stopped")
            stopTimer()
            // TODO: - make func to update db, then when finished, reset timerState to .idle
        case .stopped:
            timeTrackerState = .idle
        default:
            print("not avalilable")
        }
    }
    func startTimer(){
        timerTimeElapsed = 0
        $timerTimeElapsed
            .receive(on: RunLoop.main)
            .sink { [weak self] int in
                self?.timerTimeElapsedDisplay = self?.displayTime(second: int) ?? ""
                print(int)
            }
            .store(in: &timerCancellable)
        
        let startActivityTime = Date()
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
            }.store(in: &timerCancellable)

        if timerState == .on {
            print("Timer is on")
            notificationManager.notifications = [Notification(id: "com.indrapp.fokus", title: "Yeay! You have finished your Activity", timeInterval: timerTime)]
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
                }).store(in: &timerCancellable)
        }
            
    }
    func saveStartedTimerToCoreData() {
        activityTime = Date() // date now
        var activityTitleToSave = ""
        if activityTitle == "" {
            activityTitleToSave = "an Activity"
        } else {
            activityTitleToSave = activityTitle
        }
        
    }
    
    func stopTimer() {
//        for cancellable in timerCancellable {
//            cancellable.cancel()
//        }
        timerCancellable.removeAll()
        timeTrackerState = .stopped
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


