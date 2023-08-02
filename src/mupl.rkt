#lang racket
(provide (all-defined-out)) 

;; definition of structures for MUPL programs

(struct var  (string) #:transparent)  ;; a variable, e.g., (var "foo")
(struct int  (num)    #:transparent)  ;; a constant number, e.g., (int 17)
(struct add  (e1 e2)  #:transparent)  ;; add two expressions
(struct ifgreater (e1 e2 e3 e4)    #:transparent) ;; if e1 > e2 then e3 else e4
(struct fun  (nameopt formal body) #:transparent) ;; a recursive(?) 1-argument function
(struct call (funexp actual)       #:transparent) ;; function call
(struct mlet (var e body) #:transparent) ;; a local binding (let var = e in body) 
(struct apair (e1 e2)     #:transparent) ;; make a new pair
(struct fst  (e)    #:transparent) ;; get first part of a pair
(struct snd  (e)    #:transparent) ;; get second part of a pair
(struct aunit ()    #:transparent) ;; unit value -- good for ending a list
(struct isaunit (e) #:transparent) ;; evaluate to 1 if e is unit else 0
(struct closure (env fun) #:transparent) 

;; racketlist->mupllist

(define (racketlist->mupllist l)
  (cond [(null? l) (aunit)]
        [#t (apair (car l) (racketlist->mupllist (cdr l)))]))

;; mupllist->racketlist

(define (mupllist->racketlist l)
  (cond [(aunit? l) null]
        [#t (cons (apair-e1 l) (mupllist->racketlist (apair-e2 l)))]))

;; lookup a variable in an environment

(define (envlookup env str)
  (cond [(null? env) (error "unbound variable during evaluation" str)]
        [(equal? (car (car env)) str) (cdr (car env))]
        [#t (envlookup (cdr env) str)]))

;; evaluate under env

(define (eval-under-env e env)
  
  (cond [(var? e) ;;var
         (envlookup env (var-string e))]

        ;; addition
        
        [(add? e) 
         (let ([v1 (eval-under-env (add-e1 e) env)]
               [v2 (eval-under-env (add-e2 e) env)])
           (if (and (int? v1)
                    (int? v2))
               (int (+ (int-num v1) 
                       (int-num v2)))
               (error "MUPL addition applied to non-number")))]

        ;; integer
        
        [(int? e) e]

        ;; aunit(null)
        
        [(aunit? e) e]

        ;; closure
        
        [(closure? e) e]

        ;; ifgreater
        
        [(ifgreater? e)
         (let ([v1 (eval-under-env (ifgreater-e1 e) env)]
               [v2 (eval-under-env (ifgreater-e2 e) env)])
           (if (and (int? v1)
                    (int? v2))
               (if (> (int-num v1) (int-num v2))
                   (eval-under-env (ifgreater-e3 e) env)
                   (eval-under-env (ifgreater-e4 e) env))
               (error "MUPL ifgreater applied to non-number")))]

        ;; fun
        [(fun? e)
         (closure env e)]

        ;; call the fun with env
        
        [(call? e)
         (let ([v1 (eval-under-env (call-funexp e) env)]
               [v2 (eval-under-env (call-actual e) env)])

               (if (closure? v1)
                   (let ([fun-name (fun-nameopt (closure-fun v1))]
                         [argument-name (fun-formal (closure-fun v1))]
                         [fun_body (fun-body (closure-fun v1))])
                         (eval-under-env fun_body (append (if fun-name
                                                              (list (cons fun-name v1))
                                                              null)
                                                          (cons (cons argument-name v2) (closure-env v1)))))
                     (error "It is not a closure")))]

        ;; mlet
        
        [(mlet? e)
         (let ([v (eval-under-env (mlet-e e) env)])
           (eval-under-env (mlet-body e) (append (list (cons (mlet-var e) v)) env)))]

        ;; pair
        
        [(apair? e)
         (let ([v1 (eval-under-env (apair-e1 e) env)]
               [v2 (eval-under-env (apair-e2 e) env)])
           (apair v1 v2))]

        ;; first value of the pair
        
        [(fst? e)
         (let ([v (eval-under-env (fst-e e) env)])
           (if (apair? v)
               (apair-e1 v)
               (error "fst doesn't work for non pair")))]

        ;; second value of the pair
        
        [(snd? e)
         (let ([v (eval-under-env (snd-e e) env)])
           (if (apair? v)
               (apair-e2 v)
               (error "snd doesn't work for non pair")))]

        ;; isaunit
        
        [(isaunit? e)
         (let ([v (eval-under-env (isaunit-e e) env)])
           (if (aunit? v)
               (int 1)
               (int 0)))]
         
        ;; true for all other results
        
        [#t (error (format "bad MUPL expression: ~v" e))]))

;; evaluate expression

(define (eval-exp e)
  (eval-under-env e null))
        
;; additional extended functions

(define (ifaunit e1 e2 e3)
  (ifgreater (isaunit e1) (int 0) e2 e3))

(define (mlet* lstlst e2)
  (if (null? lstlst)
      e2
      (mlet (car (car lstlst)) (cdr (car lstlst))
            (mlet* (cdr lstlst) e2)))
  )

(define (ifeq e1 e2 e3 e4)
  (mlet* (list (cons "_x" e1) (cons "_y" e2))
         (ifgreater (var "_x") (var "_y") e4
                    (ifgreater (var "_y") (var "_x") e4 e3))))

;; map

(define mupl-map
  (fun "map" "f"
       (fun #f "mlist"
            (ifaunit (var "mlist")
                     (aunit)
                     (apair (call (var "f") (fst (var "mlist")))
                            (call (call (var "map") (var "f"))
                                  (snd (var "mlist"))))))))

(define mupl-mapAddN 
  (mlet "map" mupl-map
        (fun #f "n"
             (call (var "map") (fun #f "x"
                                    (add (var "x") (var "n")))))))


