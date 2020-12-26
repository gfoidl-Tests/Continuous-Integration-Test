// (c) gfoidl, all rights reserved

using System;
using System.Collections.Generic;
using System.Diagnostics;
using Microsoft.Extensions.Logging;
using Moq;
using NUnit.Framework;

[DebuggerNonUserCode]
public abstract class AbstractLogger<T> : ILogger<T>
{
#if NETCOREAPP
    public List<LogMessage> LogMessages { get; } = new List<LogMessage>();
#endif
    //---------------------------------------------------------------------
    public IDisposable BeginScope<TState>(TState state) => Mock.Of<IDisposable>();
    public bool IsEnabled(LogLevel logLevel) => true;
    //---------------------------------------------------------------------
    public void Log<TState>(LogLevel logLevel, EventId eventId, TState state, Exception exception, Func<TState, Exception, string> formatter)
    {
        string msg = formatter(state, exception);
        this.Log(logLevel, exception, msg);

#if NETCOREAPP
        this.LogMessages.Add(new LogMessage(logLevel, msg, exception));
#endif

        TestContext.WriteLine(msg);
    }
    //---------------------------------------------------------------------
    public abstract void Log(LogLevel logLevel, Exception ex, string msg);
    //---------------------------------------------------------------------
#if NETCOREAPP
    public record LogMessage(LogLevel LogLevel, string Message, Exception Exception = null);
#endif
}
