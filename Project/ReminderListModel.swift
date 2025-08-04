//
//  ReminderListModel.swift
//  Project
//
//  Created by Nastya Shlepakova on 03/08/2025.
//

import CoreData
import Foundation
import SwiftUI
import Combine


enum Route: Hashable {
    case show(Reminder)
    case edit(Reminder)
}

class ReminderListModel: ObservableObject {
    private(set) var allReminders: [Reminder] {
        didSet {
            applyFilter()
        }
    }
    
    @Published private(set) var filteredReminders: [Reminder] = []
    
    private func applyFilter() {
        filteredReminders.removeAll()
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filteredReminders = allReminders
        } else {
            filteredReminders = allReminders.filter {
                $0.summary.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    @Published var isAddingView = false
    @Published var searchText = "" {
        didSet {
            applyFilter()
        }
    }
    @Published var path = NavigationPath()
    @Published var viewWidth = CGFloat.zero
    @Published var row = 0
    var viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    init(context: NSManagedObjectContext) {
        self.allReminders = []
        self.viewContext = context
        fetchItems()
    }
    
    init(reminders: [Reminder], context: NSManagedObjectContext) {
        self.allReminders = reminders
        self.filteredReminders = reminders
        self.viewContext = context
    }

    func updateReminder() {
        fetchItems()
    }
    
    func selectShow(reminder: Reminder) {
        path.append(Route.show(reminder))
    }
    
    func selectEdit(reminder: Reminder) {
        path.append(Route.edit(reminder))
    }
    
   func clearSelection() {
        path.removeLast()
    }

    func cancelAddingReminder() {
        isAddingView = false
    }

    func startAddingReminder() {
        isAddingView = true
    }

    func addReminder() {
        isAddingView = false
        fetchItems()
    }
    
    func completedChange(reminder: Reminder)  {
        objectWillChange.send()
          viewContext.perform {
              reminder.toggleReminderStatus()
              self.saveContext()
          }
      }
    
    func deleteItem(by id: NSManagedObjectID) {
        viewContext.perform {
            if let object = try? self.viewContext.existingObject(with: id) {
                self.viewContext.delete(object)
                self.saveContext()
                self.fetchItems()
            }
        }
    }
    
    func fetchItems() {
        allReminders.removeAll()
           let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Reminder.updatedAt, ascending: false)]
           do {
               let fetchedTasks = try self.viewContext.fetch(request)
               DispatchQueue.main.async {
                   self.allReminders = fetchedTasks
                   self.applyFilter()
               }
              
           } catch {
               print("Error loading: \(error.localizedDescription)")
           }
       }
    func loadData() async {
        guard let url = URL(string: "https://drive.google.com/uc?export=download&id=1MXypRbK2CS9fqPhTtPonn580h1sHUs2W") else {
                print("Invalid URL")
            return
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                
                if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                    let results = decodedResponse
                    results.todos.forEach { todo in
                        viewContext.perform {
                            let newItem = Reminder(context: self.viewContext)
                            newItem.id = UUID()
                            newItem.summary = todo.todo
                            newItem.notes = todo.todo
                            newItem.updatedAt = Date()
                            if todo.completed {
                                newItem.reminderStatus = .done
                            } else {
                                newItem.reminderStatus = .notReady
                            }
                            self.saveContext()
                        }
                    }
                    UserDefaults.standard.set(false, forKey: "isFirstLoad")
                }
            } else {
                print("Failed to download file, status code: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
            }
        } catch {
            print("Invalid data")
        }
    }
    private func saveContext() {
        viewContext.perform {
            do {
                try self.viewContext.save()
            } catch {
                print("Error saving: \(error.localizedDescription)")
            }
        }
    }
    
}

