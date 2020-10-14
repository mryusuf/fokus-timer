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
    @State private var taskTrackerScreenOffset: CGFloat = 0
    @GestureState private var taskTrackerTranslation: CGFloat = 0
    @EnvironmentObject var timeTrackerViewModel: TimeTrackerViewModel
    
    @State var currentDate = Date()
    @State private var selectedDay = 0
    @State var isSwipping = true
    @State var startPos : CGPoint = .zero
    @State var isTrackerScreenFullyShown = false
    
    init() {
        selectedDay = calendar.component(.weekday, from: currentDate)
    }
    
    var body: some View {
        GeometryReader { geomerty in
            Color("white").edgesIgnoringSafeArea(.all)
            if taskTrackerScreenOffset > geomerty.size.height * 0.03 {
                VStack {
                    CalendarView(interval: .init()) { date in
                        if isCurrentDate(date: date) {
                            WeekCalendarHeader(date: date, backgroundColor: isSelectedDateIsToday(date: date) ? Color("focus") : Color.clear, foregroundColor: isSelectedDateIsToday(date: date) ? Color("white") : Color("focus"), dateString: getCurrentDate(date: date))
                                .onTapGesture {
                                    timeTrackerViewModel.selectedDate = date
                                }
                        } else {
                            WeekCalendarHeader(date: date, backgroundColor: date == timeTrackerViewModel.selectedDate ? Color("break") : Color.clear, foregroundColor: Color("black"), dateString: getCurrentDate(date: date))
                                .onTapGesture {
                                    timeTrackerViewModel.selectedDate = date
                                }
                        }
                    }
                    TaskList(focusTasks: $timeTrackerViewModel.todayFocusTasks, breakTasks: $timeTrackerViewModel.todayBreakTasks)
                }
                .disabled(!isSwipping ? true : false)
//                .overlay(!isSwipping ? Color("overlay") : Color.clear)
            }
            
            TaskTrackerScreen(timeTrackerViewModel: _timeTrackerViewModel, isFullyShown: $isTrackerScreenFullyShown)
                .background(Color(timeTrackerViewModel.selectedActivity.rawValue))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .offset(y: !timeTrackerViewModel.isTimerStarted() ? taskTrackerScreenOffset : geomerty.size.height * 0.03)
                .offset(y: taskTrackerTranslation)
                .animation(.spring(response: 0.1, dampingFraction: 2, blendDuration: 0.01))
                .gesture(
                    DragGesture()
                        .updating($taskTrackerTranslation) { value, state, _ in
                            // Add drag effect only when taskTrackerScreen is down
                            if taskTrackerScreenOffset >= geomerty.size.height * 0.8 {
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
                                    taskTrackerScreenOffset = geomerty.size.height * 0.03
                                    print("up with offset \(taskTrackerScreenOffset)")
                                    isTrackerScreenFullyShown = true
                                } else {
                                    taskTrackerScreenOffset = geomerty.size.height * 0.8
                                    
                                    print("down with offset \(taskTrackerScreenOffset)")
                                    isTrackerScreenFullyShown = false
                                }
                                // Handle Horizontal Swipe
                                let gestureLocX = gesture.location.x
                                let xDist =  abs(gestureLocX - startPos.x)
                                let yDist =  abs(gesture.location.y - startPos.y)
                                if isSwipeFromFocusToBreak(gestureLocX: gestureLocX, yDist: yDist, xDist: xDist) {
                                    timeTrackerViewModel.toggleSelectedActivity()
                                }
                                else if isSwipeFromBreakToFocus(gestureLocX: gestureLocX, yDist: yDist, xDist: xDist) {
                                    timeTrackerViewModel.toggleSelectedActivity()
                                }
                                isSwipping.toggle()
                            }
                        }
                )
                .edgesIgnoringSafeArea(.bottom)
                .onAppear(perform: {
                    if timeTrackerViewModel.unfinishedTaskExist() {
                        taskTrackerScreenOffset = geomerty.size.height * 0.03
                        isTrackerScreenFullyShown = true
                    } else {
                        taskTrackerScreenOffset = geomerty.size.height * 0.8
                    }
                })
        }
    }
}

extension MainScreen {
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
        return (calendar.component(.day, from: timeTrackerViewModel.selectedDate), calendar.component(.day, from: Date())) == (calendar.component(.day, from: Date()), calendar.component(.day, from: date))
    }
    
}
struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
