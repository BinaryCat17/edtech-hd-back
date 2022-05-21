# systemctl start postgresql12.service
psql -U postgres -d store -a -f initdb.sql