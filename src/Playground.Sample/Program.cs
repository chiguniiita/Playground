using Playground.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace Playground.Sample
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello world!!");
            Console.WriteLine(GetInformationalVersion());
            Console.ReadKey();
        }
        static string GetInformationalVersion()
        {
            return Assembly.GetExecutingAssembly().GetCustomAttribute<AssemblyInformationalVersionAttribute>().InformationalVersion;
        }
        private static string GetJsonString(object o)
        {
            return JsonConvert.SerializeObject(o);
        }
    }
}
