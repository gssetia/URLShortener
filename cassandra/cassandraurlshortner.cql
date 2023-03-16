CREATE KEYSPACE IF NOT EXISTS cassandraurlshortner
WITH replication = {'class': 'SimpleStrategy', 'replication_factor' : 2};
USE cassandraurlshortner;
CREATE TABLE IF NOT EXISTS urls (short text, long text, PRIMARY KEY (short));
