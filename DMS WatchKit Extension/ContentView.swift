//
//  ContentView.swift
//  DMS-Watch WatchKit Extension
//
//  Created by GoEun Jeong on 2021/06/03.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Image("leftArrow")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .onTapGesture {
                        viewModel.changeDate(left: true)
                    }
                Text(viewModel.date + " " + viewModel.day)
                Image("rightArrow")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .onTapGesture {
                        viewModel.changeDate(left: false)
                    }
            }
            
            List { // 리스트
                MealRow(title: "아침", menu: viewModel.meal.breakfast.joined(separator:", "))
                MealRow(title: "점심", menu: viewModel.meal.lunch.joined(separator:", "))
                MealRow(title: "저녁", menu: viewModel.meal.dinner.joined(separator:", "))
            }.listStyle(CarouselListStyle()) // 리스트의 스타일을 구경해봅시다!
        }
        .onAppear() { // 이 뷰가 띄워졌을 때
            viewModel.viewDidLoad()
        }
    }
}

struct MealRow: View {
    var title: String
    var menu: String
    var body: some View {
        VStack(alignment: .center) {
            Text(title)
            Text(menu)
        }.multilineTextAlignment(.center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
