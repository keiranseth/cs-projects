;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname space-invaders-ms) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/universe)
(require 2htdp/image)

;; Space Invaders


;; Constants:

(define WIDTH  300)
(define HEIGHT 500)

(define INVADER-X-SPEED 1.5)  ;speeds (not velocities) in pixels per tick
(define INVADER-Y-SPEED 1.5)
(define TANK-SPEED 2)
(define MISSILE-SPEED -10)

(define HIT-RANGE 10)

(define INVADE-RATE 100)

(define BACKGROUND (empty-scene WIDTH HEIGHT))

(define INVADER
  (overlay/xy (ellipse 10 15 "outline" "blue")              ;cockpit cover
              -5 6
              (ellipse 20 10 "solid"   "blue")))            ;saucer

(define TANK
  (overlay/xy (overlay (ellipse 28 8 "solid" "black")       ;tread center
                       (ellipse 30 10 "solid" "green"))     ;tread outline
              5 -14
              (above (rectangle 5 10 "solid" "black")       ;gun
                     (rectangle 20 10 "solid" "black"))))   ;main body

(define TANK-HEIGHT/2 (/ (image-height TANK) 2))
(define TANK-YPOS (- HEIGHT TANK-HEIGHT/2))

(define MISSILE (ellipse 5 15 "solid" "red"))

(define TI-HITBOX-X (/ (+ (image-width TANK)
                          (image-width INVADER))
                       4))
(define TI-HITBOX-Y (/ (+ (image-height TANK)
                          (image-height INVADER))
                       4))

(define MI-HITBOX-X (/ (+ (image-width MISSILE)
                          (image-width INVADER))
                       2))
(define MI-HITBOX-Y (/ (+ (image-height MISSILE)
                          (image-height INVADER))
                       2))

(define SPAWN-SAMPLESPACE 100)
(define SPAWN-RATE 1) ; -> out of SPAWN-SAMPLESPACE


;; Data Definitions:

(define-struct tank (x dir))
;; Tank is (make-tank Number Integer[-1, 1])
;; interp. the tank location is x, HEIGHT - TANK-HEIGHT/2 in screen coordinates
;;         the tank moves TANK-SPEED pixels per clock tick left if dir -1, right if dir 1

(define T0 (make-tank (/ WIDTH 2) 1))   ;center going right
(define T1 (make-tank 50 1))            ;going right
(define T2 (make-tank 50 -1))           ;going left

#;
(define (fn-for-tank t)
  (... (tank-x t) (tank-dir t)))



(define-struct invader (x y dir))
;; Invader is (make-invader Number Integer[-1 or 1])
;; interp. the invader is at (x, y) in screen coordinates
;;         having x-direction along dir.

(define I1 (make-invader 150 100 1))           ;not landed, moving right
(define I2 (make-invader 150 HEIGHT -1))       ;exactly landed, moving left
(define I3 (make-invader 150 (+ HEIGHT 1) 10)) ;> landed, moving right


#;
(define (fn-for-invader invader)
  (... (invader-x invader) (invader-y invader) (invader-dir invader)))


(define-struct missile (x y))
;; Missile is (make-missile Number Number)
;; interp. the missile's location is x y in screen coordinates

(define M1 (make-missile 150 300))                       ;not hit U1
(define M2 (make-missile (invader-x I1) (+ (invader-y I1) 10)))  ;exactly hit U1
(define M3 (make-missile (invader-x I1) (+ (invader-y I1)  5)))  ;> hit U1

#;
(define (fn-for-missile m)
  (... (missile-x m) (missile-y m)))


(define-struct game (invaders missiles tank))
;; Game is (make-game  (listof Invader) (listof Missile) Tank)
;; interp. the current state of a space invaders game
;;         with the current invaders, missiles and tank position
(define G0 (make-game empty empty T0))
(define G1 (make-game empty empty T1))
(define G2 (make-game (list I1) (list M1) T1))
(define G3 (make-game (list I1 I2) (list M1 M2) T1))

#;
(define (fn-for-game s)
  (... (fn-for-loinvader (game-invaders s))
       (fn-for-lom (game-missiles s))
       (fn-for-tank (game-tank s))))


;; Function Definitions

;; Game -> Game
;; start the world with: 
;;   (space-invaders (make-game '() '() (make-tank (/ WIDTH 2) 0)))
;; 
(define (space-invaders g)
  (big-bang g                    ; Game
    (on-tick   tock)             ; Game -> Game
    (to-draw   render)           ; Game -> Image
    (stop-when end-game?)        ; Game -> Boolean
    (on-key    handle-key)))     ; Game KeyEvent -> Game


;; Game -> Game
;; Handle the movement of the tank, missiles, and invaders.
;(define (tock g) g)

(define (tock g)
  (make-game (spawn-invaders (move-invaders (filter-invaders (game-invaders g)
                                                             (game-missiles g)))
                             (random SPAWN-SAMPLESPACE))
             (move-missiles (filter-missiles (game-missiles g) (game-invaders g)))
             (move-tank (game-tank g))))


;; (listof Invader) Natural -> (listof Invader)
;; Spawn an invader if the randomly-generated number is <= SPAWN-RATE.
(check-random (spawn-invaders '() 0) (list (make-invader (random WIDTH)
                                                         0
                                                         (rand-num->inv-dir (random 2)))))
(check-random (spawn-invaders '() (- SPAWN-RATE 1)) (list (make-invader (random WIDTH)
                                                                        0
                                                                        (rand-num->inv-dir (random 2)))))
(check-random (spawn-invaders '() (+ SPAWN-RATE 1)) '())
(check-random (spawn-invaders (list (make-invader 100 100 -1)
                                    (make-invader 100 100 -1)
                                    (make-invader 100 100 -1)) (- SPAWN-RATE 1))
              (list (make-invader (random WIDTH)
                                  0
                                  (rand-num->inv-dir (random 2)))
                    (make-invader 100 100 -1)
                    (make-invader 100 100 -1)
                    (make-invader 100 100 -1)))
(check-random (spawn-invaders (list (make-invader 100 100 -1)
                                    (make-invader 100 100 -1)
                                    (make-invader 100 100 -1))
                              (+ SPAWN-RATE 1))
              (list (make-invader 100 100 -1)
                    (make-invader 100 100 -1)
                    (make-invader 100 100 -1)))

;(define (spawn-invaders loi n) loi)

(define (spawn-invaders loi n)
  (if (<= n SPAWN-RATE)
      (cons (make-invader (random WIDTH)
                          0
                          (rand-num->inv-dir (random 2)))
            loi)
      loi))


;; Natural[0, 1] -> Integer
;; Provides x-direction of a newly-spawned invader
;; given a randomly-generated number between 0 and 1.
(check-expect (rand-num->inv-dir 0) 1)
(check-expect (rand-num->inv-dir 1) -1)

;(define (rand-num->inv-dir n) 1)

(define (rand-num->inv-dir n)
  (cond [(= n 0) 1]
        [(= n 1) -1]))


;; (listof Invader) -> (listof Invader)
;; Handle the movement of the given list of invaders.
(check-expect (move-invaders '()) '())
(check-expect (move-invaders (list (make-invader 100 100 -1)))
              (list (make-invader (+ 100 (* INVADER-X-SPEED -1)) (+ 100 INVADER-Y-SPEED) -1)))
(check-expect (move-invaders (list (make-invader 60 51 1)
                                   (make-invader 140 111 1)
                                   (make-invader 214 101 -1)))
              (list (make-invader (+ 60 (* INVADER-X-SPEED 1)) (+ 51 INVADER-Y-SPEED) 1)
                    (make-invader (+ 140 (* INVADER-X-SPEED 1)) (+ 111 INVADER-Y-SPEED) 1)
                    (make-invader (+ 214 (* INVADER-X-SPEED -1)) (+ 101 INVADER-Y-SPEED) -1)))

;(define (move-invaders loi) loi)
#;
(define (move-invaders loi)
  (cond [(empty? loi) (...)]
        [else
         (... (first loi)
              (move-invaders (rest loi)))]))

(define (move-invaders loi)
  (cond [(empty? loi) '()]
        [else
         (cons (move-invader (first loi))
               (move-invaders (rest loi)))]))


;; Invader -> Invader
;; Move the given invader by INVADER-X-SPEED and INVADER-Y-SPEED.
(check-expect (move-invader (make-invader 100 100 1))
              (make-invader (+ 100 (* INVADER-X-SPEED 1)) (+ 100 INVADER-Y-SPEED) 1))
(check-expect (move-invader (make-invader 101 101 -1))
              (make-invader (+ 101 (* INVADER-X-SPEED -1)) (+ 101 INVADER-Y-SPEED) -1))
(check-expect (move-invader (make-invader (- WIDTH (- INVADER-X-SPEED 0.01)) 44 1))
              (make-invader WIDTH (+ 44 INVADER-Y-SPEED) 1))
(check-expect (move-invader (make-invader (+ 0 (- INVADER-X-SPEED 0.01)) 55 -1))
              (make-invader 0 (+ 55 INVADER-Y-SPEED) -1))
(check-expect (move-invader (make-invader WIDTH 55 1))
              (make-invader WIDTH (+ 55 INVADER-Y-SPEED) -1))
(check-expect (move-invader (make-invader 0 111 -1))
              (make-invader 0 (+ 111 INVADER-Y-SPEED) 1))

;(define (move-invader i) i)

(define (move-invader i)
  (cond [(or (and (= (invader-x i) 0) (= (invader-dir i) -1))
             (and (= (invader-x i) WIDTH) (= (invader-dir i) 1)))
         (make-invader (invader-x i)
                       (+ (invader-y i) INVADER-Y-SPEED)
                       (* (invader-dir i) -1))]
        [(and (<= (abs (- WIDTH (invader-x i))) INVADER-X-SPEED)
              (= (invader-dir i) 1))
         (make-invader WIDTH
                       (+ (invader-y i) INVADER-Y-SPEED)
                       (invader-dir i))]
        [(and (<= (abs (- 0 (invader-x i))) INVADER-X-SPEED)
              (= (invader-dir i) -1))
         (make-invader 0
                       (+ (invader-y i) INVADER-Y-SPEED)
                       (invader-dir i))]
        [else
         (make-invader (+ (invader-x i) (* INVADER-X-SPEED (invader-dir i)))
                       (+ (invader-y i) INVADER-Y-SPEED)
                       (invader-dir i))]))


;; (listof Invader) (listof Missile) -> (listof Invader)
;; Handle the existence of the given list of invaders.
(check-expect (filter-invaders '() '()) '())
(check-expect (filter-invaders '()
                               (list (make-missile 100 100)
                                     (make-missile 50 100)
                                     (make-missile 100 45))) '())
(check-expect (filter-invaders (list (make-invader 100 100 -1)
                                     (make-invader 111 100 1)
                                     (make-invader 100 45 -1)) '())
              (list (make-invader 100 100 -1)
                    (make-invader 111 100 1)
                    (make-invader 100 45 -1)))
(check-expect (filter-invaders (list (make-invader 100 100 -1)
                                     (make-invader 111 100 1)
                                     (make-invader 100 45 -1))
                               (list (make-missile 50 51)
                                     (make-missile 32 70)
                                     (make-missile 10 20)))
              (list (make-invader 100 100 -1)
                    (make-invader 111 100 1)
                    (make-invader 100 45 -1)))
(check-expect (filter-invaders (list (make-invader 100 100 -1)
                                     (make-invader 111 100 1)
                                     (make-invader 100 45 -1))
                               (list (make-missile 50 51)
                                     (make-missile 100 45)
                                     (make-missile 10 20)))
              (list (make-invader 100 100 -1)
                    (make-invader 111 100 1)))

;(define (filter-invaders loi lom) loi)
#;
(define (filter-invaders loi lom)
  (cond [(empty? loi) (... lom)]
        [else
         (... lom
              (first loi)
              (filter-invaders (rest loi) (... lom)))]))

(define (filter-invaders loi lom)
  (cond [(empty? loi) loi]
        [else
         (if (invader-hit? (first loi) lom)
             (filter-invaders (rest loi) lom)
             (cons (first loi) (filter-invaders (rest loi) lom)))]))

;; Invader (listof Missile) -> Boolean
;; Return true if given invader is
;; hit by the given list of missiles.
(check-expect (invader-hit? (make-invader 100 100 -1) '()) #false)
(check-expect (invader-hit? (make-invader 100 100 -1)
                            (list (make-missile 50 50)))
              #false)
(check-expect (invader-hit? (make-invader 100 100 -1)
                            (list (make-missile 100 100)))
              #true)
(check-expect (invader-hit? (make-invader 100 100 1)
                            (list (make-missile 50 50)
                                  (make-missile 10 20)
                                  (make-missile 100 40)))
              #false)
(check-expect (invader-hit? (make-invader 100 100 1)
                            (list (make-missile 50 50)
                                  (make-missile 100 100)
                                  (make-missile 100 40)))
              #true)

;(define (invader-hit? i lom) #false)
#;
(define (invader-hit? i lom)
  (cond [(empty? lom) (... i)]
        [else
         (... i
              (first lom)
              (invader-hit? (... i) (rest lom)))]))

(define (invader-hit? i lom)
  (cond [(empty? lom) #false]
        [else
         (if (missile-invader-contact? (first lom) i)
             #true
             (invader-hit? i (rest lom)))]))


;; (listof Missile) -> (listof Missile)
;; Handle the movement of the given list of missiles.
(check-expect (move-missiles '()) '())
(check-expect (move-missiles (list (make-missile 100 100)))
              (list (make-missile 100 (+ 100 MISSILE-SPEED))))
(check-expect (move-missiles (list (make-missile 50 50)
                                   (make-missile 110 75)
                                   (make-missile 66 120)))
              (list (make-missile 50 (+ 50 MISSILE-SPEED))
                    (make-missile 110 (+ 75 MISSILE-SPEED))
                    (make-missile 66 (+ 120 MISSILE-SPEED))))

;(define (move-missiles lom) lom)
#;
(define (move-missiles lom)
  (cond [(empty? lom) (...)]
        [else
         (... (first lom)
              (move-missiles (rest lom)))]))

(define (move-missiles lom)
  (cond [(empty? lom) '()]
        [else
         (cons (move-missile (first lom))
               (move-missiles (rest lom)))]))


;; Missile -> Missile
;; Move the given missile by MISSILE-SPEED
(check-expect (move-missile (make-missile 140 110))
              (make-missile 140 (+ 110 MISSILE-SPEED)))

;(define (move-missile m) m)

(define (move-missile m)
  (make-missile (missile-x m)
                (+ (missile-y m) MISSILE-SPEED)))


;; (listof Missile) (listof Invader) -> (listof Missile)
;; Handle the movement and existence of the given list of missiles.
(check-expect (filter-missiles '() '()) '())
(check-expect (filter-missiles '()
                               (list (make-invader 100 50 1)
                                     (make-invader 50 75 -1)
                                     (make-invader 200 150 1)))
              '())
(check-expect (filter-missiles (list (make-missile 100 75))
                               '())
              (list (make-missile 100 75)))
(check-expect (filter-missiles (list (make-missile 50 50)
                                     (make-missile 150 100)
                                     (make-missile 100 75))
                               '())
              (list (make-missile 50 50)
                    (make-missile 150 100)
                    (make-missile 100 75)))
(check-expect (filter-missiles (list (make-missile 50 50))
                               (list (make-invader 100 100 1)
                                     (make-invader 150 100 -1)
                                     (make-invader 100 150 1)))
              (list (make-missile 50 50)))
(check-expect (filter-missiles (list (make-missile 100 150))
                               (list (make-invader 100 100 -1)
                                     (make-invader 150 100 1)
                                     (make-invader 100 150 -1)))
              '())
(check-expect (filter-missiles (list (make-missile 50 50)
                                     (make-missile 60 50)
                                     (make-missile 50 60))
                               (list (make-invader 100 100 -1)
                                     (make-invader 150 100 1)
                                     (make-invader 100 150 -1)))
              (list (make-missile 50 50)
                    (make-missile 60 50)
                    (make-missile 50 60)))
(check-expect (filter-missiles (list (make-missile 50 50)
                                     (make-missile 100 150)
                                     (make-missile 50 60)
                                     (make-missile 50 -3))
                               (list (make-invader 100 100 -1)
                                     (make-invader 150 100 1)
                                     (make-invader 100 150 -1)))
              (list (make-missile 50 50)
                    (make-missile 50 60)))

;(define (filter-missiles lom loi) lom)
#;
(define (filter-missiles lom loi)
  (cond [(empty? lom) (... loi)]
        [else
         (... loi
              (first lom)
              (filter-missiles (rest lom) (... loi)))]))

(define (filter-missiles lom loi)
  (cond [(empty? lom) lom]
        [else
         (if (or (missile-outside? (first lom))
                 (missile-hit? (first lom) loi))
             (filter-missiles (rest lom) loi)
             (cons (first lom)
                   (filter-missiles (rest lom) loi)))]))


;; Missile -> Boolean
;; Return #true if the missile passes the top side
;; of the screen.
(check-expect (missile-outside? (make-missile 100 100)) #false)
(check-expect (missile-outside? (make-missile 100 0)) #false)
(check-expect (missile-outside? (make-missile 100 -2)) #true)

;(define (missile-outside? m) #false)

(define (missile-outside? m)
  (< (missile-y m) 0))


;; Missile (listof Invader) -> Boolean
;; Return true if given missile is hit
;; by the given list of invaders.
(check-expect (missile-hit? (make-missile 100 100)
                            '())
              #false)
(check-expect (missile-hit? (make-missile 100 100)
                            (list (make-invader 50 50 -1)))
              #false)
(check-expect (missile-hit? (make-missile 100 100)
                            (list (make-invader 100 100 11)))
              #true)
(check-expect (missile-hit? (make-missile 100 100)
                            (list (make-invader 50 50 1)
                                  (make-invader 41 50 -1)
                                  (make-invader 50 41 1)))
              #false)
(check-expect (missile-hit? (make-missile 100 100)
                            (list (make-invader 50 50 1)
                                  (make-invader 100 100 -1)
                                  (make-invader 50 41 1)))
              #true)

;(define (missile-hit? m loi) #false)
#;
(define (missile-hit? m loi)
  (cond [(empty? loi) (... m)]
        [else
         (... m
              (first loi)
              (missile-hit? (rest loi) (... m)))]))

(define (missile-hit? m loi)
  (cond [(empty? loi) #false]
        [else
         (if (missile-invader-contact? m (first loi))
             #true
             (missile-hit? m (rest loi)))]))


;; Missile Invader -> Boolean
;; Return true if both the missile and invader
;; are in each other's hitbox.
(check-expect (missile-invader-contact? (make-missile 100 110)
                                        (make-invader 50 52 -1))
              #false)
(check-expect (missile-invader-contact? (make-missile 100 110)
                                        (make-invader 100 110 1))
              #true)

;(define (missile-invader-contact? m i) #false)

(define (missile-invader-contact? m i)
  (and (<= (abs (- (missile-x m) (invader-x i))) MI-HITBOX-X)
       (<= (abs (- (missile-y m) (invader-y i))) MI-HITBOX-Y)))


;; Tank -> Tank
;; Handle the movement of the user's tank.
(check-expect (move-tank (make-tank 100 0))
              (make-tank 100 0))
(check-expect (move-tank (make-tank 110 1))
              (make-tank (+ 110 (* TANK-SPEED 1)) 1))
(check-expect (move-tank (make-tank WIDTH 1))
              (make-tank WIDTH 1))
(check-expect (move-tank (make-tank 120 -1))
              (make-tank (+ 120 (* TANK-SPEED -1)) -1))
(check-expect (move-tank (make-tank 0 -1))
              (make-tank 0 -1))

;(define (tock-tank t) t)

(define (move-tank t)
  (cond [(and (<= (+ (tank-x t) (* TANK-SPEED (tank-dir t)))
                  WIDTH)
              (>= (+ (tank-x t) (* TANK-SPEED (tank-dir t)))
                  0))
         (make-tank (+ (tank-x t) (* TANK-SPEED (tank-dir t)))
                    (tank-dir t))]
        [else t]))


;; Game -> Image
;; Render every element of the game on screen.
;(define (render g) g)

(define (render g)
  (render-invaders (game-invaders g)
                   (render-missiles (game-missiles g)
                                    (render-tank (game-tank g)
                                                 BACKGROUND))))


;; (listof Invader) Image -> Image
;; Render every existing invader on the given background image.
(check-expect (render-invaders '() BACKGROUND) BACKGROUND)
(check-expect (render-invaders (list (make-invader 50 75 1))
                               BACKGROUND)
              (place-image INVADER
                           50 75
                           BACKGROUND))
(check-expect (render-invaders (list (make-invader 100 100 1)
                                     (make-invader 50 200 -1)
                                     (make-invader 200 300 1))
                               BACKGROUND)
              (place-image INVADER
                           100 100
                           (place-image INVADER
                                        50 200
                                        (place-image INVADER
                                                     200 300
                                                     BACKGROUND))))

;(define (render-invaders loi i) i)
#;
(define (render-invaders loi i)
  (cond [(empty? loi) (... i)]
        [else
         (... i
              (first loi)
              (render-invaders (rest loi) (... i)))]))

(define (render-invaders loi i)
  (cond [(empty? loi) i]
        [else
         (place-image INVADER
                      (invader-x (first loi)) (invader-y (first loi))
                      (render-invaders (rest loi) i))]))


;; (listof Missile) Image -> Image
;; Render every existing missile on the given background image.
(check-expect (render-missiles '() BACKGROUND) BACKGROUND)
(check-expect (render-missiles (list (make-missile 50 100))
                               BACKGROUND)
              (place-image MISSILE
                           50 100
                           BACKGROUND))
(check-expect (render-missiles (list (make-missile 100 100)
                                     (make-missile 50 200)
                                     (make-missile 150 75)) BACKGROUND)
              (place-image MISSILE
                           100 100
                           (place-image MISSILE
                                        50 200
                                        (place-image MISSILE
                                                     150 75
                                                     BACKGROUND))))

;(define (render-missiles lom i) i)
#;
(define (render-missiles lom i)
  (cond [(empty? lom) (...)]
        [else
         (... i
              (first lom)
              (render-missiles (rest lom) (... i)))]))

(define (render-missiles lom i)
  (cond [(empty? lom) i]
        [else
         (place-image MISSILE
                      (missile-x (first lom)) (missile-y (first lom))
                      (render-missiles (rest lom) i))]))


;; Tank Image -> Image
;; Render the tank on the given background image.
(check-expect (render-tank (make-tank 100 1) BACKGROUND)
              (place-image TANK
                           100 TANK-YPOS
                           BACKGROUND))

;(define (render-tank t i) i)

(define (render-tank t i)
  (place-image TANK
               (tank-x t) TANK-YPOS
               i))


;; Game -> Boolean
;; Check if the game meets end condition.

;(define (end-game? g) #false)

(define (end-game? g)
  (or (invaders-infiltrated? (game-invaders g))
      (tank-hit? (game-invaders g) (game-tank g))))


;; (listof Invaders) -> Boolean
;; Return #true if any invader pass the screen bottom.
(check-expect (invaders-infiltrated? '()) #false)
(check-expect (invaders-infiltrated? (list (make-invader 100 100 -1))) #false)
(check-expect (invaders-infiltrated? (list (make-invader 100 HEIGHT -1))) #true)
(check-expect (invaders-infiltrated? (list (make-invader 44 11 1)
                                           (make-invader 120 50 -1)
                                           (make-invader 100 100 -1))) #false)
(check-expect (invaders-infiltrated? (list (make-invader 44 11 1)
                                           (make-invader 120 50 -1)
                                           (make-invader 100 HEIGHT -1))) #true)

;(define (invaders-infiltrated? loi) #false)
#;
(define (invaders-infiltrated? loi)
  (cond [(empty? loi) (...)]
        [else
         (... (first loi)
              (invaders-infiltrated? (rest loi)))]))

(define (invaders-infiltrated? loi)
  (cond [(empty? loi) #false]
        [else
         (if (invader-infiltrated? (first loi))
             #true
             (invaders-infiltrated? (rest loi)))]))


;; Invader -> Boolean
;; Return #true if the invader passed the screen bottom.
(check-expect (invader-infiltrated? (make-invader 100 100 -1)) #false)
(check-expect (invader-infiltrated? (make-invader 53 HEIGHT 1)) #true)
(check-expect (invader-infiltrated? (make-invader 200 (+ HEIGHT 1) -1)) #true)

;(define (invader-infiltrated? i) #false)

(define (invader-infiltrated? i)
  (>= (invader-y i) HEIGHT))


;; (listof Invader) Tank -> Boolean
;; Return true if the tank is hit by an invader.
(check-expect (tank-hit? '()
                         (make-tank 100 1))
              #false)
(check-expect (tank-hit? (list (make-invader 50 50 1)
                               (make-invader 200 200 -1)
                               (make-invader 100 10 1))
                         (make-tank 100 1))
              #false)
(check-expect (tank-hit? (list (make-invader 50 50 1)
                               (make-invader 200 200 -1)
                               (make-invader 100 TANK-YPOS 1)
                               (make-invader 100 10 1))
                         (make-tank 100 1))
              #true)

;(define (tank-hit? loi t) #false)
#;
(define (tank-hit? loi t)
  (cond [(empty? loi) (... t)]
        [else
         (... t
              (first loi)
              (tank-hit? (rest loi) t))]))

(define (tank-hit? loi t)
  (cond [(empty? loi) #false]
        [else
         (if (tank-invader-touch? t
                                  (first loi))
             #true
             (tank-hit? (rest loi) t))]))


;; Tank Invader -> Boolean
;; Return #true if the tank is touched by an invader.
(check-expect (tank-invader-touch? (make-tank 100 1)
                                   (make-invader 100 100 -1))
              #false)
(check-expect (tank-invader-touch? (make-tank 100 1)
                                   (make-invader 100 TANK-YPOS -1))
              #true)

;(define (tank-invader-touch? t i) #false)

(define (tank-invader-touch? t i)
  (and (<= (abs (- (invader-x i) (tank-x t))) TI-HITBOX-X)
       (<= (abs (- (invader-y i) TANK-YPOS)) TI-HITBOX-Y)))


;; Game KeyEvent -> Game
;; Handle the user controls for the tank.
;(define (handle-key g ke) g)

(define (handle-key g ke)
  (make-game (game-invaders g)
             (handle-offense (game-missiles g) (game-tank g) ke)
             (handle-tank (game-tank g) ke)))


;; (listof Missile) Tank KeyEvent -> (listof Missile)
;; Handle the user-controlled tank missiles.
(check-expect (handle-offense '()
                              (make-tank 100 0)
                              "a")
              '())
(check-expect (handle-offense '()
                              (make-tank 100 0)
                              " ")
              (list (make-missile 100 TANK-YPOS)))
(check-expect (handle-offense (list (make-missile 100 100)
                                    (make-missile 50 50)
                                    (make-missile 200 11))
                              (make-tank 200 1)
                              "a")
              (list (make-missile 100 100)
                    (make-missile 50 50)
                    (make-missile 200 11)))
(check-expect (handle-offense (list (make-missile 100 100)
                                    (make-missile 50 50)
                                    (make-missile 200 11))
                              (make-tank 200 -1)
                              " ")
              (cons (make-missile 200 TANK-YPOS)
                    (list (make-missile 100 100)
                          (make-missile 50 50)
                          (make-missile 200 11))))

;(define (handle-offense lom t ke) lom)
#;
(define (handle-offense lom t ke)
  (cond [(string=? ke " ") (... lom t)]
        [else
         (... lom t)]))

(define (handle-offense lom t ke)
  (cond [(string=? ke " ") (cons (make-missile (tank-x t)
                                               TANK-YPOS)
                                 lom)]
        [else lom]))


;; Tank KeyEvent -> Tank
;; Handle the tank's user-controlled direction of movement.
(check-expect (handle-tank (make-tank 100 1)
                           "left")
              (make-tank 100 -1))
(check-expect (handle-tank (make-tank 100 -1)
                           "left")
              (make-tank 100 -1))
(check-expect (handle-tank (make-tank 100 1)
                           "right")
              (make-tank 100 1))
(check-expect (handle-tank (make-tank 100 -1)
                           "right")
              (make-tank 100 1))
(check-expect (handle-tank (make-tank 100 1)
                           "a")
              (make-tank 100 1))

;(define (handle-tank t ke) t)

(define (handle-tank t ke)
  (cond [(string=? ke "left") (make-tank (tank-x t) -1)]
        [(string=? ke "right") (make-tank (tank-x t) 1)]
        [else
         t]))