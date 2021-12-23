//
//  ParentAPIUseCase.swift
//  Combine_Parallel_API
//
//  Created by Tsuruta, Hiromu | ECID on 2021/06/09.
//

import Foundation

// MARK: - Protocol
protocol ParentAPIUseCaseProtocol {
    // without throws
    func fetch() async -> TotalViewEntity
    func fetchEntity() async -> ViewEntity?
    func fetchSubEntity() async -> SubViewEntity?
    // with throws
    func fetchWithThrows() async throws -> TotalViewEntity
    func fetchEntityWithThrows() async throws -> ViewEntity
    func fetchSubEntityWithThrows() async throws -> SubViewEntity
}

// MARK: - UseCase
final class ParentAPIUseCase {
    
    // MARK: Property

    private let client: APIUseCaseProtocol
    private let subClient: SubAPIUseCaseProtocol
    
    // MARK: Initializer
    
    init(client: APIUseCaseProtocol = APIUseCase(),
         subClient: SubAPIUseCaseProtocol = SubAPIUseCase()) {
        
        self.client = client
        self.subClient = subClient
    }
}

// MARK: - ParentAPIUseCaseProtocol
extension ParentAPIUseCase: ParentAPIUseCaseProtocol {

    // MARK: without throws

    func fetch() async -> TotalViewEntity {
        let entity = TotalViewEntity()
        entity.main = await fetchEntity()
        entity.sub = await fetchSubEntity()
        return entity
    }

    func fetchEntity() async -> ViewEntity? {
        await withCheckedContinuation { [weak self] continuation in
            self?.client.fetch() { result in
                switch result {
                case .success(let entity): continuation.resume(returning: entity)
                case .failure(_): continuation.resume(returning: nil)
                }
            }
        }
    }

    func fetchSubEntity() async -> SubViewEntity? {
        await withCheckedContinuation { [weak self] continuation in
            self?.subClient.fetch() { result in
                switch result {
                case .success(let entity): continuation.resume(returning: entity)
                case .failure(_): continuation.resume(returning: nil)
                }
            }
        }
    }

    // MARK: with throws

    func fetchWithThrows() async throws -> TotalViewEntity {
        let entity = TotalViewEntity()
        entity.main = try await fetchEntityWithThrows()
        entity.sub = try await fetchSubEntityWithThrows()
        return entity
    }

    func fetchEntityWithThrows() async throws -> ViewEntity {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.client.fetch(completion: continuation.resume(with:))
        }
    }

    func fetchSubEntityWithThrows() async throws -> SubViewEntity {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.subClient.fetch(completion: continuation.resume(with:))
        }
    }
}
