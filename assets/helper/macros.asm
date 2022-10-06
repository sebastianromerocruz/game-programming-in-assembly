;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; M A C R O S . a s m                                                                                 ;;
;; ——————————————————————————————————————————————————————————————————————————————————————————————————— ;;
;; Author: Sebastián Romero Cruz                                                                       ;;
;; Summer 2022                                                                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Title:           Clear Memory                                  ;;
;; Name:            CLEARMEM                                      ;;
;; —————————————————————————————————————————————————————————————— ;;
;; Purpose:         Performs routine vertical blanks and memory   ;;
;;                  clearing at the beginning of every ROM run.   ;;
;;                                                                ;;
;; Parameters:      None                                          ;;
;; Time:            Varies                                        ;;
;; Size:            ~30 bytes                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CLEARMEM   .MACRO
            VBlankOne:
                BIT PPUSTATUS
                BPL VBlankOne

            ClearMem:
                LDA #$00
                STA $0100,X
                STA $0200,X
                STA $0400,X
                STA $0500,X
                STA $0600,X
                STA $0700,X
                LDA #$FE
                STA $0300,X

                INX
                BNE ClearMem

            VBlankTwo:
                BIT PPUSTATUS
                BPL VBlankTwo
           .ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Title:           Clear Sound Registers                         ;;
;; Name:            CLEARMEM                                      ;;
;; —————————————————————————————————————————————————————————————— ;;
;; Purpose:         Performs routine sound register clearing at   ;;
;;                  the beginning of every ROM run.               ;;
;;                                                                ;;
;; Parameters:      None                                          ;;
;; Time:            Varies                                        ;;
;; Size:            TBD                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CLEARSOUND .MACRO
                LDA #$00            ; Initialize sound registers
                LDX #$00
            ClearSoundLoop:
                STA $4000,X
                INX
                CPX #$0F
                BNE ClearSoundLoop
                LDA #$10
                STA $4010 
                LDA #$00
                STA $4011                                                       ;;
                STA $4012                                                       ;;
                STA $4013  
                LDA #%00011111
                STA $4015 
                LDA #$00
                LDX #$00
           .ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Title:           Boolean NOT (!)                               ;;
;; Name:            NOT                                           ;;
;; —————————————————————————————————————————————————————————————— ;;
;; Purpose:         Negates a binary flag, where 1 represents a   ;;
;;                  boolean true and 0 a boolean false.           ;; 
;;                      i.e. flag = !flag                         ;;
;;                                                                ;;
;; Parameters:      \1: The address of the binary flag            ;;
;; Time:            9 Cycles                                      ;;
;; Size:            8 bytes                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NOT     .MACRO
         LDA \1
         EOR #$FF
         AND #$01
         STA \1
        .ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Title:           Stop If Negative Directional Limit Is Reached ;;
;; Name:            STOPNEG                                       ;;
;; —————————————————————————————————————————————————————————————— ;;
;; Purpose:         Loads address \1 and, if subtracting one to   ;;
;;                  it results in a collision (i.e. == \2), jump  ;;
;;                  to \3.                                        ;;
;;                                                                ;;
;; Parameters:      \1: The address of a value                    ;;
;;                  \2: Limit literal value                       ;;
;;                  \3: Jump destination if limit is met          ;;
;; Time:            TBD                                           ;;
;; Size:            TBD                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
STOPNEG .MACRO
         LDA \1
         SEC
         SBC #$01
         CMP #\2
         BEQ \3
        .ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Title:           Stop If Positive Directional Limit Is Reached ;;
;; Name:            STOPNEG                                       ;;
;; —————————————————————————————————————————————————————————————— ;;
;; Purpose:         Loads address \1 and, if adding one to it     ;;
;;                  results in a collision (i.e. == \2), jump to  ;;
;;                  \3.                                        ;;
;;                                                                ;;
;; Parameters:      \1: The address of a value                    ;;
;;                  \2: Limit literal value                       ;;
;;                  \3: Jump destination if limit is met          ;;
;; Time:            TBD                                           ;;
;; Size:            TBD                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
STOPPOS .MACRO
         LDA \1
         CLC
         ADC #$01
         CMP #\2
         BEQ \3
        .ENDM