import SwiftUI

struct UnitDetailView: View {
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("CAMERA 1")
                        .font(.largeTitle.bold())
                    
                    Text("Check-in")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Stato Operativo")
                        .font(.headline)
                    
                    Text("Task: Da rifare")
                    Text("Lingua: IT")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Note Prenotazione")
                        .font(.headline)
                    
                    Text("Letti separati fattura")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Note Interne")
                        .font(.headline)
                    
                    Text("Disponibile nella prossima versione")
                        .foregroundStyle(.secondary)
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
    }
}

#Preview {
    NavigationStack {
        UnitDetailView()
    }
}
