//
//  Promise.swift
//  ASwiftPromise
//
//  Created by @JonathanADunlap on 6/5/14.
//  Copyright (c) 2014 dunlap. All rights reserved.
//
/*
struct Test<T> {
    var v:T?;
    mutating func s( v:(T)->() ) {
        self.v = v;
    }
    mutating func g() -> T? {
        return v;
    }
    init() {}
}*/

struct Promise<T,F> {
    typealias FS = T->();
    typealias FF = F->();
    var svalue:T?;
    var fvalue:F?;
    var slisteners:FS[] = FS[]()
    var flisteners:FF[] = FF[]()
    
    
    init() {
        
    }
    
    mutating func setup(inout deferred:Deferred<T,F>) {
        deferred.done( onDone );
        deferred.fail( onFail );
    }
    
    mutating func onDone(y:T) -> () {
        self.svalue = y;
        for f in slisteners {
            f(y);
        }
    }
    
    mutating func onFail(y:F) -> () {
        self.fvalue = y;
        for f in flisteners {
            f(y);
        }
    }
    
    mutating func done(listener:FS) {
        if let s = svalue {
            listener(s);
        }
        else {
            slisteners += listener;
        }
        
    }
    mutating func fail(listener:FF) {
        if let f = fvalue {
            listener(f);
        }
        else { flisteners += listener; }
    }
    
    mutating func then(success:FS, fail:FF) {
        self.done(success);
        self.fail(fail);
    }
}

struct Deferred<T,F> {
    typealias FS = (T)->();
    typealias FF = (F)->();
    typealias D = Deferred<T,F>;
    typealias P = Promise<T,F>;
    var slistener:FS?
    var flistener:FF?
    var svalue:T?;
    var fvalue:F?;
    
    init() {
    }
    
    func resolved()->Bool {
        return svalue && fvalue
    }
    
    mutating func resolve(val:T) -> D {
        svalue = val;
        if let s = slistener {
            s(val);
        }
        return self
    }
    
    mutating func reject(val:F) -> D {
        fvalue = val;
        if let f = flistener {
            f(val);
        }
        return self;
    }
    
    mutating func done(listener:FS) {
        if let s = svalue {
            listener(s);
        }
        else { slistener = listener; }
        
    }
    mutating func fail(listener:FF) {
        if let f = fvalue {
            listener(f);
        }
        else { flistener = listener; }
    }
    
    mutating func getPromise() -> Promise<T,F> {
        var p = Promise<T,F>()
        p.setup(&self);
        return p;
    }
}