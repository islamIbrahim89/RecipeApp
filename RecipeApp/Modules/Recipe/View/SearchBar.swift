//
//  SearchBar.swift
//  RecipeApp
//
//  Created by islam moussa on 03/02/2025.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        ZStack {
            TextField("Search Recipes...", text: $text)
                .accessibilityIdentifier("Search")
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
                .overlay {
                    if !text.isEmpty {
                        HStack {
                            Spacer()
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 10)
                            }
                        }.padding()
                    }
                }
        }
    }
}
