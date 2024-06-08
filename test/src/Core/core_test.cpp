#include <project/Core/core.hpp>

#include <gtest/gtest.h>

TEST(CoreAddTest, CheckValues)
{
    core c(3);
    c.add(1);
    ASSERT_EQ(c.getData(), 4);
    EXPECT_TRUE(true);
}
int main(int argc, char **argv)
{
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}