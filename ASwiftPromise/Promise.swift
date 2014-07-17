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
operator prefix <= {} // shortcut for assignments
operator prefix >= {} // shortcut for forEach
operator prefix >>= {} // shortcut for map
operator prefix %= {} // shortcut for filter

extension Observable {
    /*
    func print() -> () {
        forEach() {
            println( String( $0 ) );
        }
    }*/
    // Map elements from the stream
    func map<K>( f:(T)->K ) -> Observable<K> {
        var p = Observable<K>(isCold:isCold) // Hot
        on() { (v:T)->() in p.val = f(v) };
        return p;
    }
    
    // Reduce the stream
    func fold<K>( f:(T, K)->K, var total:K ) -> Observable<K> {
        var p = Observable<K>(isCold:isCold) // Hot
        on() {
            total = f($0, total);
            p.val = total;
        }
        return p;
    }
    
    // Filter elements from the stream
    func filter( f:(T)->Bool ) -> Observable<T> {
        var p = Observable<T>(isCold:isCold) // Hot
        on() {
            (v:T)->() in if(f(v)) { p.val = v }
        };
        return p;
    }
    
    // Merge two streams together
    func merge<K>( f:Observable<K> ) -> Observable<(T,K)> {
        var p = Observable<(T,K)>(isCold:isCold);
        
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
    
    func forEach(f:(T)->()) -> Observable<T> {
        on(f);
        return self;
    }
    
    // Produce a future with an array of values that slide from the last N values
    // Slides are always hot
    func slideBy( n:Int ) -> Observable<[T]> {
        var fu = Observable<[T]>(isCold:isCold);
        var list:[T] = [];
        on() {
            list += $0;
            if(list.count >= n) {
                let start = list.count - n;
                let end = list.count;
                list = Array(list[start..<end]);
                fu.val = list;
            }
        }
        return fu;
    }
}

class FNode<T> { // function node
    typealias F = (T)->();
    var f:F;
    var once:Bool = false
    var next:FNode<T>?;
    var prev:FNode<T>?;
    var isHead:Bool=false; // workaround for compiler head comparison bug
    init(cb:F, once:Bool=false) { self.f = cb; self.once = once; }
}
class FLL<T> { // function link list
    typealias F = (T)->();
    var head:FNode<T>?;
    func forEachCall(t:T) {
        var current = head;
        do {
            if let node = current {
                node.f(t);
                current = node.next;
                if(node.once) { removeNode(node); }
            } else {
                break;
            }
        } while(true);
    }
    func removeNode(n:FNode<T>) {
        if let p = n.prev {
            p.next = n.next; // it's fine that n has no next node (option type);
        }
        n.next = nil; n.prev = nil;
        // compiler bug http://stackoverflow.com/questions/24668210/swift-using-if-on-an-enum-resulting-in-error-not-convertible-to-arraycastkind
        if(n.isHead) { head = nil; }
    }
    func add(f:F, once:Bool=false) {
        var c = head;
        head = FNode(cb:f, once:once);
        head!.isHead = true;
        head!.next = c;
        if c { c!.prev = head; c!.isHead = false; }
    }
    func removeAll()->() {
        var current = head;
        do {
            if let node = current {
                node.prev = nil; // break circles
                current = node.next;
            } else {
                break;
            }
        } while(true);
        
        head=nil; // chop the head
    }
    init() {}
}
@assignment func +=<T> (inout left: FLL<T>, right: (T)->()) {
    left.add(right);
}

class Observable<T> { // : Future<T>
    var _onSet:FLL<T> = FLL<T>();
    var history:[T] = [];
    var isCold = false;
    var val:T? = nil {
        didSet {
            if isCold || history.count == 0 { history += val!; }
            else { history[0] = val!; }
            _onSet.forEachCall(val!);
        }
    }
    init(isCold:Bool=false) {
        self.isCold = isCold;
    }
    deinit {
        
    }
    // Call the handler only once
    func once( t:(T)->() )->Observable<T>  {
        _onSet.add(t, once:true);
        return self;
    }
    
    func removeAllListeners() {
        _onSet.removeAll();
    }
    
    func removeHistory() {
        history = [];
    }
    
    func on( t:(T)->() )->Observable<T>  {
        if isCold {
            for s in history { t(s); } //replay history
        }
        _onSet += t;
        return self;
    }
    func clone()->Observable<T> { return Observable<T>(isCold: isCold); }
    
}

@assignment func <=<T> (inout left: Observable<T>, right: T) {
    left.val = right;
}
@infix @assignment func >=<T> (inout left: Observable<T>, right: (T)->()) -> Observable<T> {
    left.forEach(right);
    return left;
}
@infix func >>=<T,K> (left: Observable<T>, right: (T)->(K)) -> Observable<K> {
    return left.map(right);
}
@infix func %=<T> (left: Observable<T>, right: (T)->(Bool)) -> Observable<T> {
    return left.filter(right);
}

// Promises encapsolate two Observables for success and fail
class Promise<T,F> {
    let success:Observable<T>;
    let fail:Observable<F>;
    
    func subscribe(data:(T)->(), err:(F)->()) {
        onData(data).onFail(err);
    }
    
    func onData(f:(T)->()) -> Promise<T,F> {
        success.on(f);
        return self;
    }
    
    func onFail(f:(F)->()) -> Promise<T,F> {
        fail.on(f);
        return self;
    }
    
    func send(e:T) {
        success.val = e;
    }
    
    func fail(e:F) {
        fail.val = e;
    }
    
    init(isCold:Bool=false) {
        success = Observable<T>(isCold:isCold);
        fail = Observable<F>(isCold:isCold);
    }
}

// Shorthand for success handlers on the promise
@infix func >=<T,F> (left: Promise<T,F>, right: (T)->()) -> Observable<T> {
    left.success.forEach(right);
    return left.success;
}
@infix func >>=<T,F,K> (left: Promise<T,F>, right: (T)->(K)) -> Observable<K> {
    return left.success >>= right;
}
@infix func %=<T,F> (left: Promise<T,F>, right: (T)->(Bool)) -> Observable<T> {
    return left.success %= right;
}
@infix func <=<T,F> (left: Promise<T,F>, right: T) {
    left.success.val = right;
}
