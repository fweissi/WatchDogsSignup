import Vapor
import HTTP
import Foundation
import VaporPostgreSQL

final class MemberMiddleware: Middleware {
    let drop: Droplet?
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        var errorStatus: Status = .forbidden
        var errorMessage = "You are not allowed to perform this task in a browser."
        if request.uri.host.contains("update") {
            print("Update")
        }
        
        if request.accept.prefers("html") {
            let url = URL(string: request.uri.path)
            if let lastComponent = url?.lastPathComponent {
                if lastComponent.contains("css") || lastComponent.contains("js") || lastComponent.contains("gif") {
                    return try next.respond(to: request)
                }
                else {
                    do {
                        var response = try next.respond(to: request)
                        
                        if url!.absoluteString.contains("members") {
                            switch lastComponent {
                            case "members":
                                if let drop = drop,
                                    let bodyBytes = response.body.bytes {
                                    do {
                                        let parameters = try JSON(bytes: bodyBytes)
                                        let myResponse = try drop.view.make("manage", ["members": parameters]).makeResponse()
                                        response = myResponse
                                    }
                                    catch {
                                        print("Error")
                                    }
                                }
                            default:
                                response = Response(redirect: "/members")
                            }
                        }
                        else if url!.absoluteString.contains("teachers") {
                            let components = url!.path.components(separatedBy: "/")
                            let count = components.count
                            let lastComponent = components[count - 2]
                            
                            switch lastComponent {
                            case "", "teachers":
                                if let drop = drop,
                                    let bodyBytes = response.body.bytes {
                                    do {
                                        let parameters = try JSON(bytes: bodyBytes)
                                        let myResponse = try drop.view.make("teacher", ["hasTeacher": false, "teachers": parameters, "teacher": "{}"]).makeResponse()
                                        return myResponse
                                    }
                                    catch {
                                        print(error.localizedDescription)
                                        errorStatus = .expectationFailed
                                        errorMessage = "The page cannot be rendered due to a parsing error."
                                        throw Abort.custom(status: errorStatus, message: errorMessage)
                                    }
                                }
                            case "show":
                                if let drop = drop,
                                    let bodyBytes = response.body.bytes {
                                    do {
                                        let parameter = try JSON(bytes: bodyBytes)
                                        let parameters = try Teacher.all().makeJSON()
                                        let myResponse = try drop.view.make("teacher", ["hasTeacher": true, "teachers": parameters, "teacher": parameter]).makeResponse()
                                        return myResponse
                                    }
                                    catch {
                                        errorStatus = .expectationFailed
                                        errorMessage = "The page cannot be rendered due to a parsing error."
                                        throw Abort.custom(status: errorStatus, message: errorMessage)
                                    }
                                }
                            default:
                                return Response(redirect: "/teachers")
                            }
                        }
                    }
                    catch {
                        throw Abort.custom(status: errorStatus, message: errorMessage)
                    }
                }
            }
        }
        
        return try next.respond(to: request)
    }
}
