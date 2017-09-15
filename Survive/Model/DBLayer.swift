//
//  DBLayer.swift
//  Survive
//
//  Created by YANGWEI on 05/09/2017.
//  Copyright © 2017 GINOF. All rights reserved.
//

import SQLite

class DBLayer {
    init() {
        self.initialDBConnect()
    }
    
    private func initialDBConnect() {
        let db = try? Connection("path/to/db.sqlite3")
        
        let users = Table("users")
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        let email = Expression<String>("email")
        
        _ = try? db?.run(users.create { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(email, unique: true)
        })
        
        // CREATE TABLE "users" (
        //     "id" INTEGER PRIMARY KEY NOT NULL,
        //     "name" TEXT,
        //     "email" TEXT NOT NULL UNIQUE
        // )
        
        let insert = users.insert(name <- "Alice", email <- "alice@mac.com")
        let rowid = try? db?.run(insert)
        // INSERT INTO "users" ("name", "email") VALUES ('Alice', 'alice@mac.com')
        
//        for user in try? db?.prepare(users) {
//            print("id: \(user[id]), name: \(user[name]), email: \(user[email])")
//            // id: 1, name: Optional("Alice"), email: alice@mac.com
//        }
//        // SELECT * FROM "users"
//        
//        let alice = users.filter(id == rowid)
//        
//        _ = try? db?.run(alice.update(email <- email.replace("mac.com", with: "me.com")))
//        // UPDATE "users" SET "email" = replace("email", 'mac.com', 'me.com')
//        // WHERE ("id" = 1)
//        
//        _ = try? db?.run(alice.delete())
        // DELETE FROM "users" WHERE ("id" = 1)
        
//        db.scalar(users.count) // 0

    }
}
