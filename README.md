This is a simple (working) Promise library for Apple's Swift language.

Simple pre and post resolve examples:

    var t = Deffered<Int,Int>();
    var p = t.promise;
    p.onSuccess() { (x) in println(x) };


    var m = p.success
        .filter() { $0 < 100 }
        .map() { "test" + String($0) };

    m.on() { println($0) }
    t.done(98);
    t.done(99);
    t.done(100); // filtered

    //Merging
    var t2 = Deffered<String,String>();
    t2.promise.success.merge(m).on() { // fires when t2 and t are fulfilled
       println( $0 ); // return value is a Tuple of type <String, Int>
    }
    t2.done("hello"); // fulfill promise t2
    t.done(1); // update promise t
    t.done(100); // filtered

[@jonathanAdunlap](http://twitter.com/jonathanAdunlap)
