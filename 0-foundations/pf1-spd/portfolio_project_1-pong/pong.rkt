;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname pong) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; Simple Pong

(require 2htdp/image)
(require 2htdp/universe)
(require racket/random)


;; Constant Definitions

(define DVDR-COLOR "White")
(define DVDR-WIDTH 1)
(define DVDR-STYLE "solid")
(define DVDR-CAP "butt")
(define DVDR-JOIN "bevel")

(define BG-WIDTH 1080)
(define BG-HEIGHT (* BG-WIDTH 9/16))
(define BG-COLOR "Black")
(define BACKGROUND (add-line (empty-scene BG-WIDTH
                                          BG-HEIGHT
                                          BG-COLOR)
                             (/ BG-WIDTH 2) 0
                             (/ BG-WIDTH 2) BG-HEIGHT
                             (pen DVDR-COLOR
                                  DVDR-WIDTH
                                  DVDR-STYLE
                                  DVDR-CAP
                                  DVDR-JOIN)))

(define PADDLE-WIDTH (/ BG-WIDTH 40))
(define PADDLE-HEIGHT (* PADDLE-WIDTH 4))

(define USER-COLOR "Blue")
(define ENEMY-COLOR "Sea Green")
(define USER-PADDLE (rectangle PADDLE-WIDTH PADDLE-HEIGHT "solid" USER-COLOR))
(define ENEMY-PADDLE (rectangle PADDLE-WIDTH PADDLE-HEIGHT "solid" ENEMY-COLOR))

(define USER-LINE (+ 4
                     (+ 0 (/ (image-width USER-PADDLE)
                             2))))
(define ENEMY-LINE (- (- BG-WIDTH (/ (image-width ENEMY-PADDLE)
                                     2))
                      4))
(define USER-HIT (+ USER-LINE
                    (/ PADDLE-WIDTH 2)))
(define ENEMY-HIT (- ENEMY-LINE
                     (/ PADDLE-WIDTH 2)))

(define BALL-RADIUS (/ BG-WIDTH 80))
(define BALL-COLOR "Gray")
(define BALL (circle BALL-RADIUS "solid" BALL-COLOR))
(define BALL-SPEED 11)
(define S-BALL-X (/ BG-WIDTH 2))
(define S-BALL-Y (/ BG-HEIGHT 2))

(define SCORE-SIZE (/ BG-WIDTH 20))
(define SCORE-COLOR "White")
(define SCORE-XP (/ BG-WIDTH 2))
(define SCORE-YP (/ BG-HEIGHT 4))
(define SCORE-DIVIDER "    ")

(define MSG-SIZE (+ SCORE-SIZE 4))
(define MSG-COLOR "White")
(define MSG-XP (/ BG-WIDTH 2))
(define MSG-YP (+ (/ BG-HEIGHT 2) 100))

(define XPOS-S (/ BG-WIDTH 2))
(define YPOS-S (/ BG-HEIGHT 2))
(define PADDLE-B (+ 0
                    (/ PADDLE-HEIGHT 2)))
(define PADDLE-E (- BG-HEIGHT
                    (/ PADDLE-HEIGHT 2)))

(define UPAD-SPEED (- BALL-SPEED 2))
(define EPAD-SPEED (- BALL-SPEED 1))

(define WIN-SCORE 9)



;; Data Definitions

;; Position is is a structure:
;;   (make-posn Integer[0, BG-WIDTH] Integer[0, BG-HEIGHT])
;; The position of an object on screen.
(define P1 (make-posn 0 0))
(define P2 (make-posn 10 11))
(define P3 (make-posn BG-WIDTH BG-HEIGHT))
#;
(define (fn-for-posn p)
  (... (posn-x p)
       (posn-y p)))


;; X-Direction is one of:
;;  - 1, and
;;  - -1.
;; Interpretation. The direction of movement along the x-axis.
;;  - 1 means right-wards movement, and
;;  - -1 means left-wards movement.
#;
(define (fn-for-xdir xd)
  (cond [(= xd 1) (...)]
        [(= xd -1) (...)]))


;; Y-Direction is one of:
;;  - -1,
;;  - 0, and
;;  - 1.
;; Interpretation. The direction of movement along the y-axis.
;;  - -1 means upwards movement,
;;  - 0 means there is no movement, and
;;  - 1 means downwards movement.
#;
(define (fn-for-ydir yd)
  (cond [(= yd -1) (...)]
        [(= yd 0) (...)]
        [(= yd 1) (...)]))


(define-struct dirn (xd yd))
;; Direction is a structure:
;;   (make-dir X-Direction Y-Direction)
;; Interpretation. The direction of movement along x- and y-axes.
#;
(define (fn-for-dirn d)
  (... (fn-for-xdir (dirn-xd d))
       (fn-for-ydir (dirn-yd d))))


(define-struct ball (posn dirn))
;; Ball is a structure:
;;   (make-ball Position Direction)
;; Interpretation. A Ball is the ball the paddles hit in a game of Pong.
(define B0 (make-ball (make-posn XPOS-S YPOS-S) (make-dirn 0 -1)))
#;
(define (fn-for-ball b)
  (... (fn-for-posn (ball-posn b))
       (fn-for-dirn (ball-dirn b))))


;; Score is Integer[0, 9].
;; Interpretation. A paddle's score in a game of Pong.
(define S1 0)
(define S2 3)
(define S3 9)
#;
(define (fn-for-score s)
  (... s))


(define-struct paddle (posn ydir score))
;; Paddle is a structure:
;;   (make-paddle Position Y-Direction Score)
;; Interpretation. A Paddle is a player in a game of Pong, where
;;      - posn is the player's current Position,
;;      - ydir is the player's current y-direction of movement, and
;;      - score is the player's current score.
(define USER (make-paddle (make-posn USER-LINE YPOS-S) 0 0))
(define ENEMY (make-paddle (make-posn ENEMY-LINE YPOS-S) 0 0))
#;
(define (fn-for-paddle p)
  (... (fn-for-posn (paddle-posn p))
       (fn-for-ydir (paddle-ydir p))
       (fn-for-score (paddle-score p))))


(define-struct game (user enemy ball))
;; Game is a structure:
;;   (make-game Paddle Paddle Ball)
;; Interpretation. The program state of a game of Pong.
;; The attributes include:
;;    - user represents the user's paddle,
;;    - enemy represents the computer opponent's paddle, and
;;    - ball represents the state of the ball.
#;
(define (fn-for-game g)
  (... (fn-for-paddle (game-user g))
       (fn-for-paddle (game-enemy g))
       (fn-for-ball (game-ball g))))



;; Function Definitions

(define GAME-START (make-game USER
                              ENEMY
                              (make-ball (make-posn S-BALL-X S-BALL-Y)
                                         (make-dirn (random-ref (list -1 1))
                                                    (random-ref (list -1 1))))))

;; Game -> Game
;; Begin the world with:
;;     (simple-pong GAME-START)

(define (simple-pong g)
  (big-bang g                  ; Game
    (on-tick tock)             ; Game -> Game
    (to-draw draw)             ; Game -> Image
    (on-key handle-inputs)))   ; Game KeyEvent -> Game



;; Game -> Game
;; Produce the next game state, where the ball's movement,
;; the enemy paddle's movement, and the scores are handled.
(check-expect (tock (make-game (make-paddle (make-posn USER-LINE YPOS-S)
                                            -1 0)
                               (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                            1 0)
                               (make-ball (make-posn XPOS-S YPOS-S)
                                          (make-dirn 1 -1))))
              (make-game (make-paddle (make-posn USER-LINE (+ YPOS-S (* UPAD-SPEED -1)))
                                      -1 0)
                         (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                      1 0)
                         (make-ball (make-posn (+ XPOS-S
                                                  (* BALL-SPEED 1))
                                               (+ YPOS-S
                                                  (* BALL-SPEED -1)))
                                    (make-dirn 1 -1))))
(check-random (tock (make-game (make-paddle (make-posn USER-LINE 100)
                                            -1 0)
                               (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                            1 0)
                               (make-ball (make-posn USER-LINE YPOS-S)
                                          (make-dirn 0 -1))))
              (make-game (make-paddle (make-posn USER-LINE YPOS-S)
                                      0 0)
                         (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                      0 (+ 0 1))
                         (make-ball (make-posn S-BALL-X S-BALL-Y)
                                    (make-dirn (random-ref (list -1 1))
                                               (random-ref (list -1 1))))))

;(define (tock g) g)

(define (tock g)
  (cond [(end? g) g]
        [(goal? (game-ball g)) (reset-match (set-score g))]
        [else (move-elements g)]))


;; Game -> Boolean
;; Signals the win condition.
(check-expect (end? (make-game (make-paddle (make-posn USER-LINE YPOS-S)
                                            1
                                            5)
                               (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                            1
                                            4)
                               (make-ball (make-posn USER-LINE 50)
                                          (make-dirn -1 -1)))) #false)
(check-expect (end? (make-game (make-paddle (make-posn USER-LINE YPOS-S)
                                            1
                                            2)
                               (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                            1
                                            9)
                               (make-ball (make-posn USER-LINE 50)
                                          (make-dirn -1 -1)))) #true)
(check-expect (end? (make-game (make-paddle (make-posn USER-LINE YPOS-S)
                                            1
                                            9)
                               (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                            1
                                            4)
                               (make-ball (make-posn ENEMY-LINE 50)
                                          (make-dirn 1 1)))) #true)

;(define (end? g) #false)

(define (end? g)
  (or (= (paddle-score (game-user g)) 9)
      (= (paddle-score (game-enemy g)) 9)))


;; Game -> Game
;; Handle the movement of all game elements.
(check-expect (move-elements (make-game (make-paddle (make-posn USER-LINE YPOS-S)
                                                     -1 0)
                                        (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                                     1 0)
                                        (make-ball (make-posn XPOS-S YPOS-S)
                                                   (make-dirn 1 -1))))
              (make-game (make-paddle (make-posn USER-LINE (+ YPOS-S (* UPAD-SPEED -1)))
                                      -1 0)
                         (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                      1 0)
                         (make-ball (make-posn (+ XPOS-S
                                                  (* BALL-SPEED 1))
                                               (+ YPOS-S
                                                  (* BALL-SPEED -1)))
                                    (make-dirn 1 -1))))

;(define (move-elements g) g)

(define (move-elements g)
  (make-game (move-user (game-user g) UPAD-SPEED)
             (move-enemy-ai (game-enemy g) (game-ball g) EPAD-SPEED)
             (move-ball (game-ball g) (game-user g) (game-enemy g) (make-posn BALL-SPEED BALL-SPEED))))


;; Paddle Integer -> Paddle
;; Move paddle p by given integer s.
(check-expect (move-user (make-paddle (make-posn USER-LINE YPOS-S)
                                      -1 0)
                         UPAD-SPEED)
              (make-paddle (make-posn USER-LINE
                                      (+ YPOS-S (* UPAD-SPEED -1)))
                           -1 0))
(check-expect (move-user (make-paddle (make-posn USER-LINE 0)
                                      -1 0)
                         UPAD-SPEED)
              (make-paddle (make-posn USER-LINE
                                      (+ 0 (/ PADDLE-HEIGHT 2)))
                           0 0))
(check-expect (move-user (make-paddle (make-posn USER-LINE BG-HEIGHT)
                                      -1 0)
                         UPAD-SPEED)
              (make-paddle (make-posn USER-LINE
                                      (- BG-HEIGHT (/ PADDLE-HEIGHT 2)))
                           0 0))

;(define (move-user p s) p)

(define (move-user p s)
  (cond [(< (abs (- (posn-y (paddle-posn p))
                    0))
            (/ PADDLE-HEIGHT 2))
         (make-paddle (make-posn (posn-x (paddle-posn p))
                                 (+ 0 (/ PADDLE-HEIGHT 2)))
                      0
                      (paddle-score p))]
        [(< (abs (- (posn-y (paddle-posn p))
                    BG-HEIGHT))
            (/ PADDLE-HEIGHT 2))
         (make-paddle (make-posn (posn-x (paddle-posn p))
                                 (- BG-HEIGHT (/ PADDLE-HEIGHT 2)))
                      0
                      (paddle-score p))]
        [else
         (make-paddle (make-posn (posn-x (paddle-posn p))
                                 (+ (posn-y (paddle-posn p))
                                    (* s
                                       (paddle-ydir p))))
                      (paddle-ydir p)
                      (paddle-score p))]))


;; Paddle Ball Integer -> Paddle
;; Make enemy paddle follow the ball.
(check-expect (move-enemy-ai (make-paddle (make-posn ENEMY-LINE 200)
                                          1 0)
                             (make-ball (make-posn XPOS-S 260)
                                        (make-dirn 1 1))
                             EPAD-SPEED)
              (make-paddle (make-posn ENEMY-LINE (+ 200 (* EPAD-SPEED 1)))
                           1 0))
(check-expect (move-enemy-ai (make-paddle (make-posn ENEMY-LINE 200)
                                          1 0)
                             (make-ball (make-posn XPOS-S 140)
                                        (make-dirn 1 -1))
                             EPAD-SPEED)
              (make-paddle (make-posn ENEMY-LINE (+ 200 (* EPAD-SPEED -1)))
                           -1 0))
(check-expect (move-enemy-ai (make-paddle (make-posn USER-LINE 200)
                                          1 0)
                             (make-ball (make-posn XPOS-S 200)
                                        (make-dirn 1 1))
                             EPAD-SPEED)
              (make-paddle (make-posn USER-LINE 200)
                           1 0))

;(define (move-enemy-ai p b s) p)

(define (move-enemy-ai p b s)
  (cond [(< (- (posn-y (paddle-posn p))
               (posn-y (ball-posn b)))
            (- (/ PADDLE-HEIGHT 4)))
         (make-paddle (make-posn (posn-x (paddle-posn p))
                                 (+ (posn-y (paddle-posn p))
                                    (* EPAD-SPEED 1)))
                      1
                      (paddle-score p))]
        [(> (- (posn-y (paddle-posn p))
               (posn-y (ball-posn b)))
            (/ PADDLE-HEIGHT 4))
         (make-paddle (make-posn (posn-x (paddle-posn p))
                                 (+ (posn-y (paddle-posn p))
                                    (* EPAD-SPEED -1)))
                      -1
                      (paddle-score p))]
        [else
         p]))


;; Ball Paddle Paddle Position -> Ball
;; Move ball b by given integer p, and make it bounce from
;; the top side, bottom side, and both paddles.
(check-expect (move-ball (make-ball (make-posn XPOS-S YPOS-S)
                                    (make-dirn 1 -1))
                         (make-paddle (make-posn USER-LINE YPOS-S)
                                      -1 0)
                         (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                      1 0)
                         (make-posn BALL-SPEED BALL-SPEED))
              (make-ball (make-posn (+ XPOS-S
                                       (* BALL-SPEED 1))
                                    (+ YPOS-S
                                       (* BALL-SPEED -1)))
                         (make-dirn 1 -1)))
(check-expect (move-ball (make-ball (make-posn 200 0)
                                    (make-dirn 1 -1))
                         (make-paddle (make-posn USER-LINE YPOS-S)
                                      -1 0)
                         (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                      1 0)
                         (make-posn BALL-SPEED BALL-SPEED))
              (make-ball (make-posn 200 0)
                         (make-dirn 1 (* -1 -1))))
(check-expect (move-ball (make-ball (make-posn 210 BG-HEIGHT)
                                    (make-dirn -1 1))
                         (make-paddle (make-posn USER-LINE YPOS-S)
                                      -1 0)
                         (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                      1 0)
                         (make-posn BALL-SPEED BALL-SPEED))
              (make-ball (make-posn 210 BG-HEIGHT)
                         (make-dirn -1 (* 1 -1))))
(check-expect (move-ball (make-ball (make-posn USER-LINE YPOS-S)
                                    (make-dirn -1 -1))
                         (make-paddle (make-posn USER-LINE YPOS-S)
                                      -1 0)
                         (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                      1 0)
                         (make-posn BALL-SPEED BALL-SPEED))
              (make-ball (make-posn USER-LINE YPOS-S)
                         (make-dirn (* -1 -1) -1)))
(check-expect (move-ball (make-ball (make-posn ENEMY-LINE YPOS-S)
                                    (make-dirn 1 1))
                         (make-paddle (make-posn USER-LINE YPOS-S)
                                      -1 0)
                         (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                      1 0)
                         (make-posn BALL-SPEED BALL-SPEED))
              (make-ball (make-posn ENEMY-LINE YPOS-S)
                         (make-dirn (* 1 -1) 1)))

;(define (move-ball b u e p) b)

(define (move-ball b u e p)
  (cond [(ball-hit-fc? b)
         (make-ball (ball-posn b)
                    (make-dirn (dirn-xd (ball-dirn b))
                               (* (dirn-yd (ball-dirn b)) -1)))]
        [(or (ball-hit-paddle? b u)
             (ball-hit-paddle? b e))
         (make-ball (ball-posn b)
                    (make-dirn (* (dirn-xd (ball-dirn b)) -1)
                               (dirn-yd (ball-dirn b))))]
        [else
         (make-ball (make-posn (+ (posn-x (ball-posn b))
                                  (* (posn-x p)
                                     (dirn-xd (ball-dirn b))))
                               (+ (posn-y (ball-posn b))
                                  (* (posn-y p)
                                     (dirn-yd (ball-dirn b)))))
                    (ball-dirn b))]))


;; Ball -> Boolean
;; Return #true if the ball hits the floor or the ceiling.
;; Else, return #false.
(check-expect (ball-hit-fc? (make-ball (make-posn XPOS-S YPOS-S)
                                       (make-dirn -1 1)))
              #false)
(check-expect (ball-hit-fc? (make-ball (make-posn 200 0)
                                       (make-dirn 1 -1)))
              #true)
(check-expect (ball-hit-fc? (make-ball (make-posn 200 BG-HEIGHT)
                                       (make-dirn -1 1)))
              #true)

;(define (ball-hit-fc? b) #false)

(define (ball-hit-fc? b)
  (or (and (<= (abs (- (posn-y (ball-posn b)) 0))
               BALL-RADIUS)
           (= (dirn-yd (ball-dirn b)) -1))
      (and (<= (abs (- (posn-y (ball-posn b)) BG-HEIGHT))
               BALL-RADIUS)
           (= (dirn-yd (ball-dirn b)) 1))))


;; Ball Paddle -> Boolean
;; Return #true if the ball collided with the paddle. Else, return #false.
(check-expect (ball-hit-paddle? (make-ball (make-posn XPOS-S YPOS-S)
                                           (make-dirn 1 -1))
                                (make-paddle (make-posn USER-LINE YPOS-S)
                                             -1 0))
              #false)
(check-expect (ball-hit-paddle? (make-ball (make-posn XPOS-S YPOS-S)
                                           (make-dirn 1 -1))
                                (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                             1 0))
              #false)
(check-expect (ball-hit-paddle? (make-ball (make-posn (+ USER-LINE 10)
                                                      (- YPOS-S 44))
                                           (make-dirn -1 -1))
                                (make-paddle (make-posn USER-LINE YPOS-S)
                                             -1 0))
              #true)
(check-expect (ball-hit-paddle? (make-ball (make-posn (- ENEMY-LINE 10)
                                                      (- YPOS-S 43))
                                           (make-dirn 1 -1))
                                (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                             1 0))
              #true)

;(define (ball-hit-paddle? b p) #false)

(define (ball-hit-paddle? b p)
  (cond [(and (or (and (= (posn-x (paddle-posn p)) USER-LINE)
                       (= (dirn-xd (ball-dirn b)) -1))
                  (and (= (posn-x (paddle-posn p)) ENEMY-LINE)
                       (= (dirn-xd (ball-dirn b)) 1)))
              (<= (abs (- (posn-x (paddle-posn p))
                          (posn-x (ball-posn b))))
                  (/ PADDLE-WIDTH 2))
              (<= (abs (- (posn-y (paddle-posn p))
                          (posn-y (ball-posn b))))
                  (/ PADDLE-HEIGHT 2)))
         #true]
        [else
         #false]))


;; Game -> Game
;; Reposition all game elements back to their original positions.
(check-random (reset-match (make-game (make-paddle (make-posn USER-LINE 450)
                                                   -1 0)
                                      (make-paddle (make-posn ENEMY-LINE 100)
                                                   1 0)
                                      (make-ball (make-posn USER-LINE YPOS-S)
                                                 (make-dirn 0 -1))))
              (make-game (make-paddle (make-posn USER-LINE YPOS-S)
                                      0 0)
                         (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                      0 0)
                         (make-ball (make-posn S-BALL-X S-BALL-Y)
                                    (make-dirn (random-ref (list -1 1))
                                               (random-ref (list -1 1))))))

;(define (reset-match g) g)

(define (reset-match g)
  (make-game (make-paddle (make-posn USER-LINE YPOS-S)
                          0 (paddle-score (game-user g)))
             (make-paddle (make-posn ENEMY-LINE YPOS-S)
                          0 (paddle-score (game-enemy g)))
             (make-ball (make-posn S-BALL-X S-BALL-Y)
                        (make-dirn (random-ref (list -1 1))
                                   (random-ref (list -1 1))))))


;; Game -> Game
;; Handle scoring after match end.
(check-random (set-score (make-game (make-paddle (make-posn USER-LINE 450)
                                                 -1 0)
                                    (make-paddle (make-posn ENEMY-LINE 100)
                                                 1 0)
                                    (make-ball (make-posn USER-LINE YPOS-S)
                                               (make-dirn -1 -1))))
              (make-game (make-paddle (make-posn USER-LINE 450)
                                      -1 0)
                         (make-paddle (make-posn ENEMY-LINE 100)
                                      1 (+ 0 1))
                         (make-ball (make-posn USER-LINE YPOS-S)
                                    (make-dirn -1 -1))))
(check-random (set-score (make-game (make-paddle (make-posn USER-LINE 450)
                                                 -1 0)
                                    (make-paddle (make-posn ENEMY-LINE 100)
                                                 1 0)
                                    (make-ball (make-posn ENEMY-LINE YPOS-S)
                                               (make-dirn 1 1))))
              (make-game (make-paddle (make-posn USER-LINE 450)
                                      -1 (+ 0 1))
                         (make-paddle (make-posn ENEMY-LINE 100)
                                      1 0)
                         (make-ball (make-posn ENEMY-LINE YPOS-S)
                                    (make-dirn 1 1))))

;(define (set-score g) g)

(define (set-score g)
  (make-game (reward-paddle (paddle-lost? (game-enemy g) (game-ball g))
                            (game-user g))
             (reward-paddle (paddle-lost? (game-user g) (game-ball g))
                            (game-enemy g))
             (game-ball g)))


;; Boolean Paddle -> Paddle
;; Add one point to given paddle if they won (#true).
(check-expect (reward-paddle #false
                             (make-paddle (make-posn USER-LINE 450)
                                          -1 1))
              (make-paddle (make-posn USER-LINE 450)
                           -1 1))
(check-expect (reward-paddle #true
                             (make-paddle (make-posn USER-LINE 450)
                                          -1 1))
              (make-paddle (make-posn USER-LINE 450)
                           -1 (+ 1 1)))

;(define (reward-paddle bool p) p)

(define (reward-paddle bool p)
  (if bool
      (make-paddle (paddle-posn p)
                   (paddle-ydir p)
                   (+ (paddle-score p) 1))
      p))


;; Paddle Ball -> Boolean
;; Return #true if paddle lost. That is,
;; if the ball went past a paddle. Else, #false.
(check-expect (paddle-lost? (make-paddle (make-posn USER-LINE 450)
                                         -1 1)
                            (make-ball (make-posn ENEMY-LINE YPOS-S)
                                       (make-dirn 1 1)))
              #false)
(check-expect (paddle-lost? (make-paddle (make-posn USER-LINE 450)
                                         -1 1)
                            (make-ball (make-posn USER-LINE YPOS-S)
                                       (make-dirn 1 1)))
              #true)
(check-expect (paddle-lost? (make-paddle (make-posn ENEMY-LINE 100)
                                         1 0)
                            (make-ball (make-posn USER-LINE YPOS-S)
                                       (make-dirn -1 -1)))
              #false)
(check-expect (paddle-lost? (make-paddle (make-posn ENEMY-LINE 100)
                                         1 0)
                            (make-ball (make-posn ENEMY-LINE YPOS-S)
                                       (make-dirn 1 1)))
              #true)
(check-expect (paddle-lost? (make-paddle (make-posn ENEMY-LINE 100)
                                         1 0)
                            (make-ball (make-posn S-BALL-X YPOS-S)
                                       (make-dirn 1 1)))
              #false)

;(define (paddle-lost? p b) #false)

(define (paddle-lost? p b)
  (cond [(and (< (posn-x (paddle-posn p)) S-BALL-X)
              (>= USER-HIT
                  (posn-x (ball-posn b))))
         #true]
        [(and (> (posn-x (paddle-posn p)) S-BALL-X)
              (<= ENEMY-HIT
                  (posn-x (ball-posn b))))
         #true]
        [else
         #false]))


;; Ball -> Boolean
;; Return #true if the ball get past either user or enemy line.
(check-expect (goal? (make-ball (make-posn XPOS-S YPOS-S)
                                (make-dirn 1 1)))
              #false)
(check-expect (goal? (make-ball (make-posn ENEMY-LINE YPOS-S)
                                (make-dirn 1 1)))
              #true)
(check-expect (goal? (make-ball (make-posn USER-LINE YPOS-S)
                                (make-dirn -1 1)))
              #true)

;(define (goal? b) #false)

(define (goal? b)
  (or (>= (posn-x (ball-posn b)) ENEMY-LINE)
      (<= (posn-x (ball-posn b)) USER-LINE)))


;; Game -> Image
;; Render all the game elements on screen.
(check-expect (draw (make-game (make-paddle (make-posn USER-LINE YPOS-S)
                                            0 0)
                               (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                            0 0)
                               (make-ball (make-posn XPOS-S YPOS-S)
                                          (make-dirn 0 -1))))
              (place-image (text (string-append (number->string 0)
                                                SCORE-DIVIDER
                                                (number->string 0))
                                 SCORE-SIZE
                                 SCORE-COLOR)
                           SCORE-XP SCORE-YP
                           (place-image USER-PADDLE
                                        USER-LINE YPOS-S
                                        (place-image ENEMY-PADDLE
                                                     ENEMY-LINE YPOS-S
                                                     (place-image BALL
                                                                  XPOS-S YPOS-S
                                                                  BACKGROUND)))))

;(define (draw g) empty-image)

(define (draw g)
  (display-winner g
                  (render-image (text (string-append (number->string (paddle-score (game-user g)))
                                                     SCORE-DIVIDER
                                                     (number->string (paddle-score (game-enemy g))))
                                      SCORE-SIZE
                                      SCORE-COLOR)
                                (make-posn SCORE-XP SCORE-YP)
                                (render-image USER-PADDLE
                                              (paddle-posn (game-user g))
                                              (render-image ENEMY-PADDLE
                                                            (paddle-posn (game-enemy g))
                                                            (render-image BALL
                                                                          (ball-posn (game-ball g))
                                                                          BACKGROUND))))))


;; Game Image -> Image
;; Display an image displaying the scores and, if applicable,
;; declare the winner of the game of Pong.
(check-expect (display-winner (make-game (make-paddle (make-posn USER-LINE YPOS-S)
                                                      -1 0)
                                         (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                                      1 0)
                                         (make-ball (make-posn XPOS-S YPOS-S)
                                                    (make-dirn 1 -1)))
                              BACKGROUND)
              BACKGROUND)
(check-expect (display-winner (make-game (make-paddle (make-posn USER-LINE YPOS-S)
                                                      -1 9)
                                         (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                                      1 0)
                                         (make-ball (make-posn XPOS-S YPOS-S)
                                                    (make-dirn 1 -1)))
                              BACKGROUND)
              (render-image (text "You won! :)"
                                  MSG-SIZE MSG-COLOR)
                            (make-posn MSG-XP MSG-YP)
                            BACKGROUND))
(check-expect (display-winner (make-game (make-paddle (make-posn USER-LINE YPOS-S)
                                                      -1 0)
                                         (make-paddle (make-posn ENEMY-LINE YPOS-S)
                                                      1 9)
                                         (make-ball (make-posn XPOS-S YPOS-S)
                                                    (make-dirn 1 -1)))
                              BACKGROUND)
              (render-image (text "Enemy won. :("
                                  MSG-SIZE MSG-COLOR)
                            (make-posn MSG-XP MSG-YP)
                            BACKGROUND))

;(define (display-winner g i) i)

(define (display-winner g i)
  (cond [(= (paddle-score (game-enemy g)) WIN-SCORE)
         (render-image (text "Enemy won. :("
                             MSG-SIZE MSG-COLOR)
                       (make-posn MSG-XP MSG-YP)
                       i)]
        [(= (paddle-score (game-user g)) WIN-SCORE)
         (render-image (text "You won! :)"
                             MSG-SIZE MSG-COLOR)
                       (make-posn MSG-XP MSG-YP)
                       i)]
        [else
         i]))


;; Image Position Image -> Image
;; Given an image, a position, and a background, place
;; the given image on the given background with the given position.
(check-expect (render-image BALL (make-posn 50 50) BACKGROUND)
              (place-image BALL
                           50 50
                           BACKGROUND))
(check-expect (render-image USER-PADDLE (make-posn USER-LINE PADDLE-B) BACKGROUND)
              (place-image USER-PADDLE
                           USER-LINE PADDLE-B
                           BACKGROUND))
(check-expect (render-image ENEMY-PADDLE (make-posn ENEMY-LINE PADDLE-E) BACKGROUND)
              (place-image ENEMY-PADDLE
                           ENEMY-LINE PADDLE-E
                           BACKGROUND))

;(define (render-image i p bg) bg)
#;
(define (render-image i p bg)
  (... i
       (fn-for-posn p)
       bg))

(define (render-image i p bg)
  (place-image i
               (posn-x p) (posn-y p)
               bg))


;; Game KeyEvent -> Game
;; Handle the key input that helps the user play.
(define (handle-inputs g ke)
  (make-game (handle-user (game-user g) ke)
             (game-enemy g)
             (game-ball g)))


;; Paddle KeyEvent -> Paddle
;; Helps the user control the user paddle and play the game.
(check-expect (handle-user (make-paddle (make-posn USER-LINE YPOS-S)
                                        0 0) "a")
              (make-paddle (make-posn USER-LINE YPOS-S)
                           0 0))
(check-expect (handle-user (make-paddle (make-posn USER-LINE YPOS-S)
                                        0 0) "up")
              (make-paddle (make-posn USER-LINE YPOS-S)
                           -1 0))
(check-expect (handle-user (make-paddle (make-posn USER-LINE YPOS-S)
                                        0 0) "down")
              (make-paddle (make-posn USER-LINE YPOS-S)
                           1 0))

;(define (handle-user p ke) p)
#;
(define (handle-user p ke)
  (cond [(string=? ke "up") (... (fn-for-posn (paddle-pos p))
                                 (fn-for-ydir (paddle-ydir p))
                                 (fn-for-score (paddle-score p)))]
        [(string=? ke "down") (... (fn-for-posn (paddle-pos p))
                                   (fn-for-ydir (paddle-ydir p))
                                   (fn-for-score (paddle-score p)))]
        [else p]))

(define (handle-user p ke)
  (cond [(string=? ke "up") (make-paddle (paddle-posn p)
                                         -1
                                         (paddle-score p))]
        [(string=? ke "down") (make-paddle (paddle-posn p)
                                           1
                                           (paddle-score p))]
        [else p]))