# Use make -B due to the fact that .inc changes are not getting tracked
# in dependencies.
# Not yet sure how to utilize rgbasm -M (https://rednex.github.io/rgbds/rgbasm.1.html#M)
# to resolve.

ASM = rgbasm
LINK = rgblink
FIX = rgbfix

ROM_NAME = game-of-life
SRC_DIR     = src
INC_DIR     = include
BUILD_DIR   = build
SOURCES     = $(foreach dir,$(SRC_DIR),$(wildcard $(dir)/*.asm))
FIX_FLAGS   = -v -p0
OUTPUT      = $(BUILD_DIR)/$(ROM_NAME)

INCDIR = include
OBJECTS = $(SOURCES:src/%.asm=build/%.obj)

.PHONY: all clean

MODE = 0			# default to game mode
test1 : MODE = 1	# test mode 1
test2 : MODE = 2	# test mode 2
test3 : MODE = 3	# test mode 3

all test1 test2 test3: create_build_dir $(OUTPUT)

create_build_dir:
	mkdir -p $(BUILD_DIR)

$(OUTPUT): $(OBJECTS)
	$(LINK) -m $@.map -o $@.gb -n $@.sym $(OBJECTS)
	$(FIX) $(FIX_FLAGS) $@.gb

build/%.obj: src/%.asm
	$(ASM) -D mode=$(MODE) -i$(INCDIR)/ -o$@ $<

clean:
	rm -rf $(BUILD_DIR)/*