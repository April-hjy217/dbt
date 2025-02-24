import pyarrow.parquet as pq

file_path = "yellow_tripdata_2024-01.parquet"

parquet_file = pq.ParquetFile(file_path)

schema = parquet_file.schema
print("Parquet schema:")
print(schema)
