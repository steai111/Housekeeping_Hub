import SwiftUI

struct UnitDetailView: View {
    
    let unit: DailyUnit
    @ObservedObject var vm: DailyViewModel
    
    @State private var internalNoteText: String = ""
    @State private var isSaving = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(unit.unit_name)
                        .font(.largeTitle.bold())
                    
                    Text(unit.booking_status)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Stato Operativo")
                        .font(.headline)
                    
                    Text("Task: \(unit.cleaning_task)")
                    Text("Lingua: \(unit.language)")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.regularMaterial)
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
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Note Interne")
                        .font(.headline)
                    
                    TextField("Scrivi nota interna...", text: $internalNoteText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(4, reservesSpace: true)
                    
                    Button {
                        Task {
                            isSaving = true
                            await vm.saveInternalNote(unitName: unit.unit_name, note: internalNoteText)
                            isSaving = false
                        }
                    } label: {
                        Text(isSaving ? "Salvataggio..." : "Salva nota")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isSaving)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
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
