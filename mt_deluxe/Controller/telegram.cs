using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using TeleSharp.TL;
using TLSharp;
using TLSharp.Core;
using System.IO;

namespace telegram
{
    public class Program
    {
        const int apiId = 2343335;
        const string apiHash = "93d03722480e26fa0a5c797c042fb3b0";
        const string number = "12067177907";
        const int groupId = -294528642;
        static void Main(string[] args)
        {
            var client = new TelegramClient(apiId, apiHash);
            client.ConnectAsync();

            var hash = client.SendCodeRequestAsync(number);
            var code = "23799"; // you can change code in debugger
            var user = client.MakeAuthAsync(number, apiHash, code);
            client.SendMessageAsync(new TLInputPeerUser() { UserId = groupId }, "TEST");
            Console.ReadKey();
        }
    }
}