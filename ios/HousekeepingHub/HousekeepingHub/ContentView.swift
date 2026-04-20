//
//  ContentView.swift
//  HousekeepingHub
//
//  Created by Stefano Ardemagni on 20/04/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            
            NavigationStack {
                DailyTaskView()
            }
            .tabItem {
                Label("Daily Task", systemImage: "list.clipboard")
            }
            
            NavigationStack {
                BathroomOSView()
            }
            .tabItem {
                Label("OS Bagno", systemImage: "sparkles")
            }
        }
    }
}

#Preview {
    ContentView()
}
