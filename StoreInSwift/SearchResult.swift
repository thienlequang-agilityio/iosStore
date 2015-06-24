//
//  SearchResult.swift
//  StoreInSwift
//
//  Created by thienle on 6/23/15.
//  Copyright (c) 2015 thienle. All rights reserved.
//

import Foundation
class SearchResult {
    var artworkURL60 = ""
    var artworkURL100 = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""
    var name = ""
    var artistName = ""
}

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == NSComparisonResult.OrderedAscending
}