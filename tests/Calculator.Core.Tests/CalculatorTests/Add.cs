// (c) gfoidl, all rights reserved

using System.IO;
using NUnit.Framework;

#if NETCOREAPP
using System.Text.Json;
#endif

// Here I'll keep the block scoped namespace to keep a bit of history ;-)
namespace Calculator.Core.Tests.CalculatorTests
{
    [TestFixture]
    public class Add
    {
        [Test]
        public void Summands_given___correct_result()
        {
            TestContext.WriteLine("Sending some messages to Progess for demo purposes. This message is written by TestContext.WriteLine.");

            // Arrange
            TestContext.Progress.WriteLine("Arrange");
            int first  = 3;
            int second = 4;

            Calculator sut = new();

            // Act:
            TestContext.Progress.WriteLine("Act");
            int actual = sut.Add(first, second);

            // Assert:
            TestContext.Progress.WriteLine("Assert");
            Assert.AreEqual(7, actual);
        }
        //---------------------------------------------------------------------
        [Test]
        public void Summand_and_0___summand_returned()
        {
            int first  = 42;
            int second = 0;

            Calculator sut = new();

            int actual = sut.Add(first, second);

            Assert.AreEqual(first, actual);
        }
        //---------------------------------------------------------------------
#if NETCOREAPP
        [Test]
        public void Summands_given___output_written_to_json_and_attached()
        {
            int first  = 42;
            int second = 666;

            var sut = new Calculator();

            int actual = sut.Add(first, second);

            using (var fs         = File.OpenWrite("res.json"))
            using (var jsonWriter = new Utf8JsonWriter(fs, new JsonWriterOptions { Indented = true }))
            {
                jsonWriter.WriteStartObject();
                jsonWriter.WriteNumber("first", first);
                jsonWriter.WriteNumber("second", second);
                jsonWriter.WriteNumber("result", actual);
                jsonWriter.WriteEndObject();
            }

            TestContext.AddTestAttachment("res.json");
            TestContext.AddTestAttachment("res.json", "Attachment with description");
        }
#endif
    }
}
