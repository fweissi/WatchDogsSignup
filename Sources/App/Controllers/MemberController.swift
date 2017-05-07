import Vapor
import HTTP
import Foundation

final class MemberController {
    
    func addRoutes(drop: Droplet) {
        drop.post("create", handler: create)
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var member = try request.member()
        try member.save()
        return member
    }
}


extension Request {
    func member() throws -> Member {
        guard let json = json else { throw Abort.badRequest }
        
        return try Member(node: json)
    }
}
