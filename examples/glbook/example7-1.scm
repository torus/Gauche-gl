;; Example 7-1  Creating a Display List

(use gl)
(use gl.glut)
(use math.const)

(define *the-torus* 0)

(define  (torus numc numt)
  (let1 twopi (* 2 pi)
    (dotimes (i numc)
      (gl-begin GL_QUAD_STRIP)
      (dotimes (j (+ numt 1))
        (for-each (lambda (k)
                    (let* ((s (+ (modulo (+ i k) numc) 0.5))
                           (t (modulo j numt))
                           (x (* (+ 1 (* 0.1 (cos (* s (/ twopi numc)))))
                                 (cos (* t (/ twopi numt)))))
                           (y (* (+ 1 (* 0.1 (cos (* s (/ twopi numc)))))
                                 (sin (* t (/ twopi numt)))))
                           (z (* 0.1 (sin (* s (/ twopi numc))))))
                      (gl-vertex x y z)))
                  '(1 0)))
      (gl-end))))

(define (init)
  (set! *the-torus* (gl-gen-lists 1))
  (gl-new-list *the-torus* GL_COMPILE)
  (torus 8 25)
  (gl-end-list)
  (gl-shade-model GL_FLAT)
  (gl-clear-color 0.0 0.0 0.0 0.0)
  )

(define (disp)
  (gl-clear GL_COLOR_BUFFER_BIT)
  (gl-color 1.0 1.0 1.0)
  (gl-call-list *the-torus*)
  (gl-flush)
  )

(define (reshape w h)
  (gl-viewport 0 0 w h)
  (gl-matrix-mode GL_PROJECTION)
  (gl-load-identity)
  (glu-perspective 30 (/ w h) 1.0 100.0)
  (gl-matrix-mode GL_MODELVIEW)
  (gl-load-identity)
  (glu-look-at 0 0 10 0 0 0 0 1 0)
  )

(define (keyboard key x y)
  (cond
   ((or (= key (char->integer #\x))
        (= key (char->integer #\X)))
    (gl-rotate 30 1.0 0.0 0.0)
    (glut-post-redisplay))
   ((or (= key (char->integer #\y))
        (= key (char->integer #\Y)))
    (gl-rotate 30 0.0 1.0 0.0)
    (glut-post-redisplay))
   ((or (= key (char->integer #\i))
        (= key (char->integer #\I)))
    (gl-load-identity)
    (glu-look-at 0 0 10 0 0 0 0 1 0)
    (glut-post-redisplay))
   ((= key 27)                          ;ESC
    (exit 0)))
  )

(define (main args)
  (glut-init args)
  (glut-init-window-size 200 200)
  (glut-init-display-mode (logior GLUT_SINGLE GLUT_RGB))
  (glut-create-window (car args))
  (init)
  (glut-reshape-func reshape)
  (glut-keyboard-func keyboard)
  (glut-display-func disp)
  (glut-main-loop)
  0)
