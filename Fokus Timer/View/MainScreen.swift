//
//  MainScreen.swift
//  Fokus Timer
//
//  Created by Indra Permana on 24/09/20.
//

import SwiftUI

struct MainScreen: View {
    @Environment(\.calendar) var calendar
    @State var components = DateComponents()
    @State private var taskTrackerScreenOffset = CGSize(width: 0, height: UIScreen.main.bounds.height * 0.8)
    @GestureState private var taskTrackerTranslation: CGFloat = 0
    @ObservedObject var timeTrackerViewModel = TimeTrackerViewModel()
    @State var selectedDate = Date()
    @State var currentDate = Date()
    @State private var selectedDay = 0
    @State var isSwipping = true
    @State var startPos : CGPoint = .zero
    
    var body: some View {
        GeometryReader { geomerty in
            Color("white").edgesIgnoringSafeArea(.all)
            VStack {
                // add one more view (week header, following $selectedDay State)
                CalendarView(interval: .init()) { date in
                    if isCurrentDate(date: date) {
                    Text("30").hidden()
                        .padding(12.0)
                        .background(isSelectedDateIsToday(date: date) ? Color("focus") : Color.clear)
                        .clipShape(Circle())
                        .overlay(
                            Text(getCurrentDate(date: date))
                                .foregroundColor(isSelectedDateIsToday(date: date) ? Color("white") : Color("focus"))
                                .bold()
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Text("30").hidden()
                            .padding(12.0)
                            .background(date == selectedDate ? Color("break") : Color.clear)
                            .clipShape(Circle())
                            .overlay(
                                Text(getCurrentDate(date: date))
                                    .foregroundColor(Color("black"))
                            )
                            .onTapGesture {
                                selectedDate = date
                            }
                    }
                }
                PagerView(pageCount: 6, currentIndex: $selectedDay) {
                    // This will be taskview list
                    Color("break")
                    Color("blue")
                    Color("focus")
                    Color("break")
                    Color("blue")
                    Color("focus")
                }
            }
            
            TaskTrackerScreen(timeTrackerViewModel: timeTrackerViewModel)
                .offset(y: !timeTrackerViewModel.isTimerStarted() ? taskTrackerScreenOffset.height : geomerty.size.height * 0.03)
                .offset(y: taskTrackerTranslation)
                .animation(.interactiveSpring())
                .gesture(
                    DragGesture()
                        .updating($taskTrackerTranslation) { value, state, _ in
                            // Add drag effect only when taskTrackerScreen is down
                            if taskTrackerScreenOffset.height >= geomerty.size.height * 0.8 {
                                state = value.translation.height
                            }
                        }
                        .onChanged { gesture in
                            if isSwipping {
                                startPos = gesture.location
                                isSwipping.toggle()
                            }
                        }
                        .onEnded { gesture in
                            if !timeTrackerViewModel.isTimerStarted() {
                                // Handle Vertical Swipe
                                if gesture.translation.height < geomerty.size.height * 0.18 {
                                    print("up")
                                    taskTrackerScreenOffset.height = geomerty.size.height * 0.03
                                } else {
                                    print("down")
                                    taskTrackerScreenOffset.height = geomerty.size.height * 0.8
                                }
                                // Handle Horizontal Swipe
                                let gestureLocX = gesture.location.x
                                let xDist =  abs(gestureLocX - startPos.x)
                                let yDist =  abs(gesture.location.y - startPos.y)
                                if isSwipeFromFocusToBreak(gestureLocX: gestureLocX, yDist: yDist, xDist: xDist) {
                                    print("Left")
                                    timeTrackerViewModel.toggleSelectedActivity()
                                }
                                else if isSwipeFromBreakToFocus(gestureLocX: gestureLocX, yDist: yDist, xDist: xDist) {
                                    print("Right")
                                    timeTrackerViewModel.toggleSelectedActivity()
                                }
                                isSwipping.toggle()
                            }
                        }
                )
                .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    func isSwipeFromFocusToBreak(gestureLocX: CGFloat, yDist: CGFloat, xDist: CGFloat ) -> Bool {
        return startPos.x > gestureLocX && yDist < xDist && timeTrackerViewModel.selectedActivity == .focus_time
    }
    
    func isSwipeFromBreakToFocus(gestureLocX: CGFloat, yDist: CGFloat, xDist: CGFloat ) -> Bool {
        return startPos.x < gestureLocX && yDist < xDist && timeTrackerViewModel.selectedActivity == .break_time
    }
    func getCurrentDate(date: Date) -> String {
        return String(calendar.component(.day, from: date))
    }
    func isCurrentDate(date: Date) -> Bool {
        return calendar.component(.day, from: date) == calendar.component(.day, from: Date())
    }
    func isSelectedDateIsToday(date: Date) -> Bool {
        return (calendar.component(.day, from: selectedDate), calendar.component(.day, from: Date())) == (calendar.component(.day, from: Date()), calendar.component(.day, from: date))
    }
    func setDateTextColor(date: Date) -> Color {
        if isCurrentDate(date: date) && !isSelectedDateIsToday(date: date) {
            return Color("focus")
        } else {
            return Color("white")
        }
    }
    func setDateBgColor(date: Date) -> Color {
        if isCurrentDate(date: date) && isSelectedDateIsToday(date: date) {
            return Color("focus")
        } else if selectedDate == date {
            print("this day")
            return Color(.brown)
        } else {
            return Color("blue")
        }
    }
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
