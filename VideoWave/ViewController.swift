//
//  ViewController.swift
//  VideoWave
//
//  Created by Mikhail Kurenkov on 14.02.2023.
//

import UIKit



class VideoWaveViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    let tableView = UITableView()

}

extension VideoWaveViewController: UITableViewDataSource {
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
}

extension VideoWaveViewController: UITableViewDelegate {
    
}

