//
//  Repository.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 17.12.2019.
//

// MARK: - ISmartTargetRepository protocol
protocol ISmartTargetRepository
{
	associatedtype Element
	typealias ElementResult = (Result<Element, ServiceError>) -> Void

	func loadSmartTargetCollection(_ completion: @escaping ElementResult)

	func saveSmartTargetCollection(_ collection: Element,
								   _ completion: @escaping ElementResult)
}

// MARK: - Class
final class SmartTargetRepository<Element: Codable>
{

	// MARK: ...Private properties
	private var dataBaseService: DataBaseService<Element>

	// MARK: ...Initialization
	init(dataBaseService: DataBaseService<Element>) {
		self.dataBaseService = dataBaseService
	}
}

// MARK: - ISmartTargetRepository
extension SmartTargetRepository: ISmartTargetRepository
{
	func loadSmartTargetCollection(
		_ completion: @escaping (Result<Element, ServiceError>) -> Void) {
		do {
			let smartTargetCollection = try dataBaseService.read()
			completion(.success(smartTargetCollection))
		}
		catch let error as ServiceError {
			completion(.failure(error))
		}
		catch let error as FilesManager.Error {
			switch error {
			case .fileNotExists:
				completion(.failure(.fileNotExists))
			default:
				completion(.failure(.canNotLoadSmartTarget(message: error.localizedDescription)))
			}
		}
		catch {
			completion(.failure(.canNotLoadSmartTarget(message: error.localizedDescription)))
		}
	}

	func saveSmartTargetCollection(_ collection: Element,
								   _ completion: @escaping (Result<Element, ServiceError>) -> Void) {
		do {
			try dataBaseService.write(collection)
			completion(.success(collection))
		}
		catch let error as ServiceError {
			completion(.failure(error))
		}
		catch {
			completion(.failure(.canNotLoadSmartTarget(message: error.localizedDescription)))
		}
	}
}
