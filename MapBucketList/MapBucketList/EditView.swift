//
//  EditView.swift
//  MapBucketList
//
//  Created by Arseniy Matus on 20.04.2022.
//

import SwiftUI

struct EditView: View {
    enum LoadingStage {
        case loading, loaded, failed
    }
    
    @Environment(\.dismiss) var dismiss
    
    var location: Location
    var onSave: (Location) -> Void
    
    @State private var name: String
    @State private var description: String
    @State private var loadingStage = LoadingStage.loading
    
    @State private var pages = [Page]()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name of the location", text: $name)
                    TextField("Description", text: $description)
                }
                Section {
                    switch loadingStage {
                    case .loading:
                        Text("Loading...")
                    case .loaded:
                        ForEach(pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline) +
                            Text(": ") +
                            Text(page.description)
                                .italic()
                        }
                    case .failed:
                        Text("An error occured")
                    }
                } header: {
                    Text("Neaby...")
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save") {
                    var newLocation = location
                    newLocation.id = UUID()
                    newLocation.name = name
                    newLocation.description = description
                    onSave(newLocation)
                    dismiss()
                }
            }
            .task {
                await fetchNearbyPlaces()
            }
        }
    }
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        
        _name = State(initialValue: location.name)
        _description = State(initialValue: location.description)
    }
    
    func fetchNearbyPlaces() async {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        
        guard let url = URL(string: urlString) else {
            loadingStage = .failed
            return
        }
        
        do {
            let (data, _ ) = try await URLSession.shared.data(from: url)
            let results = try JSONDecoder().decode(Result.self, from: data)
            pages = results.query.pages.values.sorted()
            loadingStage = .loaded
        } catch {
            loadingStage = .failed
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(location: Location.example) { _ in }
    }
}
