NASM = nasm
LD = ld

SRC = src/main.asm
BUILD = build

NAME = tarefa3

TARGET = $(BUILD)/$(NAME)
OBJECT = $(BUILD)/$(NAME).o
FLAT = $(BUILD)/$(NAME).asm

.PHONY: all clean run

all: $(TARGET)

$(BUILD):
	mkdir -p $(BUILD)

$(FLAT): $(SRC) $(shell find src -type f \( -name '*.asm' -o -name '*.inc' \)) | $(BUILD)
	$(NASM) -E -Isrc/ $(SRC) -o $(FLAT)

$(OBJECT): $(FLAT)
	$(NASM) -f elf64 $(FLAT) -o $(OBJECT)

$(TARGET): $(OBJECT)
	$(LD) $(OBJECT) -o $(TARGET)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -rf $(BUILD)
