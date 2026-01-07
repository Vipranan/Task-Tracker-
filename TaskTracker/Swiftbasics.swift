//
//  Swiftbasics.swift
//  TaskTracker
//
//  Created by Vipranan on 06/01/26.
//

import Playgrounds
#Playground {
    // basic data types of swift ui
    let age: Int = 25 // integer
    let isStudent: Bool = false // boolean
    let name: String = "Vipranan" // string
    let price: Double = 100.00 // high precision decimal
    let discount: Float = 0.10 // float values
    var fruits: [String] = ["Apple", "Orange", "Banana"] // arrays or list -- hold mockup values
    fruits.append("Pineapple") // adding elements in array or list
    //dictionary
    let user: [String: String] = [
        "name": "vipranan",
        "role": "developer"
        
    ]
    // creating function
    func greet() {
        print("hello world!")
        
    }
    
    greet()
    
    func calculatingTotal(price: Double, quantity: Int) -> Double {
        return price * Double(quantity)
    }
    
    let total = calculatingTotal(price: 9.99, quantity: 5)
    print("Total: \(total)")
}
