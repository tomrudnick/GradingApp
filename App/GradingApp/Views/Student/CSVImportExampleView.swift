//
//  CSVImportExampleView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 23.08.22.
//

import SwiftUI

struct CSVImportExampleView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Fertig")
                }
            }.padding()
            Spacer()
            VStack {
                Text("CSV Datei im UTF-8 Format kodieren")
                Image("csv_import_example")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }.padding().padding(.bottom, 250)
           
        }
    }
}

struct CSVImportExampleView_Previews: PreviewProvider {
    static var previews: some View {
        CSVImportExampleView()
    }
}
