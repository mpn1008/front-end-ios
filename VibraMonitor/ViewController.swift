//
//  ViewController.swift
//  VibraMonitor
//
//  Created by nguyen nhat minh phuong on 8/6/19.
//  Copyright © 2019 nguyen nhat minh phuong. All rights reserved.
//

import UIKit
import SocketIO

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    let manager = SocketManager(socketURL: URL(string: "http://10.23.252.116:3000")!, config: [.log(true), .compress])
    var displayArray = [rtAccel](){
        didSet{
            DispatchQueue.main.async {
                self.rtDataTableView.reloadData()
            }
        }
    }
    var dataArray = [rtAccel](){
        didSet{
            self.displayArray.append(self.dataArray[0])
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rtDataTableView.delegate = self
        self.rtDataTableView.dataSource = self
        let socket = manager.defaultSocket
        getRealtimeData(withSocket: socket, completionBlock:{[weak self] result  in
            switch result{
            case .failure(let error):
                print (error)
            case .success(let arr):
                self?.dataArray = arr
            }
        })
        let str = "https://mp-accel.herokuapp.com/api/sensordatas"
     //   postRequest(withURL: str, dataValue: 999.321)
        fetchAPI(with: str, completionBlock: { result in
            for i in 1...10{
              print(result[i])
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = rtDataTableView.dequeueReusableCell(withIdentifier: "DataCell") as! RealtimeDataTableViewCell
        let data = displayArray[indexPath.row].accel!
        cell.dataLabel.text = "Data: " + String(displayArray[indexPath.row].accel!)
        if (data < 4 && data > -4){
            cell.stateLabel.text = "State: Very Good"
            cell.stateView.backgroundColor = UIColor.green
        } else if(data < 11 && data > -11){
            cell.stateLabel.text = "State: Normal"
            cell.stateView.backgroundColor = UIColor.yellow
        } else{
            cell.stateLabel.text = "State: Bad"
            cell.stateView.backgroundColor = UIColor.red
        }
        return cell
    }
    
    @IBOutlet weak var rtDataTableView: UITableView!
    
    // To clear the table view
    @IBAction func clearButton(_ sender: UIButton) {
        self.displayArray = []
    }
    
    // To navigate to the another view (HistoricDataViewController)
    @IBAction func hDataButton(_ sender: UIButton) {
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "HistoricDataViewController") as! HistoricDataViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}




