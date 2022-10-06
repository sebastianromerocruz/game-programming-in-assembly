;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C A S S E T T E . a s m                                                                             ;;
;; ——————————————————————————————————————————————————————————————————————————————————————————————————— ;;
;; Author: Sebastián Romero Cruz                                                                       ;;
;; Summer 2022                                                                                         ;;
;; ——————————————————————————————————————————————————————————————————————————————————————————————————— ;;
;;                                                                                                     ;;
;;                      43 61 72 20 6E 6F 75 73 20 76 6F 75 6C 6F 6E 73 20                             ;;
;;                      6C 61 20 4E 75 61 6E 63 65 20 65 6E 63 6F 72 2C 0A                             ;;
;;                      50 61 73 20 6C 61 20 43 6F 75 6C 65 75 72 2C 20 72                             ;;
;;                      69 65 6E 20 71 75 65 20 6C 61 20 6E 75 61 6E 63 65                             ;;
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
noSkipFlag          .rs 1
cassetteBounceFlag  .rs 1
cassetteUpFlag      .rs 1
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
    STA noSkipFlag
    STA cassetteUpFlag
    STA cassetteBounceFlag
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
    ;; Activate controller
    LDA #CTRL_1_PORT
    STA CNTRLRONE
    LDA #$00
    STA CNTRLRONE

ReadA:
    ;; Check if A is being pressed
    LDA CNTRLRONE
    AND #BINARY_ONE
    BEQ EndReadA

    ;; To avoid very fast palette changes, only do this every other frame
    LDA noSkipFlag
    AND #BINARY_ONE
    BEQ EndReadA

    ;; Switch over to the next palette value (0-3)
    CLC
    LDA paletteCycleCounter
    ADC #$01
    STA paletteCycleCounter

    ;; If we haven't reached 4, we can go manipulate the sprite attribute bits
    CMP #PALETTE_LIM
    BNE .Cycle

    ;; But it we have reached 4, we should reset the counter to 0
    LDA #$00
    STA paletteCycleCounter

.Cycle:
    LDX #$00
    LDY #$00
.ALoop:
    LDA CSSETTE_ATR,X
    ORA #%00000011          ; turn on both palette bits —> XXXXXX11
    EOR #%00000011          ; turn off both palette bits -> XXXXXX00
    EOR paletteCycleCounter ; turn on the current palette (00, 01, 10, or 11)
    STA CSSETTE_ATR,X

.AInnerLoop:
    INX
    INY

    CPY #CHAR_GAP
    BNE .AInnerLoop

    LDY #$00
    CPX #CASSETTE_SIZE
    BNE .ALoop

EndReadA:

    ;; Read button input: A -> B -> Select -> Start -> Up -> Down -> Left -> Right
    LDA CNTRLRONE   ; B
    LDA CNTRLRONE   ; Select
    LDA CNTRLRONE   ; Start

ReadUp:
    LDA CNTRLRONE
    AND #BINARY_ONE
    BEQ EndReadUp

    ;; Upper boundary, so that we don't overlap with text
    STOPNEG CASSETTE_STRT, CASSETTE_YTOP, EndReadUp

    LDX #$00
    LDY #$00
.UpLoop:
    SEC
    LDA CASSETTE_STRT,X
    SBC #$01
    STA CASSETTE_STRT,X

.InnerUpLoop:
    INY
    INX
    CPY #CHAR_GAP
    BNE .InnerUpLoop

    LDY #$00
    CPX #CASSETTE_SIZE
    BNE .UpLoop

EndReadUp:

ReadDown:
    LDA CNTRLRONE
    AND #BINARY_ONE
    BEQ EndReadDown

    STOPPOS CASSETTE_STRT, BORDER_DOWN, EndReadDown

    LDX #$00
    LDY #$00
.DownLoop:
    CLC
    LDA CASSETTE_STRT,X
    ADC #$01
    STA CASSETTE_STRT,X

.InnerDownLoop:
    INY
    INX
    CPY #CHAR_GAP
    BNE .InnerDownLoop

    LDY #$00
    CPX #CASSETTE_SIZE
    BNE .DownLoop

EndReadDown:

ReadLeft:
    LDA CNTRLRONE
    AND #$01
    BEQ EndReadLeft

    STOPNEG CASSETTE_TILE, BRDR_UP_LFT, EndReadLeft

    LDX #$00
    LDY #$00
.LeftLoop:
    SEC
    LDA CASSETTE_TILE,X
    SBC #$01
    STA CASSETTE_TILE,X

.InnerLeftLoop: 
    INX
    INY
    CPY #CHAR_GAP
    BNE .InnerLeftLoop

    LDY #$00
    CPX #CASSETTE_SIZE
    BNE .LeftLoop

EndReadLeft

ReadRight:
    LDA CNTRLRONE
    AND #$01
    BEQ EndReadRight

    STOPPOS CASSETTE_TILE, BORDER_RGHT, EndReadRight

    LDX #$00
    LDY #$00
.RightLoop:
    CLC
    LDA CASSETTE_TILE,X
    ADC #$01
    STA CASSETTE_TILE,X

.RightInnerLoop:
    INX
    INY
    CPY #CHAR_GAP
    BNE .RightInnerLoop

    LDY #$00
    CPX #CASSETTE_SIZE
    BNE .RightLoop


EndReadRight:
    RTS

CassetteBounce:
    ;; Only bounce every other frame
    LDA noSkipFlag
    CMP #BINARY_ONE
    BNE .Skip

    ;; Should we flip direction?
    LDA cassetteBounceFlag
    CMP #BNCE_ANIM_TMR
    BEQ .FlipBounceDirection
    BNE .Bounce

.FlipBounceDirection:
    ;; cassetteUpFlag = !cassetteUpFlag
    NOT cassetteUpFlag
    
    ;; Restart the 0-5 animation timer
    LDA #$00
    STA cassetteBounceFlag

.Bounce:
    ;; Bounce either up or down depending on the value of cassetteUpFlag
    LDA cassetteUpFlag
    CMP #$00
    BEQ .Up
    BNE .Down

    ;; UP-BOUNCE
.Up:

    ;; Upper boundary, so that we don't overlap with text
    STOPNEG CASSETTE_STRT, CASSETTE_YTOP, .End

    LDX #$00
    LDY #$00
.UpLoop:
    SEC
    LDA CASSETTE_STRT,X 
    SBC #BINARY_ONE
    STA CASSETTE_STRT,X

.SpriteUpLoop:
    INY
    INX
    CPY #CHAR_GAP
    BNE .SpriteUpLoop
    
    LDY #$00
    CPX #CASSETTE_SIZE
    BNE .UpLoop

    JMP .End

    ;; DOWN-BOUNCE
.Down:
    STOPPOS CASSETTE_STRT, BORDER_DOWN, .End

    LDX #$00
    LDY #$00
.DownLoop:
    CLC
    LDA CASSETTE_STRT,X
    ADC #BINARY_ONE
    STA CASSETTE_STRT,X

.SpriteDownLoop:
    INY
    INX
    CPY #CHAR_GAP
    BNE .SpriteDownLoop
    
    LDY #$00
    CPX #CASSETTE_SIZE
    BNE .DownLoop

    ;; END BOUNCE
.End:
    CLC
    LDA cassetteBounceFlag
    ADC #BINARY_ONE
    STA cassetteBounceFlag

.Skip:
    RTS

;; Every OTHER frame, move "CASSETTE" string to the right
RotateText:
    ;; Should we skip this frame?
    LDA noSkipFlag
    CMP #BINARY_ONE
    BNE .Skip   ; if so, go to .Skip

    ;; If not, loop through the "CASSETTE" and translate right
    LDX #$00    ; x = 0
    LDY #$00    ; y = 0
.StringLoop:
    ;; Load the location of (0th + x)th letter, and shift it right
    CLC
    LDA STRNG_STRT,X
    ADC #BINARY_ONE
    STA STRNG_STRT,X

.CharacterLoop:
    ;; The next letter's x-coord is CHAR_GAP bytes away
    INX
    INY         ; y++ and x++ while y < CHAR_GAP
    CPY #CHAR_GAP
    BNE .CharacterLoop

    LDY #$00    ; reset y to 0

    ;; Once x == STRNG_SIZE, stop
    CPX #STRNG_SIZE
    BNE .StringLoop

.Skip:
    ; noSkipFlag = !noSkipFlag (see macros.asm)
    NOT noSkipFlag
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