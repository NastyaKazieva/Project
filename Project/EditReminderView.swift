//
//  EditReminderView.swift
//  Project
//
//  Created by Nastya Shlepakova on 03/08/2025.
//

import SwiftUI

struct EditReminderView: View {
    @ObservedObject var viewModel: EditReminderViewModel
    
    var body: some View {
            VStack {
                //summary field
                TextField("Имя" , text: $viewModel.draft.summary)
                    .frame(maxWidth: .infinity, minHeight: 70)
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.secondary, lineWidth: 1)
                    )
                    .padding()
                
                //notes editor
                TextEditor(text: $viewModel.draft.notes)
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.secondary, lineWidth: 1)
                    )
                    .padding(.horizontal)
            }
            .padding()
            .toolbar {
                //cancel
                ToolbarItem (placement: .topBarLeading) {
                    Button {
                        viewModel.cancel()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.yellow)
                    }
                }
                
                //save
                ToolbarItem (placement: .topBarTrailing) {
                    Button {
                        do {
                            try viewModel.save()
                        }
                        catch {
                            logger.error("Ошибка при сохранении reminder: \(error.localizedDescription)")
                        }
                    } label: {
                        Text("Save")
                            .foregroundColor(.yellow)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
}

#if DEBUG

private func previewContent() -> some View {
    let context = DataController.shared.container.viewContext
    let reminder = Reminder.sample1(in: context)
    return EditReminderView(
        viewModel: .init(
            reminder: reminder,
            env: .init(
                save: {
                    print("Saved")
                },
                cancel: {
                    print("Cancelled")
                }
            ), context: context
        )
    )
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
