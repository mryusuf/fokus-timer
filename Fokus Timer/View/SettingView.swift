//
//  SettingsView.swift
//  Fokus Timer
//
//  Created by Indra Permana on 14/10/20.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel = SettingViewModel()
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Timer")) {
                    HStack {
                        Text("Focus Timer").opacity(0.8)
                        Spacer()
                        TextField("25 minutes", text: $viewModel.focusTimeString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Break Timer").opacity(0.8)
                        Spacer()
                        TextField("25 minutes", text: $viewModel.breakTimeString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                        
                }
                
                Section(header: Text("Others")) {
                    TextField("5 minutes", text: $viewModel.breakTimeString)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationBarTitle(Text("Settings"))
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.light)
    }
}
