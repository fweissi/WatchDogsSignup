import Vapor
import HTTP
import VaporPostgreSQL

final class MemberMiddleware: Middleware {
    let drop: Droplet?
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        var response = try next.respond(to: request)
        
        if request.uri.path == "/members" && request.accept.prefers("html") {
            var parameters = [String: Node]()
            
            if let drop = drop, let db = drop.database?.driver as? PostgreSQLDriver {
                let query = try db.raw("SELECT * FROM members ORDER BY id DESC")
                parameters = ["members": query]
                let myResponse = try drop.view.make("manage", parameters).makeResponse()
                response = myResponse
            }
        }
        
        return response
    }
}
