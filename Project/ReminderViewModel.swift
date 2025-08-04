//
//  ReminderViewModel.swift
//  Project
//
//  Created by Nastya Shlepakova on 03/08/2025.
//


import CoreData
import Foundation

enum SaveError: Error, LocalizedError, Equatable {
        case invalid(String)

        var errorDescription: String? {
            switch self {
            case .invalid(let message): return message
            }
        }
}

class ReminderViewModel: ObservableObject {
    struct Environment {
        let save: () -> Void
    }
    let env: Environment

    @Published var reminder: Reminder
    
    init(reminder: Reminder, env: Environment) {
        self.reminder = reminder
        self.env = env
        //self.viewContext = context
    }
}

