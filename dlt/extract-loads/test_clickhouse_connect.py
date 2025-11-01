import clickhouse_connect

client = clickhouse_connect.get_client(
    host="54.87.106.52",
    port=8123,
    username="ftw_grp3",
    password="Squirtle#007_FTW",
    database="raw_grp3"
)

print("✅ Connected successfully!")

# Query and print databases properly
rows = client.query("SHOW DATABASES").result_rows
print("Databases:", [r[0] for r in rows])
