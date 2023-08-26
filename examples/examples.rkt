;; racketlist to mupllist with normal list
(racketlist->mupllist (list (int 3) (int 4)))  ;;output => (apair (int 3) (apair (int 4) (aunit)))

;; mupllist to racketlist with normal list
(mupllist->racketlist (apair (int 3) (apair (int 4) (aunit)))) ;;output => (list (int 3) (int 4))

;; ifgreater returns (int 2)
(eval-exp (ifgreater (int 3) (int 4) (int 3) (int 2))) ;;output => (int 2)
   
;; mlet 
(eval-exp (mlet "x" (int 1) (add (int 5) (var "x")))) ;;output => (int 6)

;; call 
(eval-exp (call (closure '() (fun #f "x" (add (var "x") (int 7)))) (int 1))) ;;output => (int 8) 
   
;; snd 
(eval-exp (snd (apair (int 1) (int 2)))) ;;output => (int 2) 
   
;; isaunit
(eval-exp (isaunit (closure '() (fun #f "x" (aunit))))) ;;output => (int 0) 
   
;; ifaunit 
(eval-exp (ifaunit (int 1) (int 2) (int 3))) ;;output => (int 3)
   
;; mlet* 
(eval-exp (mlet* (list (cons "x" (int 10))) (var "x"))) ;;output => (int 10)
   
;; ifeq 
(eval-exp (ifeq (int 1) (int 2) (int 3) (int 4))) ;;output => (int 4) 
   
;; mupl-map 
(eval-exp (call (call mupl-map (fun #f "x" (add (var "x") (int 7)))) (apair (int 1) (aunit)))) ;;output => (apair (int 8) (aunit)) 
   

   
