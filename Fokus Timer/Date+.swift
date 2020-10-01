//
//  Date+.swift
//  Fokus Timer
//
//  Created by Indra Permana on 23/09/20.
//

import Foundation

extension Date {
    func localizedDescription(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .medium,
                              in timeZone : TimeZone = .current,
                              locale   : Locale = .current) -> String {

        DateFormatter().locale = locale
        DateFormatter().timeZone = timeZone
        DateFormatter().dateStyle = dateStyle
        DateFormatter().timeStyle = timeStyle
        return DateFormatter().string(from: self)
    }
    
    var fullDate: String {
        localizedDescription(dateStyle: .full, timeStyle: .none)
    }
    var shortDate: String {
        localizedDescription(dateStyle: .short, timeStyle: .none)
    }
    var longTime: String {
        localizedDescription(dateStyle: .none, timeStyle: .long)
    }
    var shortTime: String {
        localizedDescription(dateStyle: .none, timeStyle: .short)
    }
}
