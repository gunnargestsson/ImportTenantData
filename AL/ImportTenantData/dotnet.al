dotnet
{
    assembly("System.Data")
    {
        Version = "4.0.0.0";

        type("System.Data.SqlClient.SqlConnection"; "O4N_SqlConnection") { }
        type("System.Data.SqlClient.SqlCommand"; "O4N_SqlCommand") { }
        type("System.Data.SqlClient.SqlDataReader"; "O4N_SqlDataReader") { }
        type("System.Data.SqlClient.SqlInfoMessageEventArgs"; "O4N_SqlInfoMessageEventArgs") { }
        type("System.Data.StateChangeEventArgs"; "O4N_StateChangeEventArgs") { }
        type("System.Data.SqlTypes.SqlDecimal"; "O4N_SqlDecimal") { }
    }
    assembly("System")
    {
        type("System.IO.Compression.DeflateStream"; "O4N_DeflateStream") { }
        type("System.IO.Compression.CompressionMode"; "O4N_CompressionMode") { }
    }
    assembly("mscorlib")
    {
        type("System.IO.StreamReader"; "O4N_StreamReader") { }
        type("System.IO.MemoryStream"; "O4N_MemoryStream") { }

    }
}
