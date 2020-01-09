//
//  HistoricDataViewController.swift
//  VibraMonitor
//
//  Created by nguyen nhat minh phuong on 8/14/19.
//  Copyright © 2019 nguyen nhat minh phuong. All rights reserved.
//

import UIKit

class HistoricDataViewController: ViewController{
    var accels = [Accel](){
        didSet{
            DispatchQueue.main.async {
                self.dataTableView.reloadData()
            }
        }
    }
    private var datePicker: UIDatePicker?
    let dateFormatter = DateFormatter()
    var selectedDate:Date = Date()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accels.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = dataTableView.dequeueReusableCell(withIdentifier: "AccelCell") as! DataTableViewCell
        //set round frame
        cell.stateView.layer.cornerRadius = (cell.stateView.frame.width / 2)
        cell.stateView.layer.masksToBounds = true
        
        if let data = accels[indexPath.row].accel{
            cell.dataLabel.text = "Data: " + String(accels[indexPath.row].accel!)
            let dateString = accels[indexPath.row].dateCreated!.prefix(10)
            cell.dateLabel.text = "Created on: " + dateString
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
        }
        return cell
    }
    
    override func viewDidLoad() {
        //delegation declaration
        self.dataTableView.delegate = self
        self.dataTableView.dataSource = self
        self.dataTableView.rowHeight = 85.0
        
        let today = Date()
        // dateFormatter
        self.dateFormatter.dateFormat = "MMM dd, yyyy"
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        
        //Display selected date to the textfield
        datePicker?.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        
        //click inside the textfield, the datepicker will appear
        textFieldDate.inputView = datePicker
        textFieldDate.text = self.dateFormatter.string(from: today)
        
        // catch view-tap event. When you tap the view, the date picker will disappear
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(tapGesture:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc func viewTapped(tapGesture:UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    @objc func dateChanged(datePicker:UIDatePicker){
        selectedDate = datePicker.date
        textFieldDate.text = self.dateFormatter.string(from: datePicker.date)
    }
    @IBOutlet weak var dataTableView: UITableView!
    
    @IBOutlet weak var textFieldDate: UITextField!
    
    //Display data button click action
    @IBAction func displayDataButton(_ sender: UIButton) {
        //Pass the selected date to fetchResultFromRest function. The function return an array of data if fetching process is success.
        fetchResultFromRest(withDate: selectedDate, completionBlock:{[weak self] result  in
            switch result{
            case .failure(let error):
                print (error)
            case .success(let arr):
                self?.accels = arr
            }
        })
    }
}
