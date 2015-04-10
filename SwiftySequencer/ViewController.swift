//
//  ViewController.swift
//  SwiftySequencer
//
//  Created by Ariel Elkin on 10/04/2015.
//  Copyright (c) 2015 Ariel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

        var controller = AEAudioController(audioDescription: AEAudioController.nonInterleavedFloatStereoAudioDescription())

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

