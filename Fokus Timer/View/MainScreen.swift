//
//  ContentView.swift
//  Fokus Timer
//
//  Created by Indra Permana on 20/08/20.
//

import SwiftUI

struct MainScreen: View {
    @ObservedObject private var timeTrackerViewModel = TimeTrackerViewModel()
    @State private var activityName = ""
    @State var startPos : CGPoint = .zero
    @State var isSwipping = true
    
    var body: some View {
        VStack {
            Picker("Something", selection: $timeTrackerViewModel.selectedActivity) {
                ForEach(ActivityState.allCases) {activity in
                    Text(activity.rawValue.capitalized).tag(activity)
                }
            }
                .padding()
                .animation(.easeIn(duration: 0.4))
                .disabled(withAnimation(.linear(duration: 0.7)) {
                    isTimerStarted() // TODO: this anim doesn't work, check another way to anim when change disable
                })
                .frame(minWidth: 100, idealWidth: 250, maxWidth: 250, minHeight: 100, idealHeight: 100, maxHeight: 100, alignment: .center)
//                .background(Color.clear) TODO: make picker background clear

            Text(isTimerStarted() ? timeTrackerViewModel.timerTimeElapsedDisplay:"")
                .font(.system(size: 40, weight: .semibold))
                .frame(width: 250, height: 50, alignment: .center)
            
            ZStack {
                Color(timeTrackerViewModel.selectedActivity.rawValue)
                    .clipShape(Circle())
                
                Image(systemName: isTimerStarted() ? "stop.fill":"play.fill")
                        .resizable()
                        .frame(width: 70, height: 75)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color("white"))
                        .offset(x: isTimerStarted() ? 0: 10.0, y: 0)
                
            }
//                .animation(.easeIn(duration: 0.4))
                .frame(width: 200, height: 200, alignment: .center)
                .padding(30)
                .onTapGesture{
                    timeTrackerViewModel.toggleTimer()
                }
            
            TextField("Activity Name", text: $activityName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 300, height: 50, alignment: .center)
                .disabled(isTimerStarted())
            Spacer()
            HStack {
                Text("Timer: ")
                Button(timeTrackerViewModel.timerState.rawValue) {
                    timeTrackerViewModel.toggleAlarmState()
                }
            }
            .padding(10)
            .disabled(isTimerStarted())
            
            Spacer(minLength: 150)
        }
        .padding()
        .pickerStyle(SegmentedPickerStyle())
        .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 0, idealHeight: 100, maxHeight: .infinity, alignment: .center )
        .background(Color("white").edgesIgnoringSafeArea(.all))
        .gesture(
            DragGesture(minimumDistance: 50)
                .onChanged { gesture in
                    if isSwipping {
                        startPos = gesture.location
                        isSwipping.toggle()
                    }
                }
                .onEnded { gesture in
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
        )
    }
    
    func isSwipeFromFocusToBreak(gestureLocX: CGFloat, yDist: CGFloat, xDist: CGFloat ) -> Bool {
        return startPos.x > gestureLocX && yDist < xDist && timeTrackerViewModel.selectedActivity == .focus_time
    }
    
    func isSwipeFromBreakToFocus(gestureLocX: CGFloat, yDist: CGFloat, xDist: CGFloat ) -> Bool {
        return startPos.x < gestureLocX && yDist < xDist && timeTrackerViewModel.selectedActivity == .break_time
    }
    
    func isTimerStarted() -> Bool {
        return timeTrackerViewModel.timeTrackerState == .started ? true : false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}
