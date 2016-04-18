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
    
    @IBOutlet weak var imageCover: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
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
    
    
    func loadJson(isbn: String)
    {
        let urls = NSURL(string:urlText + isbn)
        let datos = NSData(contentsOfURL: urls!)
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
            let dictionary = json as! NSDictionary
            let isbnDictionary = dictionary["ISBN:"+isbn] as! NSDictionary
            
            let authorsArray = isbnDictionary["authors"] as! NSArray
            let authors = authorsArray[0] as! NSDictionary
            let nombreAutor = authors["name"] as! String
            print("Author: \(authors["name"])")
            
            let title = isbnDictionary["title"] as! String
            print("Title: \(title)")
            
            
            
            if let cover = isbnDictionary["cover"]
            {
                print("Si tiene portada")
                self.textView.text = "Autor: " + nombreAutor + "\n" + "Título: " + title
                
                let coverDictionary = cover as! NSDictionary
                if let urlCover = coverDictionary["large"]
                {
                  loadImageUrl(urlCover as! String)
                }else if let urlCover = coverDictionary["medium"]
                {
                    loadImageUrl(urlCover as! String)
                }else if let urlCover = coverDictionary["small"]
                {
                    loadImageUrl(urlCover as! String)
                }
            }
            else
            {
                self.textView.text = "Autor: " + nombreAutor + "\n" + "Título: " + title + "\n" + "NO TIENE PORTADA"
            }
        }
        catch{}
    }
    func loadImageUrl(urlString: String) {
        let url = NSURL(string:urlString)
        let data = NSData(contentsOfURL:url!)
        if data != nil {
            self.imageCover.image = UIImage(data:data!)
        }
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
//            searchISBN(textField.text!)
            loadJson(textField.text!)
        }
        return true
    }
}


