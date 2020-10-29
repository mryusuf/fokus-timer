//
//  Calendar.swift
//  Fokus Timer
//
//  Created by Indra Permana on 30/09/20.
//

import SwiftUI

extension DateFormatter {
    
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
        
        return dates
    }
}

struct CalendarView<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar

    @State private var startWeek: Date
    @Binding private var selectedDate: Date
    let showHeaders: Bool
    let content: (Date) -> DateView

    init(
        startWeek: Date,
        selectedDate: Binding<Date>,
        showHeaders: Bool = true,
        @ViewBuilder content: @escaping (Date) -> DateView
    ) {
        self._startWeek = State(initialValue: startWeek)
        self._selectedDate = selectedDate
        self.showHeaders = showHeaders
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: 7)) {
            ForEach([months.first], id: \.self) { month in
                Section(header: header(for: startWeek)) {
                    ForEach(days(for: month!), id: \.self) { date in
                        content(date).id(date)
                    }
                }
            }
        }
    }

    private var months: [Date] {
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: startWeek) else { return [] }
        return calendar.generateDates(
            inside: weekInterval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }
    
    func changeDateBy(_ week: Int) {
        if let date = Calendar.current.date(byAdding: .weekdayOrdinal, value: week, to: startWeek) {
            self.startWeek = date
        }
    }

    private func header(for month: Date) -> some View {
        var monthToDisplay = month
        if calendar.isDate(selectedDate, equalTo: month, toGranularity: .weekOfYear) {
//            print("selected date from calendar: \(selectedDate)")
            monthToDisplay = selectedDate
        }
        let component = calendar.component(.weekOfMonth, from: monthToDisplay)
        let formatter = component == 1 ? DateFormatter.monthAndYear : .month
        let dayFormatter = DateFormatter.day
        return Group {
            if showHeaders {
                HStack {
                Text(formatter.string(from: monthToDisplay))
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("black"))
                    .padding()
                Spacer()
                HStack{
                    Group{
                        Button(action: {
                            self.changeDateBy(-1)
                        }) {
                            Image(systemName: "chevron.left.square") //
                                .resizable()
                        }
                        Button(action: {
                            self.startWeek = Date()
                        }) {
                            Image(systemName: "dot.square")
                                .resizable()
                        }
                        Button(action: {
                            self.changeDateBy(1)
                        }) {
                            Image(systemName: "chevron.right.square") //"chevron.right.square"
                                .resizable()
                        }
                    }
                    .foregroundColor(Color.blue)
                    .frame(width: 25, height: 25)
                    
                }
                .padding(.trailing, 20)
                }
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

//struct CalendarView_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarView(startWeek: Date(), selectedDat: Date(), showHeaders: true) { day in
//            Text("30")
//                .padding(12)
//                .padding(.horizontal, 3)
//                .background(Color("white"))
//                .cornerRadius(12)
//        }
//    }
//}
