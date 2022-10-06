;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A D D R E S S E S . h                                                                               ;;
;; ——————————————————————————————————————————————————————————————————————————————————————————————————— ;;
;; Author: Sebastián Romero Cruz                                                                       ;;
;; Summer 2022                                                                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	ORG $0000
VARLOC ds 1			; Where in memory our variables will be located

	ORG $C000
CPUADR ds 1			; Where in the CPU’s address space bank 0 is located

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PPU REGISTERS 																								;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ORG $2000
PPUCTRL     ds 1	; PPU control register
PPUMASK		ds 1	; PPU mask register. Controls the rendering of sprites and backgrounds, as well as colour effects.
PPUSTATUS 	ds 1	; PPU status register. This register reflects the state of various functions inside the PPU. It is often used for determining timing.
OAMADDR 	ds 1	; OAM address port. Write the address of OAM you want to access here. Most games just write $00 here and then use OAMDMA.
OAMDATA		ds 1	; Do not write directly to this register in most cases.
PPUSCROLL	ds 1	; PPU scrolling position register. This register is used to to tell the PPU which pixel of the nametable selected through PPUCTRL should be at the top left corner of the rendered screen.
PPUADDR		ds 1	; PPU address register. Because the CPU and the PPU are on separate buses, neither has direct access to the other's memory. The CPU writes to VRAM through a pair of registers on the PPU. First it loads an address into PPUADDR, and then it writes repeatedly to PPUDATA to fill VRAM. 
PPUDATA		ds 1	; PPU data port. RAM read/write data register. After access, the video memory address will increment by an amount determined by bit 2 of $2000. 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; APU REGISTERS 																								;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ORG $4010
DELMODCTRL	ds 1
DELMODDA	ds 1
DELMODADDR	ds 1
DELMODDATA	ds 1
SPRITEDMA	ds 1
VCLOCKSIG	ds 1
CNTRLRONE	ds 1
CNTRLRTWO	ds 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IRQ DISABLE ($E000-$FFFE, EVENS)																				;;
;;	- Writing any value to this register will disable MMC3 interrupts AND acknowledge any pending interrupts. 	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ORG $E000
IRQRD		ds 1

	ORG $FFFA
IRQRE		ds 1