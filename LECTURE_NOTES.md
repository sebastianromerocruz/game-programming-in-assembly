<h2 align=center>Demo Lecture</h2>

<h1 align=center>Game Programming in Assembly</h1>

### 21 Vendémiaire Year CCXXXI

***Song of the day***: _[**Life During Wartime**](https://youtu.be/jLwZvg46jms) by Talking Heads (2022)._

### Sections

1. [**Introduction**](#part-1-introduction)
2. [**Assembly Operations**](#part-2-assembly-operations)
    1. [**Moving Data Around**](#moving-data-around)
    2. [**Branching And Looping**](#branching-and-looping)
3. [**Simple Animation**](#part-3-simple-animation)
4. [**Controller Input**](#part-4-controller-input)
    1. [**Checking For An Active Bit**](#checking-for-an-active-bit)
    2. [**Changing Colour Palettes**](#changing-colour-palettes)
    3. [**Keeping Variables**](#keeping-variables)
    4. [**Manipulating Specific Bits In A Byte**](#manipulating-specific-bits-in-a-byte)
5. [**Conclusion**](#part-5-conclusion)

### Part 1: _Introduction_

> _If you know whence you came, there are absolutely no limitations to where you can go._ 
>
> – James Baldwin.

One of the questions I'm often asked is why I made the transition to computer science if my undergraduate degree was in chemical engineering. While the overarching answer to this can be generally boiled down to a "because I wanted to do something that I _actually_ enjoyed," it was, of course, a much more nuanced process. As a fan of video games and "old tech" in general, one of the first topics in computer science that I became interested in was how Nintendo Entertainment System (NES) era games were made. As I was just barely starting my CS journey at the time, most of what I found was ancient documentation that I barely understood–but, more surprisingly, I found that an NES "homebrew" community existed and _actively_ developed new games using the assembly language of old, 6502.

Now, I, myself, feel like I've only scratched the surface of this field but, as a professor of computer science, I inevitably asked myself the question of whether there was any value in learning (and potentially teaching) NES game development in a modern university setting. I'm sure the answers to this will vary wildly from person to person–the NES is, after all, over forty years old and 6502 assembly is essentially obsolete. I tend to answer this question with another one: is there any value in learning Latin, a dead language?

Regardless of whether you want to answer "yes" or you want to say "no," the reality is that learning Latin not only enhances our cognitive pattern-matching abilities, but it also enhances our English-speaking abilities and helps us understand the finer nuances of language. The parallel in 6502 and NES development is thus: you will likely never use it in your day job, sure, but having the ability to develop playable software with a minimal set of syntactical tools, interacting so closely with our machines, is no mean feat–and you will only gain a more nuanced understanding of the tools that we _do_ use everyday.

Plus, game development is never not fun to get into, regardless of its form.

### Part 2: _Assembly Operations_

Alright, provided that I've at least partially convinced you to follow along, let's get right into the 6502 that we'll need today. Feel free to follow along with this [**virtual assembler**](https://www.masswerk.at/6502/assembler.html), which I will also be using.

#### ***Moving Data Around***

Fundamentally speaking, all assembly programming is about is the transfer of numbers from one place to another. This is certainly true of game development in 6502. For instance, let's say we wanted to put (10)<sub>16</sub> into memory location `2007` (in practical NES development terms, this would be equivalent to telling the PPU to "display" whatever the data point (10)<sub>16</sub> might represent–a sprite, for example).

In 6502, we have different forms of using values–a process known as _addressing_. The two forms of addressing that we need to be aware of are:

- **Immediate Addressing**: Preceded by a `#`, these values are literals used directly to perform computations.
- **Absolute Addressing**: A full 16-bit address is specified and the byte at that address is used to perform a computation.

With this in mind, take a look at the following lines of code:

```asm
    LDA #$10   ; load hex 10 into accumulator
    STA $2007  ; store the value of accumulator to location 2000
```

<sub>**Code Block 1**: Note that, similar to many modern assembly languages, instructions are preceded by a tab of whitespace.</sub>

In 6502 assembly, hexadecimal values are preceded by a `$`, and binary values by `%`. `%00000001` is, for example, (1)<sub>2</sub>.

If we take a look at the result of this operation in our virtual assembler:

![load-1](assets/images/load-1.png)
![load-2](assets/images/load-2.png)
![load-3](assets/images/load-3.png)
![load-4](assets/images/load-4.png)

<sub>**Figures 1 – 4**: The emulated result of the assembly and running code block 1.</sub>

#### ***Branching and Looping***

Perfect. Now we need a way to automate these operations. In high-level programming languages, this would be the job of a `while`- or a `for`-loop. We don't have such control-flow structures in assembly, so instead we must manually tell the program to return to an earlier point in our program if a certain condition is true. This is known as **branching**. For this, we can make use of either of the following 6502 instructions:

- **`CMP`/ `CPY` / `CPX` (compare with accumulator / Y register / X register)**: Compares the current value stored inside the accumulator / Y register / X register with another.
- **`BNE` (branch on not equal)**: Go to a certain location in the program, denoted by a label, if the result of a comparison is false.
- **`BEQ` (branch on equal)**: Go to a certain location in the program, denoted by a label, if the result of a comparison is true.

With these in mind, the way we could loop over something, say, four times, would be as follows:

```asm
LIMIT = $04     ; we can assign labels to addresses

    LDX #$00    ; x = 0
Loop:
    INX  ; x++
    CPX #LIMIT  ; x == LIMIT

                ; the code that we want to loop would go here

    BNE Loop    ; if x != LIMIT, jump to the Loop label
```

<sub>**Code Block 2**: The code below the `Loop` label would run four times.</sub>

Let's run this code in our virtual assembler and load a number into the accumulator _after_ the loop is done as a sanity check. This should only happen if the loop has ended:

![loop-1](assets/images/loop-1.png)
![loop-2](assets/images/loop-2.png)
![loop-3](assets/images/loop-3.png)
![loop-4](assets/images/loop-4.png)
![loop-5](assets/images/loop-5.png)
![loop-6](assets/images/loop-6.png)
![loop-7](assets/images/loop-7.png)

<sub>**Figures 5 – 11**: The emulated result of the assembly and running code block 2. Notice that, as figure 11 shows, (10)<sub>16</sub> isn't loaded into the accumulator until after the loop is through. This can be used for sentinel control (i.e. a `while`-loop).</sub>

So, if we used one of our three registers to create one loop, how would we create a nested loop? Repeat the exact same process with the other two registers!

```asm
INNER = $04
OUTER = $03

    LDA #$00        ; a = 0

    LDX #$00        ; x = 0
    LDY #$00        ; y = 0
OuterLoop:
    INX             ; x++ while y < INNER
InnerLoop:
    INY             ; y++ while y < INNER

    CLC             ; clear carry flag
    ADC #2          ; let's add 2 to the accumulator every time the inner loop runs

    CPY #INNER
    BNE InnerLoop

    LDY #$00        ; reset y to 0

    CPX #OUTER      ; Once x == OUTER, stop
    BNE OuterLoop
```

<sub>**Code Block 3**: A nested loop.</sub>

![nested](assets/images/nested.png)

<sub>**Figure 12**: Our registers after the execution of code block 3. Notice that whenever we add a number to the accumulator (`ADC` / add with carry), we need to clear the carry flag (`CLC`) in case the previous operation left a carry.</sub>

This is essentially all we need to know to get started with some simple development: the ability to load data en-masse. Let's get right to it.

### Part 3: _Simple Animation_

If we assemble and run [**cassette.asm**](cassette.asm), we should see the following screen:

```commandline
➜  game-programming-in-assembly git:(main) ✗ make    
nesasm cassette.asm
NES Assembler (v3.1)

pass 1
pass 2
➜  game-programming-in-assembly git:(main) ✗ make run
open cassette.nes -a nestopia
```
![static](assets/images/static.png)

<sub>**Figure 13**: A nice cassette sprite, along with a banner with the word "cassette", doing absolutely nothing on screen.</sub>

The spritesheet that went into this design can be seen below:

![spritesheet](assets/images/spritesheet.png)

<sub>**Figure 14**: Created using [**this**](https://eonarheim.github.io/NES-Sprite-Editor/) online tool. Notice that only four sprites went into creating our cassette sprite, which is actually 12 sprites put together. More on how that works later.</sub>

Let's start with getting some basic movement. I would like the "cassette" banner to move constantly to the right and loop around to the left of the screen, as if it were a stock market signboard. This would imply a couple of things:

1. Loading up the data of each specific sprite.
2. Accessing each sprite's horizontal location sub-data.
3. Increasing its value in the direction that corresponds to the right direction (translation transformation in game programming parlance).
4. Saving the result back into the sprites's corresponding location in memory.

How are we to accomplish this? Elsewhere in the program, the [**data**](assets/banks/sprites.asm) concerning the location and orientation of these sprites was loaded up into a specific location exclusive to sprite data (in this program, the location chosen was `$0300`, or `SPRITE_RAM`). Lets take a look at the data of the first letter of `cassette`:

```asm
    .db $14, $0D, %00000000, $20  ; C
```

What can we glean from this? `db` simply means "define byte(s)", and is followed by four bytes corresponding to the `c` sprite. Each sprite consists, then, of 4 bytes of data:

1. Vertical screen position (top left corner)
2. Graphical tile (hex value of the tile [**in the sprite sheet**](assets/images/sprite-data.png))
3. Attributes (`%76543210`):
    - Bits 0 and 1 are for the colour palette
    - Bits 2, 3, and 4 are not used
    - Bit 5 is priority (0 shows the sprite in front of the background, and 1 displays it behind it)
    - Bit 6 flips the sprite horizontally (0 is normal, 1 is flipped)
    - Bit 7 flips the sprite vertically (0 is normal, 1 is flipped)
4. Horizontal screen position (top left corner)

Awesome, so it looks like sprite number 4 is our ticket forwards. Inside [**cassette.asm**](cassette.asm), locate the following label, which is where we will program our banner movement:

```asm
RotateText:
    ; TODO
    RTS
```

<sub>**Code Block 4**: Here, `RTS` basically marks the end of our `RotateText` subroutine, so it will need to be the last line. Just note that the `RTS` instruction implies that `RotateText` was "called" from somewhere else in the program. In this case, it was from the `NMI` routine, which runs every single frame.</sub>

Cool, so let's start implementing our 4-step plan from above. Since we're not only dealing with one sprite, but rather eight adjacent ones, what programming structure that we just learned can we use to apply the same process to all of them? A loop!

```asm
RotateText:
    LDX #$00    ; x = 0
.StringLoop:
    INX

    ; TODO - Loading up the data of each specific sprite.
    ; TODO - Accessing each sprite's horizontal location sub-data.
    ; TODO - Increasing its value in the direction that corresponds to the right direction (translation transformation in game programming parlance).
    ; TODO - Saving the result back into the sprites's corresponding location in memory.

    CPX ; TODO - How many times should this loop run?
    BNE .StringLoop
```

<sub>**Code Block 5**: Here, the `.` before `StringLoop` denotes that it is a section belonging to the `RotateText` subroutine.</sub>

In 6502, the only register that can perform math operations is the accumulator, so it is always a good idea to use it to do stuff like translations (even if it's just an increment). We said earlier that the sprites were all saved in memory starting at location `$0300`. If the `c` sprite were the first sprite to be loaded up, then this would be the first location that we would load, but the `c` sprite is actually the 14th sprite to be saved into memory, so it's starting location is actually at memory location `$0333`. Let's apply the label `STRNG_STRT` to this location for convenient:

```
    STRNG_STRT
     ($0300)
        v
... ––– C1 ––– C2 ––– C3 ––– C4
                              |
        A4 ––– A3 ––– A2 ––– A1
        |
        S1 ––– S2 ––– S3 ––– S4
                              |
        T4 ––– T3 ––– T2 ––– T1
        |
        E1 ––– E2 ––– E3 ––– E4 ––– ...
```

<sub>**Figure 15**: A visualisation of how each of the four bytes dedicated to each letter are stored in memory–contiguously (that is, stored right next to each other in memory).</sub>

6502 assembly has this gnarly way of addressing data that is contiguous called **absolute indexed** addressing. This effectively means that we can offset which location we are accessing by a certain index. For example, if we wanted to load the value stored 3 bytes away from location `$0100`, we would do the following:

```asm
    LDA $0100,#$03
```

This looks like perfect for our needs, since we know our starting point. We can also figure out the amount of times this loop will run with some simple math. If there are 4 letters in the word "cassette", and each letter comprises for 4 bytes, then the "size" of this sprite string is 8 × 4 = (32)<sub>10</sub> = (20)<sub>16</sub>. Let's call this value `STRNG_SIZE`:

```asm
RotateText:
    LDX #$00 ; x = 0
    LDY #$00 ; y = 0
.StringLoop:
    LDA STRNG_STRT,X  ; Load the location of (0th + x)th letter

    ; TODO - Increasing its value in the direction that corresponds to the right direction (translation transformation in game programming parlance).
    ; TODO - Saving the result back into the sprites's corresponding location in memory.

    INX              ; x++

    CPX #STRNG_SIZE  ; Once x == STRNG_SIZE, stop
    BNE .StringLoop

    RTS
```

<sub>**Code Block 6**: Here, we are offsetting the location `LDA` is loading by the current value stored in the x register.</sub>

Speaking of offsets, we have a bit of a problem here. `INX` is incrementing the value stored in the x register every time it is called within the loop. This would be great if every sprite's horizontal location byte were located right next to each other, but as we can see in figure 15, this is not the case. Each sprite's first byte contains the horizontal location, but it is then followed by the 3 more bytes of information before we reach the next sprite's horizontal location byte.

Meaning: we have to increment not by 1, but by 4. The problem here is that the only register in the 6502 microprocessor that is able to perform arithmetic and / or be offset by a value is the accumulator, so we can't simply just add 4 to the x register. It was when I first faced this limitation that I really started to feel the limitations of the 6502 assembly language, but it need not be a bad thing. Working with limitations is how we get creative, and in this case, the solution is not too far out.

Instead of adding 4 to the x register in one go, let's add 1 to it four times. In other words, we need another loop inside of our main loop:

```asm
RotateText:
    LDX #$00           ; x = 0
    LDY #$00           ; y = 0
.StringLoop:
    LDA STRNG_STRT,X   ; load the location of (0th + x)th letter

    CLC                ; clear the carry flag
    ADC #$01           ; add 1 to the value stored in the acc (aka translate to the right by 1)
    STA STRNG_STRT,X   ; store the incremented value the location of (0th + x)th memory location

.CharacterLoop:
    INX                ; x++ while y < 4
    INY                ; y++ while y < 4

    CPY #$04           ; once y == 4, stop CharacterLoop
    BNE .CharacterLoop

    LDY #$00           ; reset y to 0

    CPX #STRNG_SIZE    ; once x == STRNG_SIZE, stop StringLoop
    BNE .StringLoop

    RTS
```

<sub>**Code Block 7**: Our finished `RotateText` subroutine.</sub>

Let's see it in action!

![banner](assets/images/banner.gif)

<sub>**Figure 16**: Animation in assembly: complete!</sub>

### Part 4: _Controller Input_

Okay, so we know how to make things move in NES games, but the whole point of video games is having the _player_ make things happen with the controller. Reading for controller input is surprisingly simple when developing for the NES. One simply just has to, every frame:

1. Activate the controller port.
2. Check if any of the buttons of the NES controller are pressed. This is done in the following order:
    1. Check if A is pressed.
    2. Check if B is pressed.
    3. Check if the start button is pressed.
    4. Check if the select button is pressed.
    5. Check if the down button is pressed.
    6. Check if the left button is pressed.
    7. Check if the right button is pressed.

That's basically it as far as check for button presses is concerned. The function skeleton in our assembly file, then...

```asm
ReadControllerInput:
    ; TODO
    RTS
```

Can start to fill up a little. We can activate the controller by loading up the literal value of 1 into the register responsible for controller 1 (`$4016`, which we'll label as `CNTRLRONE` here). However, since the CPU's address bus requires a 16-bit address, we have to "fill out" this activation sequence by loading a 0 into the same address:

```asm
ReadControllerInput:
    LDA #$01         ; activate controller by loading 1
    STA CNTRLRONE    ; into $4016 and
    LDA #$00         ; "pad" the activation with a 0
    STA CNTRLRONE    ; since it's a 16-bit address
```

After the controller is activation, loading the value stored in `CNTRLRONE` again, once for each of the seven button, will let us know if the button was pressed. 

```asm
ReadControllerInput:
    LDA #$01         ; activate controller by loading 1
    STA CNTRLRONE    ; into $4016 and
    LDA #$00         ; "pad" the activation with a 0
    STA CNTRLRONE    ; since it's a 16-bit address

    ;; Read button input: A -> B -> Select -> Start -> Up -> Down -> Left -> Right
    LDA CNTRLRONE   ; A
    LDA CNTRLRONE   ; B
    LDA CNTRLRONE   ; Select
    LDA CNTRLRONE   ; Start
    LDA CNTRLRONE   ; Up
    LDA CNTRLRONE   ; Down
    LDA CNTRLRONE   ; Left
    LDA CNTRLRONE   ; Right

    RTS
```

<sub>**Code Block 8**: Loading either 1 or 0 from each of the button presses—although we are not actually down anything with the result.</sub>

Let's say a 1 is loaded for button A. What does this mean? Here, we introduce one of my favourite things about NES development: bitwise operations.

#### ***Checking For An Active Bit***

The byte loaded from of `CNTRLRONE` either has a 1 at its most significant bit (rightmost, since the 6502 is [**little endian**](https://en.wikipedia.org/wiki/Endianness)) if a specific button is pressed, and a 0 if it isn't pressed. Therefore, we must find a way to check if that bit and only that bit is switched on to 1. For this, we perform an `and` operation with this value against a binary `%00000001`:

```
CNTRLRONE  --> XXXXXXX0                | --> XXXXXXX1
                 AND                   |       AND
BINARY_ONE --> 00000001                | --> 00000001
———————————————————————————————————————————————————————————————
result     --> XXXXXXX0 (not pressed)  | --> XXXXXXX1 (pressed)
```

<sub>**Figure 17**: The two potential results of a bitwise `and` operation on `CNTRLRONE` and (1)<sub>2</sub>, where `X` represents in this case an irrelevant digit.</sub>

Let's handle moving to the right if the player presses the right button first, since we're already aquatinted with the basics of this operation:

```asm
ReadControllerInput:
    LDA #$01         ; activate controller by loading 1
    STA CNTRLRONE    ; into $4016 and
    LDA #$00         ; "pad" the activation with a 0
    STA CNTRLRONE    ; since it's a 16-bit address

    ;; Read button input: A -> B -> Select -> Start -> Up -> Down -> Left -> Right
    LDA CNTRLRONE   ; A
    LDA CNTRLRONE   ; B
    LDA CNTRLRONE   ; Select
    LDA CNTRLRONE   ; Start
    LDA CNTRLRONE   ; Up
    LDA CNTRLRONE   ; Down
    LDA CNTRLRONE   ; Left

ReadRight:
    LDA CNTRLRONE   ; Right

    ; Translate right

EndReadRight:
```

To perform an `and` operation, and branch straight to `EndReadRight` if the right button _wasn't_ pressed, we do the following:

```asm
ReadRight:
    LDA CNTRLRONE     ; load either a 0 or a 1
    AND #%00000001    ; AND with binary 1
    BEQ EndReadRight  ; if we don’t use a CMP operation before BEQ, it will branch if the value is equal to zero

    ; Translate right

EndReadRight:
```

<sub>**Code Block 9**: This of this as an if-statement checking for a button press that will `return` right away if there wasn't an actual press detected.</sub>

Nice. Now, we perform the same steps to move all of the cassette sprites to the right as we did with the banner:

1. Load the horizontal location of the current sprite, starting at the location of the first sprite in the sequence (in this case, `$0303`, labelled as `CASSETTE_TILE`), offset by the value stored in the x register.
2. Translate to the right by 1 unit by adding 1 to the loaded value.
3. Store the incremented value back into the corresponding memory location.
4. "Skip" four bytes to get to the next sprite's horizontal location until the "cassette size" has been reached.

In code:

```asm
ReadRight:
    LDA CNTRLRONE        ; load either a 0 or a 1
    AND #%00000001       ; AND with binary 1
    BEQ EndReadRight     ; if we don’t use a CMP operation before BEQ, it will branch if the value is equal to zero

    LDX #$00
    LDY #$00
.RightLoop:
    LDA CASSETTE_TILE,X  ; load the horizontal location of the current sprite
    
    CLC
    ADC #$01             ; translate to the right by 1 unit by adding 1 to the loaded value.
    STA CASSETTE_TILE,X  ; store the incremented value back into the corresponding memory location.

; "skip" four bytes to get to the next sprite's horizontal location...
.RightInnerLoop:
    INX
    INY
    CPY #$04
    BNE .RightInnerLoop

    LDY #$00
    CPX #CASSETTE_SIZE    ; ...until the "cassette size" has been reached
    BNE .RightLoop

EndReadRight:
```

<sub>**Code Block 10**: Translating to the right _only if_ the right button is pressed.</sub>

Translating to the left is essentially the same exact operation, except we decrement by one instead of incrementing. For vertical movement, our starting memory location is `$0300` (`CASSETTE_STRT`) instead of `CASSETTE_TILE`:

```asm
ReadUp:
    LDA CNTRLRONE
    AND #%00000001
    BEQ EndReadUp

    LDX #$00
    LDY #$00
.UpLoop:
    LDA CASSETTE_STRT,X

    SEC
    SBC #$01
    STA CASSETTE_STRT,X

.InnerUpLoop:
    INY
    INX
    CPY #$04
    BNE .InnerUpLoop

    LDY #$00
    CPX #CASSETTE_SIZE
    BNE .UpLoop

EndReadUp:

ReadDown:
    LDA CNTRLRONE
    AND #%00000001
    BEQ EndReadDown

    LDX #$00
    LDY #$00
.DownLoop:
    LDA CASSETTE_STRT,X

    CLC
    ADC #$01
    STA CASSETTE_STRT,X

.InnerDownLoop:
    INY
    INX
    CPY #$04
    BNE .InnerDownLoop

    LDY #$00
    CPX #CASSETTE_SIZE
    BNE .DownLoop

EndReadDown:

ReadLeft:
    LDA CNTRLRONE
    AND #%00000001
    BEQ EndReadLeft

    LDX #$00
    LDY #$00
.LeftLoop:
    LDA CASSETTE_TILE,X

    SEC
    SBC #$01
    STA CASSETTE_TILE,X

.InnerLeftLoop: 
    INX
    INY
    CPY #$04
    BNE .InnerLeftLoop

    LDY #$00
    CPX #CASSETTE_SIZE
    BNE .LeftLoop

EndReadLeft:
```

<sub>**Code Block 11**: Translating upwards, downwards, and to the left _only if_ the their corresponding buttons are pressed. Notice that, in the case of subtraction, we have to _set_ the carry flag instead of clearing it.</sub>

#### Changing Colour Palettes

Let's do something more interesting now. Remember the four bytes associated to each sprite? Let's take a look at the ones for the cassette "meta-sprite"

```asm
    ;; Corners
    .db $70, $08, %00000000, $70  ; upper left
    .db $80, $08, %10000000, $70  ; lower left
    .db $70, $08, %01000000, $88  ; upper right
    .db $80, $08, %11000000, $88  ; lower right

    ;; Middle vertical borders
    .db $78, $09, %00000000, $70  ; left
    .db $78, $09, %01000000, $88  ; right

    ;; Middle horizontal borders
    .db $70, $0A, %00000000, $78  ; upper left
    .db $70, $0A, %01000000, $80  ; upper right
    .db $80, $0A, %10000000, $78  ; lower left
    .db $80, $0A, %11000000, $80  ; lower right

    ;; Middle sections
    .db $78, $0B, %00000000, $78  ; left
    .db $78, $0B, %01000000, $80  ; right
```

<sub>**Code Block 12**: Data bank for the sprites that comprise our cassette meta-sprite.</sub>

We spoke earlier about how, in the third byte, the two most significant (leftmost) bits correspond to the palette being used to colour the sprite. The 6502 allows for up to four palettes to be assigned to a particular sprite (i.e. `00` for palette 1, `01` for palette 2, `10` for palette 3, and `11` for palette 4). So, in code block 12, we can see that all sprites are currently using colour palette 1 (`00`).

How about we try to do this: every time the player clicks on the A-button, the palette being applied to the player will rotate between the four available palettes. We can think of this is as a game mechanic; maybe every palette represents a different power-up our cassette protagonist can use. Fundamentally speaking, the frame of this process is the same as how we achieved movement: we load up the appropriate byte (`CSSETTE_ATR`, or `$0302`), perform the appropriate steps to change the palette, skip four bytes to reach the next sprite's attribute byte, and repeat the process for each of the sprites that comprise the cassette:

```asm
ReadA:
    LDA CNTRLRONE
    AND #%00000001
    BEQ EndReadA

    ; TODO - Switch over to the next palette value (0-3)

.ALoop:
    LDA CSSETTE_ATR,X

    ; TODO - Change bits 1 and 2 from the current attribute byte

    STA CSSETTE_ATR,X

.AInnerLoop:
    INX
    INY

    CPY #CHAR_GAP
    BNE .AInnerLoop

    LDY #$00
    CPX #$04
    BNE .ALoop

EndReadA:
```

<sub>**Code Block 13**: Cycle through palettes 0 - 3 (i.e. `00` - `11`) and apply it to all the cassette sprites with a loop.</sub>

#### ***Keeping Variables***

What we would like to do first is to store, somewhere in memory, a value that tells us which palette to apply at any given time that the A button is pressed. That is, if palette 2 (`10`) is selected, `ReadA` should switch over to palette 3 (`11`). If A is pressed again, it should cycle back to 0 (`00`). In high-level programming languages, a "global" variable of sorts would be ideal for this job. Can we do something similar in 6502 assembly?

Sure can. Close to the top of our `asm` file you will find a section where I am creating the variables necessary for this code to run the way it does at the moment:

```asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables                                                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .rsset VARLOC
music               .rs 16
backgroundLowByte   .rs 1
backgroundHighByte  .rs 1
```

<sub>**Code Block 14**: Here, I am basically telling the microprocessor that, starting at location `VARLOC`, I want 16 bytes reserved for my variable `music`, and 1 byte for both `backgroundLowByte` and `backgroundHighByte`, respectively.</sub>

Let's add one more variable here to keep track of our current palette value, and initialise it to 0 (i.e. `00`):

```asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Variables                                                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .rsset VARLOC
music               .rs 16
backgroundLowByte   .rs 1
backgroundHighByte  .rs 1
paletteCycleCounter .rs 1

;; Some code...

RESET:
    ;; Some more code...

    ; Loading 0 to the variable
    LDA #$00
    STA paletteCycleCounter 

    ;; Some more code
```

<sub>**Code Block 15**: Add these 3 lines of code to these sections of `cassette.asm`.</sub>

So, now, just like with the sprite data, we can access the value stored in this variable any time we want.

The steps are now to:

1. Load up the current value of `paletteCycleCounter`.
2. Switch over to the next palette value (0-3) by adding 1 to it.
3. If we haven't reached 4 (i.e. `paletteCycleCounter < 4`), change the palette bits of every sprite to match the value of `paletteCycleCounter`. If we _have_ reached 4, we should reset `paletteCycleCounter` to 0.

```asm
    ; Switch over to the next palette value (0-3)
    CLC
    LDA paletteCycleCounter
    ADC #$01
    STA paletteCycleCounter

    ; If we haven't reached 4, we can go manipulate the sprite attribute bits
    CMP #PALETTE_LIM
    BNE .Cycle

    ; But if we have reached 4, we should reset the counter to 0
    LDA #$00
    STA paletteCycleCounter
.Cycle:
    LDX #$00
    LDY #$00

    ; The rest of the A button instructions...
```

<sub>**Code Block 16**: Cycling through 0, 1, 2, and 3. Here `PALETTE_LIM` has a value of `0`.</sub>

#### ***Manipulating Specific Bits In A Byte***

This part is super fun. Checking for a button press is relatively easy, since we only have to perform an `and` operation against a specific byte. Changing two specific bits, while leaving the other six completely untouched, requires a bit of a finer touch. Nothing we can't handle though.

Our goal is the following: since `paletteCycleCounter` is keeping the value of `00`, `01`, `10`, or `11`, _if we were able to get **bits 1 and 2 to both be zeros**, a exclusive-or (`xor`) operation with the value of `paletteCycleCounter` would do the trick_. So our goal is to, regardless of their current value, get bits 1 and 2 to both be zero:

```
CSSETTE_ATR ----------> XXXXXX00 | --> XXXXXX01 | --> XXXXXX10 | --> XXXXXX11
                          ???    |       ???    |       ???    |       ???
                        ???????? | --> ???????? | --> ???????? | --> ????????
——————————————————————————————————————————————————————————————————————————————
result ---------------> XXXXXX00 | --> XXXXXX00 | --> XXXXXX00 | --> XXXXXX00
```

<sub>**Figure 18**: What operation (`???`)—and using what value as its second operand (`????????`)—will get any permutation of the last two bits to end up being zero?</sub>

One way to do this requires not one, but two simple bitwise operations. 

1. It turns out that it is easy to get any one bit to be `1` by performing an `or` operation on it against a `1`. This gets bits 1 and 2, regardless of whether they are `1` or `0`, to turn to `1`.
2. From there, we can perform an `xor` operation on that bit against a `1`. Since exclusive-or requires one `true` and one `false`, the result of this operation will be `false`, zeroing out our bit.

```
CSSETTE_ATR ----------> XXXXXX00 | --> XXXXXX01 | --> XXXXXX10 | --> XXXXXX11
                           OR    |        OR    |        OR    |        OR
                        00000011 | --> 00000011 | --> 00000011 | --> 00000011
———————————————————————————————————————————————————————————————————————————————
step one -------------> XXXXXX11 | --> XXXXXX11 | --> XXXXXX11 | --> XXXXXX11
                           XOR   |        XOR   |        XOR   |        XOR
                        00000011 | --> 00000011 | --> 00000011 | --> 00000011
———————————————————————————————————————————————————————————————————————————————
step two -------------> XXXXXX00 | --> XXXXXX00 | --> XXXXXX00 | --> XXXXXX00
                           XOR   |        XOR   |        XOR   |        XOR
paletteCycleCounter --> 00000000 | --> 00000001 | --> 00000010 | --> 00000011
———————————————————————————————————————————————————————————————————————————————
NEW PALETTE NUMBER ---> XXXXXX00 | --> XXXXXX01 | --> XXXXXX10 | --> XXXXXX11
```

<sub>**Figure 19**: A surgical bitwise operation; the other bits are never touched!</sub>

The 6502 instructions `ORA` (or) and `EOR` (exclusive-or) can help us here:

```asm
ReadA:
    LDA CNTRLRONE
    AND #%00000001
    BEQ EndReadA

    ; Switch over to the next palette value (0-3)
    CLC
    LDA paletteCycleCounter
    ADC #$01
    STA paletteCycleCounter

    ; If we haven't reached 4, we can go manipulate the sprite attribute bits
    CMP #PALETTE_LIM
    BNE .Cycle

    ; But if we have reached 4, we should reset the counter to 0
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

    STA CSSETTE_ATR,X

.AInnerLoop:
    INX
    INY

    CPY #$04
    BNE .AInnerLoop

    LDY #$00
    CPX #CASSETTE_SIZE
    BNE .ALoop

EndReadA:
```

<sub>**Code Block 17**: Our complete A button "handler".</sub>

And lo! We've got our first game mechanic going!

![palette-flipper](assets/images/palette-flipper.gif)

<sub>**Figure 20**: Personally, I think it looks super cute.</sub>

### Part 5: _Conclusion_

If I had to the hobby project that gave me the most grief—and simply because its documentation is so decentralised and obscure—it would be NES development. I think, honestly, that this is a shame. The practice of teaching and learning about concepts like memory management and computer architecture can be enhanced and made fun by simply relating it back to these very real, historical practices. At least, for a lot of us who grew up with video games from the NES, SNES, and even Nintendo 64 era, being this intimately acquainted with the machines that brought us so much joy makes us appreciate them even more.

You will surely have noticed that what I have talked about in this lecture is but a small part of what went into creating this ROM (the complete version can be found [**here**](https://github.com/sebastianromerocruz/CASSETTE.nes)). If you would like to know more about my journey in self-learning NES development, click [**here**](https://github.com/sebastianromerocruz/famicom-6502). Either way, I hope you have enjoyed yourself. Thank you for listening 💜.