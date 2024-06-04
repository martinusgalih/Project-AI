//
//  ContentView.swift
//  Project AI
//
//  Created by Martinus Galih Widananto on 04/06/24.
//

import SwiftUI

struct Item: Identifiable {
    var id = UUID()
    var name: String
    var index: Int
}

struct ContentView: View {
    let items = [
        Item(name: "Stable Diffusion", index: 0),
        Item(name: "3D Prediction", index: 1)
    ]
    
    var body: some View {
        NavigationView {
            List(items) { item in
                switch item.index {
                    case 0:
                        NavigationLink(destination: ImagePredictionController()) {
                            Text(item.name)
                        }
                    case 1:
                        NavigationLink(destination: ThreeDimensionController()) {
                            Text(item.name)
                        }
                    default:
                        EmptyView()
                }
            }
            .navigationTitle("AI Feature")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
