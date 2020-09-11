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
    
    
}
