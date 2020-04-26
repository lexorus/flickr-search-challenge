// swiftlint:disable identifier_name
func compose<A, B, C>(_ f: @escaping (A) -> B, _ g: @escaping (B) -> C) -> (A) -> C {
    { a in g(f(a)) }
}

func compose<A, B, C>(_ f: @escaping (B) -> C, _ g: @escaping (A) -> B) -> (A) -> C {
    { a in f(g(a)) }
}

func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> ((B, C) -> D) {
    { a in { b, c in f(a, b, c) } }
}

func weakify<T: AnyObject, U, V, W>(_ instance: T,
                                    _ function: @escaping (T) -> (U, V, W) -> Void) -> ((U, V, W) -> Void) {
    { [weak instance] u, v, w in instance.flatMap(function)?(u, v, w) }
}
// swiftlint:enable identifier_name
