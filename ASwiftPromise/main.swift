//
//  main.swift
//  ASwiftPromise
//
//  Created by @JonathanADunlap on 6/4/14.
//  Copyright (c) 2014 Jonathan Dunlap. All rights reserved.
//

// Cold Futures store history and replays it to new listeners
import Foundation

var t = Deffered<Int,Int>(isCold: false); //isCold: true
var p = t.promise;
//p.onSuccess() { (x) in println(x) };

var m = p.success
    .filter() { $0 < 100 }
    .map() { "test" + String($0) }
    .forEach() { println($0) }



//Merging
var t2 = Deffered<String,String>();
t2.promise.success.merge(m).forEach() {
    println( $0 );
}
t2.done("hello");
t.done(98);
t.done(99);
t.done(100); // filtered
println("completed");