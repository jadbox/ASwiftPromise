//
//  main.swift
//  ASwiftPromise
//
//  Created by @JonathanADunlap on 6/4/14.
//  Copyright (c) 2014 Jonathan Dunlap. All rights reserved.
//

// Cold Futures store history and replays it to new listeners
import Foundation

func simpleHotDeffered() {
    var def1 = Deffered<Int,Int>(isCold: false);
    def1.done(3);
    def1.promise.success.forEach(){
        if($0==3) {println("fail simpleHotDeffered");}
        else if($0==5) {println("success simpleHotDeffered");}
    }
    def1.done(5);
}; simpleHotDeffered();

func simpleColdDeffered() {
    var def1 = Deffered<Int,Int>(isCold: true);
    def1.done(3);
    var step = 0;
    def1.promise.success.forEach(){
        if($0==3 && step==0) {step++}
        else if($0==5 && step==1) {println("success simpleColdDeffered");}
        else {println("failed simpleColdDeffered")}
    }
    def1.done(5);
}; simpleColdDeffered();

func filterMapHotDeffered() {
    var def1 = Deffered<Int,Int>(isCold: false); //isCold: true for history playback
    var p = def1.promise;
    
    //var step = 0;
    var m = p.success
        .filter() { $0 < 100 }
        .map() { "My number is " + String($0) }
    
    m.forEach(){
        if($0=="My number is 105") {println("fail filterMapHotDeffered");}
        else if($0=="My number is 5") {println("success filterMapHotDeffered");}
        else {println("failed filterMapHotDeffered")}
    }
    
    def1.done(105);
    def1.done(5);
}; filterMapHotDeffered();

func mergePromise() {
    var def1 = Deffered<Int,Int>(isCold: false); //isCold: true for history playback
    
    //Merging
    var def2 = Deffered<String,String>();
    def2.promise.success.merge(def1.promise.success).forEach() {
        switch $0 {
        case(let x, let y):
            if(x=="Hello" && y==5) { println("success mergePromise"); }
        default:
            println("fail mergePromise");
        }
    }
    def1.done(5);
    def2.done("Hello");
}; mergePromise();

func foldTest() {
    var def1 = Deffered<Int,Int>(isCold: false);
    var step = 0;
    var f = def1.promise.success.fold({$0 + $1}, total:1)
        .forEach() {
            if(step==0 && $0==2) { step++; }
            else if(step==1 && $0==4) { step++; }
            else if(step==2 && $0==7) { println("success foldTest") }
            else { println("fail foldTest") }
        }
    
    def1.done(1);
    def1.done(2);
    def1.done(3);
}; foldTest();

println("completed");