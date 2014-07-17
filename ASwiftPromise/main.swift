//
//  main.swift
//  ASwiftPromise
//
//  Created by @JonathanADunlap on 6/4/14.
//  Copyright (c) 2014 Jonathan Dunlap. All rights reserved.
//

// Cold Futures store history and replays it to new listeners
import Foundation

func simpleFuture() {
    var f = Observable<Int>(isCold: false);
    f.val = 3; // thrown away since it's hot
    f.forEach() {
        if($0==3) {println("fail simpleFuture");}
        else if($0==5) {println("success simpleFuture");}
    }
    f <= 5; // shorthand for f.val = 5
}; simpleFuture();

//Test if the once method happens for just first stream element
func onceTest() {
    var f = Observable<Int>(isCold: false);
    // Method is called once and then is removed
    f.once() {
        if($0==1) {println("success of first call to onceTest");}
        else { println("fail onceTest, recieved another "+String($0)); }
    }
    f.val = 1;
    f.val = 5;
}; onceTest();

func simpleHotDefferedTest() {
    var def1 = Promise<Int,Int>(isCold: false);
    def1.send(3); // thrown away since it's hot
    def1.success.forEach() {
        if($0==3) {println("fail simpleHotDefferedTest");}
        else if($0==5) {println("success simpleHotDefferedTest");}
    }
    def1.send(5);
}; simpleHotDefferedTest();

func simpleColdDefferedTest() {
    var def1 = Promise<Int,Int>(isCold: true);
    def1.send(2); // will be stored for future listeners because it's cold
    def1 <= 3; // shorthand for def1.send(3)
    var step = 0;
    def1.success.forEach(){
        if($0==2 && step==0) {step++}
        else if($0==3 && step==1) {step++}
        else if($0==5 && step==2) {println("success simpleColdDefferedTest");}
        else {println("failed simpleColdDefferedTest")}
    }
    def1.send(5);
}; simpleColdDefferedTest();

func filterMapHotTest() {
    var def1 = Promise<Int,Int>(isCold: false); //isCold: true for history playback
    
    var m = def1.success
        .filter() { $0 < 100 }
        .map() { "My number is " + String($0) }
    
    m.forEach(){
        if($0=="My number is 105") {println("fail filterMapHotDeffered");}
        else if($0=="My number is 5") {println("success filterMapHotDeffered");}
        else {println("failed filterMapHotDeffered unexpected")}
    }
    
    def1.send(105);
    def1.send(5);
}; filterMapHotTest();

// Neat shorthand syntax
func shortHandTests() {
    var def1 = Promise<Int,Int>(isCold: false); //isCold: true for history playback
    
    var m = (def1 %= { $0 < 100 }) // filter
            >>= { "My number is " + String($0) } // map
    
    m >= { // forEach
        if($0=="My number is 105") {println("fail shortHandTests");}
        else if($0=="My number is 5") {println("success shortHandTests");}
        else {println("failed shortHandTests unexpected")}
    }
    
    def1 <= 105; // def1.val = 105
    def1 <= 5; // def1.val = 5
}; shortHandTests();

func mergeTest() {
    var def1 = Promise<Int,Int>(isCold: false); //isCold: true for history playback
    
    //Merging
    var def2 = Promise<String,String>();
    def2.success.merge(def1.success).forEach() {
        switch $0 {
        case(let x, let y):
            if(x=="Hello" && y==5) { println("success mergeTest"); }
        default:
            println("failed mergeTest");
        }
    }
    def1.send(5);
    def2.send("Hello");
}; mergeTest();

func foldTest() {
    var def1 = Promise<Int,Int>(isCold: false);
    var step = 0;
    var f = def1.success.fold({$0 + $1}, total:1)
        .forEach() {
            if(step==0 && $0==1+2) { step++; }
            else if(step==1 && $0==1+2+3) { step++; }
            else if(step==2 && $0==1+2+3+4) { println("success foldTest") }
            else { println("failed foldTest unexpected") }
        }
    
    def1.send(2);
    def1.send(3);
    def1.send(4);
}; foldTest();

func slidingTest() {
    var f = Observable<Int>(isCold: false);
    
    var step = 0;
    f.slideBy(3).forEach {
        if(step==0 && $0 == [1,5,10]) { step++; }
        else if(step==1 && $0 == [5,10,15]) { println("success slidingTest") }
        else { println("failed slidingTest unexpected with \($0)" ) }
    }
    f.val = 1;
    f.val = 5;
    f.val = 10;
    f.val = 15;
}; slidingTest();

func coldSlidingTest() {
    var f = Observable<Int>(isCold: true);
    f.val = 1;
    f.val = 5;
    f.val = 10;
    f.val = 15;
    
    var step = 0;
    f.slideBy(3).forEach {
        if(step==0 && $0 == [1,5,10]) { step++; }
        else if(step==1 && $0 == [5,10,15]) { println("success coldSlidingTest") }
        else { println("failed coldSlidingTest unexpected with \($0)" ) }
    }
}; coldSlidingTest();

func promiseFailTest() {
    var f = Promise<Int, String>(isCold: true);
    f.onData() {
        println($0);
    }
    f.onFail() {
        println($0);
    }
    f.fail("Testing failure");
}

println("completed");