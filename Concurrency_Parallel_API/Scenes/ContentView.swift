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
                // no error
                // let result1 = await useCase.fetch()
                let result1 = await useCase.fetchWithTaskGroup()
                debugPrint("main_1: ", result1.main as Any)
                debugPrint("sub_1: ", result1.sub as Any)

                // with error
                do {
                    // let result2 = try await useCase.fetchWithThrows()
                    let result2 = try await useCase.fetchWithThrowsAndTaskGroup()
                    debugPrint("main_2: ", result2.main as Any)
                    debugPrint("sub_2: ", result2.sub as Any)
                } catch {
                    debugPrint("error_2: ", error)
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
