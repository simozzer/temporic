

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _scrollColumnUp: scrolls an individual column 1 position up. The
; character in the top position will appear on the bottom
; Params: 
;   effect_index: The index of the column to be scrolled
; Returns: null
; -------------------------------------------------------------------
_scrollColumnUp
.(
  ; get the character from the 1st row and store it
  ldy #0
  lda ScreenLineLookupLo,y
  sta _line_start_lo
  lda ScreenLineLookupHi,y
  sta _line_start_hi
  ldy effect_index
  lda (_line_start),y
  sta temp_effect_char

  ; move all characters up one position
  lda #1
  sta _temp_row_index
  __loopy
  ldy _temp_row_index
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,y
  sta _line_start_hi
  ldy effect_index

  ; pull the char for the current line and store it
  lda (_line_start),y
  sta _temp_effect_char

  ldy _temp_row_index
  dey
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,y
  sta _line_start_hi
  ; retrieve the stored char and put it on the previous line
  ldy effect_index
  lda _temp_effect_char
  sta (_line_start),y

  ; go to the next line
  inc _temp_row_index
  lda _temp_row_index
  cmp #27
  bne __loopy

  ; put the character which was on the first row onto the last
  ldy #26
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,y
  sta _line_start_hi

  lda temp_effect_char
  ldy effect_index
  sta (_line_start),y

  rts
.)



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _scrollColumnDown: scrolls an individual column 1 position down. The
; character in the bottom position will appear on the top
; Params: 
;   effect_index: The index of the column to be scrolled
; Returns: null
; -------------------------------------------------------------------
_scrollColumnDown
.(
  ; get the character from the last row and store it
  ldy #26
  lda ScreenLineLookupLo,y
  sta _line_start_lo
  lda ScreenLineLookupHi,y
  sta _line_start_hi
  ldy effect_index
  lda (_line_start),y
  sta temp_effect_char

  ; move all characters down one position
  lda #25
  sta _temp_row_index
  _loop_y
  ldy _temp_row_index
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,y
  sta _line_start_hi
  ldy effect_index

  ; pull the char for the current line and store it
  lda (_line_start),y
  sta _temp_effect_char

  ldy _temp_row_index
  iny
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,y
  sta _line_start_hi
  ; retrieve the fetched character on put it on the next line
  ldy effect_index
  lda _temp_effect_char
  sta (_line_start),y

  ; go to the next line
  dec _temp_row_index
  lda _temp_row_index
  cmp #0
  bpl _loop_y

  ; put the character which was on the last row onto the first
  ldy #0
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,y
  sta _line_start_hi

  lda temp_effect_char
  ldy effect_index
  sta (_line_start),y

  rts
.)




; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; shredScreenVertical: scrolls alternate columns in different 
; directions, and continues until the screen is back in its
; original state
; Returns: null
; -------------------------------------------------------------------
shredScreenVertical
.(
  lda #0
  sta effect_temp

  screenLoop
  lda #2
  sta effect_index

  tay
  lineLoop
  jsr _scrollColumnDown
  inc effect_index
  lda effect_index
  cmp #37
  beq linesDone
  jsr _scrollColumnUp
  inc effect_index

  lda effect_index
  cmp #38
  bne lineLoop

  linesDone
  inc effect_temp
  lda effect_temp
  cmp #27
  bne screenLoop

  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _wrapColumnUp: scrolls an individual column up until the line is returned
; to its original state
; Params: 
;   effect_index: The index of the column to be scrolled
; Returns: null
; -------------------------------------------------------------------
_wrapColumnUp
.(
  lda #0
  sta inner_effect_temp
  loop
  jsr _scrollColumnUp
  jsr _effectDelay
  inc inner_effect_temp
  lda inner_effect_temp
  cmp #27
  bne loop
  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _wrapColumnDown: scrolls an individual column down until the line is returned
; to its original state
; Params: 
;   effect_index: The index of the column to be scrolled
; Returns: null
; -------------------------------------------------------------------
_wrapColumnDown
.(
  lda #0
  sta inner_effect_temp
  loop
  jsr _scrollColumnDown
  jsr _effectDelay
  inc inner_effect_temp
  lda inner_effect_temp
  cmp #27
  bne loop
  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; shredScreenUp: scrolls each column up, in turn, until the screen
; is returned to its original state
; original state
; Returns: null
; -------------------------------------------------------------------
shredScreenUp
.(
  lda #2
  sta effect_index
  loop
  jsr _wrapColumnUp
  inc effect_index

  lda effect_index
  cmp #39
  bne loop

  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; shredScreenDown: scrolls each column down, in turn, until the screen
; is returned to its original state
; original state
; Returns: null
; -------------------------------------------------------------------
shredScreenDown
.(
  lda #2
  sta effect_index
  loop
  jsr _wrapColumnDown
  inc effect_index

  lda effect_index
  cmp #39
  bne loop

  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _scrollScreenUp: scrolls entire screen 1 position up. The
; characters in the top position will appear on the bottom
; Params: none
; Returns: null
; -------------------------------------------------------------------
_scrollScreenUp
.(
  ; copy 1st row into buffer
  ldy #0
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,y
  sta _line_start_hi

  ldy #2
  copyFirstLineLoop
  lda (_line_start),Y
  sta _temp_row_data,y
  iny
  cpy #38
  bne copyFirstLineLoop

  ; copy rest of the rows up
  ldy #1
  sty _temp_row_index

  copyAllLinesLoop
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,y
  sta _line_start_hi
  dey
  lda ScreenLineLookupLo,Y
  sta _secondary_line_start_lo
  lda ScreenLineLookupHi,Y
  sta _secondary_line_start_hi
  iny
  iny
  sty _temp_row_index

  ldy #2
  copyCharsInLineLoop
  lda (_line_start),Y
  sta (_secondary_line_start),Y
  iny
  cpy #39
  bne copyCharsInLineLoop

  ldy _temp_row_index
  cpy #27
  bne copyAllLinesLoop

  ;copy data from buffer onto last row
  ldy #26
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,Y
  sta _line_start_hi

  ldy #2
  plotLastRow
  lda _temp_row_data,Y
  sta (_line_start),Y
  iny
  cpy #38
  bne plotLastRow

  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _scrollScreenDown: scrolls entire screen 1 position down. The
; characters in the bottom position will appear on the top
; Params: none
; Returns: null
; -------------------------------------------------------------------
_scrollScreenDown
.(
  ; copy last row into buffer
  ldy #26
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,y
  sta _line_start_hi

  ldy #2
  copyLastLineLoop
  lda (_line_start),Y
  sta _temp_row_data,y
  iny
  cpy #38
  bne copyLastLineLoop

  ; copy rest of the rows down
  ldy #25
  sty _temp_row_index

  copyAllLinesLoop
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,y
  sta _line_start_hi
  iny
  lda ScreenLineLookupLo,Y
  sta _secondary_line_start_lo
  lda ScreenLineLookupHi,Y
  sta _secondary_line_start_hi
  dey
  dey
  sty _temp_row_index

  ldy #2
  copyCharsInLineLoop
  lda (_line_start),Y
  sta (_secondary_line_start),Y
  iny
  cpy #39
  bmi copyCharsInLineLoop

  ldy _temp_row_index
  cpy #$ff
  bne copyAllLinesLoop

  ;copy data from buffer onto 1st row
  ldy #0
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,Y
  sta _line_start_hi

  ldy #2
  plotFirstRow
  lda _temp_row_data,Y
  sta (_line_start),Y
  iny
  cpy #38
  bne plotFirstRow

  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; wrapScreenUp: scrolls entire screen up until the screen is
; back in its original state
; Params: none
; Returns: null
; -------------------------------------------------------------------
wrapScreenUp
.(
  lda #0
  sta effect_temp
  tay
  loop
  jsr _scrollScreenUp
  ldy effect_temp
  iny
  sty effect_temp
  cpy #27
  bcc loop
  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; wrapScreenDown: scrolls entire screen down until the screen is
; back in its original state
; Params: none
; Returns: null
; -------------------------------------------------------------------
wrapScreenDown
.(
  lda #0
  sta effect_temp
  tay
  loop
  jsr _scrollScreenDown
  ldy effect_temp
  iny
  sty effect_temp
  cpy #27
  bcc loop
  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Perform a short delay to slow down an effect
; -------------------------------------------------------------------
_effectDelay
.(    
    ; a small delay
    ldy #100
    loop
    dey
    nop
    cpy #00
    Bne loop
    rts    
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


shake
.(
  jsr _scrollScreenLeft
  jsr _scrollScreenUp
  jsr _scrollScreenRight  
  jsr _scrollScreenDown

  jsr _scrollScreenUp
  jsr _scrollScreenLeft
  jsr _scrollScreenDown  
  jsr _scrollScreenRight
  rts
.)