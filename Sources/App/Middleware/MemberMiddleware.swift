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
        do {
            var response = try next.respond(to: request)
            
            if request.accept.prefers("html") {
                let url = URL(string: request.uri.path)
                if let lastComponent = url?.lastPathComponent {
                    
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
            }
            
            return response
        }
        catch {
            throw Abort.custom(status: .forbidden, message: "You are not allowed to perform this task in a browser.")
        }
    }
}
