import SwiftUI

struct DailyTaskView: View {
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text("Daily Task")
                        .font(.largeTitle.bold())
                    
                    Text("Martedì 21 Aprile 2026")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Difficulty
                HStack {
                    Text("Difficoltà")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("MEDIUM")
                        .font(.headline.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.orange.opacity(0.18))
                        .clipShape(Capsule())
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Summary
                VStack(alignment: .leading, spacing: 10) {
                    Text("Riassunto Operativo")
                        .font(.headline)
                    
                    Text("Da rifare: 3")
                    Text("Smontare: 0")
                    Text("Rassetto: 1")
                    Text("Niente: 3")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Units
                VStack(spacing: 12) {
                    NavigationLink {
                        UnitDetailView()
                    } label: {
                        unitCard(
                            name: "CAMERA 1",
                            status: "Check-in",
                            task: "Da rifare",
                            language: "IT"
                        )
                    }
                    
                    unitCard(
                        name: "CAMERA 4",
                        status: "Pernottamento",
                        task: "Rassetto",
                        language: "ENG"
                    )
                    
                    unitCard(
                        name: "APP 7",
                        status: "Pernottamento",
                        task: "Niente",
                        language: "ENG"
                    )
                }
            }
            .padding()
        }
        .navigationTitle("HousekeepingHub")
    }
    
    func unitCard(name: String, status: String, task: String, language: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.headline.bold())
            
            Text(status)
                .foregroundStyle(.secondary)
            
            HStack {
                Text(task)
                Spacer()
                Text(language)
                    .bold()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        DailyTaskView()
    }
}
