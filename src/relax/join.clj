(ns ^{:author "Zenna Tavares"
      :doc "Join"}
  ; "Join (abstract interpretation)
  ;  Joining takes two abstract objects in some domain and returns
  ;  another abstract object within the same domain."
  relax.join
  (:require [relax.common :refer :all]
            [clojure.walk :refer :all]))

; There are a number of important questions to resolve:
; 1. What precisely can I join

; 2. What should I join, what is the objective?
; Joining objects is to reduce the complexity.  Our goal is to
; reduce the program to a maneagable complexity, limiting the amount of 
; over approximation as much as possible

; 3. When joining two abstract objects say a and b, do I need to consider
; other objects, abstract or otherwise?
; Yes, other abstract objects may through the interactions in the program
; determine whether it is wise or not to join a and b.
; There are likely too many interactions to consider them all individually,
; so some alternative strategy is required.

; 4. How will joining, or deciding to join, be affected by other
; processes such as the refinement stage that happens afterwards.
; Well They are highly related.  We can view it as a two stage process, in which case,
; when joining we could either just assume that the following process
; will just improve whatever we've done already and so for all intents and purposes
; we can ignore it and just do our job.

; Or we can try to understand the implications,
; for the following stage.  At the most basic level this could be some rules we hard code 
; into the joiner which affect its decision makking based on observatiosn we've (as humans)
; seen.  Or it could learn

; More generally you could think of joinng and refining as two tool kits in the hands of the 
; interpreter and we should give it autonomy to do as it pleases.  This is
; much more complex and fits in line with stage 2.

; 4. How to join in practise?
; Well, my running

; Option 1. Somehow do normal evaluation until I reach a budget.
; How can I know if i've reached a budget?
; Once I've reached a budget how can I backtrack?
; Thi would interoduce an arbitrary order dependence.
;1 
(defn join?
  [obj]
  (tagged-list? obj 'join-obj))

(defn make-join
  [args]
  `(~'join-obj ~(set args)))

(defn join-substitute
  "Take an expression and join some terms in it
   joins is '[[a b c][d e]"
  [program joins]
  (postwalk-replace
    (apply merge
      (mapv
        (fn [join-set]
          (zipmap join-set
                  (repeat (count join-set) `(~'join ~@join-set))))
        joins))
    program))

(def prog
  '(and (>= x0 0.9) (<= x0 1.1) (>= y0 0.9) (<= y0 1.1) (>= x2 8.9) (<= x2 9.1) (>= y2 8.9) (<= y2 9.1) (>= (+ x1 (* -1 x0)) 0) (<= (+ x1 (* -1 x0)) 5) (>= (+ x2 (* -1 x1)) 0) (<= (+ x2 (* -1 x1)) 5) (or (<= x0 2) (>= x0 5) (<= y0 5) (>= y0 7)) (or (<= x0 5) (>= x0 8) (<= y0 0) (>= y0 3)) (or (<= x1 2) (>= x1 5) (<= y1 5) (>= y1 7)) (or (<= x1 5) (>= x1 8) (<= y1 0) (>= y1 3)) (or (<= x2 2) (>= x2 5) (<= y2 5) (>= y2 7)) (or (<= x2 5) (>= x2 8) (<= y2 0) (>= y2 3))))