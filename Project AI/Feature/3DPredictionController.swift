//
//  3DPredictionController.swift
//  Project AI
//
//  Created by Martinus Galih Widananto on 04/06/24.
//

import SwiftUI
import Replicate
import SDWebImageSwiftUI

private let client = Replicate.Client(token: "yourToken")

enum ThreeDimensionPrediction: Predictable {
    static var modelID = "cjwbw/shap-e"
    static let versionID = "5957069d5c509126a73c7cb68abcddbb985aeefa4d318e7c63ec1352ce6da68c"
    
    struct Input: Codable {
        let prompt: String
    }
    
    typealias Output = [URL]
}

struct ThreeDimensionController: View {
    @State private var prompt = ""
    @State private var prediction: ThreeDimensionPrediction.Prediction? = nil
    
    func generate() async throws {
        prediction = try await ThreeDimensionPrediction.predict(with: client,
                                                       input: .init(prompt: prompt))
        try await prediction?.wait(with: client)
    }
    
    func cancel() async throws {
        try await prediction?.cancel(with: client)
    }
    
    var body: some View {
        Form {
            Section {
                TextField(text: $prompt,
                          prompt: Text("Enter a prompt to display 3d image"),
                          axis: .vertical,
                          label: {})
                .disabled(prediction?.status.terminated == false)
                .submitLabel(.go)
                .onSubmit(of: .text) {
                    Task {
                        try await generate()
                    }
                }
            }
            if let prediction {
                ZStack {
                    Color.clear
                        .aspectRatio(1.0, contentMode: .fit)
                    
                    switch prediction.status {
                        case .starting, .processing:
                            VStack{
                                ProgressView("Generating...")
                                    .padding(32)
                                
                                Button("Cancel") {
                                    Task { try await cancel() }
                                }
                            }
                        case .succeeded:
                            if let url = prediction.output?.first {
                                VStack {
                                    WebImage(url: url)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(32)
                                        .frame(width: 300, height: 300)
                                    
                                    ShareLink("Export", item: url)
                                        .padding(32)
                                }
                            }
                        case .failed:
                            Text(prediction.error?.localizedDescription ?? "Unknown error")
                                .foregroundColor(.red)
                        case .canceled:
                            Text("The prediction was canceled")
                                .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding()
                .listRowBackground(Color.clear)
                .listRowInsets(.init())
            }
        }
    }
}
