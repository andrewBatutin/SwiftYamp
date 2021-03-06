//
//  YampConnectionTest.swift
//  SwiftYamp
//
//  Created by Andrey Batutin on 6/22/17.
//  Copyright © 2017 Andrey Batutin. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftYamp

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
                    sut.onDataReceived = { data in
                        
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
            
            context("outgoing redirect"){
            
                it("should redirect to new url if redirect callback is implemented"){
                    let h = HandshakeFrame(version: 0x1)
                    var closeCode:CloseCodeType?
                    var closeFrame:CloseFrame?
                    let sut = WebSocketConnection(url: "ws://localhost:8888")!
                    
                    sut.onRedirect = {
                        return "new_url"
                    }
                    
                    sut.onDataSend = { data in
                        closeFrame = try! CloseFrame(data: data!)
                    }
                    
                    sut.onClose = { reason, code in
                        closeCode = code
                    }
                    
                    sut.webSocket?.onData?(try! h.toData())
                    expect(closeCode).toEventually(equal(CloseCodeType.Redirect))
                    expect(closeFrame?.message).toEventually(equal("new_url"))
                }
                
            }
            
            context("incoming redirect"){
                
                it("should reconnect to new url if close.redirect received"){
                    
                    let redirectClose = CloseFrame(closeCode: .Redirect, message: "ws://localhost:7777")
                    var closeCode:CloseCodeType?
                    let sut = WebSocketConnection(url: "ws://localhost:8888")!
                    var reasonRedirect:String?
                    var isConnected = false
                    var handshakeSend:HandshakeFrame?
                    
                    sut.onClose = { reason, code in
                        closeCode = code
                        sut.reconnect(url: reason)
                        
                        let h = HandshakeFrame(version: 0x1)
                        
                        sut.onConnect = {
                            isConnected = true
                        }
                        
                        sut.onDataReceived = { data in
                            
                            handshakeSend = try! HandshakeFrame(data: data!)
                        }
                        
                        sut.webSocket?.onData?(try! h.toData())
                        
                        reasonRedirect = reason
                        
                    }
                    sut.webSocket?.onData?(try! redirectClose.toData())
                    expect(closeCode).toEventually(equal(CloseCodeType.Redirect))
                    expect(isConnected).toEventually(beTrue())
                    expect(handshakeSend!.version).toEventually(equal(UInt16(0x01)))
                    expect(reasonRedirect!).toEventually(equal("ws://localhost:7777"))
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
                
                it("received close.timeout", closure: {
                    
                    var closeCode:CloseCodeType?
                    let c = CloseFrame(closeCode: .Timeout)
                    let sut = WebSocketConnection(url: "ws://localhost:8888")!
                    
                    sut.onClose = { reason, code in
                        closeCode = code
                    }
                    
                    sut.webSocket?.onData?(try! c.toData())
                    expect(closeCode).toEventually(equal(CloseCodeType.Timeout))
                    
                })
                
            }
            
        }
        
    }
}
