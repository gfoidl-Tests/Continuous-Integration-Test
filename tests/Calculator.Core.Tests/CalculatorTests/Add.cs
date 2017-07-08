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
			int a = 3;
			int b = 4;

			var sut = new Calculator();

			// Act:
			int actual = sut.Add(a, b);

			// Assert:
			Assert.AreEqual(7, actual);
		}
	}
}