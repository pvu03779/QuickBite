import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            ShoppingListView()
                .tabItem {
                    Label("Shopping", systemImage: "cart")
                }
            FavoritesView()
                .tabItem {
                    Label("Saved", systemImage: "heart")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
