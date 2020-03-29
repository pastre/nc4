//
//  StoreManager.swift
//  NC4
//
//  Created by Bruno Pastre on 29/03/20.
//  Copyright © 2020 Bruno Pastre. All rights reserved.
//

import StoreKit

class StoreManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver, SKPaymentQueueDelegate {
    
    enum Product: String, CaseIterable {
        case lifePack
        case removeAds
        
        init(_ product: SKProduct) {
            switch product.productIdentifier {
            case "lifePack":
                self = .lifePack
            default:
                self = .removeAds
            }
        }
        
        func getProduct() -> SKProduct? {
            return StoreManager.instance.products?.filter { $0.productIdentifier == self.rawValue}.first
        }
    }
    
    static let instance = StoreManager()
    private var request:  SKProductsRequest!
    private var products: [SKProduct]?
    
    
     // MARK: - SKProductsRequestDelegate
     func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
         DispatchQueue.main.async {
             self.products = response.products
             print("[IAP] Recvd", response.products.count, "products from appstore")
         }
     }
    // MARK: - SKPaymentTransactionObserver
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for t in transactions {
            if t.transactionState == .purchased {
                
                
                for product in self.products! {
                    if product.productIdentifier == t.payment.productIdentifier {
                        let p = Product(product)
                        switch p {
                        case .lifePack:
                            self.onLifeBought()
                        default:
                            self.onAdsBought()
                        }
                        
                    }
                }
                
                queue.finishTransaction(t)
            }
            
        }
    }
    
    private func onLifeBought() {
        StorageFacade.instance.addRevives(5)
        NotificationCenter.default.post(name: kON_ADS_REMOVED, object: nil)
    }
    
    private func onAdsBought() {
        StorageFacade.instance.setAds(enabled: false)
        NotificationCenter.default.post(name: kON_ADS_REMOVED, object: nil)
    }
    
    override private init() {
        super.init()
        
        self.request = SKProductsRequest(productIdentifiers: [ Product.lifePack.rawValue, Product.removeAds.rawValue ])
        self.request.delegate = self
        
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().delegate = self
    }
    
    func buy(product p: Product) {
        guard let product = p.getProduct() else { return }
        let payment = SKPayment(product: product)
        
        SKPaymentQueue.default().add(payment)
    }
    
    func fire() {
        
        self.request.start()
        print("[IAP] fired!")
    }
 }
