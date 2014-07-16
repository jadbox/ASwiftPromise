This is a simple (working) Promise library for Apple's Swift language. Since it's becomming more like Rx than a Promise library, I'll be changing the naming convensions soon.

Futures and Promises can be hot (default) and cold. Cold streams cache their history and replay it to new handlers.

Examples:

    var d = Deffered<Int,Int>(isCold:false);
    var p = d.promise;
    
    d.done(2); // ignored since the Deffered is cold and no handles have been placed on the promise yet
    
    var mf = p.success
        .filter() { $0 < 100 }
        .map() { "Hello World " + String($0) }
        .forEach() { (x) in println(x) };

    d.done(98);
    d.done(99);
    d.done(100); // filtered

    //Merging
    var d2 = Deffered<String,String>();
    d2.promise.success.merge(mf).on() { // fires when t2 and t are fulfilled
       println( $0 ); // return value is a Tuple of type <String, Int>
    }
    d2.done("hello"); // fulfill promise t2
    d.done(1); // update promise t
    d.done(100); // filtered because of the filter on mf
    
**See [main.swift](https://github.com/jadbox/ASwiftPromise/blob/master/ASwiftPromise/main.swift) for more examples!**

[@jonathanAdunlap](http://twitter.com/jonathanAdunlap)
