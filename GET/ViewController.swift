//
//  ViewController.swift
//  GET
//
//  Created by Juan Sebastián Landy Ríos on 21/3/16.
//  Copyright © 2016 eureka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var txtISBN: UITextField!
    @IBOutlet weak var textView: UITextView!
    let urlText = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    //MARK: Search ISBN
    func searchISBN(isbn: String)
    {
        let request = NSMutableURLRequest(URL: NSURL(string: urlText+isbn)!)
        
        httpGet(request){
            (data, error) -> Void in
            if error != nil {
                print(error)
                dispatch_async(dispatch_get_main_queue(),{
                    
                    let errorString = error! as String
                    let alertMessage = UIAlertController(title: "Error", message: errorString, preferredStyle: .Alert)
                    alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertMessage, animated: true, completion: nil)
                })
                
                
                
                
            } else {
                print(data)
                dispatch_async(dispatch_get_main_queue(),{
                    self.textView.text = ""
                   self.textView.text = data as String
                    
                })
                
            }
        }
        
    }
    
    func httpGet(request: NSURLRequest!, callback: (String, String?) -> Void) {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){
            (data, response, error) -> Void in
            if error != nil {
                callback("", error!.localizedDescription)
            } else {
                let result = NSString(data: data!, encoding:
                    NSASCIIStringEncoding)!
                callback(result as String, nil)
            }
        }
        task.resume()
    }
    
    
    
    
}
//MARK: UITextField Delegate
extension ViewController:UITextFieldDelegate
{
     func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        if textField.hasText()
        {
            self.textView.text = "cargando..."
            searchISBN(textField.text!)
        }
        return true
    }
}

