//
//  ViewController.swift
//  RippleViewDemo
//
//  Created by Nirzar Gandhi on 30/01/24.
//

import UIKit
import CommonCrypto

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var rippleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rippleView.layer.cornerRadius = rippleView.frame.size.width / 2
        addRipple(rView: rippleView)
        
        // Example usage
        do {
            let aes = try AES(keyString: "84020APRZH66K4728KBT53V4U81CI744")
            
            let stringToEncrypt = "Jignesh"
            print("String to encrypt:\t\t\t\(stringToEncrypt)")
            
            let encryptedData = try aes.encrypt(stringToEncrypt)
            print("String encrypted (base64):\t\(encryptedData.base64EncodedString())")
            
            guard let data = Data(base64Encoded: "d2b51a8582a75edafdf5ecac12fadf0f", options: .ignoreUnknownCharacters) else { return }
            let decryptedData = try aes.decrypt(data)
            print("String decrypted:\t\t\t\(decryptedData)")
            
            
        } catch {
            print("Something went wrong: \(error)")
        }
        
        

        // Usage
        let base64String = "d2b51a8582a75edafdf5ecac12fadf0f"
        let key = "84020APRZH66K4728KBT53V4U81CI744" // 32 characters for AES-256
        let iv = self.convertUInt8ArrayToString([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f]) ?? ""

        if let decryptedString = self.aesDecrypt(base64String: base64String, key: key, iv: iv) {
            print("Decrypted string: \(decryptedString)")
        } else {
            print("Failed to decrypt")
        }
    }
    
    func convertUInt8ArrayToString(_ byteArray: [UInt8]) -> String? {
        // Convert [UInt8] to Data
        let data = Data(byteArray)
        
        // Convert Data to String
        return String(data: data, encoding: .utf8)
    }
    
    func aesDecrypt(base64String: String, key: String, iv: String) -> String? {
        // Decode the Base64 string
        guard let encryptedData = Data(base64Encoded: base64String) else {
            print("Invalid Base64 string")
            return nil
        }
        
        // Convert key and IV to Data
        guard let keyData = key.data(using: .utf8), let ivData = iv.data(using: .utf8) else {
            print("Invalid key or IV")
            return nil
        }
        
        // Prepare output buffer
        let bufferSize = encryptedData.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        
        var numBytesDecrypted = 0
        
        // Perform decryption
        let cryptStatus = encryptedData.withUnsafeBytes { encryptedBytes in
            buffer.withUnsafeMutableBytes { bufferBytes in
                keyData.withUnsafeBytes { keyBytes in
                    ivData.withUnsafeBytes { ivBytes in
                        CCCrypt(
                            CCOperation(kCCDecrypt),
                            CCAlgorithm(kCCAlgorithmAES),
                            CCOptions(kCCOptionPKCS7Padding),
                            keyBytes.baseAddress,
                            kCCKeySizeAES256,
                            ivBytes.baseAddress,
                            encryptedBytes.baseAddress,
                            encryptedData.count,
                            bufferBytes.baseAddress,
                            bufferSize,
                            &numBytesDecrypted
                        )
                    }
                }
            }
        }
        
        // Check result
        if cryptStatus == kCCSuccess {
            buffer.count = numBytesDecrypted
            return String(data: buffer, encoding: .utf8)
        } else {
            print("Decryption failed with status: \(cryptStatus)")
            return nil
        }
    }
}

// MARK: - Call Back
extension ViewController {
    
    func addRipple(rView: UIView) {
        
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: rView.bounds.size.width, height: rView.bounds.size.height))
        
        let shapePosition = CGPoint(x: rView.bounds.size.width / 2.0, y: rView.bounds.size.height / 2.0)
        let rippleShape = CAShapeLayer()
        rippleShape.bounds = CGRect(x: 0, y: 0, width: rView.bounds.size.width, height: rView.bounds.size.height)
        rippleShape.path = path.cgPath
        rippleShape.fillColor = UIColor.clear.cgColor
        rippleShape.strokeColor = UIColor(red: 86.0/255.0, green: 198.0/255.0, blue: 98.0/255.0, alpha: 1.0).cgColor
        rippleShape.lineWidth = 1
        rippleShape.position = shapePosition
        rippleShape.opacity = 0
        
        rView.layer.addSublayer(rippleShape)
        
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        scaleAnim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(2, 2, 1))
        
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1
        opacityAnim.toValue = nil
        
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnim, opacityAnim]
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.duration = 1
        animation.repeatCount = Float.infinity
        animation.isRemovedOnCompletion = false
        rippleShape.add(animation, forKey: "rippleEffect")
    }
}

protocol Cryptable {
    
    func encrypt(_ string: String) throws -> Data
    func decrypt(_ data: Data) throws -> String
}

struct AES {
    private let key: Data
    private let iv: [UInt16] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f]
    private let options: CCOptions = CCOptions(kCCOptionPKCS7Padding)
    
    init(keyString: String) throws {
        guard keyString.count == kCCKeySizeAES256 else {
            throw Error.invalidKeySize
        }
        self.key = Data(keyString.utf8)
    }
}

extension AES {
    
    enum Error: Swift.Error {
        
        case invalidKeySize
        case encryptionFailed
        case decryptionFailed
        case dataToStringFailed
    }
}

extension AES: Cryptable {
    
    func encrypt(_ string: String) throws -> Data {
        
        let dataToEncrypt = Data(string.utf8)
        let bufferSize = dataToEncrypt.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        var numberBytesEncrypted = 0
        
        try self.key.withUnsafeBytes { keyBytes in
            try dataToEncrypt.withUnsafeBytes { dataToEncryptBytes in
                try buffer.withUnsafeMutableBytes { bufferBytes in
                    
                    guard let keyBytesBaseAddress = keyBytes.baseAddress,
                          let dataToEncryptBytesBaseAddress = dataToEncryptBytes.baseAddress,
                          let bufferBytesBaseAddress = bufferBytes.baseAddress else {
                        throw Error.encryptionFailed
                    }
                    
                    let cryptStatus = CCCrypt(
                        CCOperation(kCCEncrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        self.options,
                        keyBytesBaseAddress,
                        self.key.count,
                        self.iv,
                        dataToEncryptBytesBaseAddress,
                        dataToEncryptBytes.count,
                        bufferBytesBaseAddress,
                        bufferSize,
                        &numberBytesEncrypted
                    )
                    
                    guard cryptStatus == CCCryptorStatus(kCCSuccess) else {
                        throw Error.encryptionFailed
                    }
                }
            }
        }
        
        return buffer[..<numberBytesEncrypted]
    }
    
    func decrypt(_ data: Data) throws -> String {
        
        let bufferSize = data.count
        var buffer = Data(count: bufferSize)
        var numberBytesDecrypted = 0
        
        try self.key.withUnsafeBytes { keyBytes in
            try data.withUnsafeBytes { dataToDecryptBytes in
                try buffer.withUnsafeMutableBytes { bufferBytes in
                    
                    guard let keyBytesBaseAddress = keyBytes.baseAddress,
                          let dataToDecryptBytesBaseAddress = dataToDecryptBytes.baseAddress,
                          let bufferBytesBaseAddress = bufferBytes.baseAddress else {
                        throw Error.decryptionFailed
                    }
                    
                    let cryptStatus = CCCrypt(
                        CCOperation(kCCDecrypt),
                        CCAlgorithm(kCCAlgorithmAES),
                        self.options,
                        keyBytesBaseAddress,
                        self.key.count,
                        self.iv,
                        dataToDecryptBytesBaseAddress,
                        data.count,
                        bufferBytesBaseAddress,
                        bufferSize,
                        &numberBytesDecrypted
                    )
                    
                    guard cryptStatus == CCCryptorStatus(kCCSuccess) else {
                        throw Error.decryptionFailed
                    }
                }
            }
        }
        
        let decryptedData = buffer[..<numberBytesDecrypted]
        guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
            throw Error.dataToStringFailed
        }
        
        return decryptedString
    }
}
