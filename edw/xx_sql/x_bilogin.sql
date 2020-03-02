TRUNCATE TABLE edw.x_bilogin;
INSERT INTO edw.x_bilogin
SELECT NULL AS `id`,
a.`User Name` AS `User_Name`,
a.`User Principal Name` AS `User_Principal_Name`,
a.`IP Address` AS `IP_Address`,
a.`Device Info` AS `Device_Info`,
a.`Country` AS `Country`,
date_add(concat(substring(`Event Time (UTC)`,7,4),'-',LEFT(`Event Time (UTC)`,2),'-',substring(`Event Time (UTC)`,4,2),' ',RIGHT(`Event Time (UTC)`,8)), interval 8 hour) as Event_Time
FROM
  ufdata.x_bilogin AS a 
WHERE
  a.`Login Status` = 'Success' 
GROUP BY
  a.`User Name`,
  Event_Time
ORDER BY
  Event_Time DESC;