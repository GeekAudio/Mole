import SwiftUI

@main
struct MoleApp: App {
    var body: some Scene {
        WindowGroup("Mole 中文版") {
            ContentView()
                .frame(minWidth: 900, minHeight: 620)
        }
        .defaultSize(width: 1120, height: 760)
    }
}
