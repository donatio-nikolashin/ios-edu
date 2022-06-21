import Foundation

struct Chat: Identifiable {
    
    var id: UUID { person.id }
    let person: Person
    var messages: [Message]
    var hasUnreadMessage = false
    
}

struct Person: Identifiable {
    
    let id = UUID()
    let name: String
    let imgString: String
    
}

struct Message: Identifiable {
    
    enum MessageType {
        case sent, received
    }
    
    let id = UUID()
    let date: Date
    let text: String
    let type: MessageType
    
    init(_ text: String, type: MessageType, date: Date) {
        self.text = text
        self.type = type
        self.date = date
    }
    
    init(_ text: String, type: MessageType) {
        self.init(text, type: type, date: Date())
    }
    
}

extension Chat {
    
    static let samples: [Chat] = [
        Chat(
            person: Person(name: "Hinata", imgString: "sample_2"),
            messages: [
                Message("Hey", type: .received, date: Date(timeIntervalSinceNow: -86400 * 2)),
                Message("Wassup", type: .sent, date: Date(timeIntervalSinceNow: -86400 * 2)),
                Message("How r u?", type: .received, date: Date(timeIntervalSinceNow: -86400 * 1)),
                Message("Im ok u?", type: .sent, date: Date(timeIntervalSinceNow: -86400 * 1)),
                Message("Fine", type: .received),
            ],
            hasUnreadMessage: false
        ),
        Chat(
            person: Person(name: "Zenitsu", imgString: "sample_1"),
            messages: [
                Message("Test message 1", type: .sent, date: Date(timeIntervalSinceNow: -86400 * 3)),
                Message("Test message 2", type: .received, date: Date(timeIntervalSinceNow: -86400 * 3)),
                Message("Test message 3", type: .sent, date: Date(timeIntervalSinceNow: -86400 * 3)),
                Message("Test message 4", type: .received, date: Date(timeIntervalSinceNow: -86400 * 3)),
                Message("Test message 5", type: .sent, date: Date(timeIntervalSinceNow: -86400 * 2)),
                Message("Test message 6", type: .sent, date: Date(timeIntervalSinceNow: -86400 * 2)),
                Message("Test message 7", type: .received, date: Date(timeIntervalSinceNow: -86400 * 1)),
                Message("Test message 8", type: .received, date: Date(timeIntervalSinceNow: -86400 * 1)),
                Message("Test message 9", type: .sent),
                Message("Test message 10", type: .received),
            ],
            hasUnreadMessage: true
        )
    ]
    
}
