// (c) gfoidl, all rights reserved

using Microsoft.Extensions.Logging;

namespace Calculator.Core;

public partial class Calculator
{
    // To use this as extensions method, it must be declared in a top-level class.
    private static partial class Log
    {
        [LoggerMessage(1, LogLevel.Debug, "Add called with {a} and {b}")]
        public static partial void LogAdd(ILogger logger, int a, int b);
        //-------------------------------------------------------------------------
        [LoggerMessage(2, LogLevel.Debug, "Subtract called with {a} and {b}")]
        public static partial void LogSubtract(ILogger logger, int a, int b);
    }
}
