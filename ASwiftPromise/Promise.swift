//  ASwiftPromise
//
//  Promise.swift
//  TestSwf
//
//  Created by Jonathan Dunlap on 6/4/14.
//  Copyright (c) 2014 Jonathan Dunlap. All rights reserved.
//
//typealias FS = T->();
import Foundation

extension Future {
    func map<K>( f:(T)->K ) -> Future<K> {
        var p = Future<K>()
        on() { (v:T)->() in p.val = f(v) };
        return p;
    }
    
    func filter( f:(T)->Bool ) -> Future<T> {
        var p = Future<T>()
        on() {
            (v:T)->() in if(f(v)) { p.val = v }
        };
        return p;
    }
    
    func merge<K>( f:Future<K> ) -> Future<(T,K)> {
        var p = Future<(T,K)>();
        var r1:T?;
        var r2:K?;
        
        func check() {
            if let a = r1 {
                if let b = r2 {
                    p.val = (a,b);
                }
            }
        }
        
        f.on() { r2 = $0; check() };
        on() { r1 = $0; check() };
        
        return p;
    }
}

class Future<T> {
    var onSet:[(T)->()] = [];
    var val:T? = nil {
        didSet {
            for s in onSet {
                s(val!);
            }
        }
    }
    
    func on(f:(T)->()) -> () {
        onSet += f;
    }
    init() {}
}

class Promise<T,F> {
    let success = Future<T>();
    let fail = Future<F>();
    
    func onSuccess(f:(T)->()) -> Promise<T,F> {
        success.onSet += f;
        return self;
    }
    
    func onFail(f:(F)->()) -> Promise<T,F> {
        fail.onSet += f;
        return self;
    }
    
    func _onDone(e:T) {
        success.val = e;
    }
    
    func _onFail(e:F) {
        fail.val = e;
    }
    
    init() {
    }
}

class Deffered<T,F> {
    //var result:T?; Todo caching
    //var error:F?;
    let promise:Promise<T,F> = Promise<T,F>();
    
    init() {
    }
    
    func done(t:T) {
        promise._onDone(t);
    }
    
    func fail(t:F) {
        promise._onFail(t);
    }
}