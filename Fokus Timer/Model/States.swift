//
//  States.swift
//  Fokus Timer
//
//  Created by Indra Permana on 14/09/20.
//

import Foundation

enum ActivityState: String, CaseIterable, Identifiable {
    case focus_time = "focus"
    case break_time = "break"

    var id: String { self.rawValue }
}

enum TimeTrackerState: String, CaseIterable, Identifiable {
    case idle
    case started
    case paused
    case stopped
    
    var id: String { self.rawValue }
}

enum TimerState: String, CaseIterable, Identifiable {
    case off
    case on
    
    var id: String { self.rawValue }
}


