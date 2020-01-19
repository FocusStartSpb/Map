//
//  MapRoutingLogic.swift
//  Map
//
//  Created by Arkadiy Grigoryanc on 2.01.2020.
//

// MARK: - MapDataPassing protocol
protocol MapDataPassing
{
	var dataStore: MapDataStore? { get set }
}

final class MapRouter
{
	weak var viewController: MapViewController?
	var dataStore: MapDataStore?
}

// MARK: - Map data passing
extension MapRouter: MapDataPassing { }
