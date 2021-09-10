//
//  PreviewGenerator.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 08.08.21.
//

import Foundation
import CoreData
import CSV
import SwiftUI

let expampleCourseNames = ["6C", "7F", "10FLS"]
let csvStudents = """
Vorname, Nachname, Email
Mathe 6C,Marit,Abken,marit-theresa.abken@nige.de,3,3,2,2,2-,_S_,4,3
Mathe 6C,Lana,Bents,lana.bents@nige.de
Mathe 6C,Jule,Eisenhauer,jule.eisenhauer@nige.de
Mathe 6C,Kilian,Günther,kilian.guenther@nige.de
Mathe 6C,Hannah,Habben,hannah.habben@nige.de
Mathe 6C,Alina,Hartmanns,alina.hartmanns@nige.de
Mathe 6C,Tida,Heckmann,tida.heckmann@nige.de
Mathe 6C,Tammo,Heymann,tammo.heymann@nige.de
Mathe 6C,Till,Ihnen,till.ihnen@nige.de
Mathe 6C,Leevke,Jabben,leevke.jabben@nige.de
Mathe 6C,Femke,Janssen,femke.janssen@nige.de
Mathe 6C,Keno,Janßen,keno.janssen@nige.de
Mathe 6C,Nils,Kraft,nils.kraft@nige.de
Mathe 6C,Lucas,Lück,lucas.lueck@nige.de
Mathe 6C,Ole,Luitjens,ole.luitjens@nige.de
Mathe 6C,Mathis,Mischo,mathis.mischo@nige.de
Mathe 6C,Leni,Neumann,leni.neumann@nige.de
Mathe 6C,Lina,Opphard,lina.opphard@nige.de
Mathe 6C,Lilly,Peck,lilly.peck@nige.de
Mathe 6C,Leon,Plantör,leon.plantoer@nige.de
Mathe 6C,Linus,Puttkammer,linus.puttkammer@nige.de
Mathe 6C,Aimo,Schipper,aimo.schipper@nige.de
Mathe 6C,Lieke,Stelzer,lieke.stelzer@nige.de
Mathe 6C,Josephine,Stiegemann,josephine.stiegemann@nige.de
Mathe 6C,Niklas,Stumberg,niklas.stumberg@nige.de
Mathe 6C,Anni,Ukena,anni.ukena@nige.de
Mathe 6C,Mattis,Zychla,mattis.zychla@nige.de
Mathe 7F,Tyler,Abeln,tyler.abeln@nige
Mathe 7F,Xenia,Aurich,xenia.aurich@nige
Mathe 7F,Jakob,Beninga,jakob.beninga@nige
Mathe 7F,Til,Christians,til.christians@nige
Mathe 7F,Zainab,Kerati,zainab.el.kerati@nige
Mathe 7F,Myra,Esen-Lürken,myra.luerken@nige
Mathe 7F,Romy,Esen-Lürken,romy.luerken@nige
Mathe 7F,Elisabeth,Grams,elisabeth.grams@nige
Mathe 7F,Marina,Gruben,marina.gruben@nige
Mathe 7F,Niklas,Hellwig,niklas.hellwig@nige
Mathe 7F,Lynn,Lange,lynn.lange@nige
Mathe 7F,Leon,Nikolic,leon.nikolic@nige
Mathe 7F,Can,Pekgürler,can.karim.pekguerler@nige
Mathe 7F,Anneke,Ritter,anneke.ritter@nige
Mathe 7F,Freya,Schneider,freya.schneider@nige
Mathe 7F,Leon,Siegmann,leon.siegmann@nige
Mathe 7F,Carlos,Sondergeld,carlos.sondergeld@nige
Mathe 7F,Smilla,Utesch,smilla.utesch@nige
Mathe 7F,Greta,Weete,greta.weete@nige
Mathe 7F,Lance,Wotschka,lance-erik.wotschka@nige.de
Mathe 10FLS,Joren,Aumann,joren.aumann@nige.de,2,2-,2,2,_S_,1,3
Mathe 10FLS,Justin,Birgfeld,justin.birgfeld@nige.de,3,3,2,2,2-,_S_,4,1
Mathe 10FLS,Emely,Bohland,emely.bohland@nige.de,3,3,2,3,3+,_S_,5,3
Mathe 10FLS,Friederike,Böök,friederike.boeoek@nige.de,3-,3-,3-,3-,_S_,5,2
Mathe 10FLS,Sina,Brüling,sina.brueling@nige.de,4,4+,4,3-,4,_S_,5,3
Mathe 10FLS,Alina,Bruns,alina.bruns@nige.de,5,4,3-,4,_S_,6,5
Mathe 10FLS,Jonas,Claassen,jonas.claassen@nige.de,3,3+,3,2,2-,_S_,3,1
Mathe 10FLS,Jonas,Cuno,jonas.cuno@nige.de,4,4-,4,4,4,_S_,4,2
Mathe 10FLS,Dinah,Ehnts,dinah.ehnts@nige.de,2,3,2-,2-,_S_,2,2
Mathe 10FLS,Finn,Freese,finn-luca.freese@nige.de,3,3,3,1,2-,_S_,4,2
Mathe 10FLS,Laura,Hinrichs,laura.hinrichs@nige.de,3,4-,3-,4,_S_,4,5
Mathe 10FLS,Joana,Janssen,joana.janssen@nige.de,4,4-,5,3-,4,_S_,4,3
Mathe 10FLS,Lara,Jeurink,lara.jeurink@nige.de,4-,4-,4,4,_S_,4,4
Mathe 10FLS,Ole,Kleine-Möllhoff,ole.kleine-moellhoff@nige.de,4,3+,3-,3,3-,_S_,6,5
Mathe 10FLS,Anton,Krovopushkin,anton.krovopushkin@nige.d4,3,2-,3,_S_,4,4
Mathe 10FLS,Daje,Niehuisen,daje.niehuisen@nige.de,3-,4,4,3-,3-,_S_,5,2
Mathe 10FLS,Fenja,Niemand,fenja.niemand@nige.de,4,4,4+,_S_,4,3
Mathe 10FLS,Nina,Petrik,nina.ayleen.petrik@nige.de,4,3+,4,3-,3-,_S_,4,4
Mathe 10FLS,Marie,Reuter,marie-c.reuter@nige.de,5,4-,3-,4,_S_,5,3
Mathe 10FLS,Clara,Schmitz,clara.schmitz@nige.de,2,2,2-,2,2,_S_,2,1
Mathe 10FLS,Skrållan,Schneider,skrallan.schneider@nige.de,4,3,3-,_S_,3,3
Mathe 10FLS,Alexa,Seewald,alexa.seewald@nige.de,4,3-,4,3,3-,_S_,3,2
Mathe 10FLS,Jana,Steffens,jana.steffens@nige.de,2-,3+,3,2-,2-,_S_,4,3
Mathe 10FLS,Fenja,Theesfeld,fenja.theesfeld@nige.de,4,3+,3,3-,3,_S_,4,3
Mathe 10FLS,Oke,Tuitjer,oke.tuitjer@nige.de,3,3+,3+,3+,_S_,4,2
Mathe 10FLS,Katharina,Willms,katharina.willms@nige.de,4,3+,3,3-,3,_S_,3,3
"""
func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }

func previewData (context: NSManagedObjectContext) -> [Course] {
    
    //  Hier werden die Kurse generiert
    var courses: [Course] = []
    for course in expampleCourseNames {
        let newCourse = Course(context: context)
        newCourse.subject = "Mathe"
        newCourse.name = course
        courses.append(newCourse)
    }
    //  Hier werden die Schüler generiert und den entsprechenden Kursen zugeordnet
    var students : [Student] = []
    let studentArray = try! CSVReader(string: csvStudents, hasHeaderRow: true)
    while let studentRow = studentArray.next() {
        let student = Student(firstName: studentRow[1], lastName: studentRow[2], email: studentRow[3],
                              course: courses.first(where: { $0.title == studentRow[0]})!, context: context)
        students.append(student)
        let studentGrades = studentRow[4..<studentRow.count]
        if studentGrades.count > 0 {
            print("DFlSDF")
        }
        var gradeType = GradeType.oral
        for grade in studentGrades {
            print("test")
            
            if grade == "_S_"{
                gradeType = GradeType.written
            } else {
                _ = Grade(value: Grade.lowerSchoolGradesTranslate[grade]!, date: Date(), half: .firstHalf, type: gradeType, comment: randomString(length: Int.random(in: 3..<20)), multiplier: 1.0, student: student, context: context)
            }
        }
    }
    return courses
}

