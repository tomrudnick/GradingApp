//
//  EmailKeys.swift
//  GradingApp
//
//  Created by Tom Rudnick on 05.09.21.
//

import Foundation

struct EmailKeys {
    static let firstName = "$Vorname"
    static let lastName = "$Nachname"
    static let oralGrade = "$ø mündliche Note"
    static let writtenGrade = "$ø schriftliche Note"
    static let grade = "$aktueller Leistungsstand gesamt"
    static let transcriptGradeFirstHalf = "$Zeungisnote 1. Halbjahr" //Darf nur erscheinen, wenn man im zweiten Halbjahr ist, ansonsten ist es transcriptGradeHalf
    static let transcriptGradeHalf = "$Zeugnisnote aktuelles Halbjahr"
    static let transcriptGrade = "$Gesamtjahresnote"
    static let selectedGrade = "$ausgewählte Note"
    static let selectedGradeDate = "$Datum der ausgewählten Note"
    static let points = "$Punkte"
    static let maxpoints = "$Max Punkte"
}
