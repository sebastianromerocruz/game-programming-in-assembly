;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C O N S T A N T S . h                                                                               ;;
;; ——————————————————————————————————————————————————————————————————————————————————————————————————— ;;
;; Author: Sebastián Romero Cruz                                                                       ;;
;; Summer 2022                                                                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ZERO        = $00

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; APU RESET AND STACK   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
APU_RESET   = $40
STACK_INIT  = $FF
NMI_ENABLE  = %10000000
SPRT_ENBLE  = %00011010

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SUBROUTINES           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Background
BG_PORT     = $20

; Palette
PLTTE_PORT  = $3F
PLTTE_SIZE  = $20

; Attributes
ATTR_APORT  = $23
ATTR_BPORT  = $C0
ATTRB_SIZE  = $40

; Sprites
SPRITE_RAM  = $0300
SPRITE_SIZE = $18
SPRITE_LOW  = $00
SPRITE_HI   = $03
NMI_LO_ADDR = OAMADDR
NMI_HI_ADDR = SPRITEDMA

; Controller Input
CTRL_1_PORT = $01
BINARY_ONE  = %00000001

CASSETTE_STRT = $0300
CASSETTE_TILE = $0303
CASSETTE_SIZE = $30
CASSETTE_YTOP = $20
BNCE_ANIM_TMR = $06

STRNG_STRT = $0333
STRNG_SIZE = $20
CHAR_GAP   = $04

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BORDER BOUNDARIES     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
BRDR_UP_LFT = $01
BORDER_DOWN = $DB
BORDER_RGHT = $FA

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PALETTES              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
PALETTE_LIM = $04
CSSETTE_ATR = $0302

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MUSIC                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
INITADDR = $A999        ; Init address for music
LOADADDR = $A6E0        ; Load address for music
PLAYADDR = $A99C        ; Play address for music