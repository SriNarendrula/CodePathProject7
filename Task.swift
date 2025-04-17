//
//  Task.swift
//

import UIKit

// The Task model
struct Task {

    // The task's title
    var title: String

    // An optional note
    var note: String?

    // The due date by which the task should be completed
    var dueDate: Date

    // Initialize a new task
    // `note` and `dueDate` properties have default values provided if none are passed into the init by the caller.
    init(title: String, note: String? = nil, dueDate: Date = Date()) {
        self.title = title
        self.note = note
        self.dueDate = dueDate
    }

    // A boolean to determine if the task has been completed. Defaults to `false`
    var isComplete: Bool = false {

        // Any time a task is completed, update the completedDate accordingly.
        didSet {
            if isComplete {
                // The task has just been marked complete, set the completed date to "right now".
                completedDate = Date()
            } else {
                completedDate = nil
            }
        }
    }

    // The date the task was completed
    // private(set) means this property can only be set from within this struct, but read from anywhere (i.e. public)
    private(set) var completedDate: Date?

    // The date the task was created
    // This property is set as the current date whenever the task is initially created.
    private(set) var createdDate: Date = Date()

    // An id (Universal Unique Identifier) used to identify a task.
    private(set) var id: String = UUID().uuidString
}

// MARK: - Task + UserDefaults
extension Task: Codable {
    // The key we'll use to store tasks in UserDefaults
       private static let tasksKey = "tasks_key"

       // Given an array of tasks, encodes them to data and saves to UserDefaults.
       static func save(_ tasks: [Task]) {
           let encoder = JSONEncoder()
           
           do {
               // Encode the tasks array to data
               let tasksData = try encoder.encode(tasks)
               
               // Save the encoded data to UserDefaults with our key
               UserDefaults.standard.set(tasksData, forKey: tasksKey)
           } catch {
               print("Error encoding tasks: \(error.localizedDescription)")
           }
       }

       // Retrieve an array of saved tasks from UserDefaults.
       static func getTasks() -> [Task] {
           // Get the saved task data using our key
           guard let tasksData = UserDefaults.standard.data(forKey: tasksKey) else {
               return [] // Return empty array if no data exists
           }
           
           let decoder = JSONDecoder()
           
           do {
               // Decode the data into an array of Task objects
               let tasks = try decoder.decode([Task].self, from: tasksData)
               return tasks
           } catch {
               print("Error decoding tasks: \(error.localizedDescription)")
               return [] // Return empty array if decoding fails
           }
       }

       // Add a new task or update an existing task with the current task.
       func save() {
           // Get the current saved tasks
           var tasks = Task.getTasks()
           
           // Check if task already exists in array by matching ID
           if let existingIndex = tasks.firstIndex(where: { $0.id == self.id }) {
               // Remove existing task
               tasks.remove(at: existingIndex)
               // Insert updated task at same position
               tasks.insert(self, at: existingIndex)
           } else {
               // Add new task to end of array
               tasks.append(self)
           }
           
           // Save updated tasks array to UserDefaults
           Task.save(tasks)
       }
}
