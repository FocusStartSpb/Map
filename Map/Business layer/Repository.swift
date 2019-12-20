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
	func loadSmartTargetCollection(
		_ completion: @escaping SmartTargetsResultCompletion)

	func saveSmartTargetCollection(_ collection: Element,
								   _ completion: @escaping SmartTargetsResultCompletion)
}

// MARK: - Class
final class SmartTargetRepository
{

	// MARK: ...Private properties
	private var decoderService: IDecoderService
	private var dataBaseService: DataBaseService<Element>

	// MARK: ...Initialization
	init(decoderService: IDecoderService, dataBaseService: DataBaseService<Element>) {
		self.decoderService = decoderService
		self.dataBaseService = dataBaseService
	}
}

// MARK: - ISmartTargetRepository
extension SmartTargetRepository: ISmartTargetRepository
{

	func loadSmartTargetCollection(
		_ completion: @escaping SmartTargetsResultCompletion) {
		do {
			let smartTargetCollection = try dataBaseService.read()
			completion(.success(smartTargetCollection))
		}
		catch let error as ServiceError {
			completion(.failure(error))
		}
		catch {
			completion(.failure(.canNotLoadSmartTarget(message: error.localizedDescription)))
		}
	}

	func saveSmartTargetCollection(_ collection: SmartTargetCollection,
								   _ completion: @escaping SmartTargetsResultCompletion) {
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
