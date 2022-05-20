mkdir /var/lib/pgadmin
mkdir /var/log/pgadmin
chown $USER /var/lib/pgadmin
chown $USER /var/log/pgadmin
python3 -m venv pgadmin4
source pgadmin4/bin/activate
pip install pgadmin4
pgadmin4