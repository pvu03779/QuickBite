import SwiftUI
import MapKit
import CoreLocation
import Combine

struct NearbyMarketsView: View {
    @StateObject private var viewModel = MarketsViewModel()
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        VStack(spacing: 0) {
            searchBar

            if let status = viewModel.locationManager?.permissionStatus {
                if status == .denied || status == .restricted {
                    locationDeniedView
                }
            }

            Map(position: $viewModel.cameraPosition, selection: $viewModel.selectedResult) {
                ForEach(viewModel.searchResults) { market in
                    Annotation(market.item.name ?? "Market", coordinate: market.item.placemark.coordinate) {
                        Image(systemName: "cart.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }

                if let userLoc = viewModel.locationManager?.userLocation {
                    Annotation("You", coordinate: userLoc.coordinate) {
                        Image(systemName: "person.circle.fill")
                            .foregroundColor(.green)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
            }
            .frame(height: 300)

            if viewModel.isSearching {
                ProgressView("Looking around...")
                    .padding()
                Spacer()
            } else if viewModel.searchResults.isEmpty {
                Text("No nearby markets found for “\(viewModel.searchText)”.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .padding()
                Spacer()
            } else {
                List(viewModel.searchResults) { result in
                    MarketRow(result: result)
                        .onTapGesture {
                            viewModel.select(result)
                        }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Nearby Markets")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.connectLocationManager(locationManager)
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search for a store...", text: $viewModel.searchText)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding()
    }

    private var locationDeniedView: some View {
        VStack(spacing: 6) {
            Text("Location access denied")
                .font(.headline)
            Text("Turn it on in Settings to find nearby stores.")
                .font(.caption)
                .multilineTextAlignment(.center)

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.bordered)
            .tint(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding()
    }
}

@MainActor
final class MarketsViewModel: ObservableObject {
    @Published var searchResults: [MarketResult] = []
    @Published var isSearching = false
    @Published var searchText = "supermarket"
    @Published var cameraPosition: MapCameraPosition = .automatic
    @Published var selectedResult: MarketResult?

    private(set) var locationManager: LocationManager?
    private var cancellables = Set<AnyCancellable>()
    private var task: Task<Void, Never>?

    init() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self, !text.isEmpty,
                      let location = self.locationManager?.userLocation else { return }
                self.search(query: text, near: location)
            }
            .store(in: &cancellables)
    }

    func connectLocationManager(_ manager: LocationManager) {
        if locationManager != nil { return }
        locationManager = manager

        if let loc = manager.userLocation {
            search(query: searchText, near: loc)
        } else {
            manager.$userLocation
                .compactMap { $0 }
                .first()
                .sink { [weak self] loc in
                    self?.search(query: self?.searchText ?? "supermarket", near: loc)
                }
                .store(in: &cancellables)
        }
    }

    func search(query: String, near location: CLLocation) {
        task?.cancel()
        task = Task {
            isSearching = true
            defer { isSearching = false }

            let req = MKLocalSearch.Request()
            req.naturalLanguageQuery = query
            req.region = MKCoordinateRegion(center: location.coordinate,
                                            latitudinalMeters: 5000,
                                            longitudinalMeters: 5000)

            do {
                let response = try await MKLocalSearch(request: req).start()
                if Task.isCancelled { return }

                let items = response.mapItems.compactMap { item -> MarketResult? in
                    guard let coord = item.placemark.location else { return nil }
                    let dist = location.distance(from: coord)
                    return MarketResult(item: item, distance: dist)
                }
                .sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }

                self.searchResults = items
                self.cameraPosition = .region(MKCoordinateRegion(center: location.coordinate,
                                                                 latitudinalMeters: 5000,
                                                                 longitudinalMeters: 5000))
            } catch {
                print("Search failed:", error.localizedDescription)
                if !Task.isCancelled { self.searchResults = [] }
            }
        }
    }

    func select(_ result: MarketResult) {
        selectedResult = result
        cameraPosition = .region(MKCoordinateRegion(
            center: result.item.placemark.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        ))
        updateETA(for: result)
    }

    private func updateETA(for result: MarketResult) {
        guard let userLoc = locationManager?.userLocation else { return }

        let req = MKDirections.Request()
        req.source = MKMapItem(placemark: MKPlacemark(coordinate: userLoc.coordinate))
        req.destination = result.item
        req.transportType = .automobile

        Task {
            do {
                let resp = try await MKDirections(request: req).calculate()
                if let route = resp.routes.first,
                   let idx = searchResults.firstIndex(where: { $0.id == result.id }) {
                    searchResults[idx].eta = route.expectedTravelTime
                }
            } catch {
                print("ETA lookup failed:", error.localizedDescription)
            }
        }
    }

    func openInMaps(_ item: MKMapItem) {
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

struct MarketResult: Identifiable, Hashable {
    let id = UUID()
    let item: MKMapItem
    let distance: CLLocationDistance?
    var eta: TimeInterval?

    var distanceLabel: String? {
        guard let distance else { return nil }
        let f = LengthFormatter()
        f.unitStyle = .short
        return f.string(fromMeters: distance)
    }

    var etaLabel: String? {
        guard let eta else { return nil }
        let f = DateComponentsFormatter()
        f.allowedUnits = [.hour, .minute]
        f.unitsStyle = .short
        return f.string(from: eta)
    }
}

struct MarketRow: View {
    let result: MarketResult
    @EnvironmentObject private var viewModel: MarketsViewModel

    var body: some View {
        Button {
            viewModel.openInMaps(result.item)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.item.name ?? "Unknown")
                        .font(.headline)
                    Text(result.item.placemark.title ?? "No address")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    if let d = result.distanceLabel {
                        Text(d)
                            .font(.subheadline)
                    }
                    if let eta = result.etaLabel {
                        Text("~\(eta)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }
}
