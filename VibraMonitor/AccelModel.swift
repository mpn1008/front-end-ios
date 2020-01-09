//
//  AccelModel.swift
//  VibraMonitor
//
//  Created by nguyen nhat minh phuong on 8/14/19.
//  Copyright © 2019 nguyen nhat minh phuong. All rights reserved.
//

import Foundation
import SocketIO

struct Accel: Decodable,Encodable{
    var accel: Float?
    var _id:String?
    var dateCreated:String?
}

struct rtAccel:Decodable{
    var accel: Float?
}

func fetchResultFromRest(withDate date:Date ,completionBlock: @escaping (Result<[Accel], Error>) -> Void) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let urlString = "https://mp-accel.herokuapp.com/api/sensordatas"
    guard let Url = URL(string:urlString) else {return}
    let task = URLSession.shared.dataTask(with: Url) { (data, response
        , error) in
        guard let data = data else { return }
        do {
            var selectedData = [Accel]()
            let decoder = JSONDecoder()
            let gitData = try decoder.decode([Accel].self, from: data)
            for i in gitData{
                let dateString = i.dateCreated!.prefix(10)
                let inputDateString = dateFormatter.string(from: date)
                if dateString == inputDateString{
                    selectedData.append(i)
                }
            }
            completionBlock(.success(selectedData))
        } catch let err {
            print("Err \(err)")
            completionBlock(.failure(err))
        }
    }
    task.resume()
}

func fetchAPI(with url:String, completionBlock: @escaping ([Accel]) -> Void){
    let Url = URL(string:url)
    let task = URLSession.shared.dataTask(with: Url!){ data,response,error in
        guard let data = data else {return}
        do{
            let decoder = JSONDecoder()
            let gitdata = try decoder.decode([Accel].self, from: data)
            completionBlock(gitdata)
        } catch let err{
            print(err)
            completionBlock([])
        }
    }
    task.resume()
}

func postRequest(withURL urlString:String , dataValue:Float){
    let url = URL(string: urlString)
    var request = URLRequest(url: url!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    var object = Accel()
    object.accel = dataValue
    guard let uploadData = try? JSONEncoder().encode(object) else {
        return
    }
    let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
        if let error = error {
            print ("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse,
            (200...299).contains(response.statusCode) else {
                print ("server error")
                return
        }
        print(response.statusCode)
        if let mimeType = response.mimeType,
            mimeType == "application/json",
            let data = data,
            let dataString = String(data: data, encoding: .utf8) {
            print ("got data: \(dataString)")
        }
    }
    task.resume()
}

func getRealtimeData(withSocket socket:SocketIOClient, completionBlock: @escaping ( Result<[rtAccel], Error>) -> Void) {
    socket.on("datareceive") {data, ack  in
        do{
            print(data)
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let decoder = JSONDecoder()
            let gitData = try decoder.decode([rtAccel].self, from:jsonData)
            completionBlock(.success(gitData))
        } catch let err{
            print("JSONSerialization error:", err)
            completionBlock(.failure(err))
        }
        socket.emit("response","iOS response to server: received data")
    }
    socket.connect()
}
// new commit 
