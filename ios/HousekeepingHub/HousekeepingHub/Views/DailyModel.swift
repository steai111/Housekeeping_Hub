import Foundation

@MainActor
final class DailyViewModel: ObservableObject {
    
    @Published var loading = false
    @Published var difficulty = "-"
    @Published var units: [DailyUnit] = []
    
    func loadData() async {
        guard let url = URL(string: "https://housekeeping-hub.onrender.com/api/daily") else {
            return
        }
        
        loading = true
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(DailyResponse.self, from: data)
            
            difficulty = decoded.difficulty
            units = decoded.units
            
        } catch {
            print("Errore fetch:", error.localizedDescription)
        }
        
        loading = false
    }
}
