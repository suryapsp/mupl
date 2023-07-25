# MUPL(Made Up Programming Language)

A simple programming language interpreter implemented in Racket.

## Features

```
variable
addition
integer
ifgreater
functions
pair
null
closures
lexical scope
```

## Syntax

```
(var  (string) #:transparent)  ;; a variable, e.g., (var "foo")
(int  (num)    #:transparent)  ;; a constant number, e.g., (int 17)
(add  (e1 e2)  #:transparent)  ;; add two expressions
(ifgreater (e1 e2 e3 e4)    #:transparent) ;; if e1 > e2 then e3 else e4
(fun  (nameopt formal body) #:transparent) ;; a recursive(?) 1-argument function
(call (funexp actual)       #:transparent) ;; function call
(mlet (var e body) #:transparent) ;; a local binding (let var = e in body) 
(apair (e1 e2)     #:transparent) ;; make a new pair
(fst  (e)    #:transparent) ;; get first part of a pair
(snd  (e)    #:transparent) ;; get second part of a pair
(aunit ()    #:transparent) ;; unit value -- good for ending a list
(isaunit (e) #:transparent) ;; evaluate to 1 if e is unit else 0
(closure (env fun) #:transparent) 
```
