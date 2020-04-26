struct SearchPage {
    let query: String
    let size: UInt
    let number: UInt
    let totalNumberOfPages: UInt?

    var isFirst: Bool { return number == 1 }
    var isLast: Bool { number == totalNumberOfPages }
    var totalNumberOfItems: UInt { number * size }

    init(query: String,
         pageSize: UInt = 21,
         totalNumberOfPages: UInt? = nil,
         currentPage: UInt = 1) {
        self.query = query
        self.size = pageSize
        self.totalNumberOfPages = totalNumberOfPages
        self.number = currentPage
    }

    func next() -> SearchPage? {
        if isLast { return nil }
        return SearchPage(query: query,
                              pageSize: size,
                              totalNumberOfPages: totalNumberOfPages,
                              currentPage: number + 1)
    }
}
