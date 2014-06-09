This is a simple Promise library for Apple's Swift language.

It now WORKS as I found a workaround using structs versus classes, since classes cannot have variable size at compilation currently.

Simple pre and post resolve examples:

    var d = Deferred<String, String>();
    d.resolve("Pre-resolved Promise");
    var promise = d.getPromise();
    promise.done({ x in println(x) });


    var d2 = Deferred<String, String>();
    var promise2 = d2.getPromise();
    promise2.setup(&d2);
    promise2.done({ x in println(x) });
    d2.resolve("Post-resolved Promise");

[@jonathanAdunlap](http://twitter.com/jonathanAdunlap)
