//
//  main.swift
//  ASwiftPromise
//
//  Created by @JonathanADunlap on 6/4/14.
//  Copyright (c) 2014 Jonathan Dunlap. All rights reserved.
//

// Cold Futures store history and replays it to new listeners
import Foundation

var def1 = Deffered<Int,Int>(isCold: false); //isCold: true
var p = def1.promise;
//p.onSuccess() { (x) in println(x) };
def1.done(2);

var m = p.success
    .filter() { $0 < 100 }
    .map() { "test" + String($0) }
    //.forEach() { println($0) }



//Merging
var def2 = Deffered<String,String>();
def2.promise.success.merge(m).forEach() {
    println( $0 );
}

def2.done("hello");
def1.done(11);
def1.done(98);

def2.done("hello1");
def1.done(99);
def1.done(100); // filtered

println("completed");