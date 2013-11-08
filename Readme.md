## [OSX] Ruby as integrated scripting language

### Motivation

For a future OSX desktop application that should provide a scripting environment I thought Ruby would be nice. 

Solution: MacRuby. 

### What is provided here?

Nothing really special. Just some samples how to interact with the MacRuby interpreter included in Objective-c code. It calls some (okay, I have to say - not very useful) plain Ruby methods and also passes a Objective-C instance to a Ruby class. The instance of the Ruby class calls an instance method of the Objective-C instance to provide a fake feeling of having the Objective-c app API called. 

### I want to see some results !

Okay. You need Rake to compile the source:

```
rake code:compile
```

To execute the tests:

```
./macruby
```

Running that should result in something like this: 

![](http://f.cl.ly/items/2O3T0V0h320D2R1o373n/Screen%20Shot%202013-11-08%20at%2011.34.50.png)

The thing used as a "testtool" is just a wrapper around NSAssert - beautified with some colors. 

### Last words

I already integrated Objective-C and MacRuby in a single application but without using the MacRuby runtime in the Objective-C code. The simple tests which I provide with this repository are going in a satisfying direction. Of course that there should be more complicated samples. And that's obviously a **TODO**! 


Feel free to use the code if you want to. 

Author: Daniel Schmidt <dsci@code79.net>
