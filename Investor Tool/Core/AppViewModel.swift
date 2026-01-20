import Foundation
import Combine

final class AppViewModel: ObservableObject {
    let tickerSearchViewModel: TickerSearchViewModel
    let timeframePickerViewModel: TimeframePickerViewModel
    let assumptionsViewModel: AssumptionsViewModel
    let forecastViewModel: ForecastViewModel
    let returnsViewModel: ReturnsViewModel
    let sensitivityViewModel: SensitivityViewModel
    
    private var cancellables = Set<AnyCancellable>()

    init(
        tickerSearchViewModel: TickerSearchViewModel = TickerSearchViewModel(),
        timeframePickerViewModel: TimeframePickerViewModel = TimeframePickerViewModel(),
        assumptionsViewModel: AssumptionsViewModel = AssumptionsViewModel(),
        forecastViewModel: ForecastViewModel = ForecastViewModel(),
        returnsViewModel: ReturnsViewModel = ReturnsViewModel(),
        sensitivityViewModel: SensitivityViewModel = SensitivityViewModel()
    ) {
        self.tickerSearchViewModel = tickerSearchViewModel
        self.timeframePickerViewModel = timeframePickerViewModel
        self.assumptionsViewModel = assumptionsViewModel
        self.forecastViewModel = forecastViewModel
        self.returnsViewModel = returnsViewModel
        self.sensitivityViewModel = sensitivityViewModel
        
        // Forward child view model changes to AppViewModel
        tickerSearchViewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        timeframePickerViewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        assumptionsViewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        forecastViewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        returnsViewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
        
        sensitivityViewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
}
