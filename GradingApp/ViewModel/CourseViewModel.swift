//
//  CourseViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 02.08.21.
//

import Foundation
import CSV

class CourseViewModel : ObservableObject {
    
    @Published var courses: [Course] = []
    
    init() {
        courses = createDummyData()
    }
    
    private func parseCSVCourseFile(csvData: String) -> Course {
        var course: Course?
        let csv = try! CSVReader(string: csvData, hasHeaderRow: true)
        while csv.next() != nil {
            if course == nil {
                course = Course(name: csv["course"]!)
            }
            course?.students.append(Student(id: csv["id"]!, firstName: csv["firstName"]!, lastName: csv["lastName"]!, email: csv["email"]!, course: course))
        }
        return course!
    }
    
    private func parseCSVGradeFile(course: Course, csvData: String, gradeType: GradeType) {
        if let course = courses.first(where: {$0.name == course.name}) {
            let csv = try! CSVReader(string: csvData, hasHeaderRow: true)
            let gradeHeaderRow = csv.headerRow!
            while let row = csv.next() {
                let firstName = row[1]
                let lastName = row[2]
                let student = course.findStudent(firstName: firstName, lastName: lastName)
                
                if student == nil { continue } //If everything is correct this should never happen
                
                var grades : [Grade] = []
                for dateGrade in 3..<row.count {
                    grades.append(Grade(date: getDateFrom(string: gradeHeaderRow[dateGrade])!,
                                        type: gradeType,
                                        value: Grade.convertStringToInt(grade: row[dateGrade])))
                }
                grades.sort {$0.date < $1.date}
                student!.grades = grades
            }
        }
    }
    
    private func getDateFrom(string dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        return dateFormatter.date(from: dateString)
    }
    
    private func createDummyData() -> [Course] {
        let courses = createDummyCourses()
        if let course = courses.first(where: {$0.name == "Mathe 10FLS" }) {
            parseCSVGradeFile(course: course, csvData: csvNotenMuenlich10FLS, gradeType: .oral)
        }
        return courses
    }
    
    private func createDummyCourses() -> [Course]{
        return [parseCSVCourseFile(csvData: csvMathe7F), parseCSVCourseFile(csvData: csvMathe6C), parseCSVCourseFile(csvData: csvMathe10FLS)]
    }
    

    func addCourse(courseTitle: String) {
        courses.append(Course(name: courseTitle))
    }
    
    func removeCourse(_ course: Course) {
        //TODO remove Course
    }
    
    let csvMathe7F =
    """
    id,firstName,lastName,email,course
    1,Tyler,Abeln,tyler.abeln@nige.de,Mathe 7F
    2,Xenia,Aurich,xenia.aurich@nige.de,Mathe 7F
    3,Jakob,Beninga,jakob.beninga@nige.de,Mathe 7F
    4,Til,Christians,til.christians@nige.de,Mathe 7F
    5,Zainab,El Kerati,zainab.el.kerati@nige.de,Mathe 7F
    6,Myra,Esen-Lürken,myra.luerken@nige.de,Mathe 7F
    7,Romy,Esen-Lürken,romy.luerken@nige.de,Mathe 7F
    8,Elisabeth,Grams,elisabeth.grams@nige.de,Mathe 7F
    9,Marina,Gruben,marina.gruben@nige.de,Mathe 7F
    10,Niklas,Hellwig,niklas.hellwig@nige.de,Mathe 7F
    11,Lynn,Lange,lynn.lange@nige.de,Mathe 7F
    12,Leon,Nikolic,leon.nikolic@nige.de,Mathe 7F
    13,Can,Pekgürler,can.karim.pekguerler@nige.de,Mathe 7F
    14,Anneke,Ritter,anneke.ritter@nige.de,Mathe 7F
    15,Freya,Schneider,freya.schneider@nige.de,Mathe 7F
    16,Leon,Siegmann,leon.siegmann@nige.de,Mathe 7F
    17,Carlos,Sondergeld,carlos.sondergeld@nige.de,Mathe 7F
    18,Smilla,Utesch,smilla.utesch@nige.de,Mathe 7F
    19,Greta,Weete,greta.weete@nige.de,Mathe 7F
    20,Lance,Wotschka,lance-erik.wotschka@nige.de,Mathe 7F
    """
    let csvMathe6C =
    """
    id,firstName,lastName,email,course
    21,Marit,Abken,marit-theresa.abken@nige.de,Mathe 6C
    22,Lana,Bents,lana.bents@nige.de,Mathe 6C
    23,Jule,Eisenhauer,jule.eisenhauer@nige.de,Mathe 6C
    24,Kilian,Günther,kilian.guenther@nige.de,Mathe 6C
    25,Hannah,Habben,hannah.habben@nige.de,Mathe 6C
    26,Alina,Hartmanns,alina.hartmanns@nige.de,Mathe 6C
    27,Tida,Heckmann,tida.heckmann@nige.de,Mathe 6C
    28,Tammo,Heymann,tammo.heymann@nige.de,Mathe 6C
    29,Till,Ihnen,till.ihnen@nige.de,Mathe 6C
    30,Leevke,Jabben,leevke.jabben@nige.de,Mathe 6C
    31,Femke,Janssen,femke.janssen@nige.de,Mathe 6C
    32,Keno,Janßen,keno.janssen@nige.de,Mathe 6C
    33,Nils,Kraft,nils.kraft@nige.de,Mathe 6C
    34,Lucas,Lück,lucas.lueck@nige.de,Mathe 6C
    35,Ole,Luitjens,ole.luitjens@nige.de,Mathe 6C
    36,Mathis,Mischo,mathis.mischo@nige.de,Mathe 6C
    37,Leni,Neumann,leni.neumann@nige.de,Mathe 6C
    38,Lina,Opphard,lina.opphard@nige.de,Mathe 6C
    39,Lilly,Peck,lilly.peck@nige.de,Mathe 6C
    40,Leon,Plantör,leon.plantoer@nige.de,Mathe 6C
    41,Linus,Puttkammer,linus.puttkammer@nige.de,Mathe 6C
    42,Aimo,Schipper,aimo.schipper@nige.de,Mathe 6C
    43,Lieke,Stelzer,lieke.stelzer@nige.de,Mathe 6C
    44,Josephine,Stiegemann,josephine.stiegemann@nige.de,Mathe 6C
    45,Niklas,Stumberg,niklas.stumberg@nige.de,Mathe 6C
    46,Anni,Ukena,anni.ukena@nige.de,Mathe 6C
    47,Mattis,Zychla,mattis.zychla@nige.de,Mathe 6C
    """

    let csvMathe10FLS =
    """
    id,firstName,lastName,email,course
    48,Joren,Aumann,joren.aumann@nige.de,Mathe 10FLS
    49,Justin,Birgfeld,justin.birgfeld@nige.de,Mathe 10FLS
    50,Emely,Bohland,emely.bohland@nige.de,Mathe 10FLS
    51,Friederike,Böök,friederike.boeoek@nige.de,Mathe 10FLS
    52,Sina,Brüling,sina.brueling@nige.de,Mathe 10FLS
    53,Alina,Bruns,alina.bruns@nige.de,Mathe 10FLS
    54,Jonas,Claassen,jonas.claassen@nige.de,Mathe 10FLS
    55,Jonas,Cuno,jonas.cuno@nige.de,Mathe 10FLS
    56,Dinah,Ehnts,dinah.ehnts@nige.de,Mathe 10FLS
    57,Finn,Freese,finn-luca.freese@nige.de,Mathe 10FLS
    58,Laura,Hinrichs,laura.hinrichs@nige.de,Mathe 10FLS
    59,Joana,Janssen,joana.janssen@nige.de,Mathe 10FLS
    60,Lara,Jeurink,lara.jeurink@nige.de,Mathe 10FLS
    61,Ole,Kleine-Möllhoff,ole.kleine-moellhoff@nige.de,Mathe 10FLS
    62,Anton,Krovopushkin,anton.krovopushkin@nige.de,Mathe 10FLS
    63,Daje,Niehuisen,daje.niehuisen@nige.de,Mathe 10FLS
    64,Fenja,Niemand,fenja.niemand@nige.de,Mathe 10FLS
    65,Nina,Petrik,nina.ayleen.petrik@nige.de,Mathe 10FLS
    66,Marie,Reuter,marie-c.reuter@nige.de,Mathe 10FLS
    67,Skrållan,Schneider,skrallan.schneider@nige.de,Mathe 10FLS
    68,Alexa,Seewald,alexa.seewald@nige.de,Mathe 10FLS
    69,Jana,Steffens,jana.steffens@nige.de,Mathe 10FLS
    70,Fenja,Theesfeld,fenja.theesfeld@nige.de,Mathe 10FLS
    71,Oke,Tuitjer,oke.tuitjer@nige.de,Mathe 10FLS
    72,Katharina,Willms,katharina.willms@nige.de,Mathe 10FLS
    """
    
    
    let csvNotenMuenlich10FLS =
    """
    id,firstName,lastName,23.03.2021,03.05.2021,25.06.2021,05.07.2021
    48,Joren,Aumann,-1,2+,1-,1-
    49,Justin,Birgfeld,2,2-,2,2
    50,Friederike,Böök,2,3+,2-,2-
    51,Emely,Bohland,2,3,3+,3+
    52,Sina,Brüling,2,2-,2-,2-
    53,Alina,Bruns,-4,4,4,4
    54,Jonas,Claassen,2,2-,2,2
    55,Jonas,Cuno,2,2-,2-,2-
    56,Dinah,Ehnts,2,3-,2-,3+
    57,Finn,Freese,2,2,2,2
    58,Laura,Hinrichs,-2,4,3,3
    59,Joana,Janssen,-2,3-,3+,3+
    60,Lara,Jeurink,-2,3,3+,3+
    61,Ole,Kleine-Möllhoff,4,4+,4+,4+
    62,Anton,Krovopushkin,2,3+,2,2
    63,Daje,Niehuisen,2,4,3,3
    64,Fenja,Niemand,-2,3,2-,3+
    65,Nina,Petrik,3,4+,3-,3-
    66,Marie,Reuter,3,3-,3-,3-
    67,Skrållan,Schneider,-2,4,3,3
    68,Alexa,Seewald,-4,4,4,4
    69,Jana,Steffens,-1,2,2+,2+
    70,Fenja,Theesfeld,-1,2-,2,2
    71,Oke,Tuitjer,3,3,3,3
    72,Katharina,Willms,2,1-,1-,1-
    """

}
