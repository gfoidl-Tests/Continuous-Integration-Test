using NUnit.Framework;

namespace Calculator.Core.Tests.CalculatorTests
{
    [TestFixture]
    public class Add
    {
        [Test]
        public void Summands_given___correct_result()
        {
            // Arrange
            int first  = 3;
            int second = 4;

            var sut = new Calculator();

            // Act:
            int actual = sut.Add(first, second);

            // Assert:
            Assert.AreEqual(7, actual);
        }
    }
}