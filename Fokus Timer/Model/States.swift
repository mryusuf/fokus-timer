//
//  States.swift
//  Fokus Timer
//
//  Created by Indra Permana on 14/09/20.
//

import Foundation

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


