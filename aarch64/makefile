ASM := as
LD  := ld

ifeq ($(CROSS),1)
    ASM := aarch64-linux-gnu-as
    LD  := aarch64-linux-gnu-ld
endif

SRC_DIR   := src
BUILD_DIR := build

MODE ?= release

ifeq ($(MODE),debug)
    ASM_FLAGS := -g
    LD_FLAGS  :=
else
    ASM_FLAGS :=
    LD_FLAGS  := -s --gc-sections --build-id=none
endif

SRCS := $(wildcard $(SRC_DIR)/*.s)

YESM_SRC := $(SRC_DIR)/yesm.s
YESM_BIN := $(BUILD_DIR)/yesm

OTHER_SRCS := $(filter-out $(YESM_SRC),$(SRCS))
OTHER_BINS := $(patsubst $(SRC_DIR)/%.s,$(BUILD_DIR)/yesm_%,$(OTHER_SRCS))

yesm: $(YESM_BIN)
extras: $(OTHER_BINS)

$(BUILD_DIR):
	mkdir -p $@

$(YESM_BIN): $(YESM_SRC) | $(BUILD_DIR)
	$(ASM) $(ASM_FLAGS) -o $@.o $<
	$(LD)  $(LD_FLAGS)  -o $@   $@.o

$(BUILD_DIR)/yesm_%: $(SRC_DIR)/%.s | $(BUILD_DIR)
	$(ASM) $(ASM_FLAGS) -o $@.o $<
	$(LD)  $(LD_FLAGS)  -o $@   $@.o

%: $(BUILD_DIR)/yesm_%
	@:

debug:
	$(MAKE) MODE=debug

release:
	$(MAKE) MODE=release

clean:
	rm -rf $(BUILD_DIR)

all: yesm extras

.PHONY: all clean debug release extras yesm
