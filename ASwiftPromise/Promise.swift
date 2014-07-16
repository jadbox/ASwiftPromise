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
        var p = Future<K>(isCold:isCold) // Hot
        on() { (v:T)->() in p.val = f(v) };
        return p;
    }
    
    func filter( f:(T)->Bool ) -> Future<T> {
        var p = Future<T>(isCold:isCold) // Hot
        on() {
            (v:T)->() in if(f(v)) { p.val = v }
        };
        return p;
    }
    
    func merge<K>( f:Future<K> ) -> Future<(T,K)> {
        var p = Future<(T,K)>(isCold:isCold); // Hot
        
        var myCurrent:T?
        var fCurrent:K?
        on() {
            if myCurrent && fCurrent { p.val = ($0,fCurrent!); }
            else { for b in f.history {
                p.val = ($0,b);
                }
            }
            myCurrent = $0;
        }
        f.on() {
            if fCurrent && myCurrent { p.val = (myCurrent!, $0); }
            else {
                for b in self.history {
                    p.val = (b, $0);
                }
            }
            fCurrent = $0;
        }

        
        return p;
    }
    
    func forEach(f:(T)->()) -> Future<T> {
        on(f);
        return self;
    }
}

class Future<T> { // : Future<T>
    var _onSet:[(T)->()] = [];
    var history:[T] = [];
    var isCold = false;
    var val:T? = nil {
        didSet {
            if isCold || history.count == 0 { history += val!; }
            else { history[0] = val!; }
            for s in _onSet { s(val!); }
        }
    }
    init(isCold:Bool=false) {
        self.isCold = isCold;
    }
    deinit {
        
    }
    
   /* func once( t:(T)->() )->Future<T>  {
       // todo 
    }*/
    
    func removeAllListeners() {
        _onSet = [];
    }
    
    func removeHistory() {
        history = [];
    }
    
    func on( t:(T)->() )->Future<T>  {
        if isCold {
            for s in history { t(s); } //replay history
        }
        _onSet += t;
        return self;
    }
    func clone()->Future<T> { return Future<T>(); } // Hot
    
}
/*
class ColdFuture<T> : Future<T> {
    //var _onSet:[(T)->()] = [];
    var past:[T] = [];
    override var val:T? = nil {
        didSet {
            past += val!;
            for s in _onSet {
                s(val!);
            }
        }
    }
    override func on( t:(T)->() )->Future<T> {
        for s in past {
            t(s);
        }
        _onSet += t;
        return self;
    }
    override func clone()->Future<T> {
        var p = ColdFuture<T>();
        //p.past = past;
        return p;
    }
    init() {
        //super.init();
    }
}*/

class Promise<T,F> {
    let success:Future<T>;
    let fail:Future<F>;
    
    func onSuccess(f:(T)->()) -> Promise<T,F> {
        success.on(f);
        return self;
    }
    
    func onFail(f:(F)->()) -> Promise<T,F> {
        fail.on(f);
        return self;
    }
    
    func _onDone(e:T) {
        success.val = e;
    }
    
    func _onFail(e:F) {
        fail.val = e;
    }
    
    init(isCold:Bool=false) {
        if isCold==false {
            success = Future<T>(); // Hot
            fail = Future<F>();
        } else {
            success = Future<T>(isCold:true);
            fail = Future<F>(isCold:true);
        }
    }
}

class Deffered<T,F> {
    let promise:Promise<T,F>;
    
    init(isCold:Bool=false) {
        promise = Promise<T,F>(isCold:isCold);
    }
    
    func done(t:T) {
        promise._onDone(t);
    }
    
    func fail(t:F) {
        promise._onFail(t);
    }
}