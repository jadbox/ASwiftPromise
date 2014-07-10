//
//  Promise.swift
//  ASwiftPromise
//
//  Created by @JonathanADunlap on 6/5/14.
//  Copyright (c) 2014 dunlap. All rights reserved.
//

class Promise<T,F> {
    typealias FS = T->();
    typealias FF = F->();
    var svalue:T?;
    var fvalue:F?;
    var slisteners:[FS] = [FS]()
    var flisteners:[FF] = [FF]()

    init() {
        
    }
    
    func setup(inout deferred:Deferred<T,F>) {
        deferred.done( onDone );
        deferred.fail( onFail );
    }
    
    func onDone(y:T) -> () {
        self.svalue = y;
        for f in slisteners {
            f(y);
        }
    }
    
    func onFail(y:F) -> () {
        self.fvalue = y;
        for f in flisteners {
            f(y);
        }
    }
    
    func done(listener:FS) {
        if let s = svalue {
            listener(s);
            println("fired done listener");

        }
        else {
            slisteners += listener;
            println("adding done listener");
        }
        println(slisteners.count);
    }
    func fail(listener:FF) {
        if let f = fvalue {
            listener(f);
        }
        else { flisteners += listener; }
    }
    
    /*func then(success:FS, fail:FF) {
        self.done(success);
        self.fail(fail);
    }*/
}

class Deferred<T,F> : Promise<T,F> {
    typealias FS = (T)->();
    typealias FF = (F)->();
    typealias D = Deferred<T,F>;
    typealias P = Promise<T,F>;
    var slistener:FS?
    var flistener:FF?
    //var svalue:T?;
    //var fvalue:F?;
    
    init() {
    }
    
    func resolved()->Bool {
        return svalue && fvalue
    }
    
    func resolve(val:T) -> D {
        svalue = val;
        if let s = slistener {
            s(val);
        }
        return self
    }
    
    func reject(val:F) -> D {
        fvalue = val;
        if let f = flistener {
            f(val);
        }
        return self;
    }
    
    func getPromise() -> Promise<T,F> {
        var p = Promise<T,F>();
        var a = self as Deferred<T,F>;
        p.setup(&a);
        return p;
    }
}