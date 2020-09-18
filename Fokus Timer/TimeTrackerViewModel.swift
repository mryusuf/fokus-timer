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
    @Published var timerState: TimerState = .idle
    @Published var alarmState: AlarmState = .off
    @Published var activityTime: Date = Date()
    @Published var timerTimeElapsed = 0
    @Published var activityTitle: String = ""
    
    var setAlarm = 15
    var timerCancellable = Set<AnyCancellable>()
    
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
        switch alarmState {
        case .off:
            alarmState = .on
        case .on:
            alarmState = .off
        }
    }
    
    func toggleTimer() {
        switch timerState {
        case .idle:
            
            print("timer started")
            // Start Timer and save date to db
            timerState = .started
            startTimer()
        case .started:
            print("timer stopped")
            stopTimer()
            // TODO: - make func to update db, then when finished, reset timerState to .idle
        case .stopped:
            timerState = .idle
        default:
            print("not avalilable")
        }
    }
    func startTimer(){
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
                print(self?.timerTimeElapsed ?? 0)
            }.store(in: &timerCancellable)

        if alarmState == .on {
            print("Alarm is on")
            // cancel timerCancellable when timerTimeElapsed is equal to alarm time
            $timerTimeElapsed
                .receive(on: RunLoop.main)
                .sink(receiveValue: {value in
                    if value == self.setAlarm {
                        self.stopTimer()
                        // TODO: Fire up sound and notification
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
        timerState = .stopped
    }
    
}
