import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

//prefix(unitlOutputFrom:)用另外一个publisher的输出来控制获取前几个消息，之后再也不发送消息 2023-03-14(Tue) 09:53:34
example(of: "prefix(untilOutputFrom:)") {
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    
    taps
        .prefix(untilOutputFrom: isReady)
        .sink(receiveCompletion: { value in
            print("Complete with: \(value)")
        }, receiveValue: { value in
            print("\(value) is leading number")
        })
        .store(in: &subscriptions)
    
    (1...5).forEach { i in
        taps.send(i)
        if i == 2 {
            isReady.send()
        }
    }
}
/*
 ——— Example of: prefix(untilOutputFrom:) ———
 1 is leading number
 2 is leading number
 Complete with: finished
 */

//prefix(while:)用来获取前几个消息,后面再也不发送消息 2023-03-14(Tue) 09:47:32
example(of: "prefix(while:)") {
    let numbers = (4...12).publisher
    numbers
        .prefix(while: { value in
            print("x", " prefix logic is working on \(value)")
            return value.isMultiple(of: 4)
        })
        .sink { value in
            print(value, " is the leading number")
        }
        .store(in: &subscriptions)
}
/*
 ——— Example of: prefix(while:) ———
 x  prefix logic is working on 4
 x  prefix logic is working on 5
 4  is the leading number
 */

//prefix用来获取前几个消息 2023-03-14(Tue) 09:44:39
example(of: "prefix") {
    let numbersPublisher = (0...9).publisher
    numbersPublisher
        .prefix(2)
        .sink { value in
            print("Leading number: \(value)")
        }
        .store(in: &subscriptions)
}
/*
 ——— Example of: prefix ———
 First of number: 0
 First of number: 1
 */


//drop(unitilOutputFrom:)用其他publisher的输出当做中止丢弃的条件 2023-03-14(Tue) 09:36:19
example(of: "drop(untilOutputFrom:)") {
    let isReady = PassthroughSubject<Void, Never>()
    let taps = PassthroughSubject<Int, Never>()
    
    taps
        .drop(untilOutputFrom: isReady)
        .sink { value in
            print("\(value) is rest of value after tapping")
        }
        .store(in: &subscriptions)
    
    (1...5).forEach { i in
        taps.send(i)
        if i == 2 {
            isReady.send()
        }
    }
}
/*
 ——— Example of: drop(untilOutputFrom:) ———
 3 is rest of value after tapping
 4 is rest of value after tapping
 5 is rest of value after tapping
 */

//drop(while:)用来按条件从头丢弃连续的信息，条件不满足后，就不再丢弃 2023-03-14(Tue) 09:22:11
example(of: "drop(while:)") {
    let numbers = (4...12).publisher
    numbers
        .drop(while: { value in
            print("x", " drop logic is working on \(value)")
            return value.isMultiple(of: 4)
        })
        .sink { value in
            print(value, " is rest of number after drop")
        }
        .store(in: &subscriptions)
}
/*
  ——— Example of: drop(while:) ———
 x  drop logic is working on 4
 x  drop logic is working on 5
 5  is rest of number after drop
 6  is rest of number after drop
 7  is rest of number after drop
 8  is rest of number after drop
 9  is rest of number after drop
 10  is rest of number after drop
 11  is rest of number after drop
 12  is rest of number after drop
 */


//dropFirst可以简单丢弃前几个消息 2023-03-14(Tue) 09:07:46
example(of: "dropFirst") {
    let numbersPublisher = (0...9).publisher
    numbersPublisher
        .dropFirst(7)
        .sink { value in
            print("Rest of number: \(value)")
        }
        .store(in: &subscriptions)
}
/*
 ——— Example of: dropFirst ———
 Rest of number: 7
 Rest of number: 8
 Rest of number: 9

 */

//使用first，last查找队列中的一个消息,注意last需要接收到全部队列的数据 2023-03-13(Mon) 10:08:37 2023-03-16(Thu) 05:43:08
example(of: "first/last(where:)") {
    let numbersPublisher = (1...6).publisher
    numbersPublisher //查询到之后，停止
        .print("First filter Numbers")
        .first { value in
            value % 2 == 0
        }
        .sink { value in
            print("First filter Completed with: \(value)")
        } receiveValue: { value in
            print("First filter Received value: \(value)")
        }
        .store(in: &subscriptions)
    
    numbersPublisher //发送全部信息，再查询
        .print("Last filter Numbers")
        .last { value in
            value % 2 == 0
        }
        .sink { value in
            print("Last filter Completed with: \(value)")
        } receiveValue: { value in
            print("Last filter Received value: \(value)")
        }
        .store(in: &subscriptions)
    
    let manualNumberSender = PassthroughSubject<Int, Never>()
    
    manualNumberSender //发送全部信息，再查询
        .print("Manual last filter Numbers")
        .last { value in
            value % 2 == 0
        }
        .sink { value in
            print("Manual last filter Completed with: \(value)")
        } receiveValue: { value in
            print("Manual last filter Received value: \(value)")
        }
        .store(in: &subscriptions)
    
    manualNumberSender //查询到之后，停止
        .print("Manual first filter Numbers")
        .first { value in
            value % 2 == 0
        }
        .sink { value in
            print("Manual first filter Completed with: \(value)")
        } receiveValue: { value in
            print("Manual first filter Received value: \(value)")
        }
        .store(in: &subscriptions)
    
    manualNumberSender.send(1)
    manualNumberSender.send(2)
    manualNumberSender.send(3)
    manualNumberSender.send(4)
    manualNumberSender.send(5)
    
    manualNumberSender.send(completion: .finished)
}
/*
 ——— Example of: first(where:) ———
 First filter Numbers: receive subscription: (1...6)
 First filter Numbers: request unlimited
 First filter Numbers: receive value: (1)
 First filter Numbers: receive value: (2)
 First filter Numbers: receive cancel
 First filter Received value: 2
 First filter Completed with: finished
 Last filter Numbers: receive subscription: (1...6)
 Last filter Numbers: request unlimited
 Last filter Numbers: receive value: (1)
 Last filter Numbers: receive value: (2)
 Last filter Numbers: receive value: (3)
 Last filter Numbers: receive value: (4)
 Last filter Numbers: receive value: (5)
 Last filter Numbers: receive value: (6)
 Last filter Numbers: receive finished
 Last filter Received value: 6
 Last filter Completed with: finished
 Manual last filter Numbers: receive subscription: (PassthroughSubject)
 Manual last filter Numbers: request unlimited
 Manual first filter Numbers: receive subscription: (PassthroughSubject)
 Manual first filter Numbers: request unlimited
 Manual last filter Numbers: receive value: (1)
 Manual first filter Numbers: receive value: (1)
 Manual last filter Numbers: receive value: (2)
 Manual first filter Numbers: receive value: (2)
 Manual first filter Numbers: receive cancel
 Manual first filter Received value: 2
 Manual first filter Completed with: finished
 Manual last filter Numbers: receive value: (3)
 Manual last filter Numbers: receive value: (4)
 Manual last filter Numbers: receive value: (5)
 Manual last filter Numbers: receive finished
 Manual last filter Received value: 4
 Manual last filter Completed with: finished
 */


//只关注消息结束的时候，使用ignoreOutput，仅处理completion 2023-03-13(Mon) 09:47:17
example(of: "ignoreOutput") {
    let numbersPublisher = (1...10000).publisher
    
    numbersPublisher
        .ignoreOutput()
        .sink { value in
            print("Completed with \(value)")
        } receiveValue: { value in
            print("Received value: \(value)")
        }
        .store(in: &subscriptions)

}
/*
 ——— Example of: ignoreOutput ———
 Completed with finished
 */


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
