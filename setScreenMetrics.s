
#DEFINE FULL_SCREEN_WIDTH 38
#DEFINE FULL_SCREEN_HEIGHT 27
#DEFINE FULLSCREEN_TEXT_FIRST_COLUMN 2
#DEFINE FULLSCREEN_TEXT_FIRST_ROW 0

#DEFINE TOP_SCREEN_WIDTH 38
#DEFINE TOP_SCREEN_HEIGHT 13
#DEFINE TOPSCREEN_TEXT_FIRST_COLUMN 2
#DEFINE TOPSCREEN_TEXT_FIRST_ROW 0

#DEFINE BOTTOM_SCREEN_WIDTH 38
#DEFINE BOTTOM_SCREEN_HEIGHT 13
#DEFINE BOTTOMSCREEN_TEXT_FIRST_COLUMN 2
#DEFINE BOTTOMSCREEN_TEXT_FIRST_ROW 14

#DEFINE LEFT_SCREEN_WIDTH 18
#DEFINE LEFT_SCREEN_HEIGHT 27
#DEFINE LEFTSCREEN_TEXT_FIRST_COLUMN 2
#DEFINE LEFTSCREEN_TEXT_FIRST_ROW 0

#DEFINE RIGHT_SCREEN_WIDTH 18
#DEFINE RIGHT_SCREEN_HEIGHT 27
#DEFINE RIGHTSCREEN_TEXT_FIRST_COLUMN 22
#DEFINE RIGHTSCREEN_TEXT_FIRST_ROW 0


#DEFINE FULLSCREEN_TEXT_LAST_COLUMN 39

_setMetricsForFullScreen
.(
    lda #FULL_SCREEN_WIDTH
    sta screen_area_width
    lda #FULL_SCREEN_HEIGHT
    sta screen_area_height
    lda _player1_x
    sta player_x
    lda _player1_y
    sta player_y
    lda #FULLSCREEN_TEXT_FIRST_COLUMN
    sta screen_area_left
    lda #FULLSCREEN_TEXT_FIRST_ROW
    sta screen_area_top
    jsr _setOtherScreenMetrics
    rts
.)

_setMetricsForLeftScreen
.(
    lda #LEFT_SCREEN_WIDTH
    sta screen_area_width
    lda #LEFT_SCREEN_HEIGHT
    sta screen_area_height
    lda _player1_x
    sta player_x
    lda _player1_y
    sta player_y
    lda #LEFTSCREEN_TEXT_FIRST_COLUMN
    sta screen_area_left
    lda #LEFTSCREEN_TEXT_FIRST_ROW
    sta screen_area_top
    jsr _setOtherScreenMetrics
    rts
.)

_setMetricsForRightScreen
.(
    lda #RIGHT_SCREEN_WIDTH
    sta screen_area_width
    lda #RIGHT_SCREEN_HEIGHT
    sta screen_area_height
    lda _player2_x
    sta player_x
    lda _player2_y
    sta player_y
    lda #RIGHTSCREEN_TEXT_FIRST_COLUMN
    sta screen_area_left
    lda #RIGHTSCREEN_TEXT_FIRST_ROW
    sta screen_area_top
    jsr _setOtherScreenMetrics
    rts
.)


_setMetricsForTopScreen
.(
    lda #TOP_SCREEN_WIDTH
    sta screen_area_width
    lda #TOP_SCREEN_HEIGHT
    sta screen_area_height
    lda _player1_x
    sta player_x
    lda _player1_y
    sta player_y
    lda #TOPSCREEN_TEXT_FIRST_COLUMN
    sta screen_area_left
    lda #TOPSCREEN_TEXT_FIRST_ROW
    sta screen_area_top
    jsr _setOtherScreenMetrics
    rts
.)

_setMetricsForBottomScreen
.(
    lda #BOTTOM_SCREEN_WIDTH
    sta screen_area_width
    lda #BOTTOM_SCREEN_HEIGHT
    sta screen_area_height
    lda _player2_x
    sta player_x
    lda _player2_y
    sta player_y
    lda #BOTTOMSCREEN_TEXT_FIRST_COLUMN
    sta screen_area_left
    lda #BOTTOMSCREEN_TEXT_FIRST_ROW
    sta screen_area_top
    jsr _setOtherScreenMetrics
    rts
.)

_setOtherScreenMetrics
.(
    lda screen_area_left
    clc
    adc screen_area_width
    sta screen_area_left_plus_width
    sec
    sbc #01
    sta screen_area_max_col_index

    ldy screen_area_left
    dey
    sty screen_area_min_col_index

    lda screen_area_top
    clc
    adc screen_area_height
    sta screen_area_top_plus_height
    sec
    sbc #01
    sta screen_area_max_row_index

    ldy screen_area_top
    dey
    sty screen_area_min_row_index 

    rts
.)
