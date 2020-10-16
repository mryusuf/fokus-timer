//
//  SettingsView.swift
//  Fokus Timer
//
//  Created by Indra Permana on 14/10/20.
//

import SwiftUI
import Combine

struct SettingsView: View {
    @ObservedObject var viewModel = SettingsViewModel()
//    @State private var offset = CGSize(width: 0, height: UIScreen.main.bounds.height * 0.6)
    let limit = 4
    
    var body: some View {
        Form {
            Section(header: Text("Minutes of Timer")) {
                HStack {
                    Text("Focus Time").opacity(0.8)
                    Spacer()
                    TextField(viewModel.focusTimeString, text: $viewModel.tempFocusTimeString, onEditingChanged: { isEditing in
                            if isEditing {
                                viewModel.tempFocusTimeString = ""
                            } else {
                                viewModel.tempFocusTimeString = viewModel.focusTimeString
                            }
                        }, onCommit: {
                            print("udah edit brow")
                        }
                        )
                        .keyboardType(.asciiCapableNumberPad)
                        .lineLimit(4)
//                        .onChange(of: viewModel.tempFocusTimeString) { value in
//                            if value == "" {
//                                print("SettingsView: kosong brow")
//    //                            viewModel.tempFocusTimeString = viewModel.focusTimeString
//                            } else {
//                                viewModel.focusTimeString = value
//                            }
//                        }
                        .onReceive(Just(viewModel.tempFocusTimeString)) { _ in limitTimerTime() }
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Break Time").opacity(0.8)
                    Spacer()
                    TextField(viewModel.breakTimeString, text: $viewModel.tempBreakTimeString, onEditingChanged: { isEditing in
                        if isEditing {
                            viewModel.tempBreakTimeString = ""
                        } else {
                            viewModel.tempBreakTimeString = viewModel.breakTimeString
                        }
                    }, onCommit : {
                        
                    }
                    )
                        .keyboardType(.asciiCapableNumberPad)
                        .onChange(of: viewModel.tempBreakTimeString) { value in
                            if value == "" {
                                print("SettingsView: kosong brow")
    //                            viewModel.tempFocusTimeString = viewModel.focusTimeString
                            } else {
                                viewModel.breakTimeString = value
                            }
                        }
                        .multilineTextAlignment(.trailing)
                }
            }
        }.navigationBarTitle(Text("Settings"))
//        GeometryReader { geometry in
//            Color(.white).edgesIgnoringSafeArea(.all)
//            Color(.blue)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                .offset(offset)
//                .gesture(
//                    DragGesture()
//                        .onChanged {gesture in
//                            offset.height = gesture.translation.height
//                        }
//                        .onEnded {gesture in
//                            if gesture.translation.height < geometry.size.height * 0.5 {
//                                offset.height = geometry.size.height * 0.15
//                            } else {
//                                offset.height = geometry.size.height * 0.8
//                            }
//                        }
//                )
//        }
    }
    
    //Function to keep text length in limits
        func limitTimerTime() {
            if viewModel.tempFocusTimeString.count > limit {
                viewModel.tempFocusTimeString = String(viewModel.tempFocusTimeString.prefix(limit))
            }
        }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.light)
    }
}
