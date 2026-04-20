import Foundation

struct DailyResponse: Codable {
    let status: String
    let date: String
    let difficulty: String
    let units: [DailyUnit]
}

struct DailyUnit: Codable, Identifiable {
    let id = UUID()

    let unit_name: String
    let booking_status: String
    let cleaning_task: String
    let language: String
    let beddy_notes: String

    enum CodingKeys: String, CodingKey {
        case unit_name
        case booking_status
        case cleaning_task
        case language
        case beddy_notes
    }
}
