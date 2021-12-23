//
//  ContentView.swift
//  Concurrency_Parallel_API
//
//  Created by Tsuruta, Hiromu | ECID on 2021/12/23.
//

import SwiftUI

struct ContentView: View {

    private let useCase: ParentAPIUseCaseProtocol = ParentAPIUseCase()

    var body: some View {
        Text("API TEST!")
            .padding()
            .task {
                let result = await useCase.fetch()

                debugPrint("main: ", result.main as Any)
                debugPrint("sub: ", result.sub as Any)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
