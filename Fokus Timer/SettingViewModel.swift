//
//  SettingsViewModel.swift
//  Fokus Timer
//
//  Created by Indra Permana on 14/10/20.
//

import Foundation
import Combine
import AudioToolbox

class SettingsViewModel: ObservableObject {
    let viewModel = SettingsValues()
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
                AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { return }
            } else if time > 1339 {
                focusTimeString = 1339.description
                // can't set > 23:59
                AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { return }
            }
            viewModel.setFocusTime(minute: time)
        }
    }
    @Published var breakTimeString: String = "" {
        didSet {
            let filtered = focusTimeString.filter { $0.isNumber }
            if focusTimeString != filtered {
                focusTimeString = filtered
            }
            let time = Int(breakTimeString) ?? 1
            if time < 1 {
                breakTimeString = 1.description
                AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { return }
            } else if time > 1440 {
                breakTimeString = 1339.description
                AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { return }
            }
            viewModel.setBreakTime(minute: time)
        }
    }
    
    var bags = Set<AnyCancellable>()
    
    init() {
        viewModel.$focusTime
            .map { int in int.description }
            .receive(on: RunLoop.main)
            .sink {[weak self] time in
                self?.focusTimeString = time
            }
            .store(in: &bags)
        viewModel.$breakTime
            .map { int in int.description}
            .receive(on: RunLoop.main)
            .sink {[weak self] time in
                self?.breakTimeString = time
            }
            .store(in: &bags)
    }
}
