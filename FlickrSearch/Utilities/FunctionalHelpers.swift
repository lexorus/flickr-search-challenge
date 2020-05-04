// swiftlint:disable identifier_name opening_brace
func compose<A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
    { a in g(f(a)) }
}

func compose<A, B, C>(_ f: @escaping (B) -> C, _ g: @escaping (A) -> B) -> (A) -> C {
    { a in f(g(a)) }
}

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> ((B) -> C) {
    { a in { b in f(a, b) } }
}

func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> ((B, C) -> D) {
    { a in { b, c in f(a, b, c) } }
}

func weakify<T: AnyObject, U>(_ instance: T,
                              _ function: @escaping (T) -> (U) -> Void) -> ((U) -> Void) {
    { [weak instance] u in instance.flatMap(function)?(u) }
}
// swiftlint:enable identifier_name opening_brace
