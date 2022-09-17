//
//  FokusTimeAttributes.swift
//  Fokus Timer
//
//  Created by Indra Permana on 16/09/22.
//

import Foundation
import ActivityKit

public struct FokusTimeAttributes: ActivityAttributes {
    public typealias FokusTime = ContentState
    
    public struct ContentState: Codable, Hashable {
        var activityName: String
        var activityType: ActivityState
        var timer: ClosedRange<Date>
        var isCountingDown: Bool
    }
    
}


public enum ActivityState: String, CaseIterable, Identifiable, Codable {
    case focus_time = "focus"
    case break_time = "break"

    public var id: String { self.rawValue }
}
