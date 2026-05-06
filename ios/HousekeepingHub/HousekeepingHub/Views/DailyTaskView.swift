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
    
    func unitStatusColor(_ unit: DailyUnit) -> Color {
        if unit.completed {
            return Color.green
        }
        
        if unit.cleaning_task != "niente" {
            return Color.yellow
        }
        
        return Color.gray.opacity(0.5)
    }
    
    var workingUnits: [DailyUnit] {
        vm.units.filter { $0.cleaning_task != "niente" }
    }

    var completedWorkingUnitsCount: Int {
        workingUnits.filter { $0.completed }.count
    }

    var remainingWorkingUnitsCount: Int {
        max(workingUnits.count - completedWorkingUnitsCount, 0)
    }

    var completionPercentage: Int {
        guard !workingUnits.isEmpty else { return 100 }
        return Int((Double(completedWorkingUnitsCount) / Double(workingUnits.count)) * 100)
    }

    var completionProgress: Double {
        guard !workingUnits.isEmpty else { return 1.0 }
        return Double(completedWorkingUnitsCount) / Double(workingUnits.count)
    }

    var isDayCompleted: Bool {
        !workingUnits.isEmpty && remainingWorkingUnitsCount == 0
    }
    
    func isToggleableApartment(_ unit: DailyUnit) -> Bool {
        let name = unit.unit_name.lowercased()
        return name == "app 5" || name == "app 6"
    }

    func unitDisplayName(_ unit: DailyUnit) -> String {
        let name = unit.unit_name.lowercased()
        
        if unit.is_room_override {
            if name == "app 5" {
                return "CAMERA 5"
            }
            
            if name == "app 6" {
                return "CAMERA 6"
            }
        }
        
        return unit.unit_name.uppercased()
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
                    
                    // Progress
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HStack {
                            Text(isDayCompleted ? "GIORNATA COMPLETATA ✅" : "PROGRESSO GIORNATA")
                                .font(.headline.bold())
                            
                            Spacer()
                            
                            Text("\(completionPercentage)%")
                                .font(.headline.bold())
                        }
                        
                        ProgressView(value: completionProgress)
                            .tint(isDayCompleted ? .green : .blue)
                        
                        HStack {
                            Text("Completate: \(completedWorkingUnitsCount) / \(workingUnits.count)")
                            Spacer()
                            Text("Rimanenti: \(remainingWorkingUnitsCount)")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                                        HStack(alignment: .top) {
                                            HStack(spacing: 8) {
                                                Text(unitDisplayName(unit))
                                                    .font(.headline.bold())
                                                
                                                Circle()
                                                    .fill(unitStatusColor(unit))
                                                    .frame(width: 10, height: 10)
                                            }
                                            
                                            Spacer()
                                            
                                            HStack(spacing: 10) {
                                                if isToggleableApartment(unit) {
                                                    Button {
                                                        Task {
                                                            await vm.toggleRoomOverride(unitName: unit.unit_name)
                                                        }
                                                    } label: {
                                                        Text(unit.is_room_override ? "CAM" : "APP")
                                                            .font(.caption.bold())
                                                            .padding(.horizontal, 8)
                                                            .padding(.vertical, 4)
                                                            .background(Color.gray.opacity(0.22))
                                                            .clipShape(Capsule())
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                                
                                                if !unit.internal_note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                    Image(systemName: "note.text")
                                                        .font(.headline)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
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
                    Spacer()
                        .frame(height: 110)
                }
                .padding()
            }
            .refreshable {
                vm.loadCachedData()
            }
            .navigationTitle("Housekeeping Hub")
        }
        .task {
            vm.loadCachedData()
            await vm.loadData()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                vm.loadCachedData()
            }
        }
    }
}

#Preview {
    DailyTaskView()
}
