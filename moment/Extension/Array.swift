import RealmSwift

extension Array where Element: RealmCollectionValue {

    public func toList() -> List<Element> {
        let list: List<Element> = List()
        forEach(list.append)
        return list
    }

}

extension List where Element: Object {

    public func toArray() -> Array<Element> {
        var array: [Element] = []
        forEach { element in array.append(element) }
        return array
    }

}