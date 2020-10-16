//
//  WeekCalendarHeader.swift
//  Fokus Timer
//
//  Created by Indra Permana on 05/10/20.
//

import SwiftUI

struct WeekCalendarHeader: View {
    var date: Date
    var backgroundColor: Color
    var foregroundColor: Color
    var dateString: String
    var body: some View {
        Text("30").hidden()
            .padding(12.0)
            .background(backgroundColor)
            .clipShape(Circle())
            .overlay(
                Text(dateString)
                    .foregroundColor(foregroundColor)
            )
    }

}
