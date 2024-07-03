//
//  PhotoLibraryFetcher.swift
//  luminous
//
//  Created by kureha8827 on 2024/06/30.
//

import SwiftUI
import Photos

class PhotoLibraryFetcher: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    @Published var uiImages: [[UIImage]] = []   // ここにフォトライブラリ内の写真が代入される
    @Published var albums: [AlbumData] = []    // ここにフォトライブラリ内のアルバムの"名前"が代入される
    @Published var isFirstEditView = true
    @Published var isFirstPhotosPickerView: [Bool] = []

    struct AlbumData: Hashable {
        var rawAlbum: PHAssetCollection
        var name: String
        var quantity: Int
        var thumbnail: UIImage
    }


    override init() {
        super.init()
        // フォトライブラリの変更を監視するためのオブザーバーを登録
        PHPhotoLibrary.shared().register(self)
    }


    deinit {
        // オブザーバーの登録解除
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }


    func fetchAlbumsData() {
        print("fetchAlbumsData")
        // 1. すべての写真
        let allPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)

        if let collection = allPhoto.firstObject {
            var rawAlbum: PHAssetCollection
            var name: String
            var quantity: Int
            var thumbnail: UIImage = UIImage()

            name = collection.localizedTitle ?? ""
            rawAlbum = collection
            quantity = PHAsset.fetchAssets(in: collection, options: nil).count

            // サムネイルの取得
            let fetchOptions = PHFetchOptions()
            fetchOptions.fetchLimit = 1
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            if let asset = fetchResult.firstObject {
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
                            thumbnail = image
                            self.albums.append(AlbumData(rawAlbum: rawAlbum, name: name, quantity: quantity, thumbnail: thumbnail))
                            self.isFirstPhotosPickerView.append(true)
                        }
                    }
                }
            }
        }



        // 2. お気に入り
        let recentlyPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)

        if let collection = recentlyPhoto.firstObject {
            var rawAlbum: PHAssetCollection
            var name: String
            var quantity: Int
            var thumbnail: UIImage = UIImage()

            name = collection.localizedTitle ?? ""
            rawAlbum = collection
            quantity = PHAsset.fetchAssets(in: collection, options: nil).count

            // サムネイルの取得
            let fetchOptions = PHFetchOptions()
            fetchOptions.fetchLimit = 1
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            if let asset = fetchResult.firstObject {
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
                            thumbnail = image
                            self.albums.append(AlbumData(rawAlbum: rawAlbum, name: name, quantity: quantity, thumbnail: thumbnail))
                            self.isFirstPhotosPickerView.append(true)
                        }
                    }
                }
            }
        }



        // 写真アルバムを取得
        let albumsPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: nil)

        albumsPhoto.enumerateObjects { collection, _, _ in
            self.uiImages.append([])

            var rawAlbum: PHAssetCollection
            var name: String
            var quantity: Int
            var thumbnail: UIImage = UIImage()

            name = collection.localizedTitle ?? ""
            rawAlbum = collection
            quantity = PHAsset.fetchAssets(in: collection, options: nil).count

            // サムネイルの取得
            let fetchOptions = PHFetchOptions()
            fetchOptions.fetchLimit = 1
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
            if let asset = fetchResult.firstObject {
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
                            thumbnail = image
                            self.albums.append(AlbumData(rawAlbum: rawAlbum, name: name, quantity: quantity, thumbnail: thumbnail))
                            self.isFirstPhotosPickerView.append(true)
                        }
                    }
                }
            }
        }
    }


    func fetchPhotos(_ idx: Int, _ scrollCount: Int) -> Bool {
        print("fetchPhotos-start")

        // 写真取得時のオプションの設定
        let fetchOptions = PHFetchOptions()

        // 読み込まれ次第300枚ずつ表示
        fetchOptions.fetchLimit = 300 * (scrollCount + 1)    // 取得する画像の上限
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]    // 作成日時でソート
        //            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue) // 画像メディアタイプの写真だけを取得

        let collection = albums[idx].rawAlbum

        // アルバム内の写真アセットを非同期で取得
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)

        fetchResult.enumerateObjects { asset, index, _ in
            if (index >= scrollCount * 300) {
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
        }
        return true
    }


    func fetchOriginalImage(_ address: [Int]) -> UIImage {
        print("fetchOriginalImage")
        // 写真取得時のオプションの設定
        let fetchOptions = PHFetchOptions()

        // 読み込まれ次第300枚ずつ表示
//        fetchOptions.fetchLimit = 300 * (scrollCount + 1)    // 取得する画像の上限
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]    // 作成日時でソート
        //            fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue) // 画像メディアタイプの写真だけを取得

        let collection = albums[address[0]].rawAlbum

        // アルバム内の写真アセットを非同期で取得
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)

        var resultImage: UIImage = UIImage()

        fetchResult.enumerateObjects { asset, index, _ in
            if (index == address[1]) {
                let imageManager = PHImageManager.default()
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                requestOptions.deliveryMode = .highQualityFormat

                imageManager.requestImage(
                    for: asset,
                    targetSize: PHImageManagerMaximumSize,
                    contentMode: .aspectFit,
                    options: requestOptions
                ) { image, _ in
                    if let image = image {
                        resultImage = image
                    }
                }
            }
        }
        return resultImage
    }

    // フォトライブラリの変更を検知したときに呼ばれる
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("photoLibraryDidChange")
        DispatchQueue.main.async {
            self.albums = []
            self.uiImages = []
            self.isFirstEditView = true
            self.isFirstPhotosPickerView = Array(repeating: true, count: self.isFirstPhotosPickerView.count)
        }
    }
}
