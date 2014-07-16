This is a simple (working) Promise library for Apple's Swift language.

Currently, promises do not cache results-- meaning the result handler needs to be added before promise resolves.

Simple pre and post resolve examples:

    var d = Deffered<Int,Int>();
    var p = d.promise;

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
    
See main.swift for more examples!

[@jonathanAdunlap](http://twitter.com/jonathanAdunlap)
