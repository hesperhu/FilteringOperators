import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()


//对消息队列中的optional结果进行统一的unwrap处理 2023-03-13(Mon) 09:38:59
example(of: "compactMap") {
    let stringsPublisher = ["a", "12.3", "899"].publisher
    stringsPublisher
        .compactMap { value in
            Float(value)
        }
        .sink { value in
            print("compactMap filtering result: ", value)
        }
        .store(in: &subscriptions)
    
    stringsPublisher
        .map { value in
            Float(value)
        }
        .filter { value in
            value == nil ? false : true
        }
        .sink { value in
            print("filter and unwrap filtering result: ", value ?? "Non")
        }
        .store(in: &subscriptions)
}
/*
 ——— Example of: compactMap ———
 compactMap filtering result:  12.3
 compactMap filtering result:  899.0
 filter and unwrap filtering result:  12.3
 filter and unwrap filtering result:  899.0
 */

//过滤掉队列中相邻的重复数据 2023-03-08(Wed) 10:20:01
example(of: "RemoveDuplicates") {
    let words = "我 知道 知道 知道 你 不 知道"
        .components(separatedBy: " ")
        .publisher
    
    words
        .removeDuplicates()
        .collect()
        .sink { value in
            print(value)
        }
        .store(in: &subscriptions)
}
/*
 ——— Example of: RemoveDuplicates ———
 ["我", "知道", "你", "不", "知道"]
 */


//可以对数据队列进行过滤，只发送需要的数据 2023-03-08(Wed) 10:05:05
example(of: "filter") {
    let numbers = (1...12).publisher
    numbers
        .filter { value in
            value.isMultiple(of: 4)
        }
        .sink { value in
            print(value, " is a mutiple of 4")
        }
        .store(in: &subscriptions)
}
/*
 
 ——— Example of: filter ———
 4  is a mutiple of 4
 8  is a mutiple of 4
 12  is a mutiple of 4
 */

/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
