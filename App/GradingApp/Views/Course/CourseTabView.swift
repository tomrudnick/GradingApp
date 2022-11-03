//
//  CourseTabView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

enum UndoManagerAction {
    case undo
    case redo
    case none
}

struct CourseTabView: View {
    
    @Environment(\.currentHalfYear) var halfYear
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openWindow) private var openWindow
    
    @StateObject var sendEmailViewModel = SendMultipleEmailsCourseViewModel()
    @StateObject var undoRedoVM = UndoRedoViewModel()
    private var idiom : UIUserInterfaceIdiom { UIDevice.current.userInterfaceIdiom }
    
    @ObservedObject var course: Course
    @State var showAddStudent = false
    @State var showAddMultipleGrades = false
    
    @State var showTranscriptHalfYearSheet = false
    @State var showTranscriptSheet = false
    @State var showSendEmailSheet = false
    @State var showUndoRedoAlert = false
    @State var showCalculatedTranscriptSheet = false
    @State var showNewExamSheet = false
    
    @State var studentGrade: [Student:Int] = [:]
    
    @Binding var selectedTab: String
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            StudentListView(course: course)
                .tabItem {
                    Image(systemName:"person.3.fill")
                    Text("Kurs")
                }.tag("StudentListView")
            StudentGradeListView(course: course)
                .tabItem {
                    Image(systemName:"graduationcap")
                    Text("Leistungsübersicht")
                }.tag("StudentGradeListView")
            
            GradeAtDatesSelectionView(course: course)
                .tabItem{
                    Image(systemName:"calendar")
                    Text("Daten")
                }.tag("GradeAtDatesSelectionView")
            
        }
        //.edgesIgnoringSafeArea(.top)
        .navigationBarTitle("\(course.title) - \(halfYear == .firstHalf ? "1. HJ" : "2. HJ")", displayMode: .inline)
        .toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                Text("")
            }
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                Menu {
                    Button {
                        self.showNewExamSheet.toggle()
                    } label: {
                        Text("Neue Klassenarbeit")
                    }

                    Button(action: {
                        self.showSendEmailSheet.toggle()
                    }, label: {
                        Text("Email verschicken...")
                    }).disabled(!sendEmailViewModel.emailAccountViewModel.emailAccountUsed)
                    if course.type == .holeYear {
                        if halfYear == .secondHalf {
                            Button {
                                self.showCalculatedTranscriptSheet.toggle()
                            } label: {
                                Text("Aktuellen Zeugnisstand anzeigen")
                            }
                        }
                        Button {
                            self.showTranscriptHalfYearSheet.toggle()
                        } label: {
                            Text("Zeugnisnoten \(halfYear == .firstHalf ? "1. " : "2. ") HJ einstellen")
                        }
                        Button {
                            self.showTranscriptSheet.toggle()
                        } label: {
                            Text("Gesamtzeugnisnote einstellen")
                        }
                    } else {
                        Button {
                            self.showTranscriptHalfYearSheet.toggle()
                        } label: {
                            Text("Zeugnisnote einstellen")
                        }
                    }
                    undoButton
                    redoButton

                } label: {
                    Image(systemName: "ellipsis.circle")
                        .imageScale(.large)
                }
            }
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                Button(action: {
                    if studentGrade.isEmpty {
                        studentGrade = Dictionary(uniqueKeysWithValues: course.students.map({($0, -1)}))
                    }
                    #if targetEnvironment(macCatalyst)
                        openWindow(value: course.id)
                    #else
                        showAddMultipleGrades = true
                    #endif
                }, label: {
                    Image(systemName: "plus.circle")
                })
                
            }
        })
        .alert(isPresented: $showUndoRedoAlert) {
            return undoRedoVM.getAlert(viewContext: viewContext)
            
        }
        
        
        .onAppear {
            let apparence = UITabBarAppearance()
            apparence.configureWithOpaqueBackground()
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = apparence
                
            }

            self.sendEmailViewModel.fetchData(course: course, half: halfYear)
        }
        .fullScreenCover(isPresented: $showNewExamSheet, content: {
            NewExam(course: course)
        })
        .sheet(isPresented: $showSendEmailSheet, content: {
            SendEmailsView(title: course.title, emailViewModel: sendEmailViewModel)
        })
        .if(UIScreen.main.traitCollection.userInterfaceIdiom == .phone) { view in
            view.fullScreenCover(isPresented: $showTranscriptHalfYearSheet, content: {
                StudentTranscriptGradesHalfYear(course: course).environment(\.currentHalfYear, halfYear)
            })
            .fullScreenCover(isPresented: $showAddMultipleGrades, content: {
                AddMultipleGradesView(course: course)
            })
            .fullScreenCover(isPresented: $showTranscriptSheet, content: {
                StudentTranscriptGradesFullYearView(course: course).environment(\.currentHalfYear, halfYear)
            })
            .fullScreenCover(isPresented: $showCalculatedTranscriptSheet) {
                StudentCalculatedTranscriptGrades(course: course)
            }
    }
        
        .if(UIScreen.main.traitCollection.userInterfaceIdiom == .pad) { view in
            view.sheet(isPresented: $showAddMultipleGrades, content: {
                AddMultipleGradesView(course: course)
            })
            .sheet(isPresented: $showTranscriptHalfYearSheet) {
                StudentTranscriptGradesHalfYear(course: course).environment(\.currentHalfYear, halfYear)
            }
            .sheet(isPresented: $showTranscriptSheet, content: {
                StudentTranscriptGradesFullYearView(course: course).environment(\.currentHalfYear, halfYear)
            })
            .sheet(isPresented: $showCalculatedTranscriptSheet) {
                StudentCalculatedTranscriptGrades(course: course)
            }
        }
        
    }
    var undoButton: some View {
        Button {
            self.undoRedoVM.undoManagerAction = .undo
            self.showUndoRedoAlert = true
        } label: {
            Label("Undo", systemImage: "arrow.uturn.backward")
        }
    }
    
    var redoButton: some View {
        Button {
            self.undoRedoVM.undoManagerAction = .redo
            self.showUndoRedoAlert = true
        } label: {
            Label("Redo", systemImage: "arrow.uturn.forward")
        }
    }
}

//struct CourseTabView_Previews: PreviewProvider {
//    
//    static let course = previewData(context: PersistenceController.preview.container.viewContext).first!
//    
//    static var previews: some View {
//        NavigationView {
//            CourseTabView(course: course)
//        }
//    }
//}

