import Fluent
import SQLKit


struct UpdateRecentPackages2: Migration {
    let dropSQL: SQLQueryString = "DROP MATERIALIZED VIEW recent_packages"

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        guard let db = database as? SQLDatabase else {
            fatalError("Database must be an SQLDatabase ('as? SQLDatabase' must succeed)")
        }
        let updatedViewSQL: SQLQueryString =
            """
            CREATE MATERIALIZED VIEW recent_packages AS
            SELECT
                p.id,
                r.owner AS repository_owner,
                r.name AS repository_name,
                r.summary AS package_summary,
                v.package_name,
                MAX(p.created_at) AS created_at
            FROM packages p
            JOIN versions v ON v.package_id = p.id
            JOIN repositories r ON r.package_id = p.id
            WHERE v.package_name IS NOT NULL
              AND r.owner IS NOT NULL
              AND r.name IS NOT NULL
            GROUP BY p.id, r.owner, r.name, r.summary, v.package_name
            ORDER BY MAX(p.created_at) DESC
            LIMIT 100
            """
        return db.raw(dropSQL).run()
            .flatMap { db.raw(updatedViewSQL).run() }
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        guard let db = database as? SQLDatabase else {
            fatalError("Database must be an SQLDatabase ('as? SQLDatabase' must succeed)")
        }
        let oldViewSQL: SQLQueryString =
            """
            CREATE MATERIALIZED VIEW recent_packages AS
            SELECT
                p.id,
                r.owner AS repository_owner,
                r.name AS repository_name,
                v.package_name,
                MAX(p.created_at) AS created_at
            FROM packages p
            JOIN versions v ON v.package_id = p.id
            JOIN repositories r ON r.package_id = p.id
            WHERE v.package_name IS NOT NULL
              AND r.owner IS NOT NULL
              AND r.name IS NOT NULL
            GROUP BY p.id, r.owner, r.name, v.package_name
            ORDER BY MAX(p.created_at) DESC
            LIMIT 100
            """
        return db.raw(dropSQL).run()
            .flatMap { db.raw(oldViewSQL).run() }
    }
}
