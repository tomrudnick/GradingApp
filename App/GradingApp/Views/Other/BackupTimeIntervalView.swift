//
//  BackupTimeIntervalView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 24.12.21.
//

import SwiftUI

struct BackupTimeIntervalView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selection: BackupViewModel.BackupNotifyInterval
    
    var body: some View {
        List {
            ForEach(BackupViewModel.BackupNotifyInterval.allCases, id: \.self) { value in
                Button {
                    selection = value
                    dismiss()
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
