//
//  YampConnectionTest.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/22/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Quick
import Nimble


class TableOfContentsSpec: QuickSpec {
    override func spec() {
        describe("handshake") {
            
            context("succesfull connection"){
            
                it("send handshake echo on handshake received") {
                
                    let h = HandshakeFrame(version: 0x1)
                    var isConnected = false
                    var handshakeSend:HandshakeFrame?
                    let sut = WebSocketConnection(url: "ws://localhost:8888")!
                    
                    sut.onConnect = {
                        isConnected = true
                    }
                    sut.onData = { data in
                        
                        handshakeSend = try! HandshakeFrame(data: data!)
                    }
                    sut.webSocket?.onData?(try! h.toData())
                    
                    expect(isConnected).toEventually(beTrue())
                    expect(handshakeSend!.version).toEventually(equal(UInt16(0x01)))
                }
            }
            
            context("version not supported"){
                
                it("sends close.version_not_supported resp"){
                    
                    let h = HandshakeFrame(version: 0x0)
                    
                    var closeCode:CloseCodeType?
                    let sut = WebSocketConnection(url: "ws://localhost:8888")!
                    
                    sut.onClose = { reason, code in
                        closeCode = code
                    }

                    sut.webSocket?.onData?(try! h.toData())
                    
                    expect(closeCode).toEventually(equal(CloseCodeType.VersionNotSupported))
                    
                }
                
            }
        }
        
        describe("normal operation"){
            
            context("timeout"){
                
                it("send close.timeout", closure: { 
                    
                    var closeCode:CloseCodeType?
                    let sut = WebSocketConnection(url: "ws://localhost:8888")!
                    
                    sut.onClose = { reason, code in
                        closeCode = code
                    }
                    
                    sut.timeout()
                    
                    expect(closeCode).toEventually(equal(CloseCodeType.Timeout))
                    
                })
                
            }
            
        }
        
    }
}
