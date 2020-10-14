//
//  Calendar.swift
//  Fokus Timer
//
//  Created by Indra Permana on 30/09/20.
//

import SwiftUI

fileprivate extension DateFormatter {
    
    static var day: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }
    
    static var month: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }

    static var monthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

fileprivate extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)
//        print(interval.start)
//        print(interval.end)

        enumerateDates(
            startingAfter: interval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        
//        print("the date generated: \(dates.last)")
        return dates
    }
}

struct CalendarView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar

    let interval: DateInterval
    let showHeaders: Bool
    let content: (Date) -> DateView

    init(
        interval: DateInterval,
        showHeaders: Bool = true,
        @ViewBuilder content: @escaping (Date) -> DateView
    ) {
        self.interval = interval
        self.showHeaders = showHeaders
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
            ForEach(months, id: \.self) { month in
                Section(header: header(for: month)) {
                    ForEach(days(for: month), id: \.self) { date in
                        content(date).id(date)
                    }
                }
            }
        }
    }

    private var months: [Date] {
        calendar.generateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }

    private func header(for month: Date) -> some View {
        let component = calendar.component(.weekdayOrdinal, from: month)
        let formatter = component == 1 ? DateFormatter.monthAndYear : .month
        let dayFormatter = DateFormatter.day
        return Group {
            if showHeaders {
                Text(formatter.string(from: month))
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("black"))
                    .padding()
            }
            LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
                ForEach(days(for: month), id: \.self) { day in
                    Text(dayFormatter.string(from: day))
                        .foregroundColor(Color("gray"))
                        .font(.system(size: 14))
                }
            }
            Divider()
        }
    }

    private func days(for date: Date) -> [Date] {
        guard
            let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: date),
            let firstWeek = calendar.dateInterval(of: .weekday, for: weekInterval.start),
            let lastWeek = calendar.dateInterval(of: .weekday, for: weekInterval.end - 1)
        else { return [] }
        return calendar.generateDates(
            inside: DateInterval(start: firstWeek.start, end: lastWeek.end),
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(interval: .init(), showHeaders: true) { day in
            Text("30")
                .padding(12)
                .padding(.horizontal, 3)
                .background(Color("white"))
                .cornerRadius(12)
        }
    }
}
