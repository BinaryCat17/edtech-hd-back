SELECT
    cc.compname,
    cc.checkname,
    uc.username,
    CASE WHEN ucc.username = uc.username THEN ucc.votes ELSE 0 END AS votes,
    cc.maxvotes,
    cc.level,
    cc.description
FROM
    (
        usercomps uc
        JOIN compchecks cc ON uc.compname = cc.compname
    )
    LEFT OUTER JOIN usercompchecks ucc ON ucc.username = uc.username
    AND ucc.compname = uc.compname
    AND ucc.checkname = cc.checkname
    ORDER BY cc.level