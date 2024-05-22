# include build_config.mk

#Makefile debugging. usage: make print-VARIABLE
print-%	: ; @echo $* = $($*)


OBJ_DIR = $(BUILD_DIR)/obj
OUTPUT_DIR = $(BUILD_DIR)/out


C_SOURCES :=  $(shell find $(SRC_DIR) -type f -regex ".*\.c")
ASM_SOURCES := $(shell find $(SRC_DIR)/ -type f -regex ".*\.S")
HEADER_FILES := $(shell find $(HEADER_DIRS) -type f -regex ".*\.h")


EXTERNAL_HEADERS_DST = $(addprefix $(OUTPUT_DIR)/,$(notdir $(EXTERNAL_HEADERS_SRC)))
# Must be immediately set otherwise the makefile rules will not parse it correctly
RECOMPILATION_DEPENDENCIES := Makefile $(HEADER_FILES) $(EXTERNAL_HEADERS_DST)


OBJECTS = $(addprefix $(OBJ_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
OBJECTS += $(addprefix $(OBJ_DIR)/,$(notdir $(ASM_SOURCES:.S=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
vpath %.S $(sort $(dir $(ASM_SOURCES)))
vpath %.h $(sort $(dir $(EXTERNAL_HEADERS_SRC)))

# Obtain CPU count
CPU_COUNT = `grep -c ^processor /proc/cpuinfo`

# all must be above the $(OUTPUT_DIR)/$(OUTPUT_FILE) rule, otherwise it will be ignored
.PHONY: all
all: $(OUTPUT_DIR)/$(OUTPUT_FILE) $(EXTERNAL_HEADERS_DST) tests

.PHONY: no-tests
no-tests: $(OUTPUT_DIR)/$(OUTPUT_FILE) $(EXTERNAL_HEADERS_DST)

.PHONY: clean
ifndef BUILD_DIR
$(error If BUILD_DIR is not set `/` will be deleted)
endif

# Check whether the BUILD_DIR variable is set at all
ifeq ($(strip $(BUILD_DIR)),)
$(error BUILD_DIR not set)
endif

clean: 
	@rm -fr $(BUILD_DIR)/*

.PHONY: tests
tests: $(OUTPUT_DIR)/$(OUTPUT_FILE)
	@if [ -d "$(TESTS_SRC_DIR)" ]; then "${MAKE}" -j$(CPU_COUNT) -C $(TESTS_SRC_DIR) TOOLCHAIN=$(TOOLCHAIN) ; fi



$(OUTPUT_DIR)/%.h: %.h
	@mkdir -p $(@D)
	@cp -av $< $@

$(OBJ_DIR)/%.o: %.S $(RECOMPILATION_DEPENDENCIES)
	@mkdir -p $(@D)
	@$(CC) -c $(CFLAGS) $< -o $@


$(OBJ_DIR)/%.o: %.c $(RECOMPILATION_DEPENDENCIES)
	@mkdir -p $(@D)
	$(CC) -c $(CFLAGS) $< -o $@

$(OUTPUT_DIR)/$(OUTPUT_FILE): $(OBJECTS)
	@mkdir -p $(@D)
	@$(FINAL_STAGE)
