This is a simple (working) Promise library for Apple's Swift language. Since it's becomming more like Rx than a Promise library, I'll be changing the naming conventions soon.

Futures and Promises can be hot (default) and cold. Cold streams cache their history and replay it to new handlers.

Examples:

    var d = Deffered<Int,Int>(isCold:false);
    var p = d.promise;
    
    d.send(2); // ignored since the Deffered is hot and no handles have been placed on the promise yet
    
    var mf = p.success
        .filter() { $0 < 100 }
        .map() { "Hello World " + String($0) } // change the stream from ints to strings
        .forEach() { (x) in println(x) }; // forEach does not change the stream output

    d.send(98);
    d <= 99; // shorthand for d.send(99)
    d <= 105; // filtered since 105 is not < 100

    //Merging
    var d2 = Deffered<String,String>();
    d2.promise.success.merge(mf).on() { // fires when both streams are fulfilled
       println( $0 ); // return value is a Tuple of type <String, String>
    }
    d2 <= "hello"; // fulfill promise in d2
    d <= 1; // update promise p
    d <= 100; // filtered because of the filter on mf
    
**See [main.swift](https://github.com/jadbox/ASwiftPromise/blob/master/ASwiftPromise/main.swift) for more examples!**

[@jonathanAdunlap](http://twitter.com/jonathanAdunlap)
