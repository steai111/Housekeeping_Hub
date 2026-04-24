import SwiftUI

enum AppTab {
    case daily
    case bathroom
}

struct ContentView: View {
    
    @AppStorage("selectedAppearance") private var selectedAppearance: String = "system"
    @State private var selectedTab: AppTab = .daily
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            Group {
                switch selectedTab {
                case .daily:
                    NavigationStack {
                        DailyTaskView()
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    appearanceMenu
                                }
                            }
                    }
                    
                case .bathroom:
                    NavigationStack {
                        BathroomOSView()
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    appearanceMenu
                                }
                            }
                    }
                }
            }
            .padding(.bottom, selectedTab == .bathroom ? 92 : 0)

            customTabBar
        }
        .preferredColorScheme(appColorScheme)
    }
    
    var customTabBar: some View {
        HStack {
            
            Button {
                selectedTab = .daily
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "list.clipboard")
                        .font(.title3)
                    
                    Text("Daily Task")
                        .font(.caption.bold())
                }
                .foregroundColor(selectedTab == .daily ? .blue : .gray)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            
            Button {
                selectedTab = .bathroom
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.title3)
                    
                    Text("OS Bagno")
                        .font(.caption.bold())
                }
                .foregroundColor(selectedTab == .bathroom ? .blue : .gray)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
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
