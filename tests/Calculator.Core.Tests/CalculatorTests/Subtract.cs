// (c) gfoidl, all rights reserved

using NUnit.Framework;

namespace Calculator.Core.Tests.CalculatorTests
{
    [TestFixture]
    public class Subtract
    {
        [Test]
        public void Args_given___correct_result()
        {
            // Arrange
            int first  = 4;
            int second = 3;

            var sut = new Calculator();

            // Act:
            int actual = sut.Subtract(first, second);

            // Assert:
            Assert.AreEqual(1, actual);
        }
        //---------------------------------------------------------------------
        [Test, Ignore("for demo purposes")]
        public void Foo()
        {
            Assert.AreEqual(1, 1);
        }
    }
}
