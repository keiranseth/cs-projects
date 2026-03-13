;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname ohhi) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)

;; 0h h1


;; 0h h1 Solver
;; In 0h h1, a board is an n x n grid of blocks.
;; The goal is to fill the board with blue and yellow
;; blocks such that
;;  - no row and no column has three consecutive blocks of the same color, and
;;  - each row and column has the same number of blue and yellow blocks.



;; Structures

;; Block is one of:
;; - "B",
;; - "Y", and
;; - "N".
;; These are the blocks of the game, where
;; - "B" represents the blue blocks,
;; - "Y" represents the yellow blocks and
;; - "N" represents a null block.

;; SideLength is an integer(>=2). 
;; It represents the side length of the board.

;; Position is an integer[0, s^2 - 1].
;; It represents a 0-index position of a block on the board.
;; Given the board of side length s, the position can range from 0 to s^2 - 1.

;; PosList is (listof Position).
;; It represents all Positions of a board.
;; Given the board of side length s, the poslist is [0, ..., s^2 - 1].

;; Board is (listof Block).
;; It represents all the current blocks of the board, where
;; the Block's list position in the board is its actual Position.



;; Constants

(define B "B")
(define Y "Y")
(define N "N")

(define MTBY4
  (list N N N N
        N N N N
        N N N N
        N N N N))

(define BY4-p1
  (list N N B B
        N N B N
        N N N N
        N Y N N))
(define BY4-s1
  (list Y Y B B
        Y B B Y
        B B Y Y
        B Y Y B))

(define BY4-p2
  (list N N N B
        B B N N
        N N B B
        N B N N))
(define BY4-s2
  (list B Y Y B
        B B Y Y
        Y Y B B
        Y B B Y))

(define MTBY6
  (list N N N N N N
        N N N N N N
        N N N N N N
        N N N N N N
        N N N N N N
        N N N N N N))

(define BY6-p1
  (list N N B  N N N
        N N N  N N N
        Y N N  Y B N
        
        N N N  Y N N
        N N N  N B N
        Y Y N  B N N))
(define BY6-s1
  (list B Y B  Y B Y
        B B Y  B Y Y
        Y B Y  Y B B
        
        B Y B  Y Y B
        Y B Y  B B Y
        Y Y B  B Y B))
(define MTBY8
  (list N N N N N N N N
        N N N N N N N N
        N N N N N N N N
        N N N N N N N N
        N N N N N N N N
        N N N N N N N N
        N N N N N N N N
        N N N N N N N N))
(define BY8-p1
  (list N N N N  B N N N
        N B N N  N N N N
        Y N N N  N N N B
        N N Y N  B N N N
        
        N B N Y  N Y N B
        N N N N  N N N N
        N N Y Y  N N N N
        N B N N  N N N N))
(define BY8-s1
  (list B Y Y B  B Y Y B
        Y B B Y  Y B B Y
        Y Y B B  Y B Y B
        B Y Y B  B Y B Y
        
        Y B B Y  B Y Y B
        B Y Y B  Y B B Y
        B B Y Y  B Y B Y
        Y B B Y  Y B Y B))



;; Program Logic

;; Board -> Board or #f
;; Return a solution for the given board.
;; If impossible, return false.
;; Assume: given board is valid.
(check-expect (solve BY4-p1) BY4-s1)
(check-expect (solve BY4-p2) BY4-s2)
(check-expect (solve BY6-p1) BY6-s1)
(check-expect (solve BY8-p1) BY8-s1)

;(define (solve bd) bd)

(define (solve bd)
  (local [(define (solve--bd bd)
            (if (solved? bd)
                bd
                (solve--lobd (next-boards bd))))
          (define (solve--lobd lobd)
            (cond [(empty? lobd) #f]
                  [else
                   (local [(define try (solve--bd (first lobd)))]
                     (if (not (false? try))
                         try
                         (solve--lobd (rest lobd))))]))]
    (solve--bd bd)))


;; Board -> boolean
;; Return true if the given board is solved. That is,
;; if there are no more null blocks.
;; (Why? Because the next-boards will only produce
;; valid next boards. Thus, if it produces a full board,
;; where there are no more null blocks, it is a valid solution.)
(check-expect (solved? BY4-p1) #f)
(check-expect (solved? BY4-s1) #t)
(check-expect (solved? BY6-p1) #f)
(check-expect (solved? BY6-s1) #t)

;(define (solved? bd) #f)

(define (solved? bd)
  (no-null-block? bd))


;; Board -> (listof Board)
;; Given a board, return a list of valid boards which
;; serve as a progression towards solving the given board.
;; The resulting boards must be valid solutions. That is,
;;  - each resulting board must have has less null blocks than the given board,
;;  - each resulting board do not have three consecutive blocks of the same color, and
;;  - if given a solved board, return an empty list.
(check-expect (next-boards (list N N N N
                                 N N N N
                                 N N N N
                                 N N N N))
              (list (list B N N N
                          N N N N
                          N N N N
                          N N N N)
                    (list Y N N N
                          N N N N
                          N N N N
                          N N N N)))
(check-expect (next-boards (list Y N N N
                                 N N B N
                                 N N N Y
                                 N B N Y))
              (list (list Y B N N
                          N N B N
                          N N N Y
                          N B N Y)
                    (list Y Y N N
                          N N B N
                          N N N Y
                          N B N Y)))
(check-expect (next-boards (list Y Y B B
                                 B B Y Y
                                 N Y N Y
                                 Y B N N))
              (list (list Y Y B B
                          B B Y Y
                          B Y N Y
                          Y B N N)))
(check-expect (next-boards (list B B Y Y
                                 B Y B Y
                                 Y N Y B
                                 N N B B))
              (list (list B B Y Y
                          B Y B Y
                          Y B Y B
                          N N B B)))
(check-expect (next-boards (list Y B B Y
                                 Y N B N
                                 B Y Y N
                                 B Y Y B))
              '())

;(define (next-boards bd) '())

(define (next-boards bd)
  (local [
          (define (is-board-valid? bd0)
            (and (is-no-three-next? bd0)
                 (is-colors-valid? bd0)
                 (are-units-unique? bd0)))
          ]
    (filter is-board-valid?
            (map (lambda (b)
                   (write-board bd
                                (get-first-null bd)
                                b))
                 (list B Y)))))


;; Board -> Boolean
;; Given a board, return true if no column or row
;; are identical in placement of colored blocks.
;; That is, block lists must be unique among rows (columns).
(check-expect (are-units-unique? (list N N N N
                                       N N N N
                                       N N N N
                                       N N N N))
              #t)
(check-expect (are-units-unique? (list N N N N
                                       N B Y N
                                       N B Y N
                                       N N N N))
              #t)
(check-expect (are-units-unique? (list B B B B
                                       B B B B
                                       B B B B
                                       B B B B))
              #f)
(check-expect (are-units-unique? (list Y Y Y Y
                                       Y Y Y Y
                                       Y Y Y Y
                                       Y Y Y Y))
              #f)
(check-expect (are-units-unique? (list Y B B Y
                                       Y B B Y
                                       B Y Y B
                                       B Y Y B))
              #f)
(check-expect (are-units-unique? (list Y B B Y
                                       Y Y B B
                                       B B Y Y
                                       B Y Y B))
              #t)

;(define (are-units-unique? bd) #f)

(define (are-units-unique? bd)
  (local [(define ROW-VALUES
            (get-unit-values bd (get-row-posns bd)))
          (define COL-VALUES
            (get-unit-values bd (get-col-posns bd)))
          (define (units-distinct? bl1 bl2)
            (ormap (lambda (b1 b2)
                     (or (string=? b1 N)
                         (string=? b2 N)
                         (not (string=? b1 b2))))
                   bl1 bl2))
          (define (compare-rows bl bls)
            (cond [(empty? bls) #t]
                  [else
                   (and (units-distinct? bl (first bls))
                        (compare-rows bl (rest bls)))]))
          (define (no-identical-rowcols? bl)
            (cond [(empty? bl) #t]
                  [else
                   (and (compare-rows (first bl)
                                      (rest bl))
                        (no-identical-rowcols? (rest bl)))]))]
    (and (no-identical-rowcols? ROW-VALUES)
         (no-identical-rowcols? COL-VALUES))))



;; Board -> Boolean
;; Given a board, return true if no column or row
;; has an unequal number of colors. That is,
;; the number of yellow blocks and blue
;; blocks must be equal.
(check-expect (is-colors-valid? (list N N N N
                                      N N N N
                                      N N N N
                                      N N N N))
              #t)
(check-expect (is-colors-valid? (list B B Y Y
                                      B Y B Y
                                      Y B Y B
                                      Y Y B B))
              #t)
(check-expect (is-colors-valid? (list B B Y Y
                                      B Y B N
                                      Y N Y Y
                                      B Y Y B))
              #f)
(check-expect (is-colors-valid? (list B B Y Y
                                      N B B Y
                                      Y B Y B
                                      B Y Y B))
              #f)

;(define (is-colors-valid? bd) #f)

(define (is-colors-valid? bd)
  (local [(define UNIT-VALUES
            (get-unit-values bd (get-unit-posns bd)))
          (define SIDE-LENGTH
            (get-side-length bd))
          (define COLOR-LIMIT
            (/ SIDE-LENGTH 2))

          (define-struct colorcount (blue yellow))
          
          (define (count-colors bl)
            (local [(define (count-colors bl colcount)
                      (cond [(empty? bl) colcount]
                            [(string=? (first bl) B)
                             (count-colors (rest bl)
                                           (make-colorcount (add1 (colorcount-blue colcount))
                                                            (colorcount-yellow colcount)))]
                            [(string=? (first bl) Y)
                             (count-colors (rest bl)
                                           (make-colorcount (colorcount-blue colcount)
                                                            (add1 (colorcount-yellow colcount))))]
                            [else
                             (count-colors (rest bl)
                                           colcount)]))]
              (count-colors bl (make-colorcount 0 0))))
          
          (define (is-colors-valid0? bl)
            (and (<= (colorcount-blue (count-colors bl)) COLOR-LIMIT)
                 (<= (colorcount-yellow (count-colors bl)) COLOR-LIMIT)))]
    (andmap is-colors-valid0? UNIT-VALUES)))



;; Board -> Boolean
;; Given a board, return true if no column or row
;; has three consecutive blocks of the same color.
(check-expect (is-no-three-next? (list N N N N
                                       N N N N
                                       N N N N
                                       N N N N))
              #t)
(check-expect (is-no-three-next? (list B B B B
                                       B B B B
                                       B B B B
                                       B B B B))
              #f)
(check-expect (is-no-three-next? (list Y Y Y Y
                                       Y Y Y Y
                                       Y Y Y Y
                                       Y Y Y Y))
              #f)
(check-expect (is-no-three-next? (list B B Y Y
                                       B Y B Y
                                       Y B Y B
                                       N N Y B))
              #t)
(check-expect (is-no-three-next? (list B B Y Y
                                       B Y B Y
                                       Y Y Y B
                                       N N Y B))
              #f)
(check-expect (is-no-three-next? (list B B Y Y
                                       B Y B B
                                       Y B Y B
                                       N N Y B))
              #f)

;(define (is-no-three-next? bd) #f)

(define (is-no-three-next? bd)
  (local [(define UNIT-VALUES
            (get-unit-values bd (get-unit-posns bd)))
          (define (is-no-three-consecutive? bl)
            (local [(define (helper bl0 prev3 prev2 prev1)
                      (cond [(empty? bl0) (or (not (string=? prev3 prev2 prev1))
                                              (string=? N prev3 prev2 prev1))]
                            [else
                             (and (or (not (string=? prev3 prev2 prev1))
                                      (string=? N prev3 prev2 prev1))
                                  (helper (rest bl0)
                                          prev2 prev1 (first bl0)))])
                      )]
              (helper (rest (rest (rest bl)))
                      (first bl)
                      (first (rest bl))
                      (first (rest (rest bl))))))]
    (andmap is-no-three-consecutive? UNIT-VALUES)
    ))


;; Board or (listof Block) -> boolean
;; Return #t the given structure has a null block.
;; Else, return #f.
(check-expect (no-null-block? (list B Y N B)) #f)
(check-expect (no-null-block? (list B Y Y B)) #t)

;(define (no-null-block? bl) #f)

(define (no-null-block? bl)
  (cond [(empty? bl) #t]
        [else
         (if (string=? (first bl) N)
             #f
             (no-null-block? (rest bl)))]))


;; Board (listof (listof Position)) -> (listof (listof Block))
;; Given a board and a list of PositionLists, return
;; a list of BlockLists.
(check-expect (get-unit-values (list B B Y Y
                                     Y B Y B
                                     N Y B N
                                     N N N N)
                               (list (list 0 1 2 3)
                                     (list 4 5 6 7)
                                     (list 0 4 8 12)
                                     (list 1 5 9 13)))
              (list (list B B Y Y)
                    (list Y B Y B)
                    (list B Y N N)
                    (list B B Y N)))

;(define (get-unit-values bd llp) '())

(define (get-unit-values bd llp)
  (local [(define (get-block-list lp)
            (cond [(empty? lp) '()]
                  [else
                   (cons (read-block bd (first lp))
                         (get-block-list (rest lp)))]))]
    (map get-block-list
         llp)))


;; Board -> (listof Position)
;; Return the list of all units.
(check-expect (get-unit-posns (list B B Y Y
                                    Y B Y B
                                    N Y B N
                                    N N N N))
              (append (list (list 0 4 8 12)
                            (list 1 5 9 13)
                            (list 2 6 10 14)
                            (list 3 7 11 15))
                      (list (list 0 1 2 3)
                            (list 4 5 6 7)
                            (list 8 9 10 11)
                            (list 12 13 14 15))))
(check-expect (get-unit-posns (list B B Y Y B B
                                    Y B Y B Y B
                                    N Y B N N B
                                    N N N N N N
                                    N N N N N N
                                    N N N N N N))
              (append (list (list 0 6 12 18 24 30)
                            (list 1 7 13 19 25 31)
                            (list 2 8 14 20 26 32)
                            (list 3 9 15 21 27 33)
                            (list 4 10 16 22 28 34)
                            (list 5 11 17 23 29 35))
                      (list (list 0 1 2 3 4 5)
                            (list 6 7 8 9 10 11)
                            (list 12 13 14 15 16 17)
                            (list 18 19 20 21 22 23)
                            (list 24 25 26 27 28 29)
                            (list 30 31 32 33 34 35))))

;(define (get-unit-posns bd) '())

(define (get-unit-posns bd)
  (append (get-col-posns bd)
          (get-row-posns bd)))


;; Board -> (listof Position)
;; Return the list of positions, with each list having positions
;; in the same column.
(check-expect (get-col-posns (list B B Y Y
                                   Y B Y B
                                   N Y B N
                                   N N N N))
              (list (list 0 4 8 12)
                    (list 1 5 9 13)
                    (list 2 6 10 14)
                    (list 3 7 11 15)))
(check-expect (get-col-posns (list B B Y Y B B
                                   Y B Y B Y B
                                   N Y B N N B
                                   N N N N N N
                                   N N N N N N
                                   N N N N N N))
              (list (list 0 6 12 18 24 30)
                    (list 1 7 13 19 25 31)
                    (list 2 8 14 20 26 32)
                    (list 3 9 15 21 27 33)
                    (list 4 10 16 22 28 34)
                    (list 5 11 17 23 29 35)))

;(define (get-col-posns bd) '())

(define (get-col-posns bd)
  (local [(define SL
            (get-side-length bd))
          (define COL-STARTS
            (build-list SL identity))
          (define REST-OF-COLS
            (map (lambda (i) (build-list SL
                                         (lambda (j) (+ (* j SL) i))))
                 COL-STARTS))]
    REST-OF-COLS))

;; Board -> (listof Position)
;; Return the list of positions, with each list having positions
;; in the same row.
(check-expect (get-row-posns (list B B Y Y
                                   Y B Y B
                                   N Y B N
                                   N N N N))
              (list (list 0 1 2 3)
                    (list 4 5 6 7)
                    (list 8 9 10 11)
                    (list 12 13 14 15)))
(check-expect (get-row-posns (list B B Y Y B B
                                   Y B Y B Y B
                                   N Y B N N B
                                   N N N N N N
                                   N N N N N N
                                   N N N N N N))
              (list (list 0 1 2 3 4 5)
                    (list 6 7 8 9 10 11)
                    (list 12 13 14 15 16 17)
                    (list 18 19 20 21 22 23)
                    (list 24 25 26 27 28 29)
                    (list 30 31 32 33 34 35)))

;(define (get-row-posns bd) '())

(define (get-row-posns bd)
  (local [(define SL
            (get-side-length bd))
          (define ROW-STARTS
            (build-list SL (lambda (x) (* x SL))))
          (define REST-OF-ROWS
            (map (lambda (i) (build-list SL
                                         (lambda (j) (+ j i))))
                 ROW-STARTS))]
    REST-OF-ROWS))



;; Board -> Integer
;; Return the number of Positions in the given board.
(check-expect (get-size (list)) 0)
(check-expect (get-size MTBY4) 16)
(check-expect (get-size MTBY6) 36)
(check-expect (get-size MTBY8) 64)

;(define (get-size bd) 0)

(define (get-size bd)
  (cond [(empty? bd) 0]
        [else
         (+ 1
            (get-size (rest bd)))]))

;; Board -> Integer
;; Return the side length of the given board.
(check-expect (get-side-length '()) 0)
(check-expect (get-side-length MTBY4) 4)
(check-expect (get-side-length MTBY6) 6)
(check-expect (get-side-length MTBY8) 8)

;(define (get-side-length bd) 100)

(define (get-side-length bd)
  (sqrt (get-size bd)))


;; Board Block -> Position or #f
;; Return the first Position, p, that matches the given Block, b.
;; Else, return #f.
(check-expect (get-first-block (list B B Y Y
                                     B Y B Y
                                     Y N Y B
                                     N N Y B)
                               B)
              0)
(check-expect (get-first-block (list N N Y Y
                                     B Y B Y
                                     Y N Y B
                                     N N Y B)
                               B)
              4)
(check-expect (get-first-block (list B B Y Y
                                     B Y B Y
                                     Y N Y B
                                     N N Y B)
                               Y)
              2)
(check-expect (get-first-block (list B B Y Y
                                     B Y B Y
                                     Y N Y B
                                     N N Y B)
                               N)
              9)
(check-expect (get-first-block (list B B Y Y
                                     B Y B Y
                                     Y B Y B
                                     B Y Y B)
                               N)
              #f)

;(define (get-first-block bd b) #f)

(define (get-first-block bd b)
  (local [(define (get-first-block0 bd0 i)
            (cond [(empty? bd0) #f]
                  [else
                   (local [(define current-elt (first bd0))]
                     (if (string=? current-elt b)
                         i
                         (get-first-block0 (rest bd0) (+ i 1))))]))]
    (get-first-block0 bd 0)))


;; Board -> Position or #f
;; Return the Position of the first null block.
;; Else, return #f.
(check-expect (get-first-null (list N B Y Y
                                    B Y B Y
                                    Y N Y B
                                    N N Y B))
              0)
(check-expect (get-first-null (list B B Y Y
                                    B Y B Y
                                    Y N Y B
                                    N N Y B))
              9)
(check-expect (get-first-null (list B B Y Y
                                    B Y B Y
                                    Y B Y B
                                    Y B Y N))
              15)
(check-expect (get-first-null BY4-s1) #f)

;(define (get-first-null bd) #f)
#;
(define (get-first-null bd)
  (local [(define (get-first-null0 bd0 i)
            (cond [(empty? bd0) #f]
                  [else
                   (local [(define current-elt (first bd0))]
                     (if (string=? current-elt N)
                         i
                         (get-first-null0 (rest bd0) (+ i 1))))]))]
    (get-first-null0 bd 0)))

(define (get-first-null bd)
  (local []
    (get-first-block bd N)))


;; Board Position -> Block
;; Return the Block in the given Position on the Board.
(check-expect (read-block (list N B Y Y
                                B Y B Y
                                Y N Y B
                                N N Y B)
                          0) N)
(check-expect (read-block (list N B Y Y
                                B Y B Y
                                Y N Y B
                                N N Y B)
                          11) B)
(check-expect (read-block (list N B Y Y
                                B Y B Y
                                Y N Y B
                                N N Y B)
                          14) Y)
(check-expect (read-block (list N B Y Y
                                B Y B Y
                                Y N Y B
                                N N Y B)
                          15) B)

;(define (read-block bd p) (first bd))

(define (read-block bd p)
  (cond [(zero? p) (first bd)]
        [else
         (read-block (rest bd) (- p 1))]))


;; Board Position Block -> Board
;; Write the given board, b, in the given position, p,
;; on the given board, bd.
;; Note: The given Position will always pertain to a valid
;;       Position in the given Board.
;;                             board
;;                    empty             (cons first rest)
;;
;;            0       IMPOSSIBLE        (cons Block rest)
;;
;;Position
;;
;;           >0       IMPOSSIBLE        (recurse on rest and i - 1)
(check-expect (write-board (list B B Y Y
                                 B Y B Y
                                 Y N Y B
                                 N N Y B)
                           3 B)
              (list B B Y B
                    B Y B Y
                    Y N Y B
                    N N Y B))
(check-expect (write-board (list B B Y Y
                                 B Y B Y
                                 Y N Y B
                                 N N Y B)
                           12 B)
              (list B B Y Y
                    B Y B Y
                    Y N Y B
                    B N Y B))

;(define (write-board bd p b) bd)

(define (write-board bd p b)
  (cond [(zero? p) (cons b (rest bd))]
        [else
         (cons (first bd)
               (write-board (rest bd)
                            (- p 1) b))]))



;; 0hh1 Renderer


;; Assets

(define BLOCK-SIZE 54)
(define BLU (square BLOCK-SIZE "solid" "Blue"))
(define YLW (square BLOCK-SIZE "solid" "Yellow"))
(define NUL (square BLOCK-SIZE "solid" "Light Gray"))
(define BLOCK-GAP (square 8 "solid" "White"))
(define BOARD-GAP (square 32 "solid" "White"))
(define ARROW
  (beside (rectangle 90 11 "solid" "Black")
          (rotate -90 (triangle 27 "solid" "Black"))))


;; Rendering Functions

;; Board -> Image
;; Render the given 0hh1 board.
(check-expect (render-board (list B Y
                                  Y B))
              (above (beside BLU BLOCK-GAP YLW)
                     BLOCK-GAP
                     (beside YLW BLOCK-GAP BLU)))
(check-expect (render-board (list B B Y N
                                  Y N N B
                                  N Y B Y
                                  Y B Y B))
              (above (beside BLU BLOCK-GAP BLU BLOCK-GAP YLW BLOCK-GAP NUL)
                     BLOCK-GAP
                     (beside YLW BLOCK-GAP NUL BLOCK-GAP NUL BLOCK-GAP BLU)
                     BLOCK-GAP
                     (beside NUL BLOCK-GAP YLW BLOCK-GAP BLU BLOCK-GAP YLW)
                     BLOCK-GAP
                     (beside YLW BLOCK-GAP BLU BLOCK-GAP YLW BLOCK-GAP BLU)))
(check-expect (render-board (list B B Y Y
                                  Y Y B B
                                  B Y B Y
                                  Y B Y B))
              (above (beside BLU BLOCK-GAP BLU BLOCK-GAP YLW BLOCK-GAP YLW)
                     BLOCK-GAP
                     (beside YLW BLOCK-GAP YLW BLOCK-GAP BLU BLOCK-GAP BLU)
                     BLOCK-GAP
                     (beside BLU BLOCK-GAP YLW BLOCK-GAP BLU BLOCK-GAP YLW)
                     BLOCK-GAP
                     (beside YLW BLOCK-GAP BLU BLOCK-GAP YLW BLOCK-GAP BLU)))

;(define (render-board bd) empty-image)

(define (render-board bd)
  (local [
          (define SIDE-LENGTH (get-side-length bd))
          (define ROW-VALUES (get-unit-values bd
                                              (get-row-posns bd)))
          (define (render-block bl)
            (cond [(string=? bl N) NUL]
                  [(string=? bl Y) YLW]
                  [(string=? bl B) BLU]))
          (define (render-one-row rw)
            (cond [(empty? rw) empty-image]
                  [else
                   (local [(define fblock (first rw))
                           (define rblocks (rest rw))]
                     (beside (render-block fblock)
                             (if (empty? rblocks)
                                 empty-image
                                 BLOCK-GAP)
                             (render-one-row rblocks)))]))
          (define (render-board0 rws)
            (cond [(empty? rws) empty-image]
                  [else
                   (local [(define frow (first rws))
                           (define otrows (rest rws))]
                     (above (render-one-row frow)
                            (if (empty? otrows)
                                empty-image
                                BLOCK-GAP)
                            (render-board0 otrows)))]))
          ]
    (render-board0 ROW-VALUES)))




;; 0hh1 Solver with Renderer

;; Board -> Image
;; Return the original and the solved versions of the given board.
(check-expect (solver-with-renderer (list Y N Y N
                                          N N N B
                                          N N N N
                                          N N Y N))
              (beside/align "middle"
                            (render-board (list Y N Y N
                                                N N N B
                                                N N N N
                                                N N Y N))
                            BOARD-GAP
                            ARROW
                            BOARD-GAP
                            (render-board (list Y B Y B
                                                Y Y B B
                                                B Y B Y
                                                B B Y Y))))

(define (solver-with-renderer bd)
  (beside/align "middle"
                (render-board bd)
                BOARD-GAP
                ARROW
                BOARD-GAP
                (render-board (solve bd))))

(define (solver-with-renderer-nw bd)
  (big-bang bd
    [to-draw solver-with-renderer]))

#;
(solver-with-renderer-nw (list Y N Y N
                               N N N B
                               N N N N
                               N N Y N))
#;
(solver-with-renderer-nw (list Y N Y  N N N
                               N N Y  N Y B
                               N N N  N N N

                               N N Y  N N N
                               N N N  B N N
                               N N N  N Y Y))
#;
(solver-with-renderer-nw (list N N Y N  N N B N
                               N N N B  N B B N
                               B N N N  N N N N
                               N N Y Y  N N N N

                               N B N N  N Y N N
                               N N Y N  N N N Y
                               N N N N  N N N N
                               N Y N N  N Y N N))
#;
(solver-with-renderer-nw (list N N N Y N  Y N N N N
                               N N N N B  N Y N B N
                               B N B N N  N Y Y N N
                               N Y N N N  N N N N B
                               B B N Y N  N N N N N

                               N N B N N  N Y B Y Y
                               N B N B N  N N N N N
                               N N N N B  Y N N N N
                               B N N N N  Y Y N Y Y
                               N N N Y N  N N B N N))
#;
(solver-with-renderer-nw (list N N Y Y N N  N B N Y N N
                               Y N N N N N  Y N N Y N N
                               N Y N N B N  N B N N N N
                               N N Y N N N  N N N N N B
                               N N N N N N  N N N N B N
                               N B B N N N  N Y Y N N N

                               N N N N N N  N Y Y N Y N
                               B N N N N N  N N N N N Y
                               N B N N B B  N N Y N N N
                               N N Y N B N  N N N Y N Y
                               Y N N N N N  N N N N N N
                               N B N B N N  Y Y N N N Y))