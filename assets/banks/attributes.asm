;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ATTRIBUTE TABLE
;;
;; Due to hardware limitations, we have to assign the colour palettes in GROUPS OF TILES. These
;; values are recommended to be in binary as the way they are operated upon lends itself to the
;; individual digits of the number.
;;
;; For example, let's say we have the following byte: %00011011, which represents a 32x32 pixel
;; square (4x4 tiles). Each set of two bits will the define the colour palette for a 16x16 pixel
;; (2x2 tile) quadrant. Therefore, we can break out byte above into the following:
;;
;;      00 01 10 11
;;
;; Notice that in this byte, we are using all four possible colour palettes. Starting in the 
;; bottom left corner and moving counter-clockwise, the sets of 2 bits will create the colour 
;; palettes for the 2x2 tile quadrants. I.e.:
;;  - The first colour palette (00) will be assigned to the bottom left corner
;;  - The second color palette (01) will be in the bottom right corner
;;  - The third (10) is in the top right corner
;;  - The fourth color palette (11) is used in the top left corner
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
    .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
    .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
    .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
    .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
    .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
    .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
    .db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000