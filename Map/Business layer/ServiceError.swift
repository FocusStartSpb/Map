//
//  ServiceError.swift
//  Map
//
//  Created by Антон on 17.12.2019.
//

import Foundation

enum ServiceError: Error
{
	case decodingError(Error)
	case noData
	case session(Error)
	case wrongURL
	case noHTTPResponse
	case clientError
	case serverError
}
