import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var searchText = ""
    @State private var results = [MKMapItem]()
    @State private var mapSelection: MKMapItem?
    @State private var showDetails = false
    @State private var getDirections = false
    @State private var routeDisplaying = false
    @State private var route: MKRoute?
    @State private var routeDestination: MKMapItem?
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        Map( position: $cameraPosition, selection: $mapSelection) {
            UserAnnotation() {
                ZStack {
                    Circle()
                        .frame(width: 32, height: 32)
                        .foregroundStyle(.blue.opacity(0.25))
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.white)
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(.blue)
                }
            }
            
            ForEach(results, id: \.self) { item in
                if !routeDisplaying || item == routeDestination {
                    let placemark = item.placemark
                    Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                }
            }
            
            if let route {
                MapPolyline(route.polyline)
                    .stroke(.blue, lineWidth: 6)
            }
        }
        .overlay(alignment: .bottom) {
            TextField("Search for a destination...", text: $searchText)
                .font(.subheadline)
                .padding(12)
                .background(Color.white)
                .padding()
                .shadow(radius: 10)
        }
        .onAppear{
            viewModel.checkIfLocationServiceIsEnabled()
        }
        .onSubmit(of: .text) {
            Task {
                await searchPlaces()
            }
        }
        .onChange(of: getDirections) { oldValue, newValue in
            if newValue {
                fetchRoute()
            }
        }
        .onChange(of: mapSelection) { oldValue, newValue in
            showDetails = newValue != nil
        }
        .sheet(isPresented: $showDetails) {
            LocationDetailView(
                mapSelection: $mapSelection,
                show: $showDetails,
                getDirection: $getDirections
            )
            .presentationDetents([.height(340)])
            .presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
            .presentationCornerRadius(12)
        }
        .mapControls {
            MapCompass()
            MapPitchToggle()
            MapUserLocationButton()
        }
    }
}
     
extension ContentView {
    func searchPlaces() async {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = viewModel.region
        
        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            self.results = response.mapItems
            
            // Reset the navigation state when a new search is performed
            self.routeDisplaying = false
            self.route = nil
            self.routeDestination = nil
            self.mapSelection = nil
            self.getDirections = false  // Added to reset getDirections
            
        } catch {
            print("Error searching for places: \(error.localizedDescription)")
        }
    }
    
    func fetchRoute() {
        if let mapSelection {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: .init(coordinate: viewModel.region.center))
            request.destination = mapSelection
            
            Task {
                do {
                    let result = try await MKDirections(request: request).calculate()
                    route = result.routes.first
                    routeDestination = mapSelection
                    
                    withAnimation(.snappy) {
                        routeDisplaying = true
                        showDetails = false
                        
                        if let rect = route?.polyline.boundingMapRect, routeDisplaying {
                            cameraPosition = .rect(rect)
                        }
                    }
                } catch {
                    print("Error fetching route: \(error.localizedDescription)")
                }
            }
        }
    }
}
     
extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude: 25.02452355830736, longitude: 121.29619785782673)
    }
}
     
extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(
            center: .userLocation,
            latitudinalMeters: 10000,
            longitudinalMeters: 10000
        )
    }
}

   
    
    #Preview {
        ContentView()
    }

