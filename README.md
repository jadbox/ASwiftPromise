<img src="http://www.minddriven.de/wp-content/uploads/2009/11/Rx_Logo_512.png" width="100px"/>

This is a simple (working) Promise library for Apple's Swift language. Since it's becomming more like Rx (Reactive Extensions) than a Promise library, I'll be changing the naming conventions where appropriate. Currently, Observables do not handle any response other than it's generic type (versus Rx which does allow this). Conversely, a Promise contains two Observables for handling the primary data types as well as the error type. This library completely utilizes a strongly typed interface for handlers, stream transforms, sugar operators; everything is typed for compile-time checking! 

Another major different between this library and Rx is that Observables and Observers are collapsed into just Observables. The reason for having both objects in Rx is to seperate/isolate the reciever of data from the data sender; however since Swift does not provide protected members, isolation isn't technically possible (without resorting to odd conventions). As a side effect, the api becomes a tad simplier, although less strict/pure.

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
    p <= 106; // filtered out of p2 because of the filter on mf used for merging
    
**See [main.swift](https://github.com/jadbox/ASwiftPromise/blob/master/ASwiftPromise/main.swift) for several more detailed examples!**

forEach shorthand >=

Mapping shorthand >>=

Filter shorthand %=

Send (input) data shorthand <=

Shorthand merge of Observable(s) +

Shorthand example:

    var p = Promise<Int,Int>();
    
    // m is filtered %= and mapped >>=
    var m = (p %= { $0 < 100 })
            >>= { "My number is " + String($0) }
    
    // forEach over the m stream
    m >= { 
        println("\($0)"); // Prints "My number is 105"
    }
    
    // 2nd Observable
    var def2 = Observable<Int>();
    var m2 = def2 >>= { $0 + 1 };
    // Merged Observable of m and m2
    var merged = m + m2; // result is an Observable<(type of M, type of M2)>
    merged >= {
        // $0.0 and $0.1 are tuple accessors
        println("Value of m is \($0.0) and m2 is \($0.1)"); 
    }
    
    // Fulfill values
    def2 <= 11; // alias of def2.val = 11
    def1 <= 105; // alias of def1.val = 105
    def1 <= 5; 

[@jonathanAdunlap](http://twitter.com/jonathanAdunlap)
