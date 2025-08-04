//
//  DataController.swift
//  Project
//
//  Created by Nastya Shlepakova on 03/08/2025.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    static let shared = DataController()
    
    let container = NSPersistentContainer(name: "ToDoList")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
