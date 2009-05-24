#include <gtest/gtest.h>
#include "../src/Paragraph.h"

class ParagraphTest : public testing::Test {
protected:

    ParagraphTest() {
        // Setup                               
    }

    virtual ~ParagraphTest() {
        // Clean up
    }

    virtual void SetUp() {
        // Before each test
    }

    virtual void TearDown() {
        // after each test
    }

};


TEST(ParagraphTest, Example) {
    string a = "Hello";
    string b = "World";

    EXPECT_NE(a,b);
}

TEST(ParagraphTest, GetNextPhrase) {
    vector<string> expected;
    string text = "This. Is. A... Test..With.....Spaces. And ... Dots";
    Paragraph p(text);

    expected.push_back("This");
    expected.push_back("Is");
    expected.push_back("A");
    expected.push_back("Test");
    expected.push_back("With");
    expected.push_back("Spaces");
    expected.push_back("And");
    expected.push_back("Dots");

    ASSERT_EQ(expected.size(), p.NumberOfPhrases());

    for (int i = 0; i < p.NumberOfPhrases(); i++) {
        EXPECT_EQ(expected[i], p.GetNextPhrase());
    }
}

int main(int argc, char **argv) {
    testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
