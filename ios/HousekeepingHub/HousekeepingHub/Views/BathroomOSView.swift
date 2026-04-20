import SwiftUI

struct BathroomOSView: View {
    
    var body: some View {
        VStack(spacing: 24) {
            
            VStack(spacing: 6) {
                Text("OS Bagno")
                    .font(.largeTitle.bold())
                
                Text("Procedura guidata pulizia bagno")
                    .foregroundStyle(.secondary)
            }
            .padding(.top)
            
            VStack(spacing: 10) {
                Text("Step 1 / 23")
                    .font(.headline)
                
                ProgressView(value: 1, total: 23)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 16) {
                Text("Spruzzare ganci + interno wc con prodotto + spazzolare con lo scopino.")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button("Indietro") {
                }
                .buttonStyle(.bordered)
                
                Button("Avanti") {
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.bottom)
        }
        .padding()
    }
}

#Preview {
    BathroomOSView()
}
