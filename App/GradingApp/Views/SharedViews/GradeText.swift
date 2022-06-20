//
//  GradeText.swift
//  GradingApp
//
//  Created by Tom Rudnick on 20.06.22.
//

import SwiftUI

struct GradeText: View {
    
    let ageGroup: AgeGroup
    let grade: Double
    
    var body: some View {
        Text(getGradeText()).foregroundColor(Grade.getColor(points: grade))
    }
    
    func getGradeText() -> String {
        if ageGroup == .lower {
            return String(format: "%.1f", Grade.convertDecimalGradesToGradePoints(points: grade))
        } else {
            return String(format: "%.1f", grade)
        }
        
    }
}
