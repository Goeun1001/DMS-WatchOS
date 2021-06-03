//
//  ContentViewModel.swift
//  DMS-Watch WatchKit Extension
//
//  Created by GoEun Jeong on 2021/06/03.
//

import Foundation

struct Meal: Codable { // 아점저
    var breakfast: [String]
    var lunch: [String]
    var dinner: [String]
}

class ContentViewModel: ObservableObject {
    @Published var date = ""
    @Published var day = ""
    @Published var meal = Meal(breakfast: ["급식이 없습니다."], lunch: ["급식이 없습니다."], dinner: ["급식이 없습니다."])
    private var changeDate = 0
    
    private let dayFormatter = DateFormatter()
    private let dateFormatter = DateFormatter()
    private let modelFormatter = DateFormatter()
    
    init() {
        modelFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.dateFormat = "MM월 dd일"
        dayFormatter.locale = Locale(identifier: "ko_kr")
        dayFormatter.timeZone = TimeZone(abbreviation: "KST")
        dayFormatter.dateFormat = "EEEE"
    }
    
    func viewDidLoad() {
        DispatchQueue.main.async {
            self.date = self.dateFormatter.string(from: Date())
            self.day = self.dayFormatter.string(from: Date())
            self.getMeal(date: self.modelFormatter.string(from: Date()))
        }
    }
    
    func changeDate(left: Bool) {
        DispatchQueue.main.async {
            if left {
                self.changeDate -= 1
                let modifiedDate = Calendar.current.date(byAdding: .day, value: self.changeDate, to: Date())!
                self.date = self.dateFormatter.string(from: modifiedDate)
                self.day = self.dayFormatter.string(from: modifiedDate)
                self.getMeal(date: self.modelFormatter.string(from: modifiedDate))
            } else {
                self.changeDate += 1
                let modifiedDate = Calendar.current.date(byAdding: .day, value: self.changeDate, to: Date())!
                self.date = self.dateFormatter.string(from: modifiedDate)
                self.day = self.dayFormatter.string(from: modifiedDate)
                self.getMeal(date: self.modelFormatter.string(from: modifiedDate))
            }
        }
    }
    
    func getMeal(date: String) {
        guard let url = URL(string: "https://api.dsm-dms.com/meal/" + date) else { return } // 통신할 url
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, res, err in // 연결학고 데이터와 응답, 에러를 받음.
            
            guard self != nil else { return }
            if err != nil {
                self?.meal = Meal(breakfast: ["인터넷 연결이 불안정합니다."], lunch: ["인터넷 연결이 불안정합니다."], dinner: ["인터넷 연결이 불안정합니다."])
                return } // 만약 오류가 있으면 프린트
            print((res as! HTTPURLResponse).statusCode) // 상태코드가 어떻게 되는지 출력
            switch (res as! HTTPURLResponse).statusCode {
            
            case 200: // 서버와 통신이 성공했다면
                guard let data = data else { return }
                let jsonSerialization = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: [String: [String]]]
                let list = jsonSerialization["\(date)"]!
                if list["breakfast"] == nil || list["breakfast"]!.isEmpty || list["breakfast"]!.count == 1 {
                    self?.meal.breakfast = ["급식이 없습니다."]
                } else {
                    self?.meal.breakfast = list["breakfast"]!
                }
                if list["lunch"] == nil || list["lunch"]!.isEmpty || list["lunch"]!.count == 1  {
                    self?.meal.lunch = ["급식이 없습니다."]
                } else {
                    self?.meal.lunch = list["lunch"]!
                }
                if list["dinner"] == nil || list["dinner"]!.isEmpty || list["dinner"]!.count == 1  {
                    self?.meal.dinner = ["급식이 없습니다."]
                } else {
                    self?.meal.dinner = list["dinner"]!
                }
            default:
                self?.meal = Meal(breakfast: ["오류가 났습니다."], lunch: ["오류가 났습니다."], dinner: ["오류가 났습니다."])
            }
        }.resume()
    }
}
