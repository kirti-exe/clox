CC     = gcc
WARN   = -std=c11 -Wall -Wextra -Wno-unused-parameter
INC    = -Iinclude

SRCDIR = src
OBJDIR = build

ifeq ($(OS),Windows_NT)
  EXE = .exe
  ifdef MSYSTEM
    RM    = rm -rf
    MKDIR = mkdir -p $(OBJDIR)
  else
    RM    = rmdir /S /Q
    MKDIR = if not exist $(OBJDIR) mkdir $(OBJDIR)
  endif
else
  EXE   =
  RM    = rm -rf
  MKDIR = mkdir -p $(OBJDIR)
endif

TARGET = clox$(EXE)
SRC    = $(wildcard $(SRCDIR)/*.c)
OBJ    = $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(SRC))
DEP    = $(OBJ:.o=.d)

CFLAGS = $(WARN) $(INC) -O2

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $(OBJ)

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@$(MKDIR)
	$(CC) $(CFLAGS) -MMD -MP -c $< -o $@

-include $(DEP)

debug:
	-$(MAKE) clean
	$(MAKE) CFLAGS="$(WARN) $(INC) -g -O0 -DDEBUG_PRINT_CODE -DDEBUG_TRACE_EXECUTION -DDEBUG_STRESS_GC -DDEBUG_LOG_GC" $(TARGET)

test: $(TARGET)
	@for f in tests/*.lox; do echo "== $$f"; ./$(TARGET) $$f || exit 1; done

clean:
	-$(RM) $(OBJDIR) $(TARGET)

.PHONY: all debug test clean