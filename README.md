<img src="http://www.minddriven.de/wp-content/uploads/2009/11/Rx_Logo_512.png" width="100px"/>

This is a simple (working) Promise library for Apple's Swift language. Since it's becomming more like Rx (Reactive Extensions) than a Promise library, I'll be changing the naming conventions where appropriate. Currently, Observables do not handle any response other than it's generic type (versus Rx which does allow this). Conversely, a Promise contains two Observables for handling the primary data types as well as the error type.

Observables and Promises can be hot (default) and cold. Cold streams cache their history and replay it to new handlers.

Supported operations: filter, map, forEach, fold, merge, slideBy, once

Simple setup (using shorthands):

    var o = Observable<String>();
    o >= { // same as o.forEach{
        println("Hello \($0)");
    }
    o <= "World"; // same as o.send("World")

Examples:

    // A Promise contains two Observables to monitor sent data and raised errors
    var p = Promise<Int,String>(isCold:false); // Data will be Ints and errors will be Strings
    
    // === Error case ===
    p.onFail { // same as p.errrors.forEach
        println("Failed with \($0)")
    }
    p.fail("Testing Failure"); // triggers above fail handler (of type String)
    
    // === Handling Data === 
    p.send(2); // ignored since it is hot and no handles have been placed on the promise yet
    
    var mf = p.success
        .filter { $0 < 100 } // filter items less than 100 from the stream
        .map { "World \($0)" } // change the stream from ints to strings
        .forEach { (x) in println(x) }; // forEach does not change the stream output

    p.send(98);
    p <= 99; // shorthand for send(99)
    p <= 105; // filtered since 105 is not < 100

    //Merging
    var p2 = Promise<String,String>();
    p2.success.merge(mf).forEach { // fires when both streams are fulfilled
       println( $0 ); // prints ("Hello", "World 1") of type Tuple<String, String>
    }
    p2 <= "Hello"; // fulfill promise in d2
    p <= 1; // update promise p
    p <= 100; // filtered because of the filter on mf
    
**See [main.swift](https://github.com/jadbox/ASwiftPromise/blob/master/ASwiftPromise/main.swift) for several more detailed examples!**

forEach shorthand >=

Mapping shorthand >>=

Filter shorthand %=

Send (input) data shorthand <=

[@jonathanAdunlap](http://twitter.com/jonathanAdunlap)
