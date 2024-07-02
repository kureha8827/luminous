//
//  PhotoLibraryFetcher.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/30.
//

import SwiftUI
import Photos

class PhotoLibraryFetcher: ObservableObject {
    @Published var uiImages: [[UIImage]] = []   // ここにフォトライブラリ内の写真が代入される
    @Published var albums: [String] = []    // ここにフォトライブラリ内のアルバムの"名前"が代入される
    @Published var rawAlbums: [PHAssetCollection] = []    // ここにフォトライブラリ内のアルバムが代入される


    func fetchAlbumsName() {
        // 写真アルバムを取得
        let albumsPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)

        albumsPhoto.enumerateObjects { collection, idx, _ in
            self.uiImages.append([])
            // アルバム名を取得
            self.albums.append(collection.localizedTitle ?? "")
            self.rawAlbums.append(collection)
        }
        print("rawAlbums: \(rawAlbums)")
    }


    func fetchPhotos(idx: Int) -> Bool {
        // 写真取得時のオプションの設定
        let fetchOptions = PHFetchOptions()
        //            fetchOptions.fetchLimit = 10    // 取得する画像の上限
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]    // 作成日時でソート
        //            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue) // 画像メディアタイプの写真だけを取得

        let collection = rawAlbums[idx]

        // アルバム内の写真アセットを非同期で取得
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)

        fetchResult.enumerateObjects { asset, _, _ in
            let imageManager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true

            imageManager.requestImage(
                for: asset,
                targetSize: CGSize(width: 300, height: 300),
                contentMode: .aspectFit,
                options: requestOptions
            ) { image, _ in
                if let image = image {
                    DispatchQueue.main.async {
                        self.uiImages[idx].append(image)
                    }
                }
            }
        }
        return true
    }
}
