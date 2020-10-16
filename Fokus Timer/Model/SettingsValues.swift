//
//  SettingsValues.swift
//  Fokus Timer
//
//  Created by Indra Permana on 14/10/20.
//

import Foundation

class SettingsValues {
    @Published private(set) var focusTime: Int {
        didSet {
            UserDefaults.standard.set(focusTime  * 60, forKey: focusKey)
        }
    }
    @Published private(set) var breakTime: Int {
        didSet {
            UserDefaults.standard.set(breakTime  * 60, forKey: breakKey)
        }
    }
    private let focusKey = "focus-time"
    private let breakKey = "break-time"
    
    init() {
        focusTime = UserDefaults.standard.integer(forKey: focusKey) / 60
        breakTime = UserDefaults.standard.integer(forKey: breakKey) / 60
        
        if focusTime == 0 {
            focusTime = 25
        }
        if breakTime == 0 {
            breakTime = 5
        }
    }
    
    func setFocusTime(minute: Int) {
        focusTime = minute
        
//        print("SettingsValues: time is set \(focusTime)")
    }
    
    func setBreakTime(minute: Int) {
        breakTime = minute
    }
    
    func getFocusTIme() -> Int {
        return UserDefaults.standard.integer(forKey: focusKey)
    }
    
    func getBreakTime() -> Int {
        return UserDefaults.standard.integer(forKey: breakKey)
    }
}
