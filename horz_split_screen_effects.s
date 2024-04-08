/*
1.) This unit also requires lookup.s, or you could include the following:

;////////////////////////////////////
; Lookup tables for lo and hi bytes 
; of each line in text mode
;////////////////////////////////////
:ScreenLineLookupLo 
  .byt $A8,$D0,$F8,$20,$48,$70,$98,$C0,$E8,$10                        
  .byt $38,$60,$88,$B0,$D8,$00,$28,$50,$78,$A0                            
  .byt $C8,$F0,$18,$40,$68,$90,$B8  

:ScreenLineLookupHi 
  .byt $BB,$BB,$BB,$BC,$BC,$BC,$BC,$BC,$BC,$BD                        
  .byt $BD,$BD,$BD,$BD,$BD,$BE,$BE,$BE,$BE,$BE                            
  .byt $BE,$BE,$BF,$BF,$BF,$BF,$BF


2.) Also need zero page variables declaring e.g.

_line_start
_line_start_lo .dsb 1
_line_start_hi .dsb 1
_secondary_line_start
_secondary_line_start_lo .dsb 1
_secondary_line_start_hi .dsb 1

*/

effect_index .dsb 1,0 ;used as a parameter to determine which row/column to process
temp_effect_char .dsb 1,0 ;used for temporary storage for wrapping characters when scrolling
_temp_effect_char .dsb 1,0;used for temporary storage in inner loop for wrapping characters when scrolling 
effect_temp .dsb 1,0 ; used to keep count of the number of iterations for repeated operations
inner_effect_temp .dsb 1,0 ; used to keep count of the number of iterations for repeated operations
_temp_row_index .dsb 1,0; used to store row index on routines when scrolling columns up or down
_temp_row_data .dsb 40,0; used to store the contents of an entire row of character data


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _scrollRowLeft: scrolls an individual row 1 position left. The
; character in the leftmost position will appear on the right
; Params: 
;   effect_index: The index of the row to be scrolled
; Returns: null
; -------------------------------------------------------------------
_max_col_index .byt 1
_scrollRowLeft
.(
  ldy effect_index
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,Y
  sta _line_start_hi

  ; copy char from left column into temp_effect_char
  ldy screen_area_left
  lda (_line_start),y
  sta temp_effect_char
  
  ; move all chars left
  ldy screen_area_left
  iny
  loop
  lda (_line_start),Y
  dey
  sta (_line_start),Y
  iny
  iny
  cpy screen_area_left_plus_width
  bne loop

  ; copy the character from the 1st column into the last column
  ldy screen_area_max_col_index
  lda temp_effect_char
  sta (_line_start),y

  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _wrapRowLeft: scrolls an individual row left until the line is returned
; to its original state
; Params: 
;   effect_index: The index of the row to be scrolled
; Returns: null
; -------------------------------------------------------------------
_wrapRowLeft
.(
  lda screen_area_left_plus_width
  sec
  sbc #02
  sta _wrap_col_last_index

  lda screen_area_left
  sec
  sbc #02
  sta inner_effect_temp
  loop
  jsr _scrollRowLeft
  jsr _effectDelay
  inc inner_effect_temp
  lda inner_effect_temp
  cmp _wrap_col_last_index
  bne loop
  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _wrapRowRight: scrolls an individual row right until the line is returned
; to its original state
; Params: 
;   effect_index: The index of the row to be scrolled
; Returns: null
; -------------------------------------------------------------------
_wrap_col_last_index .byt 1
_wrapRowRight
.(
  lda screen_area_left_plus_width
  sec
  sbc #02
  sta _wrap_col_last_index

  lda screen_area_left
  sec
  sbc #02
  sta inner_effect_temp
  loop
  jsr _scrollRowRight
  jsr _effectDelay
  inc inner_effect_temp
  lda inner_effect_temp
  cmp _wrap_col_last_index
  bne loop
  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _scrollRowRight: scrolls an individual row 1 position right. The
; character in the rightmost position will appear on the left
; Params: 
;   effect_index: The index of the row to be scrolled
; Returns: null
; -------------------------------------------------------------------
_min_col_index .byt 1
_scrollRowRight
.(
  ldy effect_index
  lda ScreenLineLookupLo,Y
  sta _line_start_lo
  lda ScreenLineLookupHi,Y
  sta _line_start_hi
  
  ; copy char from right column into temp_effect_char
  ldy screen_area_max_col_index

  lda (_line_start),y
  sta temp_effect_char
  
  ; move all chars right
  dey
  loop
  lda (_line_start),Y
  iny
  sta (_line_start),Y
  dey
  dey
  cpy screen_area_min_col_index
  bne loop

  ; copy the character from the last column into the 1st column
  ldy screen_area_left
  lda temp_effect_char
  sta (_line_start),y

  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<





; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _scrollScreenLeft: scrolls entire screen 1 position left. The
; characters in the leftmost position will appear on the right
; Params: none
; Returns: null
; -------------------------------------------------------------------
_scroll_left_max_index .byt 1
_scrollScreenLeft
.(
  ldx screen_area_top
  loop
  stx effect_index
  jsr _scrollRowLeft
  inx
  cpx screen_area_top_plus_height
  bne loop
  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; _scrollScreenRight: scrolls entire screen 1 position right. The
; characters in the rightmost position will appear on the left
; Params: none
; Returns: null
; -------------------------------------------------------------------
_scroll_right_max_index .byt 1
_scrollScreenRight
.(
  ldx screen_area_top
  loop
  stx effect_index
  jsr _scrollRowRight
  inx
  cpx screen_area_top_plus_height
  bne loop
  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; wrapScreenLeft: scrolls entire screen left until the screen is
; back in its original state
; Params: none
; Returns: null
; -------------------------------------------------------------------
_wrapScreenLeft
.(
  lda #0
  sta effect_temp
  tay
  loop
  jsr _scrollScreenLeft
  ldy effect_temp
  iny
  sty effect_temp
  cpy screen_area_width
  bcc loop
  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<



; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; wrapScreenRight: scrolls entire screen right until the screen is
; back in its original state
; Params: none
; Returns: null
; -------------------------------------------------------------------
_wrapScreenRight
.(
  lda #0
  sta effect_temp
  tay
  loop
  jsr _scrollScreenRight
  ldy effect_temp
  iny
  sty effect_temp
  cpy screen_area_width
  bcc loop
  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; shredScreenLeft: scrolls each row left, in turn, until the screen
; is returned to its original state
; original state
; Returns: null
; -------------------------------------------------------------------
_shredScreenLeft
.(
  lda screen_area_top
  sta effect_index
  loop
  jsr _wrapRowLeft
  inc effect_index

  lda effect_index
  cmp screen_area_top_plus_height
  bne loop

  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; shredScreenRight: scrolls each row right, in turn, until the screen
; is returned to its original state
; original state
; Returns: null
; -------------------------------------------------------------------
_shredScreenRight
.(
  lda screen_area_top
  sta effect_index
  loop
  jsr _wrapRowRight
  inc effect_index

  lda effect_index
  cmp screen_area_top_plus_height
  bne loop

  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




; >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; shredScreenHorizontal: scrolls alternate rows in different 
; directions, and continues until the screen is back in its
; original state
; Returns: null
; -------------------------------------------------------------------
_max_row_index .byt 1
_shredScreenHorizontal
.(
  ; calculate max row index
  lda screen_area_top_plus_height
  clc
  adc #01
  sta _max_row_index

  ;calculate number of horizonal iterations
  lda #00
  sta effect_temp

  screenLoop
  lda screen_area_top
  sta effect_index

  tay
  lineLoop
  jsr _scrollRowLeft
  inc effect_index
  lda effect_index
  cmp screen_area_top_plus_height
  beq linesDone
  jsr _scrollRowRight
  inc effect_index

  jsr _effectDelay

  lda effect_index
  cmp _max_row_index
  bne lineLoop

  linesDone
  inc effect_temp
  lda effect_temp
  cmp screen_area_width
  bne screenLoop

  rts
.)
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<




