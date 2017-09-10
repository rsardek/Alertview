//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

//////////////
////////////////
//////
//////
//////  Window setup
////
//////////
////////////////


let window = UIWindow()
window.frame = CGRect(x: 0, y: 0, width: 300, height: 400)

let context = UIViewController()
window.rootViewController = context
window.makeKeyAndVisible()

PlaygroundPage.current.liveView = window
PlaygroundPage.current.needsIndefiniteExecution = true

//////////////
////////////////
//////
//////
//////  Alert view
////
//////////
////////////////


struct AlertItem {
    
    enum AlertItemType {
        case button(String) // title
        case textField(String) // text
    }
    let type:AlertItemType
    let handler:(String?)->Void
}
struct Alert {
    let title:String
    let message:String
    let items:[AlertItem]
}
struct Starter {
    
    private let parser = Parser()
    
    public func loginScreen(){
        
        var username:String?
        var password:String?
        let myItemText = AlertItem(type: .textField("username")) { output in
            // print("alert-item .textField1. \(output)")
            username = output
        }
        let myItemText2 = AlertItem(type: .textField("password")) { output in
            // print("alert-item .textField2. \(output)")
            password = output
        }
        let myItemButton1 = AlertItem(type: .button("Ok")) { _ in
            // print("alert-item,  .button 1")
            print("login now: [\(username) - \(password)]")
        }
        let myItemButton2 = AlertItem(type: .button("Cancel")) { _ in
            // print("alert-item,  .button 2")
        }
        
        let construct = Alert(title: "Welcome",
                              message: "Please login",
                              items: [myItemText, myItemText2, myItemButton1, myItemButton2])
        
        context.present(parser.evaluate(construct), animated: true, completion: nil)
        
        
    }
}

class Parser:NSObject {
    
    private var textControls = [ UITextField: (String?)->Void ]()
    
    public func evaluate(_ alert:Alert)->UIAlertController{
        
        let controller = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        
        alert.items.map({ item in
            
            switch item.type {
            case .button(let input):
                let action = UIAlertAction(title: input, style: .default, handler: { (action:UIAlertAction) in
                    item.handler(nil)
                })
                controller.addAction(action)
                
            case .textField(let input):
                controller.addTextField { (textField: UITextField!) in
                    textField.placeholder = input
                    textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
                    self.textControls[textField] = item.handler
                    
                }
            }
            
        })
        return controller
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        
        // get the correct handler, and invoke
        if let handler = self.textControls
            .filter({ key, _ in textField == key})
            .map( { _, value in value })
            .first {
            
            handler(textField.text)
        }
    }
    
}

let starter = Starter()
starter.loginScreen()


//////////////
////////////////
//////
//////
//////  Tests
////
//////////
////////////////

import Foundation
import XCTest

class AlertTests: XCTestCase {
    
    private let parser = Parser()
    
    func testInsertedNumberOfTextfields(){
        
        let myItemText = AlertItem(type: .textField("sample")) { _ in  }
        let myItemText2 = AlertItem(type: .textField("sample")) { _ in }
        let alert = Alert(title: "sample", message: "sample", items: [myItemText, myItemText2])
        let alertController = parser.evaluate(alert)
        XCTAssert(alertController.textFields?.count == 2, "Incorrect number of textfields inserted")
    }
    
    func testNumberOfActions(){
        
        let myItemButton1 = AlertItem(type: .button("click me")) { _ in }
        let myItemButton2 = AlertItem(type: .button("click me")) { _ in }
        let alert = Alert(title: "sample", message: "sample", items: [myItemButton1, myItemButton2])
        let alertController = parser.evaluate(alert)
        XCTAssert(alertController.actions.count == 2, "Incorrect number of actions inserted")
    }
    
    func testMessageAndTitle(){
        
        let alert = Alert(title: "sample", message: "sample", items:[])
        let alertController = parser.evaluate(alert)
        XCTAssert(alertController.message == "sample", "Incorrect message inserted")
        XCTAssert(alertController.title == "sample", "Incorrect title inserted")
        
    }
    
    func testInsertedTextEventCorrect(){
        // this can be done through an iOS target
    }
}

AlertTests.defaultTestSuite().run()

