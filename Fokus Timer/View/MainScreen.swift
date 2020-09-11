//
//  ContentView.swift
//  Fokus Timer
//
//  Created by Indra Permana on 20/08/20.
//

import SwiftUI

struct MainScreen: View {
    @ObservedObject private var timeTrackerViewModel = TimeTrackerViewModel()
    var body: some View {
        VStack {
            Picker("Something", selection: $timeTrackerViewModel.selectedActivity) {
                ForEach(ActivityState.allCases) {activity in
                    Text(activity.rawValue.capitalized).tag(activity)
                }
            }.padding()
            ZStack {
                Circle()
                    .padding()
                    .foregroundColor(Color.init("\(timeTrackerViewModel.selectedActivity.rawValue)"))
                    .animation(.easeIn(duration: 0.4))
                    .onTapGesture{
                        print("tapped")
                    }
                
                Text("Start").font(Font.system(size: 20)).foregroundColor(.init("white"))
            }
            
                
            Text("\(timeTrackerViewModel.selectedActivity.rawValue)").foregroundColor(.blue)
        }
        
        .pickerStyle(SegmentedPickerStyle())
        .frame(minWidth: 0, idealWidth: 100, maxWidth: .infinity, minHeight: 0, idealHeight: 100, maxHeight: .infinity, alignment: .center )
        .background(Color.init("white").edgesIgnoringSafeArea(.all))
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}

enum ActivityState: String, CaseIterable, Identifiable {
    case focus_time = "focus"
    case break_time = "break"

    var id: String { self.rawValue }
}
