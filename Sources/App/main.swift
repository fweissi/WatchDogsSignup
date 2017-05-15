import Vapor
import VaporPostgreSQL

let drop = Droplet()
try drop.addProvider(VaporPostgreSQL.Provider)
drop.preparations += Member.self
drop.preparations += Post.self

let memberController = MemberController()
memberController.addRoutes(drop: drop)

let postController = PostController()
postController.addRoutes(drop: drop)

drop.get { request in
    return try drop.view.make("home")
}

drop.get("version") { request in
    if let db = drop.database?.driver as? PostgreSQLDriver {
        let version = try db.raw("SELECT version()")
        return try JSON(node: version)
    }
    else {
        return "No DB Connection"
    }
}

drop.resource("posts", PostController())

drop.run()
