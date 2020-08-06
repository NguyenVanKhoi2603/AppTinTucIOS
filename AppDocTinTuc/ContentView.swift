//
//  ContentView.swift
//  AppDocTinTuc
//
//  Created by Khôi Nguyễn on 8/6/20.
//  Copyright © 2020 ProjectiOs. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI
import WebKit

struct ContentView: View {
    @ObservedObject var list = getData()
    var body: some View {
        NavigationView {
            List(list.datas){ item in
                NavigationLink(destination: webView(url: item.url)
                    .navigationBarTitle("", displayMode: .inline)){
                    
                    HStack(spacing: 15){
                                        VStack(alignment: .leading, spacing: 10){
                                            Text(item.title).fontWeight(.heavy)
                                            Text(item.desc).lineLimit(2)
                                        }
                                        
                                        if item.image != ""{
                                            WebImage(url: URL(string: item.image)!, options: .highPriority, context: nil).resizable().frame(width: 110, height: 135).cornerRadius(20)
                                        }
                                         
                                    }.padding(.vertical, 15)
                }
                
            }.navigationBarTitle("Google news")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct dataType : Identifiable {
    var id: String
    var title: String
    var desc : String
    var url: String
    var image : String
}

class getData: ObservableObject {
    @Published var datas = [dataType]()
    init() {
        let source = "https://newsapi.org/v2/top-headlines?sources=google-news&apiKey=ef315645f7ea4642bd5d33711cd656e9"
        let url = URL(string: source)!
        let sesstion = URLSession(configuration: .default)
        
        sesstion.dataTask(with: url){(data, _, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                return
            }
            let json = try! JSON(data: data!)
            
            for i in json["articles"]{
                let title = i.1["title"].stringValue
                let description = i.1["description"].stringValue
                let url = i.1["url"].stringValue
                let image = i.1["urlToImage"].stringValue
                let id = i.1["publishedAt"].stringValue
                
                DispatchQueue.main.async {
                    self.datas.append(dataType(id: id, title: title, desc: description, url: url, image: image))
                }
                
                
            }
        }.resume()
    }
}

struct webView: UIViewRepresentable {
    var url : String
    func makeUIView(context: UIViewRepresentableContext<webView>) -> webView.UIViewType {
        let view = WKWebView()
        view.load(URLRequest(url: URL(string: url)!))
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<webView>) {
        
    }
}
