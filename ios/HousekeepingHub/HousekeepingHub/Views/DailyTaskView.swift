import SwiftUI

struct DailyTaskView: View {
    
    @StateObject private var vm = DailyViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Daily Task")
                            .font(.largeTitle.bold())
                        
                        Text("Dati live da Render")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text("Difficoltà")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(vm.difficulty)
                            .font(.headline.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.orange.opacity(0.18))
                            .clipShape(Capsule())
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    if vm.loading {
                        ProgressView()
                            .padding(.top, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(vm.units) { unit in
                                VStack(alignment: .leading, spacing: 8) {
                                    
                                    Text(unit.unit_name)
                                        .font(.headline.bold())
                                    
                                    Text(unit.booking_status)
                                        .foregroundStyle(.secondary)
                                    
                                    HStack {
                                        Text(unit.cleaning_task)
                                        Spacer()
                                        Text(unit.language)
                                            .bold()
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("HousekeepingHub")
        }
        .task {
            await vm.loadData()
        }
    }
}

#Preview {
    DailyTaskView()
}
