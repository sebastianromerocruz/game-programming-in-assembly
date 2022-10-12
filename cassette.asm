;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; G A M E   P R O G R A M M I N G   I N   A S S E M B L Y                                             ;;
;; ——————————————————————————————————————————————————————————————————————————————————————————————————— ;;
;; Author: Sebastián Romero Cruz                                                                       ;;
;; Fall 2022                                                                                           ;;
;; ——————————————————————————————————————————————————————————————————————————————————————————————————— ;;
;;                                                                                                     ;;
;;                      49 66 20 79 6F 75 20 6B 6E 6F 77 20 77 68 65 6E 63                             ;;
;;                      65 20 79 6F 75 20 63 61 6D 65 2C 20 74 68 65 72 65                             ;;
;;                      20 61 72 65 20 61 62 73 6F 6C 75 74 65 6C 79 20 6E                             ;;
;;                      6F 20 6C 69 6D 69 74 61 74 69 6F 6E 73 20 74 6F 20                             ;;
;;                      77 68 65 72 65 20 79 6F 75 20 63 61 6E 20 67 6F 2E                             ;;
;;                                                                                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ines directives                                                                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .inesprg 2
    .ineschr 1
    .inesmap 0
    .inesmir 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper files and macros                                                                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .include "assets/helper/addresses.h"
    .include "assets/helper/constants.h"
    .include "assets/helper/macros.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables                                                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .rsset VARLOC
music               .rs 16
backgroundLowByte   .rs 1
backgroundHighByte  .rs 1
paletteCycleCounter .rs 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Reset                                                                                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .bank 0
    .org $8000

RESET:
    ;; Housecleaning
    SEI
    CLD

    ;; Disable APU
    LDX APU_RESET
    STX CNTRLRTWO

    ;; Initialise stack
    LDX STACK_INIT
    TXS                 ; transfer X register value to stack pointer

    ;; Disable NMI, PPU Mask, and DMC IRQ
    LDX #ZERO
    STX PPUCTRL
    STX PPUMASK
    STX DELMODADDR

    LDA #$00
    STA paletteCycleCounter
    
    ;; Vertical blanks and memory clear (see macros.asm)
    CLEARMEM    
    ;; Initialise sound registers (see macros.asm)
    CLEARSOUND  

    ;; Initialise music
    JSR INITADDR

    ;; Disable NMI, PPU Mask, and DMC IRQ
    LDA #$00
    STA PPUCTRL
    STA PPUMASK

    ;; Subroutines
    JSR LoadBackground
    JSR LoadAttributes
    JSR LoadPalettes
    JSR LoadSprites  

    ;; Re-enable NMI
    LDA #NMI_ENABLE
    STA PPUCTRL

    ;; Re-enable PPU Mask
    LDA #SPRT_ENBLE
    STA PPUMASK

    ;; Disabling scrolling
    LDA #ZERO
    STA PPUADDR
    STA PPUADDR
    STA PPUSCROLL
    STA PPUSCROLL

    ;; Game loop
InfiniteLoop:
    JMP InfiniteLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Music data                                                                                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .bank 1
    .org LOADADDR
    .incbin "assets/audio/music.nsf"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NMI and NMI-based subroutines                                                                       ;;
;; ——————————————————————————————————————————————————————————————————————————————————————————————————— ;;
;;      - NMI                                                                                          ;;
;;      - CassetteBounce                                                                               ;;
;;      - RotateText                                                                                   ;;
;;      - PLAYADDR                                                                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .bank 2
    .org CPUADR
NMI:
    ;; Back up registers
    PHA
    TXA
    PHA
    TYA
    PHA           

    ;; Load the low and high sprite bytes to their respective addresses
    LDA #SPRITE_LOW
    STA NMI_LO_ADDR

    LDA #SPRITE_HI
    STA NMI_HI_ADDR

    ;; Run NMI subroutines
    JSR ReadControllerInput
    JSR CassetteBounce
    JSR RotateText

    ;; Update music
    JSR PLAYADDR

    ;; Restore registers
    PLA
    TAY
    PLA
    TAX
    PLA

    RTI

ReadControllerInput:
    ; TODO
    RTS

CassetteBounce:
    ; TODO
    RTS

RotateText:
    ; TODO
    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutines                                                                                         ;;
;; ——————————————————————————————————————————————————————————————————————————————————————————————————— ;;
;;      - IniniteLoop                                                                                  ;;
;;      - LoadBackground                                                                               ;;
;;      - LoadAttributes                                                                               ;;
;;      - LoadPalettes                                                                                 ;;
;;      - LoadSprites                                                                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LoadBackground:
    ;; Reset PPU
    LDA PPUSTATUS

    ;; Tell the PPU where to load data (do it twice for necessary 2 bytes)
    LDA #BG_PORT
    STA PPUADDR
    LDA #ZERO
    STA PPUADDR

    ;; Load the low and high bytes of the background into our variables
    LDA #LOW(background)
    STA backgroundLowByte
    LDA #HIGH(background)
    STA backgroundHighByte

    ;; Loop through the background memory banks
    LDX #ZERO
    LDY #ZERO
.Loop:
    ;; Store that current byte into the PPU
    LDA [backgroundLowByte],Y
    STA PPUDATA

    ;; Keep y++ until overflow
    INY
    CPY #$00
    BNE .Loop

    ;; Keep x++ until .Loop iterates four times to cover the necessary bytes (1024)
    INC backgroundHighByte
    INX
    CPX #$04
    BNE .Loop

    ;; Returns
    RTS

LoadAttributes:
    LDA PPUSTATUS

    ;; Tell PPU where to store attribute data (16-bit address)
    LDA #ATTR_APORT
    STA PPUADDR
    LDA #ATTR_BPORT
    STA PPUADDR

    LDX #$00
.Loop:
    LDA attributes,X
    STA PPUDATA

    INX
    CPX #ATTRB_SIZE
    BNE .Loop

    RTS

LoadPalettes:
    LDA PPUSTATUS

    ;; Tell PPU where to store the palette data
    LDA #PLTTE_PORT
    STA PPUADDR
    LDA #$00
    STA PPUADDR

    LDX #$00
.Loop:
    LDA palettes,X
    STA PPUDATA

    INX
    CPX #PLTTE_SIZE
    BNE .Loop

    RTS

LoadSprites:
    LDX #$00
.Loop:
    LDA sprites,X
    STA SPRITE_RAM,X

    INX
    CPX SPRITE_SIZE
    BNE .Loop

    RTS

background:
    .include "assets/banks/background.asm"

palettes:
    .include "assets/banks/palettes.asm"

attributes:
    .include "assets/banks/attributes.asm"

sprites:
    .include "assets/banks/sprites.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sprite bank files                                                                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .bank 3
    .org $E000
    .org $FFFA
    .dw NMI
    .dw RESET
    .dw 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spritesheet                                                                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .bank 4
    .org $0000
    .incbin "assets/graphics/graphics.chr"