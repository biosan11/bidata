{
    "job": {
        "content": [
            {

            "reader": {
                    "name": "mysqlreader",
                    "parameter": {
                        "username": "root",
                        "password": "biosan",
                        "column": ["*"],
                        "splitPk": "auto_id",
                        "connection": [
                            {
                                "table": [
                                    "ar_detail"
                                ],
                                "jdbcUrl": [
                                    "jdbc:mysql://172.16.0.181:3306/jsh?useUnicode=true&characterEncoding=utf8"
                                ]
                            }
                        ]
                    }
                },
                "writer": {
                    "name": "mysqlwriter",
                    "parameter": {
                        "writeMode": "insert",
                        "username": "root",
                        "password": "JSW!0103aa",
                        "column": [
                           "*"
                        ],
                        "session": [
                            "set session sql_mode='ANSI'"
                        ],
                        "preSql": [
                            "truncate ar_detail"
                        ],
                        "connection": [
                            {
                                "jdbcUrl": "jdbc:mysql://127.0.0.1:3306/my_db?useUnicode=true&characterEncoding=utf8",
                                "table": [
                                    "ar_detail"
                                ]
                            }
                        ]
                    }
                    
                }
            }
        ],
        "setting": {
            "speed": {
                "channel": 5
            }
        }
    }
}