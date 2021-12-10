// (c) gfoidl, all rights reserved

using Microsoft.Extensions.Logging;

namespace Calculator.Core;

/// <summary>
/// Simple calculator
/// </summary>
public partial class Calculator
{
    private readonly ILogger? _logger;
    //-------------------------------------------------------------------------
    public Calculator(ILogger<Calculator>? logger = null) => _logger = logger;
    //-------------------------------------------------------------------------
    /// <summary>
    /// Addition
    /// </summary>
    /// <param name="a">First summand</param>
    /// <param name="b">Second summand</param>
    /// <returns>Sum of <paramref name="a"/> and <paramref name="b"/>.</returns>
    public int Add(int a, int b)
    {
        if (_logger is not null)
        {
            Log.LogAdd(_logger, a, b);
        }

        return a + b;
    }
    //-------------------------------------------------------------------------
    /// <summary>
    /// Subtraction
    /// </summary>
    /// <param name="a">Minuend</param>
    /// <param name="b">Subtrahend</param>
    /// <returns>Difference of <paramref name="a"/> and <paramref name="b"/>.</returns>
    public int Subtract(int a, int b)
    {
        if (_logger is not null)
        {
            Log.LogSubtract(_logger, a, b);
        }

        return a - b;
    }
}
