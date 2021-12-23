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
    func fetchWithTaskGroup() async -> TotalViewEntity
    func fetchEntity() async -> ViewEntity?
    func fetchSubEntity() async -> SubViewEntity?
    // with throws
    func fetchWithThrows() async throws -> TotalViewEntity
    func fetchWithThrowsAndTaskGroup() async throws -> TotalViewEntity
    func fetchEntityWithThrows() async throws -> ViewEntity
    func fetchSubEntityWithThrows() async throws -> SubViewEntity
}

// MARK: - UseCase
actor ParentAPIUseCase {
    
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
        async let main = fetchEntity()
        async let sub = fetchSubEntity()
        let result = await (main: main, sub: sub)

        let entity = TotalViewEntity()
        entity.main = result.main
        entity.sub = result.sub
        return entity
    }

    func fetchWithTaskGroup() async -> TotalViewEntity {
        await withTaskGroup(of: ViewEntitable?.self,
                            returning: TotalViewEntity.self) { group in

            group.addTask { await self.fetchEntity() }
            group.addTask { await self.fetchSubEntity() }

            let result = TotalViewEntity()
            for await entity in group {
                if let main = entity as? ViewEntity { result.main = main }
                if let sub = entity as? SubViewEntity { result.sub = sub }
            }
            return result
        }
    }

    func _fetchWithTaskGroup() async -> TotalViewEntity {
        let result = TotalViewEntity()

        await withTaskGroup(of: ViewEntitable?.self) { group in
            group.addTask { await self.fetchEntity() }
            group.addTask { await self.fetchSubEntity() }

            for await entity in group {
                if let main = entity as? ViewEntity { result.main = main }
                if let sub = entity as? SubViewEntity {result.sub = sub }
            }
        }
        return result
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
        async let main = fetchEntityWithThrows()
        async let sub = fetchSubEntityWithThrows()
        let result = await (main: try main, sub: try sub)

        let entity = TotalViewEntity()
        entity.main = result.main
        entity.sub = result.sub
        return entity
    }

    func fetchWithThrowsAndTaskGroup() async throws -> TotalViewEntity {
        try await withThrowingTaskGroup(of: ViewEntitable.self,
                                        returning: TotalViewEntity.self) { group in

            group.addTask { try await self.fetchEntityWithThrows() }
            group.addTask { try await self.fetchSubEntityWithThrows() }

            let result = TotalViewEntity()
            for try await entity in group {
                if let main = entity as? ViewEntity { result.main = main }
                if let sub = entity as? SubViewEntity { result.sub = sub }
            }
            return result
        }
    }

    func _fetchWithThrowsAndTaskGroup() async throws -> TotalViewEntity {
        let result = TotalViewEntity()

        try await withThrowingTaskGroup(of: ViewEntitable.self) { group in
            group.addTask { try await self.fetchEntityWithThrows() }
            group.addTask { try await self.fetchSubEntityWithThrows() }

            for try await entity in group {
                if let main = entity as? ViewEntity { result.main = main }
                if let sub = entity as? SubViewEntity { result.sub = sub }
            }
        }
        return result
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
