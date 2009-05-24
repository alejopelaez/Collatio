BIN_DIR=../bin
TEST_DIR=../test
RTF_LIB_DIR=rtf

all: $(BIN_DIR)/datasets/
	g++ md5.c main.cc -o $(BIN_DIR)/collatio
clean:
	rm -f $(BIN_DIR)/collatio
	rm -rf $(BIN_DIR)/datasets
	cd $(RTF_LIB_DIR) && make clean

$(BIN_DIR)/datasets/: $(BIN_DIR)/
	mkdir -p $(BIN_DIR)/datasets

$(BIN_DIR)/:
	mkdir $(BIN_DIR)
test-all:
	g++ $(TEST_DIR)/ParagraphTest.cc -lgtest -o $(TEST_DIR)/ParagraphTest 
	$(TEST_DIR)/ParagraphTest
	rm $(TEST_DIR)/ParagraphTest

rtfreader:
	cd $(RTF_LIB_DIR); make