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
    var body: some View {
        ScrollView {
            Section(header: CustomHeader(title: "Focus", color: Color("focus"))) {
                if focusTasks.count > 0 {
                    ForEach(focusTasks) { task in
                        TaskRow(task: task).padding()
                    }
                }
            }.textCase(.none)
            Section(header: CustomHeader(title: "Break", color: Color("break"))) {
                if breakTasks.count > 0 {
                    ForEach(breakTasks) { task in
                        TaskRow(task: task).padding()
                    }
                }
            }.textCase(.none)
        }
    }
}

struct CustomHeader: View {
    let title: String
    let color: Color
    var body: some View {
            VStack {
                Spacer()
                HStack {
                    Text(title)
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                    Spacer()
                }
                Spacer()
            }.background(FillColor(color: color))
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
