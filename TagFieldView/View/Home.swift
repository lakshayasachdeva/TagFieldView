//
//  Home.swift
//  TagFieldView
//
//  Created by Lakshaya Sachdeva on 13/10/23.
//

import SwiftUI

struct Home: View {
    @State private var tags: [Tag] = []
    var body: some View {
        NavigationStack{
            ScrollView(.vertical) {
                VStack {
                    TagField(tags: $tags)
                }
                .padding()
            }
            .navigationTitle("Tag View")
        }
    }
}

#Preview {
    Home()
}
