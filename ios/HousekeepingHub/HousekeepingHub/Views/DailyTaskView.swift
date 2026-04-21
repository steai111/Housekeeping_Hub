import SwiftUI

struct DailyTaskView: View {
    
    @StateObject private var vm = DailyViewModel()
    
    var daRifareCount: Int {
        vm.units.filter { $0.cleaning_task == "Da rifare" }.count
    }
    
    var smontareCount: Int {
        vm.units.filter { $0.cleaning_task == "Smontare" }.count
    }
    
    var rassettoCount: Int {
        vm.units.filter { $0.cleaning_task == "Rassetto" }.count
    }
    
    var nienteCount: Int {
        vm.units.filter { $0.cleaning_task == "Niente" }.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Daily Task")
                            .font(.largeTitle.bold())
                        
                        Text(vm.date)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Difficulty
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
                    
                    // Summary
                    VStack(alignment: .leading, spacing: 10) {
                        Text("RIASSUNTO OPERATIVO")
                            .font(.headline.bold())
                        
                        Text("Da rifare: \(daRifareCount)")
                        Text("Smontare: \(smontareCount)")
                        Text("Rassetto: \(rassettoCount)")
                        Text("Niente: \(nienteCount)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    // Units
                    if vm.loading {
                        ProgressView()
                            .padding(.top, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(vm.units) { unit in
                                NavigationLink {
                                    UnitDetailView(unit: unit, vm: vm)
                                } label: {
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
                                .buttonStyle(.plain)
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
