//
//  AppDelegate.swift
//  VideoWave
//
//  Created by Mikhail Kurenkov on 14.02.2023.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var window: UIWindow? = { return UIWindow(frame: UIScreen.main.bounds) }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        let presenter = VideoWavePresenter(repository: depsScope.repository, videoPlayer: depsScope.videoPlayer)
//        let viewController = VideoWaveMVPViewController(presenter: presenter)
        
        let viewController = VideoWaveUDFViewController(deps: depsScope)
        
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        return true
    }

    private let depsScope = DepsScope()
}

final class DepsScope: VideoWaveUDFViewControllerDeps {
    
    lazy var videoPlayer: VideoPlayer = VideoPlayerImpl()
    
    lazy var  repository: VideoRepository = VideoRepositoryImpl()
    
}
