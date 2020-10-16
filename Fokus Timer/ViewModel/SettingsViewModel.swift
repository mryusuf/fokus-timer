//
//  SettingsViewModel.swift
//  Fokus Timer
//
//  Created by Indra Permana on 14/10/20.
//

import Foundation
import Combine
import UIKit

class SettingsViewModel: ObservableObject {
    let settingValues = SettingsValues()
    @Published var focusTimeString: String = "" {
        didSet {
            let filtered = focusTimeString.filter { $0.isNumber }
            if focusTimeString != filtered {
                focusTimeString = filtered
            }
            let time = Int(focusTimeString) ?? 1
            if time < 1 {
                focusTimeString = 1.description
                // show toast or something
                playErrorHaptic()
            } else if time > 1339 {
                focusTimeString = 1339.description
//                tempFocusTimeString = focusTimeString
                // can't set > 23:59
                playErrorHaptic()
            }
//            print("SettingsViewModel: time is set \(focusTimeString)")
            settingValues.setFocusTime(minute: Int(focusTimeString) ?? 1)
        }
    }
    @Published var breakTimeString: String = "" {
        didSet {
            let filtered = breakTimeString.filter { $0.isNumber }
            if breakTimeString != filtered {
                breakTimeString = filtered
            }
            let time = Int(breakTimeString) ?? 1
            if time < 1 {
                breakTimeString = 1.description
                playErrorHaptic()
            } else if time > 1339 {
                breakTimeString = 1339.description
                playErrorHaptic()
            }
            settingValues.setBreakTime(minute: time)
        }
    }
    @Published var tempFocusTimeString: String = "" {
        didSet {
//            print("SettingsViewModel: tempFocusTimeString \(tempFocusTimeString)")
            let filtered = focusTimeString.filter { $0.isNumber }
            if focusTimeString != filtered {
                focusTimeString = filtered
            }
            let time = Int(tempFocusTimeString) ?? 1
//            let oldTime = Int(oldValue) ?? 1
            if time < 1 {
                tempFocusTimeString = 1.description
                focusTimeString = tempFocusTimeString
                playErrorHaptic()
            } else if time > 1339 {
                tempFocusTimeString = 1339.description
                focusTimeString = tempFocusTimeString
                playErrorHaptic()
            } else if tempFocusTimeString != "" {
                focusTimeString = tempFocusTimeString
            }
        }
    }
    @Published var tempBreakTimeString: String = "" {
        didSet {
//            print("SettingsViewModel: tempBreakTimeString \(tempBreakTimeString)")
            let time = Int(tempBreakTimeString) ?? 1
            let oldTime = Int(oldValue) ?? 1
            if time < 1 {
                tempBreakTimeString = 1.description
//                playErrorHaptic()
            } else if time > 1339 && oldTime <= 1339 {
                tempBreakTimeString = oldValue
//                playErrorHaptic()
            }
//            focusTimeString = tempFocusTimeString
        }
    }
    var bags = Set<AnyCancellable>()
    
    init() {
        focusTimeString = settingValues.focusTime.description
        tempFocusTimeString = focusTimeString
        breakTimeString = settingValues.breakTime.description
        tempBreakTimeString = breakTimeString
    }
    
    func playErrorHaptic() {
        let hapticGenerator = UINotificationFeedbackGenerator()
        hapticGenerator.notificationOccurred(.error)
    }
}
