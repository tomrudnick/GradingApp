//
//  BackupTimeIntervalView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 24.12.21.
//

import SwiftUI

struct BackupTimeIntervalView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selection: BackupSettingsViewModel.BackupNotifyInterval
    
    var body: some View {
        List {
            ForEach(BackupSettingsViewModel.BackupNotifyInterval.allCases, id: \.self) { value in
                Button {
                    selection = value
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Text(value.rawValue)
                        Spacer()
                        if selection == value {
                            Image(systemName: "checkmark")
                        }
                    }
                }

            }
        }
    }
}
