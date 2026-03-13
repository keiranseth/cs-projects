# TA Solver

This final project serves as the last project/exam. We are assigned to write a program which solves a TA-scheduling problem given a set of TAs and slots.

Close this page if you're taking the course and have not completed your implementation of this project yet.

## Project

-   See [`ta-solver-ms.rkt`](./ta-solver-ms.rkt) to see my solution with detailed comments and scratchwork.
-   See [`ta-solver-fv.rkt`](./ta-solver-fv.rkt) to see my solution in perfect submission quality.

## Problem

From HTC: Complex Data

> In UBC's version of How to Code, there are often more than 800 students taking the course in any given semester, meaning there are often over 40 Teaching Assistants.
>
> Designing a schedule for them by hand is hard work - luckily we've learned enough now to write a program to do it for us!
>
> Below are some data definitions for a simplified version of a TA schedule. There are some number of slots that must be filled, each represented by a natural number. Each TA is available for some of these slots, and has a maximum number of shifts they can work.
>
> Design a search program that consumes a list of TAs and a list of Slots, and produces one valid schedule where each Slot is assigned to a TA, and no TA is working more than their maximum shifts. If no such schedules exist, produce false.
>
> You should supplement the given check-expects and remember to follow the recipe!

## Data Definitions

From HTC: Complex Data

```rkt
;; Slot is Natural
;; interp. each TA slot has a number, is the same length, and none overlap

(define-struct ta (name max avail))
;; TA is (make-ta String Natural (listof Slot))
;; interp. the TA's name, number of slots they can work, and slots they're available for

(define SOBA (make-ta "Soba" 2 (list 1 3)))
(define UDON (make-ta "Udon" 1 (list 3 4)))
(define RAMEN (make-ta "Ramen" 1 (list 2)))
(define MOCHI (make-ta "Mochi" 2 (list 4 5 6)))

(define NOODLE-TAs (list SOBA UDON RAMEN))



(define-struct assignment (ta slot))
;; Assignment is (make-assignment TA Slot)
;; interp. A TA is assigned to work the given slot.

;; Schedule is (listof Assignment)
```

## Functions

```rkt
;; (listof TA) (listof Slot) -> Schedule or false
;; produce valid schedule given TAs and Slots; false if impossible
```

```rkt
;; Schedule (listof Slot) -> Boolean
;; Return #t if the given schedule fulfills all
;; the given slots. Remember not all TAs have
;; to be assigned, but all slots must be assigned.
;; Important: next-assignments does not filter out
;;            schedules where TAs are over-assigned slots.
;;            solved? has to take care of this problem.
;; 1. Check if every slot is assigned.
;; 2. Check if every TA in the schedule is NOT over-assigned.
```

```rkt
;; Schedule (listof TA) Slot -> (listof Schedule)
;; Return all possible schedules from the given
;; set of TAs for the given slot.
;; 0. Add new assignments to given schedule.
;;    - There's more than one, and thus for every possible
;;      set of TA assignments, make a new sched.
;; 1. Filter out TAs that cannot be assigned.
;; 2. Make an assignment per assignable TA.
;; 3. Map each new assignment to the old schedule.
```
