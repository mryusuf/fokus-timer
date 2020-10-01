//
//  TimerRepository.swift
//  Fokus Timer
//
//  Created by Indra Permana on 21/09/20.
//

import Foundation

extension Task {
    var taskType: ActivityState {
        ActivityState(rawValue: type ?? "") ?? .break_time
    }
    
    var titleText: String {
        title ?? "My activity"
    }
    var dateText: String {
        time_start?.fullDate ?? Date().fullDate
    }
    var timeText: String {
        time_start?.shortTime ?? Date().shortTime
    }
}

