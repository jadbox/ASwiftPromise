//
//  main.swift
//  ASwiftPromise
//
//  Created by @JonathanADunlap on 6/4/14.
//  Copyright (c) 2014 Jonathan Dunlap. All rights reserved.
//

import Foundation

var t = Deffered<Int,Int>();
var p = t.promise;
//p.onSuccess( { (x) in println(x) } );


var m = p.success
    .filter( { $0 < 100 } )
    .map( { "test" + String($0) } );

m.onSet += { println($0) }
t.done(98);
t.done(99);
t.done(100);

println("Hello, World!");


