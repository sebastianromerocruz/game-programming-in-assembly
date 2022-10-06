cassetteSprite:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; Our cassette consists of 8 tiles (24 bytes). Below, each tile consists of 4 bytes of data:
    ;;      1. Vertical screen position (top left corner)
    ;;      2. Graphical tile (hex value of the tile in the sprite sheet)
    ;;      3. Attributes (%76543210):
    ;;              - Bits 0 and 1 are for the colour palette
    ;;              - Bits 2, 3, and 4 are not used
    ;;              - Bit 5 is priority (0 shows the sprite in front of the background, and 1 displays it
    ;;                behind it)
    ;;              - Bit 6 flips the sprite horizontally (0 is normal, 1 is flipped)
    ;;              - Bit 7 flips the sprite vertically (0 is normal, 1 is flipped)
    ;;      4. Horizontal screen position (top left corner)
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;; Corners
    .db $70, $08, %00000000, $70  ; upper left
    .db $80, $08, %10000000, $70  ; lower left
    .db $70, $08, %01000000, $88  ; upper right
    .db $80, $08, %11000000, $88  ; lower right

    ;; Middle vertical borders
    .db $78, $09, %00000000, $70  ; left
    .db $78, $09, %01000000, $88  ; right

    ; ;; Middle horizontal borders
    .db $70, $0A, %00000000, $78  ; upper left
    .db $70, $0A, %01000000, $80  ; upper right
    .db $80, $0A, %10000000, $78  ; lower left
    .db $80, $0A, %11000000, $80  ; lower right

    ;; Middle sections
    .db $78, $0B, %00000000, $78  ; left
    .db $78, $0B, %01000000, $80  ; right

    ;; Cassette
    .db $14, $0D, %00000000, $20  ; C
    .db $14, $0E, %00000000, $25  ; A
    .db $14, $0F, %00000000, $2A  ; S
    .db $14, $0F, %00000000, $2A  ; S
    .db $14, $10, %00000000, $2F  ; E
    .db $14, $11, %00000000, $34  ; T
    .db $14, $11, %00000000, $39  ; T
    .db $14, $10, %00000000, $3E  ; E
    