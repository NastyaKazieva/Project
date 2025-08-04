//
//  EditReminderViewModel.swift
//  Project
//
//  Created by Nastya Shlepakova on 03/08/2025.
//

import CoreData
import Foundation

struct ReminderDraft {
    var summary: String = ""
    var notes: String = ""
    var status: Reminder.Status = .notReady
}

class EditReminderViewModel: ObservableObject {
    struct Environment {
        let save: () -> Void
        let cancel:() -> Void
    }
    @Published var draft: ReminderDraft
    private let context: NSManagedObjectContext
    private var existingReminder: Reminder?
    private let env: Environment
    
    
    init(reminder: Reminder?, env: Environment, context: NSManagedObjectContext) {
        self.existingReminder = reminder
        if let reminder = reminder {
            self.draft = ReminderDraft(
            summary: reminder.summary,
            notes: reminder.notes,
            status: reminder.reminderStatus
            )
        } else {
            self.draft = ReminderDraft()
        }
        
        self.env = env
        self.context = context
    }
    
    func save() throws {
        guard !draft.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw SaveError.invalid("Summary cannot be empty.")
        }
        
        if let existing = existingReminder {
            existing.update(summary: draft.summary, notes: draft.notes, status: draft.status)
        } else {
            let reminder = Reminder(context: context)
            context.insert(reminder)
            reminder.id = UUID()
            reminder.summary = draft.summary
            reminder.notes = draft.notes
            reminder.reminderStatus = draft.status
            reminder.updatedAt = Date()
        }
        
        do {
            try context.save()
        } catch {
            context.rollback()
            logger.error("Failed to save reminder: \(error.localizedDescription)")
            throw error
        }
        env.save()
    }
    func cancel() {
        env.cancel()
    }
}
