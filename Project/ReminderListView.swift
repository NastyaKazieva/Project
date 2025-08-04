//
//  ReminderListView.swift
//  Project
//
//  Created by Nastya Shlepakova on 03/08/2025.
//
import CoreData
import SwiftUI

struct ReminderListView: View {
    @AppStorage("isFirstLoad") var isWelcomeScreenOver = true
    @ObservedObject var viewModel: ReminderListModel
    @Environment(\.colorScheme) var colorScheme
    
    init(context: NSManagedObjectContext) {
        _viewModel = ObservedObject(wrappedValue: ReminderListModel( context: context))
    }
    init(context: NSManagedObjectContext, reminders: [Reminder]) {
        _viewModel = ObservedObject(wrappedValue: ReminderListModel(reminders: reminders, context: context))
    }
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List(viewModel.filteredReminders, id: \.self) { reminder in
                HStack(alignment: .center) {
                    Image(systemName: reminder.isDone ?  "checkmark.circle" : "circle")
                        .resizable()
                        .font(.system(size: 16, weight: .thin))
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(reminder.isDone ? .yellow : .gray)
                        .onTapGesture {
                            viewModel.completedChange(reminder: reminder)
                        }
                        .frame(maxHeight: .infinity, alignment: .topLeading)
                    ReminderSummaryView(viewModel: ReminderSummaryViewModel( reminder: reminder))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectShow(reminder: reminder)
                        }
                        .contextMenu {
                            Button {
                                viewModel.selectEdit(reminder: reminder)
                            } label: {
                                Label("Редактировать", systemImage: "square.and.pencil")
                            }
                            ShareLink(item: reminder.summary) {
                                Label("Поделиться", systemImage: "square.and.arrow.up")
                            }
                            Button(role: .destructive) {
                                viewModel.deleteItem(by: reminder.objectID)
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        } preview: {
                            ReminderSummaryView(viewModel: ReminderSummaryViewModel( reminder: reminder))
                                .padding()
                                .frame(minWidth: viewModel.viewWidth, alignment: .leading)
                                .background( Color(UIColor.secondarySystemGroupedBackground))
                                .environment(\.colorScheme, colorScheme)
                                .containerRelativeFrame(.horizontal)
                        }
                    
                }
                .id(reminder.id)
                .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                .listRowBackground(Color.clear)
                .listRowSeparatorTint(.secondary)
                .listRowInsets(EdgeInsets())
                .padding(.vertical)
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .show(let reminder):
                    let reminderViewModel = ReminderViewModel(reminder: reminder, env: .init(save: {
                        viewModel.clearSelection()
                    }))
                    ReminderView(viewModel: reminderViewModel)
                case .edit(let reminder):
                    EditReminderView(
                        viewModel: .init(
                            reminder: reminder,
                            env: .init(
                                save: {
                                    viewModel.updateReminder()
                                    viewModel.clearSelection()
                                },
                                cancel: {
                                    viewModel.clearSelection()
                                }
                            ), context: viewModel.viewContext
                        )
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    ZStack {
                        Text("\(viewModel.allReminders.count) Задач")
                        HStack {
                            Spacer()
                            Button (action: viewModel.startAddingReminder) {
                                Image(systemName: "square.and.pencil")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isAddingView) {
            NavigationStack {
                EditReminderView(
                    viewModel: .init(
                        reminder: nil,
                        env: .init(
                            save: {
                                viewModel.addReminder()
                            },
                            cancel: {
                                viewModel.cancelAddingReminder()
                            }
                        ), context: viewModel.viewContext
                    )
                )
            }
        }
        .task {
            if isWelcomeScreenOver {
                await viewModel.loadData()
            }
        }
        .searchable(text: $viewModel.searchText)
        .overlay {
            GeometryReader { geometry in
                Color.clear
                .onAppear {
                    viewModel.viewWidth = geometry.frame(in: .local).size.width
                }
            }
        }
        
    }
}


#if DEBUG
private func previewContent() -> some View {
    let context = DataController.shared.container.viewContext
    let reminder1 = Reminder.sample1(in: context)
    let reminder2 = Reminder.sample2(in: context)
    
    return ReminderListView(context: context, reminders: [reminder1, reminder2])
}

#Preview("Dark Mode") {
    previewContent()
        .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    previewContent()
        .preferredColorScheme(.light)
}

#endif
