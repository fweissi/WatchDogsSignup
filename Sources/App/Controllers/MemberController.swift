import Vapor
import HTTP
import Foundation

final class MemberController {
    
    func addRoutes(drop: Droplet) {
        drop.group("members") { group in
            group.post("create", handler: create)
            group.get("all", handler: index)
            group.get("show", Member.self, handler: show)
            group.patch("update", Member.self, handler: update)
            group.post("delete", Member.self, handler: delete)
        }
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var member = try request.member()
        try member.save()
        return member
    }
    
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try JSON(node: Member.all().makeNode())
    }
    
    
    func show(request: Request, member: Member) throws -> ResponseRepresentable {
        return member
    }
    
    
    func update(request: Request, member: Member) throws -> ResponseRepresentable {
        let new = try request.member()
        var member = member
        member.name = new.name
        member.email = new.email
        try member.save()
        return member
    }
    
    
    func delete(request: Request, member: Member) throws -> ResponseRepresentable {
        try member.delete()
        return JSON([:])
    }
}


extension Request {
    func member() throws -> Member {
        guard let json = json else { throw Abort.badRequest }
        
        return try Member(node: json)
    }
}
