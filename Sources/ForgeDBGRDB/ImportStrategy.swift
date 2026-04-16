public enum ImportStrategy: Sendable {
    case insert    // fails on conflict
    case upsert    // insert or update
    case replace   // delete all, then insert
}
