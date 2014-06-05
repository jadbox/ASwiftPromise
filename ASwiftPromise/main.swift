//
//  main.swift
//  ASwiftPromise
//
//  Created by @JonathanADunlap on 6/4/14.
//  Copyright (c) 2014 dunlap. All rights reserved.
//

import Foundation

let d = Deferred<String, String>();
d.resolve("hello");
d.promise().done({ x in println(x) });

