//
//  ViewController.swift
//  AES256 Encryption Test
//
//  Created by Turker Kizilcik on 6.08.2023.
//

import UIKit
import Foundation
import CommonCrypto

class ViewController: UIViewController {
    
    
    @IBOutlet weak var textToEncrypt: UITextField!
    @IBOutlet weak var encryptSecretKey: UITextField!
    @IBOutlet weak var textToDecrypt: UITextField!
    @IBOutlet weak var decryptSecretKey: UITextField!
    
    @IBOutlet weak var encryptTextLabel: UILabel!
    @IBOutlet weak var decryptTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("hi")
    }
    
    func aesEncrypt(plainText: String, key: String) -> Data? {
        guard let keyData = key.data(using: .utf8), keyData.count == kCCKeySizeAES128 else {
            return nil
        }
        
        let inputData = plainText.data(using: .utf8)!
        let cryptDataLen = Int(inputData.count + kCCBlockSizeAES128)
        var cryptData = Data(count: cryptDataLen)
        
        let keyLength = size_t(kCCKeySizeAES128)
        
        let options = CCOptions(kCCOptionPKCS7Padding)
        
        var numBytesEncrypted: size_t = 0
        
        let cryptStatus = cryptData.withUnsafeMutableBytes { cryptBytes in
            inputData.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        options,
                        keyBytes.baseAddress, keyLength,
                        nil,
                        dataBytes.baseAddress, inputData.count,
                        cryptBytes.baseAddress, cryptDataLen,
                        &numBytesEncrypted
                    )
                }
            }
        }
        
        if cryptStatus == kCCSuccess {
            cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
            return cryptData
        } else {
            return nil
        }
    }
    
    func aesDecrypt(encryptedData: Data, key: String) -> String? {
        guard let keyData = key.data(using: .utf8), keyData.count == kCCKeySizeAES128 else {
            return nil
        }
        
        let cryptDataLen = Int(encryptedData.count + kCCBlockSizeAES128)
        var cryptData = Data(count: cryptDataLen)
        
        let keyLength = size_t(kCCKeySizeAES128)
        
        let options = CCOptions(kCCOptionPKCS7Padding)
        
        var numBytesDecrypted: size_t = 0
        
        let cryptStatus = cryptData.withUnsafeMutableBytes { cryptBytes in
            encryptedData.withUnsafeBytes { dataBytes in
                keyData.withUnsafeBytes { keyBytes in
                    CCCrypt(
                        CCOperation(kCCDecrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        options,
                        keyBytes.baseAddress, keyLength,
                        nil,
                        dataBytes.baseAddress, encryptedData.count,
                        cryptBytes.baseAddress, cryptDataLen,
                        &numBytesDecrypted
                    )
                }
            }
        }
        
        if cryptStatus == kCCSuccess {
            cryptData.removeSubrange(numBytesDecrypted..<cryptData.count)
            if let decryptedString = String(data: cryptData, encoding: .utf8) {
                return decryptedString
            }
        }
        
        return nil
    }
    
    @IBAction func encryptClicked(_ sender: Any) {
        let textToEncrypt = textToEncrypt.text
        let encryptionKey = encryptSecretKey.text
        
        if let encryptedData = aesEncrypt(plainText: textToEncrypt!, key: encryptionKey!) {
            let encryptedString = encryptedData.base64EncodedString()
            print("Encrypted String: \(encryptedString)")
            encryptTextLabel.text = encryptedString
        } else {
            print("Encryption failed.")
        }
    }
    
    @IBAction func decryptClicked(_ sender: Any) {
        let textToDecrypt = textToDecrypt.text
        let decryptionKey = decryptSecretKey.text

        if let encryptedData = Data(base64Encoded: textToDecrypt!),
           let decryptedString = aesDecrypt(encryptedData: encryptedData, key: decryptionKey!) {
            print("Decrypted String: \(decryptedString)")
            decryptTextLabel.text = decryptedString
        } else {
            print("Decryption failed.")
        }
    }
    
}
        
     
    
