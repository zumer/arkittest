//
//  SCNReferenceNode.swift
//  BallSpinningAroundHead
//
//  Created by Evgeny on 5/15/20.
//  Copyright © 2020 Evgeny. All rights reserved.
//

import UIKit
import SceneKit

extension SCNReferenceNode {
    convenience init(named resourceName: String, loadImmediately: Bool = true) {
        let url = Bundle.main.url(forResource: resourceName, withExtension: "scn", subdirectory: "art.scnassets")!
        self.init(url: url)!
        if loadImmediately {
            self.load()
        }
    }
}
