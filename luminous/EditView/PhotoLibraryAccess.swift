//
//  PhotoLibraryAccess.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/30.
//

import SwiftUI
import Photos

class PhotoLibraryAccess {
    func requestPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
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
