import SwiftUI

struct DailyTaskView: View {
    
    @StateObject private var vm = DailyViewModel()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    
    var daRifareCount: Int {
        vm.units.filter { $0.cleaning_task == "da_rifare" }.count
    }

    var smontareCount: Int {
        vm.units.filter { $0.cleaning_task == "smontare" }.count
    }

    var rassettoCount: Int {
        vm.units.filter { $0.cleaning_task == "rassetto" }.count
    }

    var nienteCount: Int {
        vm.units.filter { $0.cleaning_task == "niente" }.count
    }
    
    func formattedStatus(_ value: String) -> String {
        switch value {
        case "check_in":
            return "Check-in"
        case "check_out":
            return "Check-out"
        case "overnight":
            return "Pernottamento"
        case "empty":
            return "Vuota"
        default:
            return value
        }
    }

    func formattedTask(_ value: String) -> String {
        switch value {
        case "da_rifare":
            return "Da rifare"
        case "smontare":
            return "Smontare"
        case "rassetto":
            return "Rassetto"
        case "niente":
            return "Niente"
        default:
            return value
        }
    }
    
    func difficultyColor(_ value: String) -> Color {
        switch value.uppercased() {
        case "LIGHT":
            return Color.blue.opacity(0.22)
        case "MEDIUM":
            return Color.brown.opacity(0.28)
        case "HARD", "HEAVY":
            return Color.red.opacity(0.25)
        default:
            return Color.gray.opacity(0.22)
        }
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
                            .background(difficultyColor(vm.difficulty))
                            .clipShape(Capsule())
                    }
                    .padding()
                    .background(
                        colorScheme == .dark
                        ? AnyShapeStyle(.regularMaterial)
                        : AnyShapeStyle(Color.gray.opacity(0.22))
                    )
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
                    .background(
                        colorScheme == .dark
                        ? AnyShapeStyle(.regularMaterial)
                        : AnyShapeStyle(Color.gray.opacity(0.22))
                    )
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
                                        HStack(spacing: 8) {
                                            Text(unit.unit_name.uppercased())
                                                .font(.headline.bold())
                                            
                                            Circle()
                                                .fill(unit.completed ? Color.green : Color.gray.opacity(0.5))
                                                .frame(width: 10, height: 10)
                                        }
                                        
                                        Text(formattedStatus(unit.booking_status))
                                            .foregroundStyle(.secondary)
                                        
                                        HStack {
                                            Text(formattedTask(unit.cleaning_task))
                                            Spacer()
                                            Text(unit.language)
                                                .bold()
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        colorScheme == .dark
                                        ? AnyShapeStyle(.regularMaterial)
                                        : AnyShapeStyle(Color.gray.opacity(0.22))
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
            }
            .refreshable {
                await vm.loadData()
            }
            .navigationTitle("Housekeeping Hub")
        }
        .task {
            await vm.loadData()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                Task {
                    await vm.loadData()
                }
            }
        }
    }
}

#Preview {
    DailyTaskView()
}
