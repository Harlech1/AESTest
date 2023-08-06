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

    
    @IBAction func goClicked(_ sender: Any) {
        let plaintext = textToEncrypt.text
        let encryptionKey = encryptSecretKey.text
        
        
        if let encryptedData = aesEncrypt(plainText: plaintext!, key: encryptionKey!) {
            let encryptedString = encryptedData.base64EncodedString()
            print("Encrypted String: \(encryptedString)")
            encryptTextLabel.text = encryptedString
        } else {
            print("Encryption failed.")
        }
        /*
        
         */

    }
    
    @IBAction func decryptClicked(_ sender: Any) {
        let encryptedString = textToDecrypt.text
        let decryptionKey = decryptSecretKey.text

        if let encryptedData = Data(base64Encoded: encryptedString!),
           let decryptedString = aesDecrypt(encryptedData: encryptedData, key: decryptionKey!) {
            print("Decrypted String: \(decryptedString)")
            decryptTextLabel.text = decryptedString
        } else {
            print("Decryption failed.")
        }
    }
    
    
    
}
        
    /*
     enum AESError: Error {
     case keySizeError
     case keyDataError
     }
     
     public struct AES256 {
     private let key: Data
     
     public init?(key: String) throws {
     guard key.count == kCCKeySizeAES256 else {
     throw AESError.keySizeError
     }
     guard let keyData = key.data(using: .utf8) else {
     throw AESError.keyDataError
     }
     self.key = keyData
     }
     
     public func encrypt(messageData: Data?) -> Data? {
     guard let messageData else { return nil}
     return crypt(data: messageData, option: CCOperation(kCCEncrypt))
     }
     
     public func decrypt(encryptedData: Data?) -> Data? {
     return crypt(data: encryptedData, option: CCOperation(kCCDecrypt))
     }
     
     private func crypt(data: Data?, option: CCOperation) -> Data? {
     guard let data = data else { return nil }
     var outputBuffer = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
     var numBytesEncrypted = 0
     let status = CCCrypt(
     option,
     CCAlgorithm(kCCAlgorithmAES),
     CCOptions(kCCOptionPKCS7Padding),
     Array(key),
     kCCKeySizeAES256,
     nil,
     Array(data),
     data.count,
     &outputBuffer, outputBuffer.count, &numBytesEncrypted
     )
     guard status == kCCSuccess else { return nil }
     let outputBytes = outputBuffer.prefix(numBytesEncrypted)
     return Data(outputBytes)
     }
     
     
     } */
     
     
     
     //let encryptedMessage = String(decoding: encryptedData!, as: UTF8.self)
     //var base64encryptedMessage = encryptedMessage.base64Encoding()
     //encryptTextLabel.text = encryptedMessage
     //print(encryptedMessage)
     
     
     /*
     if let decryptedData = try? AES256(key: key!)?.decrypt(encryptedData: encryptedData) {
     let decryptedMessage = String(data: decryptedData, encoding: .utf8)
     if decryptedMessage == message {
     print("Encryption and decryption successful")
     } else {
     print("Encryption and decryption failed")
     }
     }
     }
     
     func decodeBase64String(_ base64String: String) {
     guard let data = Data(base64Encoded: base64String) else {
     print("Invalid Base64 string")
     return
     }
     
     if let decodedString = String(data: data, encoding: .utf8) {
     print("Decoded String: \(decodedString)")
     } else {
     print("Failed to decode the data to a string.")
     }
     }
     
     
     
     //func base64EncodedString(options: NSData.Base64EncodingOptions = []) -> String
     
     
     /* public extension String {
      
      var base64Decoded: String? {
      guard let decodedData = Data(base64Encoded: self) else { return nil }
      return String(data: decodedData, encoding: .utf8)
      }
      
      var base64Encoded: String? {
      let plainData = data(using: .utf8)
      return plainData?.base64EncodedString()
      }
      }
      */
      */
     
    
