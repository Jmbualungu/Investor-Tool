import SwiftUI

@main
struct ForecastAIApp: App {
    @StateObject private var flowRouter = FlowRouter()
    @StateObject private var config = GlobalAppConfig()
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainFlowView()
                .environmentObject(flowRouter)
                .environmentObject(config)
                .environmentObject(appViewModel)
        }
    }
}
