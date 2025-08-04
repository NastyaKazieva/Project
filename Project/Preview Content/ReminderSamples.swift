//
//  ReminderSamples.swift
//  Project
//
//  Created by Nastya Shlepakova on 03/08/2025.
//

import CoreData
import Foundation

extension Reminder {
    
    static func sample1(in context: NSManagedObjectContext) -> Reminder {
        let reminder = Reminder(context: context)
        reminder.summary = "Buy groceries"
        reminder.notes = "Milk, Eggs, Bread"
        reminder.status = "done"
        reminder.updatedAt = Date()
        return reminder
    }

    static func sample2(in context: NSManagedObjectContext) -> Reminder {
        let reminder = Reminder(context: context)
        reminder.summary = "Make notes"
        reminder.notes = "Write all notes"
        reminder.status = "notReady"
        reminder.updatedAt = Date()
        return reminder
    }
}
