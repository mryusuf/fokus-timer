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
    @State var isNotSwipping = true
    @State var startPos : CGPoint = .zero
    var offsetHigh: CGFloat = 0.03
    var offsetLow: CGFloat  = 0.66
    init() {
        selectedDay = calendar.component(.weekday, from: currentDate)
    }
    
    var body: some View {
        NavigationView {
        GeometryReader { geometry in
            Color("white").edgesIgnoringSafeArea(.all)
//            if taskTrackerScreenOffset > geomerty.size.height * 0.03 {
            if isNotSwipping && taskTrackerScreenOffset > UIScreen.main.bounds.height * offsetHigh {
                VStack {
                    CalendarView(interval: .init(), showHeaders: false) { date in
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
                        .frame(minHeight: 0, idealHeight: UIScreen.main.bounds.height * 0.5, maxHeight: UIScreen.main.bounds.height * 0.5)
                }
                .disabled(!isNotSwipping ? true : false)
//                .animation(.linear(duration: 0.4))
                // animation should be onappear and ondisappear
            }
            
            TaskTrackerScreen(timeTrackerViewModel: _timeTrackerViewModel, isFullyShown: $timeTrackerViewModel.isTrackerScreenFullyShown)
                .background(Color(timeTrackerViewModel.selectedActivity.rawValue))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .offset(y: !timeTrackerViewModel.isTimerStarted() ? taskTrackerScreenOffset : UIScreen.main.bounds.height * offsetHigh)
                .offset(y: taskTrackerTranslation)
                .animation(.interactiveSpring())
                .gesture(
                    DragGesture()
                        .updating($taskTrackerTranslation) { gesture, state, _ in
                            // Add drag effect only when taskTrackerScreen is up and swipe downs
                            if (taskTrackerScreenOffset >= UIScreen.main.bounds.height * offsetLow || (taskTrackerScreenOffset < UIScreen.main.bounds.height * offsetLow && startPos.y < gesture.location.y)) {
                                if timeTrackerViewModel.isTrackerScreenFullyShown && gesture.translation.height < 10 {
                                    state = 0
                                } else {
                                    state = gesture.translation.height
//                                    isNotSwipping = false
                                }
                                print("state \(state)")
                            }
                            
                        }
                        .onChanged { gesture in
                            startPos = gesture.location
                            if isNotSwipping {
                                if startPos.y < UIScreen.main.bounds.height / 5 {
                                    isNotSwipping.toggle()
                                }
                            }
                        }
                        .onEnded { gesture in
                            if !timeTrackerViewModel.isTimerStarted() {
                                if timeTrackerViewModel.isTrackerScreenFullyShown {
                                    // Handle Horizontal Swipe
                                    let gestureLocX = gesture.location.x
                                    let xDist =  abs(gestureLocX - startPos.x)
                                    let yDist =  abs(gesture.location.y - startPos.y)
                                    if isSwipeFromFocusToBreak(gestureLocX: gestureLocX, yDist: yDist, xDist: xDist) {
                                        timeTrackerViewModel.toggleSelectedActivity()
                                        timeTrackerViewModel.playHapticEngine()
                                    }
                                    else if isSwipeFromBreakToFocus(gestureLocX: gestureLocX, yDist: yDist, xDist: xDist) {
                                        timeTrackerViewModel.toggleSelectedActivity()
                                        timeTrackerViewModel.playHapticEngine()
                                    }
                                }
                                // Handle Vertical Swipe
//                                print("gesture translation height \(gesture.translation.height)")
                                 if gesture.translation.height < -10 {
                                    taskTrackerScreenOffset = UIScreen.main.bounds.height * offsetHigh
                                    print("up with offset \(gesture.translation.height)")
                                    timeTrackerViewModel.isTrackerScreenFullyShown = true
                                    isNotSwipping = false
                                    timeTrackerViewModel.playHapticEngine()
                                } else if gesture.translation.height > 60 {
                                    taskTrackerScreenOffset = UIScreen.main.bounds.height * offsetLow
                                    isNotSwipping = true
                                    print("down with offset \(taskTrackerScreenOffset)")
                                    timeTrackerViewModel.isTrackerScreenFullyShown = false
                                    timeTrackerViewModel.playHapticEngine()
                                }
                            }
                        }
                )
                .edgesIgnoringSafeArea(.bottom)
                
            }
        
        .navigationBarItems(
            trailing:
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape.fill")
                }
                
        )
        .navigationBarTitle(DateFormatter.month.string(from: currentDate), displayMode: .large)
        .navigationBarHidden(timeTrackerViewModel.isTrackerScreenFullyShown || !isNotSwipping)
        .onAppear(perform: {
            if timeTrackerViewModel.unfinishedTaskExist() {
                print("there is an unfinished task")
                taskTrackerScreenOffset = UIScreen.main.bounds.height * offsetHigh
                timeTrackerViewModel.isTrackerScreenFullyShown = true
            } else {
                timeTrackerViewModel.isTrackerScreenFullyShown = false
                taskTrackerScreenOffset = UIScreen.main.bounds.height * offsetLow
                print(taskTrackerScreenOffset)
            }
        })
        } // NavigationView
    } // Body
} // MainScreen

extension MainScreen {
    func isSwipeDown(gestureLocY: CGFloat, yDist: CGFloat) -> Bool {
        return startPos.y < gestureLocY
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
        return (calendar.component(.day, from: timeTrackerViewModel.selectedDate), calendar.component(.day, from: Date())) == (calendar.component(.day, from: Date()), calendar.component(.day, from: date))
    }
    
}
struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
