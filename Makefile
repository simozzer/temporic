#NO_LIB=1

SRC=main.c vars.s setScreenMetrics.s lookup.s vert_split_screen_effects.s horz_split_screen_effects.s
BIN=scrolling
OBJ=$(SRC:.c=.o)

include ../../rules.mk

all: $(SRC) $(BIN)




