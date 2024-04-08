
    .zero

    *= $50

_zp_start_

_line_start
_line_start_lo .dsb 1
_line_start_hi .dsb 1
_secondary_line_start
_secondary_line_start_lo .dsb 1
_secondary_line_start_hi .dsb 1

screen_area_width .dsb 1
screen_area_height .dsb 1
_player1_x .dsb 1
player_x .dsb 1
_player1_y .dsb 1
player_y .dsb 1
screen_area_left .dsb 1
screen_area_top .dsb 1
_player2_x .dsb 1
_player2_y .dsb 1
screen_area_max_col_index .dsb 1
screen_area_max_row_index .dsb 1
screen_area_left_plus_width .dsb 1
screen_area_top_plus_height .dsb 1
screen_area_min_row_index .dsb 1
screen_area_min_col_index .dsb 1

_zp_end

.text