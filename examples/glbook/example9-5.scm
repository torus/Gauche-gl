;; Example 9-5  Mipmap Textures

(use gl)
(use gl.glut)
(use gauche.uvector)
(use srfi-1)
(use gauche.collection)

(define *mipmap*
  (map (lambda (i)
         (let1 size (expt 2 i)
           (make-u8vector (* size size 4))))
       (iota 6)))
(define *mm-colors*
  '((255 255 255)
    (0 0 255)
    (0 255 0)
    (255 0 0)
    (255 0 255)
    (255 255  0)))

(define *texname* 0)

(define (make-images)
  (dotimes (s 6)
    (let ((size (expt 2 s))
          (image (list-ref *mipmap* s))
          (colors (list-ref *mm-colors* s)))
      (dotimes (i size)
        (dotimes (j size)
          (let1 ij (* 4 (+ (* i size) j))
            (set! (ref image ij)       (ref colors 0))
            (set! (ref image (+ ij 1)) (ref colors 1))
            (set! (ref image (+ ij 2)) (ref colors 2))
            (set! (ref image (+ ij 3)) 255)))))))

(define (init)
  (gl-enable GL_DEPTH_TEST)
  (gl-shade-model GL_FLAT)

  (gl-translate 0.0 0.0 -3.6)
  (make-images)
  (gl-pixel-store GL_UNPACK_ALIGNMENT 1)

  (let1 texnames (gl-gen-textures 1)
    (set! *texname* (ref texnames 0))
    (gl-bind-texture GL_TEXTURE_2D *texname*))
  (gl-tex-parameter GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP)
  (gl-tex-parameter GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP)
  (gl-tex-parameter GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST)
  (gl-tex-parameter GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST_MIPMAP_NEAREST)
  (for-each (lambda (image level)
              (let1 size (expt 2 (- 5 level))
                (gl-tex-image-2d GL_TEXTURE_2D level GL_RGBA size size 0
                                 GL_RGBA GL_UNSIGNED_BYTE image)))
            (reverse *mipmap*)
            (iota 6))
  (gl-tex-env GL_TEXTURE_ENV GL_TEXTURE_ENV_MODE GL_DECAL)
  (gl-enable GL_TEXTURE_2D)
  )

(define (disp)
  (gl-clear (logior GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT))
  (gl-bind-texture GL_TEXTURE_2D *texname*)
  (gl-begin GL_QUADS)
  (gl-tex-coord 0.0 0.0) (gl-vertex -2.0 -1.0 0.0)
  (gl-tex-coord 0.0 8.0) (gl-vertex -2.0 1.0 0.0)
  (gl-tex-coord 8.0 8.0) (gl-vertex 2000.0 1.0 -6000.0)
  (gl-tex-coord 9.0 0.0) (gl-vertex 2000.0 -1.0 -6000.0)
  (gl-end)
  (gl-flush)
  )

(define (reshape w h)
  (gl-viewport 0 0 w h)
  (gl-matrix-mode GL_PROJECTION)
  (gl-load-identity)
  (glu-perspective 60.0 (/ w h) 1.0 30000.0)
  (gl-matrix-mode GL_MODELVIEW)
  (gl-load-identity))

(define (keyboard key x y)
  (cond
   ((= key 27) (exit 0))
   ))

(define (main args)
  (glut-init args)
  (glut-init-display-mode (logior GLUT_SINGLE GLUT_RGB GLUT_DEPTH))
  (glut-init-window-size 500 500)
  (glut-init-window-position 50 50)
  (glut-create-window (car args))
  (init)
  (glut-display-func disp)
  (glut-reshape-func reshape)
  (glut-keyboard-func keyboard)
  (glut-main-loop)
  0)
