import Foundation

@MainActor
final class DailyViewModel: ObservableObject {
    
    @Published var loading = false
    @Published var date = "-"
    @Published var difficulty = "-"
    @Published var units: [DailyUnit] = []
    
    func loadData() async {
        
        guard let url = URL(string: "https://housekeeping-hub.onrender.com/api/daily") else {
            return
        }
        
        loading = true
        defer { loading = false }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 20
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP status:", httpResponse.statusCode)
            }
            
            let decoded = try JSONDecoder().decode(DailyResponse.self, from: data)
            
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
}
