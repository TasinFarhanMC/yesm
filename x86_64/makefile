ASM      = as
ASM_FLAGS = -g
SRC_DIR  = src
BUILD_DIR = build
LINK     = ld
LINK_FLAGS =

SRCS     := $(shell find $(SRC_DIR) -name '*.s')
OBJS     := $(patsubst $(SRC_DIR)/%.s,$(BUILD_DIR)/%.o,$(SRCS))

all: $(BUILD_DIR)/yesm

$(BUILD_DIR)/%:
	mkdir -p $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	@mkdir -p $(dir $@)
	$(ASM) $(ASM_FLAGS) -o $@ $<

$(BUILD_DIR)/yesm: $(OBJS)
	$(LINK) $(LINK_FLAGS) -o $@ $^

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all clean
