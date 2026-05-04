import Foundation

@MainActor
final class DailyViewModel: ObservableObject {
    
    @Published var loading = false
    @Published var date = "-"
    @Published var difficulty = "-"
    @Published var units: [DailyUnit] = []
    
    private let cacheKey = "cachedDailyResponse"

    func loadCachedData() {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else {
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(DailyResponse.self, from: data)
            date = decoded.date
            difficulty = decoded.difficulty
            units = decoded.units
            
            print("Daily cache loaded OK:", decoded.units.count, "unità")
        } catch {
            print("Errore load cache:", error)
        }
    }

    func saveCache(_ response: DailyResponse) {
        do {
            let data = try JSONEncoder().encode(response)
            UserDefaults.standard.set(data, forKey: cacheKey)
            print("Daily cache saved OK")
        } catch {
            print("Errore save cache:", error)
        }
    }
    
    func loadData() async {
        
        guard let url = URL(string: "https://housekeeping-hub.onrender.com/api/daily") else {
            return
        }
        
        if units.isEmpty {
            loadCachedData()
        }
        
        loading = true
        defer { loading = false }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP status:", httpResponse.statusCode)
            }
            
            let decoded = try JSONDecoder().decode(DailyResponse.self, from: data)
            saveCache(decoded)
            
            date = decoded.date
            difficulty = decoded.difficulty
            units = decoded.units
            
            print("Daily loaded OK:", decoded.units.count, "unità")
            
        } catch {
            print("Errore loadData:", error)
        }
    }
    
    func saveInternalNote(unitName: String, note: String) async {
        
        guard let url = URL(string: "https://housekeeping-hub.onrender.com/api/save-note") else {
            return
        }
        
        guard let body = try? JSONSerialization.data(withJSONObject: [
            "unit_name": unitName,
            "note": note
        ]) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            _ = try await URLSession.shared.data(for: request)
            await loadData()
        } catch {
            print("Errore save note")
        }
    }
    
    func completeUnit(unitName: String) async {
        
        guard let url = URL(string: "https://housekeeping-hub.onrender.com/api/complete-unit") else {
            return
        }
        
        guard let body = try? JSONSerialization.data(withJSONObject: [
            "unit_name": unitName
        ]) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            _ = try await URLSession.shared.data(for: request)
            await loadData()
        } catch {
            print("Errore complete unit")
        }
    }
    
    func toggleRoomOverride(unitName: String) async {
        
        guard let index = units.firstIndex(where: { $0.unit_name == unitName }) else {
            return
        }
        
        let oldUnit = units[index]
        let newOverride = !oldUnit.is_room_override
        
        let newCleaningTask: String
        if oldUnit.booking_status == "overnight" {
            newCleaningTask = newOverride ? "rassetto" : "niente"
        } else {
            newCleaningTask = oldUnit.cleaning_task
        }
        
        let updatedUnit = DailyUnit(
            unit_name: oldUnit.unit_name,
            booking_status: oldUnit.booking_status,
            cleaning_task: newCleaningTask,
            language: oldUnit.language,
            beddy_notes: oldUnit.beddy_notes,
            internal_note: oldUnit.internal_note,
            completed: oldUnit.completed,
            is_room_override: newOverride
        )
        
        units[index] = updatedUnit
        
        let response = DailyResponse(
            status: "ok",
            date: date,
            difficulty: difficulty,
            units: units
        )
        
        saveCache(response)
        
        guard let url = URL(string: "https://housekeeping-hub.onrender.com/api/toggle-room-override") else {
            return
        }
        
        guard let body = try? JSONSerialization.data(withJSONObject: [
            "unit_name": unitName
        ]) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            _ = try await URLSession.shared.data(for: request)
        } catch {
            print("Errore toggle room override")
        }
    }
}
