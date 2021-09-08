//
//  CourseTabView.swift
//  CoreDataTest
//
//  Created by Tom Rudnick on 04.08.21.
//

import SwiftUI

struct CourseTabView: View {
    
    @Environment(\.currentHalfYear) var halfYear
    
    @StateObject var sendEmailViewModel = SendMultipleEmailsViewModel()
    
    @ObservedObject var course: Course
    @State var showAddStudent = false
    @State var showAddMultipleGrades = false
    
    @State var showTranscriptHalfYearSheet = false
    @State var showTranscriptSheet = false
    @State var showSendEmailSheet = false
    
    
    var body: some View {
        TabView {
            StudentListView(course: course)
                .tabItem {
                    Image(systemName:"person.3.fill")
                    Text("Kurs")
                }
            StudentGradeListView(course: course)
                .tabItem {
                    Image(systemName:"graduationcap")
                    Text("Leistungsübersicht")
                }
            
            GradeAtDatesSelectionView(course: course)
                .tabItem{
                    Image(systemName:"calendar")
                    Text("Daten")
                }
            
        }
        //.edgesIgnoringSafeArea(.top)
        .navigationBarTitle("\(course.title) - \(halfYear == .firstHalf ? "1. HJ" : "2. HJ")", displayMode: .inline)
        .toolbar(content: {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                Text("")
            }
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                Menu {
                    Button(action: {
                        self.showSendEmailSheet.toggle()
                    }, label: {
                        Text("Email verschicken...")
                    }).disabled(!sendEmailViewModel.emailViewModel.emailAccountUsed)
                    if course.type == .holeYear {
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
                    

                } label: {
                    Image(systemName: "ellipsis.circle")
                        .imageScale(.large)
                }
            }
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarTrailing) {
                Button(action: {
                    showAddMultipleGrades = true
                }, label: {
                    Image(systemName: "plus.circle")
                })
                
            }
        })
        .onAppear {
            self.sendEmailViewModel.fetchData(course: course, half: halfYear)
        }
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
        }
        
    }
}

struct CourseTabView_Previews: PreviewProvider {
    
    static let course = previewData(context: PersistenceController.preview.container.viewContext).first!
    
    static var previews: some View {
        NavigationView {
            CourseTabView(course: course)
        }
    }
}

