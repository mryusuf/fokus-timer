//
//  TaskRow.swift
//  Fokus Timer
//
//  Created by Indra Permana on 05/10/20.
//

import SwiftUI

struct TaskRow: View {
    var task: Task
    var body: some View {
        HStack {
            Text(task.titleText)
                .bold()
                .foregroundColor(Color("black"))
            Spacer()
            Text(task.timeText)
                .font(Font.system(size: 13).monospacedDigit())
                .foregroundColor(Color("black"))
                
        }
        .padding(.horizontal)
    }
}

//struct TaskRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TaskRow()
//    }
//}
