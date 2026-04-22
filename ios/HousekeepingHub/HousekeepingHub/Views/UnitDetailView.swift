import SwiftUI

struct UnitDetailView: View {
    
    let unit: DailyUnit
    @ObservedObject var vm: DailyViewModel
    
    @State private var internalNoteText: String = ""
    @State private var isSaving = false
    @State private var saveMessage: String = ""
    @FocusState private var noteFieldFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    
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
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(unit.unit_name.uppercased())
                            .font(.largeTitle.bold())
                        
                        Text(formattedStatus(unit.booking_status))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Stato Operativo")
                            .font(.headline)
                        
                        Text("Task: \(formattedTask(unit.cleaning_task))")
                        Text("Lingua: \(unit.language)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        colorScheme == .dark
                        ? AnyShapeStyle(.regularMaterial)
                        : AnyShapeStyle(Color.gray.opacity(0.22))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Note Prenotazione")
                            .font(.headline)
                        
                        if unit.beddy_notes.isEmpty {
                            Text("Nessuna nota")
                                .foregroundStyle(.secondary)
                        } else {
                            Text(unit.beddy_notes)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        colorScheme == .dark
                        ? AnyShapeStyle(.regularMaterial)
                        : AnyShapeStyle(Color.gray.opacity(0.22))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Note Interne")
                            .font(.headline)
                        
                        TextField("", text: $internalNoteText, axis: .vertical)
                            .focused($noteFieldFocused)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    proxy.scrollTo("internalNotesBlock", anchor: .center)
                                }
                            }
                            .textFieldStyle(.plain)
                            .lineLimit(5, reservesSpace: true)
                            .padding(14)
                            .background(Color(uiColor: .systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Button {
                            Task {
                                isSaving = true
                                saveMessage = ""
                                await vm.saveInternalNote(unitName: unit.unit_name, note: internalNoteText)
                                isSaving = false
                                noteFieldFocused = false
                                saveMessage = "Nota salvata"
                                
                                try? await Task.sleep(nanoseconds: 1_200_000_000)
                                saveMessage = ""
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                                    )
                                
                                Text(isSaving ? "Salvataggio..." : "Salva nota")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                        }
                        .buttonStyle(.plain)
                        .disabled(isSaving)
                        .opacity(isSaving ? 0.7 : 1)
                        
                        if !saveMessage.isEmpty {
                            Text(saveMessage)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        colorScheme == .dark
                        ? AnyShapeStyle(.regularMaterial)
                        : AnyShapeStyle(Color.gray.opacity(0.22))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .id("internalNotesBlock")
                }
                .padding()
            }
            .navigationTitle("Dettaglio")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                internalNoteText = unit.internal_note
            }
        }
    }
}

#Preview {
    UnitDetailView(
        unit: DailyUnit(
            unit_name: "camera 1",
            booking_status: "check_in",
            cleaning_task: "da_rifare",
            language: "IT",
            beddy_notes: "Letti singoli",
            internal_note: "Nota interna test"
        ),
        vm: DailyViewModel()
    )
}
