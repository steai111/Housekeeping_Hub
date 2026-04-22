import SwiftUI

struct ContentView: View {
    
    @AppStorage("selectedAppearance") private var selectedAppearance: String = "system"
    
    var body: some View {
        TabView {
            
            NavigationStack {
                DailyTaskView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            appearanceMenu
                        }
                    }
            }
            .tabItem {
                Label("Daily Task", systemImage: "list.clipboard")
            }
            
            NavigationStack {
                BathroomOSView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            appearanceMenu
                        }
                    }
            }
            .tabItem {
                Label("OS Bagno", systemImage: "sparkles")
            }
        }
        .preferredColorScheme(appColorScheme)
    }
    
    var appearanceMenu: some View {
        Button {
            selectedAppearance =
                selectedAppearance == "dark"
                ? "light"
                : "dark"
        } label: {
            Image(systemName: "circle.lefthalf.filled")
        }
    }
    
    var appColorScheme: ColorScheme? {
        switch selectedAppearance {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }
}

#Preview {
    ContentView()
}
