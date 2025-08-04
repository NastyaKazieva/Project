//
//  ReminderDetailView.swift
//  Project
//
//  Created by Nastya Shlepakova on 03/08/2025.
//

import SwiftUI

struct ReminderDetailView: View {
    let reminder: Reminder

    var body: some View {
        VStack(alignment: .leading) {
            //summary
            Text(reminder.summary)
                .bold()
                .font(.largeTitle)
                .padding(.bottom, 3)

            //date
            Text(DateConvert.dateToString(date: reminder.updatedAt))
                .font(.caption)
                .foregroundStyle(Color.gray)
                .padding(.bottom)

            //notes
            Text(reminder.notes)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal)
    }
}

#if DEBUG

#Preview {
    let context = DataController.shared.container.viewContext
    let sampleReminder = Reminder.sample1(in: context)
    
    return ReminderDetailView(reminder: sampleReminder)
            .preferredColorScheme(.dark)
}

#endif
