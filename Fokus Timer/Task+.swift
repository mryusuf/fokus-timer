//
//  TimerRepository.swift
//  Fokus Timer
//
//  Created by Indra Permana on 21/09/20.
//

import Foundation
import CoreData

extension Task {
    var taskType: ActivityState {
        ActivityState(rawValue: type ?? "") ?? .break_time
    }

    var titleText: String {
        if title != "" {
            return title!
        } else {
            return "My activity"
        }
    }
    var dateText: String {
        time_start?.fullDate ?? Date().fullDate
    }
    var timeText: String {
        var str = ""
        if let time_start = time_start, let time_stop = time_stop {
            let diffComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time_start, to: time_stop)
            let hours = diffComponents.hour?.description
            let minutes = diffComponents.minute?.description
            let seconds = diffComponents.second?.description
            if let hours = hours, let minutes = minutes, let seconds = seconds {
//                let hourStamp = hours.count > 1 ? hours : "0" + hours
                let minuteStamp = minutes.count > 1 ? minutes : "0" + minutes
                let secondStamp = seconds.count > 1 ? seconds : "0" + seconds
                str = "\(hours):\(minuteStamp):\(secondStamp)"
            }
        }
        return str
    }
    var totalTimeInSeconds: Int {
        if let time_start = time_start, let time_stop = time_stop {
            return Int(time_stop.timeIntervalSince(time_start))
        } else {
            return 0
        }
    }
}

