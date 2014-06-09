//
//  main.swift
//  ASwiftPromise
//
//  Created by @JonathanADunlap on 6/4/14.
//  Copyright (c) 2014 dunlap. All rights reserved.
//

import Foundation

var d = Deferred<String, String>();
d.resolve("Pre-resolved Promise");
var promise = d.getPromise();
promise.setup(&d);
promise.done({ x in println(x) });

println("----");


var d2 = Deferred<String, String>();
var promise2 = d2.getPromise();
promise2.setup(&d2);
d2.resolve("Post-resolved Promise");
promise2.done({ x in println(x) });

