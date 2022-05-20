UPDATE users SET 
    username = $2
    password = $3
    fullname = $4
    email = $5
    team_role = $6
    about = $7
    team = $8
WHERE username = $1