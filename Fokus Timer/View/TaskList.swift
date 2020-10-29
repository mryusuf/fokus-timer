//
//  TaskList.swift
//  Fokus Timer
//
//  Created by Indra Permana on 10/10/20.
//

import SwiftUI

struct TaskList: View {
    @Binding var focusTasks: [Task]
    @Binding var breakTasks: [Task]
    @Binding var totalFocusTime: String
    @Binding var totalBreakTime: String
    var body: some View {
        ScrollView {
            if focusTasks.count == 0 && breakTasks.count == 0 {
                Text("There's no tracked task yet.")
//                    .frame(alignment: .center)
                    .padding()
            } else {
                if focusTasks.count > 0 {
                    Section(header: CustomHeader(title: "Focus",time: totalFocusTime, color: Color("focus"))) {
                        if focusTasks.count > 0 {
                            ForEach(focusTasks) { task in
                                TaskRow(task: task)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                }
                if breakTasks.count > 0 {
                    Section(header: CustomHeader(title: "Break", time: totalBreakTime,color: Color("break"))) {
                        if breakTasks.count > 0 {
                            ForEach(breakTasks) { task in
                                TaskRow(task: task)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
        }
        .textCase(.none)
    }
}

struct CustomHeader: View {
    let title: String
    let time: String
    let color: Color
    var body: some View {
            VStack {
                Spacer()
                HStack {
                    Text(title)
                        .bold()
                    Spacer()
                    Text(time)
                        .font((Font.system(size: 14).monospacedDigit()))
                        .bold()
                }
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 30))
                Spacer()
            }
            .background(FillColor(color: color))
            .foregroundColor(.white)
        
    }
}

struct FillColor: View {
    let color: Color
    
    var body: some View {
        GeometryReader { proxy in
            color.frame(width: proxy.size.width * 1.3)
        }
    }
}

//struct TaskList_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskList()
//    }
//}
