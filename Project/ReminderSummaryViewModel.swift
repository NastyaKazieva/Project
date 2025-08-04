//
//  ReminderSummaryViewModel.swift
//  Project
//
//  Created by Nastya Shlepakova on 03/08/2025.
//

import Foundation

class ReminderSummaryViewModel: ObservableObject {
    @Published private(set) var reminder: Reminder
    init(reminder: Reminder) {
        self.reminder = reminder
    }
}
