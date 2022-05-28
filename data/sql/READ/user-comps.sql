SELECT
    DISTINCT c.compname,
    c.description,
    c.levelcount,
    c.color
FROM
    usercomps u,
    compchecks cc,
    comps c
WHERE
    u.username = $1
    AND u.checkname = cc.checkname
    AND cc.compname = c.compname;