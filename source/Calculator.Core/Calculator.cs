namespace Calculator.Core
{
    /// <summary>
    /// Simple calculator
    /// </summary>
    public class Calculator
    {
        /// <summary>
        /// Addition
        /// </summary>
        /// <param name="a">First summand</param>
        /// <param name="b">Second summand</param>
        /// <returns>Sum of <paramref name="a"/> and <paramref name="b"/>.</returns>
        public int Add(int a, int b)
        {
            return a + b;
        }
        //---------------------------------------------------------------------
        /// <summary>
        /// Subtraction
        /// </summary>
        /// <param name="a">Minuend</param>
        /// <param name="b">Subtrahend</param>
        /// <returns>Difference of <paramref name="a"/> and <paramref name="b"/>.</returns>
        public int Subtract(int a, int b) => a - b;
    }
}
