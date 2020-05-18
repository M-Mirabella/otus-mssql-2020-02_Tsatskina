using System.Data.SqlTypes;
using System.Data.SqlClient;
using Microsoft.SqlServer.Server;

namespace CLR_for_SQL_Server
{
    public class Math
    {
        [SqlFunction]
        public static SqlDouble Factorial(SqlDouble x)
        {
            SqlDouble y = 1.0;
            while (x > 1.0)
            {
                y *= x;
                x -= 1;
            }
            return y;
        }
    }
}
