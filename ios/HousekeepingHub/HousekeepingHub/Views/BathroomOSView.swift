import SwiftUI

struct BathroomOSView: View {
    
    private let steps: [String] = [
        "Spruzzare ganci + interno wc con prodotto + spazzolare con lo scopino.",
        "Picchiare scopino sui bordi interni + mettere a scolare sotto l’asse.",
        "Anticalcare spray nel lavandino, nel bidet, pareti doccia e pavimento doccia.",
        "Straccio rosa: passare lavandino.",
        "Straccio rosa: passare bidet.",
        "Straccio rosa: passare doccia.",
        "Sciacquare con doccino le pareti della doccia (anche i muri).",
        "Con spruzzino wc spruzzare scopino e metterlo nel bidet.",
        "Con spruzzino sciacquare interno wc + tirare sciacquone.",
        "Con straccio grigio ripassare tutto il wc dentro e fuori + asse + pavimento fondo pavimento.",
        "Con straccio grigio pulire contenitore scopino.",
        "Rimettere scopino nel contenitore.",
        "Straccio rosa: passare tutto il lavandino dentro fuori sopra sotto. Se tanti peli usare carta prima.",
        "Straccio rosa: passare tutto il bidet.",
        "Passare vetri della doccia con tira vetri.",
        "Straccio doccia blu umido: passare vetri e pareti della doccia.",
        "Controllare contro luce pareti vetro doccia.",
        "Passare tiravetri pavimento doccia. Ogni tanto controllare piletta. Se ci sono troppi peli usare carta.",
        "Straccio per asciugare azzurro: asciugare tutto.",
        "Asciugare gabinetto con carta.",
        "Alcool 70% + panno azzurro/verde: passare specchio.",
        "Pulire piedini tavolino di legno e sotto al cestino con carta già usata.",
        "Spruzzare wc con candeggina e lasciarla dentro."
    ]
    
    @State private var currentStepIndex: Int = 0
    @Environment(\.colorScheme) var colorScheme
    
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
                Text("Step \(displayStep) / \(steps.count)")
                    .font(.headline)
                
                ProgressView(value: Double(progressValue), total: Double(steps.count))
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 16) {
                Text(currentStepText)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                colorScheme == .dark
                ? AnyShapeStyle(.regularMaterial)
                : AnyShapeStyle(Color.gray.opacity(0.22))
            )
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button {
                    currentStepIndex = 0
                } label: {
                    Text("Reset")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(width: 100, height: 44)
                }
                .background(colorScheme == .dark ? Color.white : Color.black)
                .foregroundColor(colorScheme == .dark ? .black : .white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Button {
                    if currentStepIndex > 0 {
                        currentStepIndex -= 1
                    }
                } label: {
                    Text("Indietro")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(width: 100, height: 44)
                }
                .background(Color.gray.opacity(0.22))
                .foregroundColor(Color(uiColor: .label))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Button {
                    if currentStepIndex < steps.count {
                        currentStepIndex += 1
                    }
                } label: {
                    Text("Avanti")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(width: 100, height: 44)
                }
                .background(Color.gray.opacity(0.22))
                .foregroundColor(Color(uiColor: .label))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.35), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.bottom)
        }
        .padding()
    }
    
    var currentStepText: String {
        if currentStepIndex >= steps.count {
            return "Procedura completata."
        }
        return steps[currentStepIndex]
    }
    
    var displayStep: Int {
        min(currentStepIndex + 1, steps.count)
    }
    
    var progressValue: Int {
        min(currentStepIndex + 1, steps.count)
    }
}

#Preview {
    BathroomOSView()
}
