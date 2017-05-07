import Vapor
import VaporPostgreSQL

let drop = Droplet()
try drop.addProvider(VaporPostgreSQL.Provider)
drop.preparations += Member.self

let memberController = MemberController()
memberController.addRoutes(drop: drop)

drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"],
    	"info": drop.localization[req.lang, "welcome", "subtitle"]
    ])
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
