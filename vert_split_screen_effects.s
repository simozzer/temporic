

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
  ldy screen_area_top
  lda ScreenLineLookupLo,y
  sta _line_start_lo
  lda ScreenLineLookupHi,y
  sta _line_start_hi
  ldy effect_index
  lda (_line_start),y
  sta temp_effect_char

  ; move all characters up one position
  ldy screen_area_top
  iny
  sty _temp_row_index
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
  cmp screen_area_top_plus_height
  bne __loopy

  ; put the character which was on the first row onto the last
  ldy screen_area_max_row_index
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
  ldy screen_area_max_row_index
  lda ScreenLineLookupLo,y
  sta _line_start_lo
  lda ScreenLineLookupHi,y
  sta _line_start_hi
  ldy effect_index
  lda (_line_start),y
  sta temp_effect_char

  ; move all characters down one position
  ldy screen_area_max_row_index
  dey
  sty _temp_row_index
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
  cmp screen_area_top
  bpl _loop_y

  ; put the character which was on the last row onto the first
  ldy screen_area_top
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
  lda screen_area_top
  sta inner_effect_temp
  loop
  jsr _scrollColumnUp
  jsr _effectDelay
  inc inner_effect_temp
  lda inner_effect_temp
  cmp screen_area_top_plus_height
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
  lda screen_area_top
  sta inner_effect_temp
  loop
  jsr _scrollColumnDown
  jsr _effectDelay
  inc inner_effect_temp
  lda inner_effect_temp
  cmp screen_area_top_plus_height
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
  lda screen_area_left
  sta effect_index
  loop
  jsr _wrapColumnUp
  inc effect_index

  lda effect_index
  cmp screen_area_max_col_index
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
  lda screen_area_left
  sta effect_index
  loop
  jsr _wrapColumnDown
  inc effect_index

  lda effect_index
  cmp screen_area_max_col_index
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
  lda #0
  sta _source_row_index
  jsr __copyRowToBuffer

  ; copy rest of the rows up
  ldy #1
  copyLinesLoop
  sty _source_row_index
  dey
  sty _dest_row_index
  tya
  pha
  jsr __copyRow
  pla
  tay
  iny
  iny
  cpy screen_area_height
  bne copyLinesLoop
  
  ;copy data from buffer onto last row
  ldy screen_area_height
  dey
  sty _dest_row_index
  jsr __copyBufferToRow

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
  ldy screen_area_top_plus_height
  dey
  sty _source_row_index
  jsr __copyRowToBuffer

  ; copy rest of the rows down
  ldy screen_area_height
  dey
  sty _temp_row_index

  copyAllLinesLoop
  ldy _temp_row_index
  sty _source_row_index
  iny
  sty _dest_row_index
  tay
  pha
  
  
  jsr __copyRow
  pla
  tay
  
  dec _temp_row_index
  ldy _temp_row_index
  cpy #1
  bne copyAllLinesLoop


  ;copy data from buffer onto 1st row
  ldy #0
  sta _dest_row_index
  jsr __copyBufferToRow


  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; wrapScreenUp: scrolls entire screen up until the screen is
; back in its original state
; Params: none
; Returns: null
; -------------------------------------------------------------------
_wrapScreenUp
.(
  lda screen_area_top
  sta effect_temp
  tay
  loop
  jsr _scrollScreenUp
  ldy effect_temp
  iny
  sty effect_temp
  cpy screen_area_top_plus_height
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
_wrapScreenDown
.(
  lda screen_area_top
  sta effect_temp
  tay
  loop
  jsr _scrollScreenDown
  ldy effect_temp
  iny
  sty effect_temp
  cpy screen_area_top_plus_height
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

_source_row_index .byt 1
_dest_row_index .byt 1

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Copy contents of 1 row to another, within the context of the current 
; screen metrics
; params:
;   _source_row_index: the index of the source row, within the current
; screen rows
;   _dest_row_index: the index of the target row, within the current 
; screen rows
; returns : null
; -------------------------------------------------------------------
__copyRow
.(
  ; lookup the start adddress of the source row
  lda _source_row_index
  clc
  adc screen_area_top
  tay 
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,Y
  sta _line_start_hi

  ;lookup the start address of the target row
  lda _dest_row_index
  clc
  adc screen_area_top
  tay 
  lda ScreenLineLookupLo,Y
  sta _secondary_line_start_lo
  lda ScreenLineLookupHi,Y
  sta _secondary_line_start_hi

  ldy screen_area_left
  ldx #0
  copyCharsLoop
  lda (_line_start),Y
  sta (_secondary_line_start),Y
  iny
  inx
  cpx screen_area_width
  bne copyCharsLoop

  rts
.)


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; __copyRowToBuffer:
; Copy contents of 1 row to offscreen buffer, within the context of the current 
; screen metrics
; params:
;   _source_row_index: the index of the source row, within the current
; screen rows
; returns : null
; -------------------------------------------------------------------
__copyRowToBuffer
.(
  lda _source_row_index
  clc
  adc screen_area_top
  tay 
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,Y
  sta _line_start_hi

  ldy screen_area_left
  ldx #0
  copyLoop
  lda (_line_start),Y
  sta _temp_row_data,y
  inx
  iny
  cpx screen_area_width
  bne copyLoop
  rts
.)


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; __copyBufferToRow:
; Copy contents of offscreen buffer to 1 row, within the context of the current 
; screen metrics
; params:
;   _dest_row_index: the index of the destination row, within the current
; screen rows
; returns : null
; -------------------------------------------------------------------
__copyBufferToRow
.(
  lda _dest_row_index
  clc
  adc screen_area_top
  tay
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,Y
  sta _line_start_hi

  ldy screen_area_left
  ldx #0
  copyLoop
  lda _temp_row_data,Y
  sta (_line_start),Y
  iny
  inx
  cpx screen_area_width
  bne copyLoop
  rts
.)