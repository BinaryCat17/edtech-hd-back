SELECT DISTINCT
    u.username,
    c.compname,
    c.levelcount,
    c.color,
    c.description
FROM
    usercomps u,
    compchecks cc,
    comps c
WHERE
    u.checkname = cc.checkname
    AND cc.compname = c.compname;