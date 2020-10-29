//
//  ContentView.swift
//  Fokus Timer
//
//  Created by Indra Permana on 20/08/20.
//

import SwiftUI

struct TaskTrackerScreen: View {
    @EnvironmentObject var timeTrackerViewModel: TimeTrackerViewModel
    @Binding var isFullyShown: Bool
    var body: some View {
            VStack {
                Group {
                if !timeTrackerViewModel.isTrackerStarted() {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 50, height: 5, alignment: .center)
                        .foregroundColor(Color("white"))
                        .padding(.top, 10)
                    if !isFullyShown {
                        Text("Swipe up to track new task")
                            .padding()
                            .foregroundColor(Color("white"))
//                            .animation(.spring())
                    } else {
                        Picker("TaskType", selection: $timeTrackerViewModel.selectedActivity) {
                            ForEach(ActivityState.allCases) {activity in
                                Text(activity.rawValue.capitalized).tag(activity)
                            }
                        }
                        .padding(10)
                        .disabled(withAnimation(.linear(duration: 0.7)) {
                            timeTrackerViewModel.isTrackerStarted() // TODO: this anim doesn't work, check another way to anim when change disable
                        })
                        .onChange(of: timeTrackerViewModel.selectedActivity) { value in
                            timeTrackerViewModel.playHapticEngine()
                        }
                        .frame(minWidth: 100, idealWidth: 250, maxWidth: 250, minHeight: 100, idealHeight: 100, maxHeight: 100, alignment: .center)
                    //                .background(Color.clear) TODO: make picker background clear
                    }
                }
                else {
                    Spacer()
                    Text(timeTrackerViewModel.isTrackerStarted() ? timeTrackerViewModel.timerTimeElapsedDisplay:"")
                        .font(Font.system(size: 60, weight: .semibold).monospacedDigit())
                        .frame(idealWidth: 280, minHeight: 0, idealHeight: 50)
//                        .animation(.none)
                        .foregroundColor(Color("white"))
                }
                }
                if isFullyShown {
                    
                    Image(systemName: timeTrackerViewModel.isTrackerStarted() ? "stop.circle.fill":"play.circle.fill")
                        .resizable()
                        .frame(width: 250, height: 250)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color("white"))
                        .padding(30)
                        .onTapGesture{
                            timeTrackerViewModel.toggleTimer()
                            timeTrackerViewModel.playSuccessHapticEngine()
                        }
                    
                    TextField("Activity Name", text: $timeTrackerViewModel.activityTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(10)
                        .frame(width: 300, height: 50, alignment: .center)
                    Spacer()
                    HStack {
                        Text("Timer: ")
                            .foregroundColor(Color("white"))
                        Button(
                            action: {
                                timeTrackerViewModel.toggleAlarmState()
                            }, label: {
                            Text(timeTrackerViewModel.timerState.rawValue).bold()
                            }
                        )
                        .foregroundColor(timeTrackerViewModel.timerState.rawValue == "off" ? Color("gray").opacity(0.7) : Color("main_bg"))
                    }
                    .font(.system(size: 20))
                    .padding(.top,50)
                    .disabled(timeTrackerViewModel.isTrackerStarted())
                    Spacer()
                } else {
                    Spacer()
                }
            }
            
            .pickerStyle(SegmentedPickerStyle())
            .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 0, idealHeight: 400, maxHeight: .infinity, alignment: .center )
            .background(Color(timeTrackerViewModel.selectedActivity.rawValue).edgesIgnoringSafeArea(.all))
            .keyboardAdaptive()
        
            
            
            
//        } else {
//            VStack {
//                RoundedRectangle(cornerRadius: 20)
//                    .frame(width: 50, height: 5, alignment: .center)
//                Text("Swipe up to track new task")
//                    .r(.spring())
//                Spacer()
//            }
//            .padding()
//            .foregroundColor(Color("white"))
//            .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 0, idealHeight: 400, maxHeight: .infinity, alignment: .center )
//            .background(Color(timeTrackerViewModel.selectedActivity.rawValue).edgesIgnoringSafeArea(.all))
//            .clipShape(RoundedRectangle(cornerRadius: 20))
//        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskTrackerScreen(timeTrackerViewModel: TimeTrackerViewModel())
//            .previewDevice("iPhone 8")
//    }
//}
