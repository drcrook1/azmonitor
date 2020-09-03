output "sql_conn_str" {
   value = "Server=tcp:${azurerm_sql_server.sqlserver.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_sql_database.sqldb.name};Persist Security Info=False;User ID=${var.sqluser};Password=${var.sqlpassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" 
}