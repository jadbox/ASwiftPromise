//
//  main.swift
//  ASwiftPromise
//
//  Created by @JonathanADunlap on 6/4/14.
//  Copyright (c) 2014 dunlap. All rights reserved.
//

import Foundation

enum PromiseState<T,F> {
    case Unresolved
    case Fail(F)
    case Success(T)
}

class Promise<T,F> {
    typealias FS = T->();
    typealias FF = F->();
    var value:PromiseState<T,F> = .Unresolved;
    var rlisteners:FS[] = []
    var flisteners:FF[] = []
    
    init() {
    }
    init(deferred:Deferred<T,F>) {
        func onDone(y:T) -> () {
            value = .Success(y);
            self.rlisteners.map( {x in x(y)} );
        }
        func onFail(y:F) -> () {
            value = .Fail(y);
            self.flisteners.map( {x in x(y)} );
        }
        deferred.done( onDone );
        deferred.fail( onFail );
    }
    
    func done(listener:FS) {
        switch value {
            case .Success(let s):
                listener(s);
        default: break;
        }
        rlisteners += listener;
        
    }
    func fail(listener:FF) {
        switch value {
        case .Fail(let f):
            listener(f);
        default: break;
        }
        flisteners += listener;
    }
    func then(success:FS, fail:FF) {
        self.done(success);
        self.fail(fail);
    }
}

class Deferred<T,F> : Promise<T,F> {
    typealias D = Deferred<T,F>;
    typealias P = Promise<T,F>;
    var promises:P[] = []
    
    
    init() {
        super.init();
    }
    
    func resolved()->Bool {
        switch value {
        case .Unresolved: return false
        default: return true
        }
    }
    
    func resolve(val:T) -> D {
        if(resolved()) { return self }
        value = .Success(val)
        rlisteners.map( {x in x(val)} );
        return self
    }
    
    func reject(val:F) -> D {
        if(resolved()) { return self }
        value = .Fail(val)
        flisteners.map( {x in x(val)} );
        return self;
    }
    
    func promise() -> P {
        let promise = P(deferred:self);
        promises += promise;
        return promise;
    }
}

let d = Deferred<String, String>();
d.resolve("hello");
d.promise().done({ x in println(x) });

