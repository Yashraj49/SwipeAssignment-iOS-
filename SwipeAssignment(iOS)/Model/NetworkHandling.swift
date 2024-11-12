//
//  NetworkHandling.swift
//  SwipeAssignment(iOS)
//
//  Created by Yashraj Jadhav on 10/11/24.
//

import Foundation

enum NetworkHandling : Error,LocalizedError {
    case invalidURL
    case invalidResponse // error from server
    case invalidData
    case unknownError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid Response"
        case .invalidData:
            return "Invalid Data"
        case .unknownError(let error):
            return error.localizedDescription
        }
    }
}
