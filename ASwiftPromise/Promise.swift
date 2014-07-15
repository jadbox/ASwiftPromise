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
        onSet += { (v:T)->() in p.set( f(v) ); };
        return p;
    }
    
    func filter( f:(T)->Bool ) -> Future<T> {
        var p = Future<T>()
        onSet += {
            (v:T)->() in if(f(v)) { p.set(v) }
        };
        return p;
    }
}

class Future<T> {
    var onSet:[(T)->()] = [];
    var value:T?;
    func set(t:T) -> () {
        value = t;
        for s in onSet {
            s(t);
        }
    }
    init() {}
}

class Promise<T,F> {
    var success = Future<T>();
    var fail = Future<F>();
    
    func onSuccess(f:(T)->()) -> Promise<T,F> {
        success.onSet += f;
        return self;
    }
    
    func onFail(f:(F)->()) -> Promise<T,F> {
        fail.onSet += f;
        return self;
    }
    
    func _onDone(e:T) {
        success.set(e);
    }
    
    func _onFail(e:F) {
        fail.set(e);
    }
    
    init() {
        //_d = d; d:Deffered<T,F>
    }
}

class Deffered<T,F> {
    var result:T?;
    var error:F?;
    var promise:Promise<T,F> = Promise<T,F>();
    
    init() {
        //promise = Promise<T,F>(d:self);
    }
    
    func done(t:T) {
        promise._onDone(t);
    }
    
    func fail(t:F) {
        promise._onFail(t);
    }
}