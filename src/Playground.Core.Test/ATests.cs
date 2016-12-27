using Microsoft.VisualStudio.TestTools.UnitTesting;
using Playground.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Playground.Core.Tests
{
    [TestClass()]
    public class ATests
    {
        [TestMethod()]
        public void GetNameTest()
        {
            var exp = "aaa";
            var act = A.GetName();

            Assert.AreSame(exp, act);
        }
    }
}