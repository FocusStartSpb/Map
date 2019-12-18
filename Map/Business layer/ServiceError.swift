//
//  ServiceError.swift
//  Map
//
//  Created by Антон on 18.12.2019.
//

import Foundation
enum ServiceError: Error
{
	case noData
	case decoding(Error)
	case session(Error)
	case wrongURL
	case noHTTPResponse
	case clientError
	case serverError
}
