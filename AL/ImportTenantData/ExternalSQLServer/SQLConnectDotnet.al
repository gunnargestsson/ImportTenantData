dotnet
{
    assembly("System.Data")
    {
        type("System.Data.SqlClient.SqlConnection"; "SqlConnection") { }
        type("System.Data.SqlClient.SqlCommand"; "SqlCommand") { }
        type("System.Data.SqlClient.SqlDataReader"; "SqlDataReader") { }
        type("System.Data.SqlClient.SqlInfoMessageEventArgs"; "SqlInfoMessageEventArgs") { }
        type("System.Data.StateChangeEventArgs"; "StateChangeEventArgs") { }
    }
}
