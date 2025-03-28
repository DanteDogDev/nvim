CC = g++
CFLAGS = -Wall -Wextra -std=c++11
TARGET = main.exe
SRC = $(wildcard *.cpp) $(wildcard */*.cpp)
OBJS = $(SRC:.cpp=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(TARGET)

%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	del /f $(OBJS) $(TARGET)
