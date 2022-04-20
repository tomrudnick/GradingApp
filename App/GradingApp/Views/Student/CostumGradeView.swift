//
//  CostumGradeView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 20.08.21.
//

import SwiftUI

struct CostumGradeView: View {
   
    var roundedGrade: String
    var grade: String
    
    var body: some View {
        VStack {
            Text(roundedGrade).font(.title)
            if  roundedGrade != "-" {
            Text(grade)
                .font(.footnote)
                .foregroundColor(.gray)
            }
        }
    }
}

struct CostumGradeView_Previews: PreviewProvider {
    static var previews: some View {
        CostumGradeView (roundedGrade: "5", grade: "5.2")
    }
}
