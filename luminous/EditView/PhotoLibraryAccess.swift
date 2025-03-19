//
//  PhotoLibraryAccess.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/30.
//

import SwiftUI
import Photos

final class PhotoLibraryAccess: @unchecked Sendable {
    func requestPermission(completion: @escaping @Sendable (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                Task { @MainActor in
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        case .restricted, .denied:
            completion(false)
        case .authorized, .limited:
            completion(true)
        @unknown default:
            completion(false)
        }
    }
}
