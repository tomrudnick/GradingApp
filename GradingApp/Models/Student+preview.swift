//
//  Student+preview.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 08.08.21.
//

import Foundation
import CoreData
import CSV

extension Student {
    static func exampleStudent(context: NSManagedObjectContext) -> Student {
        let student = Student(context: context)
        student.firstName = "Marit"
        student.lastName = "Abken"
        student.email = "marit.abken@nige.de"
        return student
    }
    static func expampleStudents (context: NSManagedObjectContext) -> [Student] {
        var students : [Student] = []
        let studentArray = try! CSVReader(string: csvStudentMathe6C, hasHeaderRow: true)
        while let studentRow = studentArray.next() {
            let student = Student(context: context)
            student.firstName = studentRow[0]
            student.lastName = studentRow[1]
            student.email = studentRow[2]
            students.append(student)
        }
        return students
    }
}


let csvStudentMathe6C = """
Marit,Abken,marit-theresa.abken@nige.de
Lana,Bents,lana.bents@nige.de
Jule,Eisenhauer,jule.eisenhauer@nige.de
Kilian,Günther,kilian.guenther@nige.de
Hannah,Habben,hannah.habben@nige.de
Alina,Hartmanns,alina.hartmanns@nige.de
Tida,Heckmann,tida.heckmann@nige.de
Tammo,Heymann,tammo.heymann@nige.de
Till,Ihnen,till.ihnen@nige.de
Leevke,Jabben,leevke.jabben@nige.de
Femke,Janssen,femke.janssen@nige.de
Keno,Janßen,keno.janssen@nige.de
Nils,Kraft,nils.kraft@nige.de
Lucas,Lück,lucas.lueck@nige.de
Ole,Luitjens,ole.luitjens@nige.de
Mathis,Mischo,mathis.mischo@nige.de
Leni,Neumann,leni.neumann@nige.de
Lina,Opphard,lina.opphard@nige.de
Lilly,Peck,lilly.peck@nige.de
Leon,Plantör,leon.plantoer@nige.de
Linus,Puttkammer,linus.puttkammer@nige.de
Aimo,Schipper,aimo.schipper@nige.de
Lieke,Stelzer,lieke.stelzer@nige.de
Josephine,Stiegemann,josephine.stiegemann@nige.de
Niklas,Stumberg,niklas.stumberg@nige.de
Anni,Ukena,anni.ukena@nige.de
Mattis,Zychla,mattis.zychla@nige.de
"""
